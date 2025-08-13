# 基础设施与环境准备 (Infrastructure)

默认采用 Docker Compose 进行部署，面向中小型企业开箱即用；大型企业可作为选型评估参考。

## 你可以这样开始

- 一键启动（推荐）：
  ```bash
  cd 04-shared-resources/infrastructure/docker-compose/minimal
  bash deploy.sh
  ```
  访问入口：
  - DefectDojo: http://localhost/dojo/
  - Grafana: http://localhost/grafana/
  - ZAP API: http://localhost/zap/

- 复用现有环境（可选）：
  - 在 02-web-security-platform 的 compose 中，将数据库/Redis 指向企业现有服务
  - 复用企业网关（Nginx/Kong/Ingress）进行统一入口管理

## 目录结构
```
04-shared-resources/infrastructure/
├── docker-compose/
│   └── minimal/
│       ├── docker-compose.yml
│       ├── nginx.conf
│       ├── init.sql
│       └── deploy.sh
└── docs/
    └── requirements.md
```

## 环境要求（最小化）
- 操作系统：macOS/Linux/Windows
- 容器：Docker 20.10+、Docker Compose v2
- 资源：4 核 CPU、8GB 内存、100GB 磁盘（推荐 8C16G）

## 安全提示
- 当前配置用于演示/评估场景，生产需替换默认口令、启用 TLS、限制暴露端口、最小化权限
- 建议将数据卷定期备份并纳入企业级监控/告警

## 面向大型企业
- 本方案可用于快速选型评估；若需高可用与企业级集成，可在此基础上迁移至 Kubernetes 并接入 SSO/监控/审计。