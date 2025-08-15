# 运维与操作指南（Operations）

## 部署（容器化）

- 统一使用 Docker + Docker Compose
- 参考 deploy/docker-compose.yml，按需启用 zap、openvas、defectdojo、grafana、数据库等服务

## 自动化扫描流程

1. 定时任务触发：Jenkins/Airflow 周期性计划
2. 资产同步：Amass + Gospider 更新资产清单
3. 分层扫描：
   - 新增资产：全量（ZAP + OpenVAS + Dependency-Check）
   - 存量资产：增量（变更页面/组件）
4. 结果处理：DefectDojo 自动导入、去重、风险报告
5. 通知与修复：企业微信/邮件消息通知，高风险实时推送

## 关键功能与建议

- 误报处理：引入 Burp Suite 人工验证，并维护误报规则库
- 自定义策略：核心业务深度策略；内部系统启用认证扫描（Cookie/Token）
- 权限管理：RBAC，按角色划分权限（开发/安全/管理层）
- WAF（可选）：对高危项做临时缓解，采用“监控→灰度→阻断”的发布流程，并记录命中/误报/延迟指标；参考 https://github.com/0xInfection/Awesome-WAF

## 维护与更新

- 定期更新扫描工具与规则
- 避开业务高峰时段，控制并发与负载