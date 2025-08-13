# 内部开发安全流水线 (Security Pipeline)

> 定位：演示与评估优先，默认采用 Docker Compose 一键启动；中小企业开箱即用，亦可复用企业现有 Jenkins/GitLab/SonarQube 环境。

本模块基于 GitLab、Jenkins 与 SonarQube，提供面向 Java 后端项目的容器化 DevSecOps 安全流水线。

## 功能特性
- 代码静态安全分析（SAST，基于 SonarQube）
- 依赖漏洞扫描（SCA，Dependency-Check/Trivy）
- CI/CD 安全集成（GitLab + Jenkins）
- 基于 Docker Compose 的容器化部署

## 目录结构
```
01-security-pipeline/
├── deploy/
│   ├── docker-compose.yml
│   └── configs/
├── ci/
│   ├── gitlab-ci-example.yml
│   └── jenkinsfile.example
└── docs/
    ├── architecture.md
    └── operations.md
```

## 基础设施准备

- 默认推荐：使用 <mcfolder name="minimal" path="04-shared-resources/infrastructure/docker-compose/minimal"></mcfolder> 一键启动基础组件（PostgreSQL/Redis/Nginx/Grafana/ZAP/DefectDojo），完成选型评估后再进行个性化集成。
- 若您的企业已有 Jenkins/GitLab CI/SonarQube 等：建议复用现有环境，参考 <mcfile name="README.md" path="04-shared-resources/infrastructure/README.md"></mcfile> 的“复用现有环境”。
- 需要模块独立部署：可使用本模块的 deploy/ 目录独立启动。

## 快速开始
1. 准备环境：Docker 20.10+、Docker Compose 2.0+、JDK 8+/11+
2. 启动服务：进入 deploy 目录，执行 docker compose up -d
3. 配置项目：在 Jenkins 中导入示例 Jenkinsfile，在 GitLab 中添加示例 CI 配置
4. 校验 SAST/SCA：触发一次构建，确认 SonarQube 与依赖扫描结果回传

## 使用建议
- 在构建前执行依赖缓存以加速 SCA
- 将质量门禁 (Quality Gate) 接入流水线阻断高危漏洞合并
- 针对不同分支设置差异化扫描策略（主分支全量、特性分支增量）

## 相关文档
- docs/architecture.md：架构与组件说明
- docs/operations.md：日常运维与故障排查