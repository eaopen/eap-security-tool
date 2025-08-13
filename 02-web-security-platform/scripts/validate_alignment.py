#!/usr/bin/env python3
"""
扫描器结果对齐校验脚本
验证解析器输出是否符合统一数据模型

使用方式：
  cd 02-web-security-platform
  python3 scripts/validate_alignment.py

脚本仅依赖 Python 标准库。
"""

import json
import os
from typing import Dict, List, Any

# 可根据需要扩展更多解析器

def validate_vulnerability_schema(vuln: Dict[str, Any]) -> bool:
    """校验漏洞对象是否符合 data-model.md 定义的 schema

    Args:
        vuln: 漏洞对象字典

    Returns:
        bool: 校验通过返回 True
    """
    required_fields = [
        'vulnerability_id', 'title', 'severity', 'status',
        'scanner_type', 'asset_id', 'created_at'
    ]

    # 必需字段检查
    for field in required_fields:
        if field not in vuln:
            print(f"缺少必需字段: {field}")
            return False

    # 枚举检查
    valid_severities = ['critical', 'high', 'medium', 'low', 'info']
    if vuln['severity'] not in valid_severities:
        print(f"无效的严重程度: {vuln['severity']}")
        return False

    valid_statuses = ['open', 'in_progress', 'resolved', 'false_positive', 'accepted']
    if vuln['status'] not in valid_statuses:
        print(f"无效的状态: {vuln['status']}")
        return False

    return True


def map_zap_severity(risk_desc: str) -> str:
    """将 ZAP 风险描述映射到统一严重程度枚举"""
    if 'High' in risk_desc:
        return 'high'
    if 'Medium' in risk_desc:
        return 'medium'
    if 'Low' in risk_desc:
        return 'low'
    return 'info'


def test_zap_parser(sample_file: str) -> List[Dict[str, Any]]:
    """使用最小样例测试 ZAP 解析逻辑

    Args:
        sample_file: zap-sample.json 文件路径

    Returns:
        List[Dict[str, Any]]: 解析出的漏洞对象列表
    """
    with open(sample_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    vulnerabilities: List[Dict[str, Any]] = []
    for site in data.get('site', []):
        for alert in site.get('alerts', []):
            vuln = {
                'vulnerability_id': f"zap_{abs(hash(alert.get('uri', '') + alert.get('param', '')))}",
                'title': alert.get('alert') or alert.get('name') or 'ZAP Alert',
                'severity': map_zap_severity(alert.get('riskdesc', '')),
                'status': 'open',
                'scanner_type': 'zap',
                'asset_id': f"web_{abs(hash(site.get('host', '')))}",
                'created_at': '2025-01-10T08:00:00Z'
            }
            vulnerabilities.append(vuln)
    return vulnerabilities


def main() -> None:
    """主入口：读取样例并执行校验"""
    # 默认样例路径（与 README 建议保持一致）
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    testdata_dir = os.path.join(base_dir, 'testdata')
    zap_sample = os.path.join(testdata_dir, 'zap-sample.json')

    if not os.path.exists(zap_sample):
        print(f"未找到样例文件: {zap_sample}\n请参考 docs/integrations.md 附录C 保存样例文件后重试。")
        return

    zap_vulns = test_zap_parser(zap_sample)
    any_failed = False
    for vuln in zap_vulns:
        if validate_vulnerability_schema(vuln):
            print(f"✓ ZAP 漏洞校验通过: {vuln['title']}")
        else:
            print(f"✗ ZAP 漏洞校验失败: {vuln['title']}")
            any_failed = True

    if any_failed:
        raise SystemExit(1)


if __name__ == '__main__':
    main()