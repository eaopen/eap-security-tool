# 统一数据模型（Data Model）

本文档定义 Web 安全评估平台中资产、漏洞、扫描任务等核心实体的标准化数据模型，用于支撑不同工具间的数据流转、存储归一化、API 接口设计以及仪表盘可视化。

## 1. 资产模型（Asset Model）

### 1.1 基础资产实体
```json
{
  "asset_id": "string",           // 资产唯一标识符
  "asset_type": "web|host|service|repository", // 资产类型
  "name": "string",               // 资产名称
  "description": "string",        // 资产描述
  "business_unit": "string",      // 所属业务单元
  "owner": "string",              // 资产负责人
  "criticality": "critical|high|medium|low", // 业务重要性
  "environment": "production|staging|development", // 环境类型
  "tags": ["string"],             // 标签列表
  "created_at": "datetime",       // 创建时间
  "updated_at": "datetime",       // 最后更新时间
  "status": "active|inactive|retired" // 资产状态
}
```

### 1.2 Web 资产扩展模型
```json
{
  "domain": "string",             // 主域名
  "subdomains": ["string"],       // 子域名列表
  "urls": ["string"],             // 入口 URL 列表
  "technologies": [               // 技术栈
    {
      "name": "string",           // 技术名称（如 "Apache", "PHP"）
      "version": "string",        // 版本号
      "category": "web_server|framework|cms|database"
    }
  ],
  "ports": [                      // 开放端口
    {
      "port": "integer",
      "protocol": "tcp|udp",
      "service": "string",        // 服务名称
      "version": "string"
    }
  ],
  "ssl_info": {                   // SSL/TLS 信息
    "enabled": "boolean",
    "certificate_expiry": "datetime",
    "cipher_suites": ["string"],
    "vulnerabilities": ["string"]
  }
}
```

### 1.3 主机资产扩展模型
```json
{
  "ip_address": "string",         // IP 地址
  "hostname": "string",           // 主机名
  "operating_system": {
    "name": "string",             // 操作系统名称
    "version": "string",          // 版本
    "architecture": "string"     // 架构（x86_64, arm64 等）
  },
  "network_segment": "string",    // 网络段
  "location": {
    "datacenter": "string",       // 数据中心
    "region": "string",           // 地理区域
    "cloud_provider": "string"    // 云服务商
  }
}
```

## 2. 漏洞模型（Vulnerability Model）

### 2.1 核心漏洞实体
```json
{
  "vulnerability_id": "string",   // 漏洞唯一标识符
  "title": "string",              // 漏洞标题
  "description": "string",        // 漏洞描述
  "severity": "critical|high|medium|low|info", // 严重程度
  "confidence": "confirmed|firm|tentative", // 置信度
  "status": "open|in_progress|resolved|false_positive|accepted", // 状态
  "asset_id": "string",           // 关联资产ID
  "scanner_type": "zap|openvas|nuclei|dependency_check|lynis|gitleaks", // 扫描器类型
  "scan_id": "string",            // 扫描任务ID
  "first_found": "datetime",      // 首次发现时间
  "last_seen": "datetime",        // 最后发现时间
  "resolution_date": "datetime",  // 解决时间
  "assignee": "string",           // 分配给
  "reporter": "string",           // 报告人
  "verified": "boolean",          // 是否已验证
  "public_exploit": "boolean",    // 是否存在公开利用
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 2.2 漏洞分类与评级
```json
{
  "category": {
    "cwe_id": "string",           // CWE 分类ID
    "cwe_name": "string",         // CWE 分类名称
    "owasp_category": "string",   // OWASP Top 10 分类
    "vulnerability_type": "string" // 漏洞类型（SQL注入、XSS等）
  },
  "cvss": {
    "version": "3.1|3.0|2.0",    // CVSS 版本
    "base_score": "float",        // 基础分数
    "temporal_score": "float",    // 时间分数
    "environmental_score": "float", // 环境分数
    "vector": "string",           // 评分向量
    "impact": {
      "confidentiality": "none|low|high",
      "integrity": "none|low|high",
      "availability": "none|low|high"
    },
    "exploitability": {
      "attack_vector": "network|adjacent|local|physical",
      "attack_complexity": "low|high",
      "privileges_required": "none|low|high",
      "user_interaction": "none|required"
    }
  }
}
```

### 2.3 漏洞位置与证据
```json
{
  "location": {
    "url": "string",              // 漏洞URL
    "parameter": "string",        // 参数名称
    "method": "GET|POST|PUT|DELETE", // HTTP方法
    "file_path": "string",        // 文件路径（代码扫描）
    "line_number": "integer",     // 行号（代码扫描）
    "function_name": "string"     // 函数名（代码扫描）
  },
  "evidence": {
    "request": "string",          // 请求内容
    "response": "string",         // 响应内容
    "payload": "string",          // 攻击载荷
    "screenshot": "string",       // 截图URL
    "proof_of_concept": "string"  // 概念验证
  },
  "references": [                 // 参考资料
    {
      "type": "cve|advisory|blog|vendor",
      "url": "string",
      "title": "string"
    }
  ]
}
```

### 2.4 修复信息
```json
{
  "remediation": {
    "recommendation": "string",   // 修复建议
    "effort": "low|medium|high",  // 修复难度
    "priority": "urgent|high|medium|low", // 修复优先级
    "steps": ["string"],          // 修复步骤
    "verification": "string",     // 验证方法
    "alternative_solutions": ["string"] // 替代方案
  },
  "compliance": [                 // 合规要求
    {
      "framework": "pci_dss|gdpr|iso27001|nist|cis", // 合规框架
      "control_id": "string",     // 控制项ID
      "requirement": "string"     // 具体要求
    }
  ]
}
```

## 3. 扫描任务模型（Scan Task Model）

### 3.1 扫描任务实体
```json
{
  "scan_id": "string",            // 扫描任务唯一标识符
  "scan_name": "string",          // 扫描任务名称
  "scan_type": "discovery|vulnerability|compliance|full", // 扫描类型
  "scanner": "zap|openvas|nuclei|dependency_check|lynis|gitleaks", // 扫描器
  "target": {
    "asset_ids": ["string"],      // 目标资产ID列表
    "urls": ["string"],           // 目标URL列表
    "ip_ranges": ["string"],      // IP范围
    "exclusions": ["string"]      // 排除项
  },
  "configuration": {
    "scan_profile": "string",     // 扫描配置文件
    "authentication": {           // 认证配置
      "enabled": "boolean",
      "type": "cookie|token|basic|form",
      "credentials": "string"     // 加密存储
    },
    "scan_depth": "shallow|medium|deep", // 扫描深度
    "concurrent_limit": "integer", // 并发限制
    "rate_limit": "integer"       // 速率限制
  },
  "schedule": {
    "type": "immediate|scheduled|recurring", // 调度类型
    "start_time": "datetime",     // 开始时间
    "recurrence": "daily|weekly|monthly", // 重复频率
    "timezone": "string"          // 时区
  },
  "status": "queued|running|completed|failed|cancelled", // 任务状态
  "progress": "float",            // 进度百分比
  "created_by": "string",         // 创建者
  "created_at": "datetime",
  "started_at": "datetime",
  "completed_at": "datetime",
  "error_message": "string"       // 错误信息
}
```

### 3.2 扫描结果统计
```json
{
  "statistics": {
    "total_vulnerabilities": "integer",
    "vulnerabilities_by_severity": {
      "critical": "integer",
      "high": "integer",
      "medium": "integer",
      "low": "integer",
      "info": "integer"
    },
    "new_vulnerabilities": "integer",
    "resolved_vulnerabilities": "integer",
    "false_positives": "integer",
    "scan_coverage": {
      "urls_scanned": "integer",
      "assets_scanned": "integer",
      "requests_sent": "integer",
      "response_codes": {
        "2xx": "integer",
        "3xx": "integer",
        "4xx": "integer",
        "5xx": "integer"
      }
    },
    "performance": {
      "duration_seconds": "integer",
      "average_response_time": "float",
      "requests_per_second": "float"
    }
  }
}
```

## 4. 用户与权限模型（User & Permission Model）

### 4.1 用户实体
```json
{
  "user_id": "string",            // 用户唯一标识符
  "username": "string",           // 用户名
  "email": "string",              // 邮箱
  "full_name": "string",          // 全名
  "department": "string",         // 部门
  "role": "admin|security_analyst|developer|viewer", // 角色
  "permissions": ["string"],      // 权限列表
  "is_active": "boolean",         // 是否激活
  "last_login": "datetime",       // 最后登录时间
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 4.2 权限控制
```json
{
  "permissions": {
    "assets": {
      "view": "boolean",
      "create": "boolean",
      "edit": "boolean",
      "delete": "boolean"
    },
    "vulnerabilities": {
      "view": "boolean",
      "assign": "boolean",
      "resolve": "boolean",
      "mark_false_positive": "boolean"
    },
    "scans": {
      "view": "boolean",
      "create": "boolean",
      "start": "boolean",
      "stop": "boolean"
    },
    "reports": {
      "view": "boolean",
      "generate": "boolean",
      "export": "boolean"
    },
    "administration": {
      "user_management": "boolean",
      "system_configuration": "boolean",
      "integration_management": "boolean"
    }
  },
  "data_filters": {
    "business_units": ["string"],  // 可访问的业务单元
    "environments": ["string"],    // 可访问的环境
    "severity_levels": ["string"]  // 可访问的严重级别
  }
}
```

## 5. 数据标准化规则

### 5.1 唯一标识符生成
- asset_id: `{asset_type}_{hash(domain/ip)}_{timestamp}`
- vulnerability_id: `{scanner}_{hash(location+title)}_{scan_id}`
- scan_id: `{scanner}_{target_hash}_{timestamp}`

### 5.2 严重程度映射
```json
{
  "severity_mapping": {
    "zap": {
      "High": "high",
      "Medium": "medium",
      "Low": "low",
      "Informational": "info"
    },
    "openvas": {
      "10.0": "critical",
      "7.0-9.9": "high",
      "4.0-6.9": "medium",
      "0.1-3.9": "low",
      "0.0": "info"
    },
    "nuclei": {
      "critical": "critical",
      "high": "high",
      "medium": "medium",
      "low": "low",
      "info": "info"
    }
  }
}
```

### 5.3 去重规则
漏洞去重基于以下字段的组合哈希：
- 资产标识符
- 漏洞类型/CWE ID
- 位置信息（URL + 参数 或 文件路径 + 行号）
- 扫描器类型

## 6. API 接口标准

### 6.1 RESTful API 设计原则
- 使用标准 HTTP 方法（GET, POST, PUT, DELETE）
- 统一错误响应格式
- 支持分页、排序、过滤
- API 版本控制（/api/v1/）

### 6.2 响应格式标准
```json
{
  "success": "boolean",
  "data": "object|array",
  "message": "string",
  "error_code": "string",
  "pagination": {
    "page": "integer",
    "size": "integer",
    "total": "integer",
    "pages": "integer"
  },
  "metadata": {
    "timestamp": "datetime",
    "request_id": "string",
    "api_version": "string"
  }
}
```

## 7. 可视化数据模型

### 7.1 仪表盘指标
```json
{
  "dashboard_metrics": {
    "risk_overview": {
      "total_assets": "integer",
      "vulnerable_assets": "integer",
      "total_vulnerabilities": "integer",
      "risk_score": "float"
    },
    "trend_analysis": {
      "vulnerability_trends": [
        {
          "date": "date",
          "critical": "integer",
          "high": "integer",
          "medium": "integer",
          "low": "integer"
        }
      ],
      "resolution_rate": "float",
      "mean_time_to_resolution": "float"
    },
    "compliance_status": [
      {
        "framework": "string",
        "compliance_percentage": "float",
        "failed_controls": "integer"
      }
    ]
  }
}
```

### 7.2 报告数据结构
```json
{
  "report": {
    "metadata": {
      "report_id": "string",
      "title": "string",
      "generated_by": "string",
      "generated_at": "datetime",
      "period": {
        "start_date": "date",
        "end_date": "date"
      }
    },
    "executive_summary": {
      "risk_level": "critical|high|medium|low",
      "key_findings": ["string"],
      "recommendations": ["string"]
    },
    "detailed_findings": [
      {
        "category": "string",
        "vulnerabilities": ["vulnerability_object"],
        "statistics": "object"
      }
    ]
  }
}
```

此数据模型确保了各组件间的数据一致性，支持扩展和集成，为 Web 安全评估平台提供了坚实的数据基础。

## 8. 样例对象（Sample Objects）

以下样例基于本文定义的数据模型，字段取值与类型可直接用于接口联调与单元测试。示例为有效 JSON（不包含注释）。

### 8.1 资产样例（Web Asset）
```json
{
  "asset_id": "web_9f86d081_2025-01-01T00:00:00Z",
  "asset_type": "web",
  "name": "Example Portal",
  "description": "示例门户站点",
  "business_unit": "BU-App",
  "owner": "alice",
  "criticality": "high",
  "environment": "production",
  "tags": ["external", "customer-facing"],
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-10T08:00:00Z",
  "status": "active",
  "domain": "example.com",
  "subdomains": ["www.example.com", "api.example.com"],
  "urls": ["https://www.example.com/", "https://www.example.com/login"],
  "technologies": [
    { "name": "nginx", "version": "1.24.0", "category": "web_server" },
    { "name": "React", "version": "18.2.0", "category": "framework" }
  ],
  "ports": [
    { "port": 80, "protocol": "tcp", "service": "http", "version": "" },
    { "port": 443, "protocol": "tcp", "service": "https", "version": "" }
  ],
  "ssl_info": {
    "enabled": true,
    "certificate_expiry": "2025-12-31T23:59:59Z",
    "cipher_suites": ["TLS_AES_256_GCM_SHA384", "TLS_CHACHA20_POLY1305_SHA256"],
    "vulnerabilities": []
  }
}
```

### 8.2 漏洞样例（Vulnerability）
```json
{
  "vulnerability_id": "zap_6b1b36c0_scan-2025-01-10",
  "title": "Cross Site Scripting (Reflected)",
  "description": "用户输入未充分转义导致反射型 XSS。",
  "severity": "high",
  "confidence": "firm",
  "status": "open",
  "asset_id": "web_9f86d081_2025-01-01T00:00:00Z",
  "scanner_type": "zap",
  "scan_id": "zap_www-example-com_2025-01-10T08:00:00Z",
  "first_found": "2025-01-10T08:05:00Z",
  "last_seen": "2025-01-10T08:05:00Z",
  "resolution_date": null,
  "assignee": "bob",
  "reporter": "security-bot",
  "verified": false,
  "public_exploit": true,
  "created_at": "2025-01-10T08:06:00Z",
  "updated_at": "2025-01-10T08:06:00Z",
  "category": {
    "cwe_id": "79",
    "cwe_name": "Improper Neutralization of Input During Web Page Generation",
    "owasp_category": "A03:2021-Injection",
    "vulnerability_type": "XSS"
  },
  "cvss": {
    "version": "3.1",
    "base_score": 7.4,
    "temporal_score": 7.0,
    "environmental_score": 6.8,
    "vector": "AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N",
    "impact": { "confidentiality": "low", "integrity": "low", "availability": "none" },
    "exploitability": { "attack_vector": "network", "attack_complexity": "low", "privileges_required": "none", "user_interaction": "required" }
  },
  "location": {
    "url": "https://www.example.com/search",
    "parameter": "q",
    "method": "GET",
    "file_path": "",
    "line_number": 0,
    "function_name": ""
  },
  "evidence": {
    "request": "GET /search?q=%3Cscript%3Ealert(1)%3C/script%3E HTTP/1.1",
    "response": "...<script>alert(1)</script>...",
    "payload": "<script>alert(1)</script>",
    "screenshot": "https://assets.example.com/proofs/xss-123.png",
    "proof_of_concept": "在搜索参数 q 中注入脚本，页面原样反射。"
  },
  "references": [
    { "type": "cwe", "url": "https://cwe.mitre.org/data/definitions/79.html", "title": "CWE-79" },
    { "type": "advisory", "url": "https://owasp.org/www-community/attacks/xss/", "title": "OWASP XSS" }
  ],
  "remediation": {
    "recommendation": "对输出进行 HTML 转义，并启用 CSP。",
    "effort": "medium",
    "priority": "high",
    "steps": [
      "对 q 参数进行白名单校验与编码",
      "输出统一使用模板引擎转义函数",
      "配置 CSP default-src 'self'"
    ],
    "verification": "提交包含恶意脚本的请求，页面不应执行脚本",
    "alternative_solutions": ["对输入进行严格白名单过滤"]
  },
  "compliance": [
    { "framework": "pci_dss", "control_id": "6.5", "requirement": "防止常见编码漏洞" }
  ]
}
```

### 8.3 扫描任务样例（Scan Task）
```json
{
  "scan_id": "zap_www-example-com_2025-01-10T08:00:00Z",
  "scan_name": "ZAP Full Scan - www.example.com",
  "scan_type": "vulnerability",
  "scanner": "zap",
  "target": {
    "asset_ids": ["web_9f86d081_2025-01-01T00:00:00Z"],
    "urls": ["https://www.example.com/"],
    "ip_ranges": [],
    "exclusions": ["https://www.example.com/admin/*"]
  },
  "configuration": {
    "scan_profile": "full-scan",
    "authentication": { "enabled": true, "type": "cookie", "credentials": "<encrypted>" },
    "scan_depth": "deep",
    "concurrent_limit": 5,
    "rate_limit": 10
  },
  "schedule": {
    "type": "immediate",
    "start_time": "2025-01-10T08:00:00Z",
    "recurrence": "weekly",
    "timezone": "UTC"
  },
  "status": "running",
  "progress": 42.5,
  "created_by": "security-bot",
  "created_at": "2025-01-10T07:59:00Z",
  "started_at": "2025-01-10T08:00:00Z",
  "completed_at": null,
  "error_message": null,
  "statistics": {
    "total_vulnerabilities": 15,
    "vulnerabilities_by_severity": { "critical": 1, "high": 3, "medium": 6, "low": 4, "info": 1 },
    "new_vulnerabilities": 5,
    "resolved_vulnerabilities": 2,
    "false_positives": 1,
    "scan_coverage": {
      "urls_scanned": 320,
      "assets_scanned": 1,
      "requests_sent": 12500,
      "response_codes": { "2xx": 11500, "3xx": 600, "4xx": 360, "5xx": 40 }
    },
    "performance": { "duration_seconds": 5400, "average_response_time": 210.5, "requests_per_second": 2.3 }
  }
}
```