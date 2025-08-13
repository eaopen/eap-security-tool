# 工具联动与接口对接（Integrations）

本章说明 02 模块中各安全组件之间如何联动、通过哪些 API/CLI 对接、以及整条数据流从“资产 → 扫描 → 归一化 → 管理平台/通知”的落地形态。

## 1. 整体联动拓扑与数据流
- 资产来源：Amass/Gospider/Nmap → 形成资产清单（域名、IP、端口、入口 URL、技术栈）。
- 任务编排：Jenkins/Airflow 依据计划与资产变化生成扫描任务（全量/增量/认证）。
- 扫描执行：
  - ZAP：Web 应用安全（主动/被动扫描）
  - OpenVAS：网络与主机层面漏洞
  - Dependency-Check：三方依赖组件漏洞
  - Lynis：系统配置基线与合规
  - Gitleaks：敏感信息泄露
- 结果汇聚与归一化：将不同工具的结果转换为统一数据模型（见 data-model.md），落库并导入 DefectDojo。
- 协作与可视化：DefectDojo 管理漏洞生命周期，Grafana 展示指标，企业微信/邮件/Jira 推进修复闭环。

## 2. 接口对接要点
### 2.1 OWASP ZAP（REST API）
- 常用能力：
  - 启动主动扫描：指定目标 URL、上下文与认证信息
  - 查询任务进度与结果
  - 导出报告（JSON/HTML/XML）
- 建议：
  - 使用“上下文 + 会话”机制实现认证扫描（Cookie/Token 注入）
  - 控制并发与爬取深度，避免对业务造成压力

### 2.2 OpenVAS（GMP/gvm-tools）
- 常用能力：
  - 创建/启动扫描任务，使用合适的扫描配置（Full and fast）
  - 查询任务状态与导出结果（XML/CSV）
- 建议：
  - 定期同步 NVT 插件库
  - 对内网/生产网络分时段扫描，避免峰值时段

### 2.3 Dependency-Check（CLI/JSON 输出）
- 扫描构件与依赖，输出 JSON 报告
- 建议与流水线结合（CI 阶段执行），将结果并入统一数据模型

### 2.4 Lynis（CLI/报告解析）
- 系统基线扫描，输出报告文本
- 通过解析关键分数/建议项归一化为配置风险记录

### 2.5 Gitleaks（CLI/JSON 输出）
- 检测代码库/页面中的密钥、令牌、密码等敏感信息
- 将匹配条目（规则、位置、片段）映射为“敏感信息泄露”类漏洞

### 2.6 DefectDojo（REST API/导入器）
- 功能：导入多工具结果、漏洞聚合去重、工作流与度量
- 建议：
  - 使用“产品/Engagement/Test”结构管理不同资产与周期
  - 保持导入源（scanner type、版本、时间）的可追溯性

## 3. 任务编排与幂等控制
- Jenkins（示例流程）：
  1) 拉取资产清单 → 2) 生成扫描矩阵（新/存量/认证） → 3) 并发执行各扫描器 → 4) 统一解析/归一化 → 5) 导入 DefectDojo → 6) 指标入库与通知
- Airflow：按 DAG 将资产更新、扫描、解析、导入、通知拆解为任务节点；为易失败节点设置重试与超时
- 幂等性：
  - 扫描任务使用唯一任务 ID（资产+时间窗口+扫描器），避免重复导入
  - 结果处理使用指纹去重（见 data-model.md）

## 4. 认证扫描与安全控制
- 认证方式：Cookie、Bearer Token、SSO 回放（OIDC）
- ZAP 上下文：限制爬取域与路径，设置登录/登出指示器
- 安全控制：限速、并发上限、黑白名单、时间窗口（避开峰值）

## 5. 失败恢复与告警
- 失败重试：对网络不稳定/扫描器拥塞设置指数退避
- 部分成功：允许单工具失败不阻断全流程，汇总阶段统一上报状态
- 告警：
  - 平台异常（扫描器不可用）
  - 任务异常（超时/配额）
  - 高危漏洞阈值触发（直达负责人/Jira）

---

## 附录A：字段映射示例（Scanner → Data Model）

说明：以下映射以 docs/data-model.md 中的统一数据模型为准，严重程度映射参见“5.2 严重程度映射”，ID 生成参见“5.1 唯一标识符生成”，去重规则参见“5.3 去重规则”。

### A.1 OWASP ZAP（JSON 输出）
- 输入关键字段（示例）：
  - alert（标题）、risk（High/Medium/Low/Informational）、confidence、url、param、method、evidence、cweid、pluginId、reference、solution
- 映射：
  - title ← alert
  - severity ← risk（通过映射表）
  - confidence ← confidence
  - location.url ← url
  - location.parameter ← param
  - location.method ← method
  - category.cwe_id ← cweid
  - remediation.recommendation ← solution
  - references[] ← reference（分号/逗号拆分）
  - metadata.plugin_id ← pluginId（可选，落在扩展字段）
- 转换示例：
```json
{
  "title": "Cross Site Scripting (Reflected)",
  "severity": "high",
  "confidence": "firm",
  "scanner_type": "zap",
  "category": { "cwe_id": "79", "vulnerability_type": "XSS" },
  "location": { "url": "https://app.example.com/search", "parameter": "q", "method": "GET" },
  "evidence": { "payload": "<script>alert(1)</script>", "request": "...", "response": "..." },
  "remediation": { "recommendation": "Properly encode output and use CSP" }
}
```

### A.2 OpenVAS（XML/CSV 输出）
- 输入关键字段：
  - host/ip、port、nvt/name、threat（score）、cve、cvss_base、solution、summary
- 映射：
  - title ← nvt.name
  - severity ← cvss_base（根据阈值映射到 critical/high/…）或 threat 等级
  - category.cve_id ← cve（可多值）
  - location.url ← "tcp://{ip}:{port}"（URL 不适用时退化为服务标识）
  - remediation.recommendation ← solution
  - evidence.request/response 通常留空或存指纹
- 转换提示：将主机与端口关联到资产（asset_id by ip+port），便于归档与趋势分析。

### A.3 Dependency-Check（JSON 输出）
- 输入关键字段：
  - dependencies[].fileName, filePath, vulnerabilities[].name(CVE), severity, cwe, cvssScore, description
- 映射：
  - title ← vulnerabilities[].name 或 description 摘要
  - severity ← severity/cvssScore（两者择优）
  - category.cwe_id ← cwe
  - location.file_path ← filePath
  - evidence.proof_of_concept ← description（节选）
  - scanner_type ← dependency_check
- 建议：把构件坐标（如 Maven GAV、npm 包名@版本）写入扩展字段，便于修复定位。

### A.4 Lynis（文本报告）
- 输入关键字段：
  - warnings/suggestions、test_id、hardening_index
- 映射：
  - title ← suggestion 或 warning 的摘要
  - severity ← 基于 test_id 重要度映射（一般为 low/medium）
  - vulnerability_type ← "System Hardening"
  - evidence ← 原始行/建议片段
  - remediation.recommendation ← 建议项

### A.5 Gitleaks（JSON 输出）
- 输入关键字段：
  - RuleID、Description、File、StartLine/EndLine、Match、Secret（可能包含明文）、Commit、Author
- 映射：
  - title ← Description
  - severity ← 根据规则/敏感级别定义（建议 high/critical）
  - category.vulnerability_type ← "Sensitive Information Exposure"
  - location.file_path ← File；location.line_number ← StartLine
  - evidence.payload ← Hash(Secret) 或 脱敏片段；避免存储明文秘钥
  - references ← 针对规则的安全基线/内控制度链接
- 安全注意：禁止长期保存原始 Secret，统一进行脱敏或哈希存储。

---

## 附录B：导入流程伪代码（示例）

```python
# 函数: 将扫描器原始结果转换为统一模型并导入
# 参数:
#   scanner: 扫描器标识（zap/openvas/dependency_check/lynis/gitleaks）
#   payload: 原始结果（JSON/XML/文本）
# 返回: 导入统计信息（计数、失败原因等）

def import_scan_results(scanner: str, payload: bytes) -> dict:
    """
    1) 解析原始结果为中间对象
    2) 标准化字段映射到 data-model（资产/漏洞/任务）
    3) 进行严重程度映射、ID 生成与去重
    4) 写入存储并导入 DefectDojo（可选）
    5) 产出统计与告警
    """
    # 解析
    findings = parse_raw(scanner, payload)

    # 标准化
    normalized = []
    for f in findings:
        v = map_to_vuln(scanner, f)  # 按附录A映射
        v["severity"] = map_severity(scanner, f)
        v["vulnerability_id"] = make_vuln_id(scanner, v)
        if not is_duplicate(v):
            normalized.append(v)

    # 存储与导入
    save_assets_and_vulns(normalized)
    if should_import_to_defectdojo():
        import_to_defectdojo(normalized)

    return {"created": len(normalized), "scanner": scanner}

---

## 附录C：最小可运行示例文件

以下为各扫描器输出的最小示例片段，可用于测试字段映射与数据解析。实际生产环境中结果会更复杂，但这些样例包含了关键字段。

### C.1 ZAP JSON 输出示例（zap-sample.json）
```json
{
  "site": [
    {
      "name": "https://www.example.com",
      "host": "www.example.com",
      "port": 443,
      "ssl": true,
      "alerts": [
        {
          "pluginid": "40012",
          "alert": "Cross Site Scripting (Reflected)",
          "name": "Cross Site Scripting (Reflected)",
          "riskdesc": "High (Medium)",
          "confidence": "Medium",
          "riskcode": "3",
          "confidencecode": "2",
          "desc": "Cross-site Scripting (XSS) is an attack technique that involves echoing attacker-supplied code into a user's browser instance.",
          "uri": "https://www.example.com/search",
          "param": "q",
          "attack": "<script>alert(1)</script>",
          "otherinfo": "",
          "solution": "Phase: Architecture and Design\\nUse a vetted library or framework that does not allow this weakness to occur or provides constructs that make this weakness easier to avoid.",
          "reference": "http://projects.webappsec.org/Cross-Site-Scripting\\nhttps://cwe.mitre.org/data/definitions/79.html",
          "cweid": "79",
          "wascid": "8",
          "sourceid": "3",
          "method": "GET",
          "evidence": "<script>alert(1)</script>",
          "instances": [
            {
              "uri": "https://www.example.com/search",
              "method": "GET",
              "param": "q",
              "attack": "<script>alert(1)</script>",
              "evidence": "<script>alert(1)</script>"
            }
          ]
        }
      ]
    }
  ]
}
```

### C.2 OpenVAS XML 输出示例（openvas-sample.xml）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<report id="12345678-1234-1234-1234-123456789012" format_id="a994b278-1f62-11e1-96ac-406186ea4fc5">
  <task id="task-12345">
    <name>Full and fast scan</name>
    <target>
      <hosts>192.168.1.100</hosts>
    </target>
  </task>
  <results>
    <result id="result-001">
      <name>Apache HTTP Server version disclosure</name>
      <host>192.168.1.100</host>
      <port>80/tcp</port>
      <nvt oid="1.3.6.1.4.1.25623.1.0.10107">
        <name>Apache HTTP Server version disclosure</name>
        <cvss_base>5.0</cvss_base>
        <family>Web Servers</family>
        <tags>cvss_base_vector=AV:N/AC:L/Au:N/C:P/I:N/A:N|summary=The remote Apache HTTP server version is disclosed|affected=Apache HTTP Server|insight=The version of the Apache HTTP server is disclosed in the Server banner|solution=Modify the HTTP server banner or use mod_security or similar to mask the version</tags>
      </nvt>
      <description>The version of the Apache HTTP server is disclosed in the Server banner.</description>
      <threat>Medium</threat>
      <severity>5.0</severity>
      <qod>
        <value>98</value>
        <type>remote_banner</type>
      </qod>
    </result>
  </results>
</report>
```

### C.3 Dependency-Check JSON 输出示例（dependency-check-sample.json）
```json
{
  "reportSchema": "1.1",
  "scanInfo": {
    "engineVersion": "8.4.0",
    "projectInfo": {
      "name": "example-app",
      "reportDate": "2025-01-10T08:00:00.000Z"
    }
  },
  "dependencies": [
    {
      "fileName": "log4j-core-2.14.1.jar",
      "filePath": "/app/lib/log4j-core-2.14.1.jar",
      "md5": "d1b2c3d4e5f6789012345678901234567890abcd",
      "sha1": "a1b2c3d4e5f6789012345678901234567890abcdef",
      "vulnerabilities": [
        {
          "source": "NVD",
          "name": "CVE-2021-44228",
          "severity": "CRITICAL",
          "cvssv2": {
            "score": 9.3,
            "accessVector": "NETWORK",
            "accessComplexity": "MEDIUM",
            "authenticationr": "NONE",
            "confidentialImpact": "COMPLETE",
            "integrityImpact": "COMPLETE",
            "availabilityImpact": "COMPLETE"
          },
          "cvssv3": {
            "baseScore": 10.0,
            "attackVector": "NETWORK",
            "attackComplexity": "LOW",
            "privilegesRequired": "NONE",
            "userInteraction": "NONE",
            "scope": "CHANGED",
            "confidentialityImpact": "HIGH",
            "integrityImpact": "HIGH",
            "availabilityImpact": "HIGH"
          },
          "cwe": "CWE-502",
          "description": "Apache Log4j2 2.0-beta9 through 2.15.0 JNDI features used in configuration, log messages, and parameters do not protect against attacker controlled LDAP and other JNDI related endpoints.",
          "references": [
            {
              "source": "NVD",
              "url": "https://nvd.nist.gov/vuln/detail/CVE-2021-44228",
              "name": "https://nvd.nist.gov/vuln/detail/CVE-2021-44228"
            }
          ]
        }
      ]
    }
  ]
}
```

### C.4 Lynis 文本输出示例（lynis-sample.txt）
```
================================================================================

  Lynis 3.0.8 Results
  
  Hardening index : 68 [############    ]
  Tests performed : 249
  Plugins enabled : 0

================================================================================

  System Tools
  ------------
  [ !! ] SSH daemon configuration                                 SSHD-7408

      Details  : SSH client alive interval not configured
      Solution : Consider hardening SSH configuration
      
  [ !! ] Kernel parameters (sysctl)                               KRNL-6000
  
      Details  : vm.swappiness set to 60, consider setting to 1-10
      Solution : Edit /etc/sysctl.conf and set vm.swappiness=1

  Suggestions (28):
  ----------------------------
  * Set a password on GRUB boot loader to prevent altering boot configuration (e.g. boot in single user mode without password) [BOOT-5122] 
  * Install package apt-listbugs to display a list of critical bugs prior to each APT installation. [PKGS-7345]
  * Consider running ARP monitoring software (arpwatch,arpon) [NETW-3032]

================================================================================
```

### C.5 Gitleaks JSON 输出示例（gitleaks-sample.json）
```json
[
  {
    "Description": "AWS Access Key",
    "StartLine": 42,
    "EndLine": 42,
    "StartColumn": 15,
    "EndColumn": 35,
    "Match": "AKIAIOSFODNN7EXAMPLE",
    "Secret": "AKIAIOSFODNN7EXAMPLE",
    "File": "src/config/aws.js",
    "SymlinkFile": "",
    "Commit": "abc123def456789012345678901234567890abcd",
    "Entropy": 3.5,
    "Author": "developer@example.com",
    "Email": "developer@example.com",
    "Date": "2025-01-10T08:00:00Z",
    "Message": "Add AWS configuration",
    "Tags": [],
    "RuleID": "aws-access-token",
    "Fingerprint": "abc123def456789012345678901234567890abcd:src/config/aws.js:aws-access-token:42"
  },
  {
    "Description": "Generic API Key",
    "StartLine": 15,
    "EndLine": 15,
    "StartColumn": 20,
    "EndColumn": 52,
    "Match": "api_key=sk_test_123456789012345678901234",
    "Secret": "sk_test_123456789012345678901234",
    "File": "config.env",
    "SymlinkFile": "",
    "Commit": "def789abc123456789012345678901234567890def",
    "Entropy": 4.2,
    "Author": "admin@example.com",
    "Email": "admin@example.com",
    "Date": "2025-01-09T16:30:00Z",
    "Message": "Update API configuration",
    "Tags": [],
    "RuleID": "generic-api-key",
    "Fingerprint": "def789abc123456789012345678901234567890def:config.env:generic-api-key:15"
  }
]
```

### C.6 使用这些示例文件

1. **下载与保存**：将上述内容分别保存为对应文件名，放在测试目录中
2. **解析测试**：编写解析脚本读取这些文件，验证字段映射逻辑
3. **对齐校验**：将解析结果与 data-model.md 中的样例对象进行比对
4. **集成测试**：在导入流程中使用这些文件作为输入，验证端到端流程

### C.7 校验脚本示例（Python）
```python
#!/usr/bin/env python3
"""
扫描器结果对齐校验脚本
验证解析器输出是否符合统一数据模型
"""

import json
import xml.etree.ElementTree as ET
from typing import Dict, List, Any

def validate_vulnerability_schema(vuln: Dict[str, Any]) -> bool:
    """
    校验漏洞对象是否符合 data-model.md 定义的 schema
    
    Args:
        vuln: 漏洞对象字典
        
    Returns:
        bool: 校验通过返回 True
    """
    required_fields = [
        'vulnerability_id', 'title', 'severity', 'status', 
        'scanner_type', 'asset_id', 'created_at'
    ]
    
    # 检查必需字段
    for field in required_fields:
        if field not in vuln:
            print(f"缺少必需字段: {field}")
            return False
    
    # 检查枚举值
    valid_severities = ['critical', 'high', 'medium', 'low', 'info']
    if vuln['severity'] not in valid_severities:
        print(f"无效的严重程度: {vuln['severity']}")
        return False
    
    valid_statuses = ['open', 'in_progress', 'resolved', 'false_positive', 'accepted']
    if vuln['status'] not in valid_statuses:
        print(f"无效的状态: {vuln['status']}")
        return False
    
    return True

def test_zap_parser(sample_file: str) -> List[Dict[str, Any]]:
    """测试 ZAP 解析器"""
    with open(sample_file, 'r') as f:
        data = json.load(f)
    
    vulnerabilities = []
    for site in data.get('site', []):
        for alert in site.get('alerts', []):
            # 这里应该调用实际的 ZAP 解析器
            vuln = {
                'vulnerability_id': f"zap_{hash(alert['uri'] + alert['param'])}",
                'title': alert['alert'],
                'severity': map_zap_severity(alert['riskdesc']),
                'status': 'open',
                'scanner_type': 'zap',
                'asset_id': f"web_{hash(site['host'])}",
                'created_at': '2025-01-10T08:00:00Z'
            }
            vulnerabilities.append(vuln)
    
    return vulnerabilities

def map_zap_severity(risk_desc: str) -> str:
    """映射 ZAP 严重程度"""
    if 'High' in risk_desc:
        return 'high'
    elif 'Medium' in risk_desc:
        return 'medium'
    elif 'Low' in risk_desc:
        return 'low'
    else:
        return 'info'

if __name__ == '__main__':
    # 测试 ZAP 解析
    zap_vulns = test_zap_parser('zap-sample.json')
    for vuln in zap_vulns:
        if validate_vulnerability_schema(vuln):
            print(f"✓ ZAP 漏洞校验通过: {vuln['title']}")
        else:
            print(f"✗ ZAP 漏洞校验失败: {vuln['title']}")
```