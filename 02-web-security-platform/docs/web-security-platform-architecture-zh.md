# 企业级 Web 网站安全评估系统

本方案基于开源组件构建“资产发现 → 漏洞扫描 → 风险管理 → 修复闭环”的一体化平台，兼顾自动化、可扩展与可运营性。本文为概览，细节请参考延伸阅读。

## 一、分层架构（概览）
- 资产发现层：Amass、Gospider、Nmap 等形成资产清单（域名、IP、端口、入口 URL、技术栈）
- 扫描引擎层：
  - Web：OWASP ZAP
  - 网络：OpenVAS
  - 依赖：OWASP Dependency-Check
  - 配置：Lynis
  - 泄露：Gitleaks
- 数据存储层：PostgreSQL（结构化漏洞）、Elasticsearch（日志/原始请求）
- 分析与管理层：DefectDojo（导入、去重、评级、生命周期）
- 展示与协作层：Grafana 仪表盘、Jira 工单、企业微信/邮件通知

## 二、核心组件与选型（摘要）
- ZAP：覆盖 OWASP Top 10；支持上下文与认证扫描
- OpenVAS：主机/网络层漏洞；可模板化扫描策略
- Dependency-Check：三方依赖漏洞；适合集成 CI
- Lynis：系统基线与加固建议
- Gitleaks：敏感信息泄露
- DefectDojo：统一管理与导入器生态，支撑闭环
- Grafana：指标可视化与趋势分析

## 三、部署与自动化（建议）
- 容器化：Docker/Compose 编排 ZAP、OpenVAS、DefectDojo、Grafana 等组件
- 计划执行：Jenkins/Airflow 定时/事件触发全量与增量扫描
- 资源控制：并发/限速/黑白名单/时间窗口，避免对生产造成影响

## 四、关键功能增强（要点）
- 误报治理：Burp 手动校验 + 误报规则库，周期性回收与评估
- 自定义策略：核心业务加深扫描；内网系统启用认证扫描
- 权限与审计：RBAC、留痕与合规模板（PCI/GDPR/等保）

## 五、运维与成本（提示）
- 成本：以服务器资源为主；组件支持水平扩展
- 维护：定期更新 ZAP POC、OpenVAS NVT；调整策略降低噪声

## 延伸阅读
- integrations.md：工具联动与接口对接
- playbooks.md：作业剧本与操作指引
- architecture.md：架构设计（模块视图/组件清单）
- operations.md：运维与操作指南（部署/故障排查）