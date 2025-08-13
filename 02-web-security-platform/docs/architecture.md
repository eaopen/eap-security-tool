# 架构设计（Architecture）

## 分层架构

资产发现层 → 扫描引擎层 → 数据存储层 → 分析与管理层 → 展示与协作层

## 核心组件与选型

- 资产发现：Amass、Gospider、Nmap
- 扫描引擎：OWASP ZAP、OpenVAS、Dependency-Check、Lynis、Gitleaks
- 数据层：PostgreSQL（漏洞详情）、Elasticsearch（日志/原始数据）
- 管理层：DefectDojo（聚合、去重、生命周期、合规）
- 展示层：Grafana（指标可视化）、Jira（协作/工单）

## 联动作业流

- 通过脚本/服务统一调度各扫描工具的 API（ZAP REST、OpenVAS XML-RPC）
- 基于资产类型自动选择扫描策略，结果归一化后写入 DefectDojo 与 Elasticsearch
- 通过 Webhook/消息渠道推送高风险告警