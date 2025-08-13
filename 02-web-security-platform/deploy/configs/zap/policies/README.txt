# ZAP 扫描策略配置

此目录包含 OWASP ZAP 的扫描策略配置文件。

## 策略说明

### default-policy.policy
- 标准 Web 应用扫描策略
- 包含常见的 OWASP Top 10 检测规则
- 适用于大多数 Web 应用的安全评估

### quick-scan.policy  
- 快速扫描策略
- 减少扫描时间，专注高危漏洞
- 适用于开发阶段的快速安全检查

### comprehensive.policy
- 全面扫描策略  
- 包含所有可用的安全检测规则
- 适用于正式发布前的完整安全评估

## 使用方法

1. 将策略文件放置在此目录
2. 通过 ZAP API 或 UI 加载策略：