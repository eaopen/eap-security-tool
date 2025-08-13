# 内部开发安全流水线

基于 Jenkins + SonarQube 的 DevSecOps 安全流水线，提供代码质量分析、安全扫描和持续集成能力。

## 🚀 功能特性

- **静态代码扫描 (SAST)**: SonarQube 代码质量与安全分析
- **依赖漏洞扫描 (SCA)**: OWASP Dependency Check 组件安全检测  
- **CI/CD 安全集成**: Jenkins 流水线自动化安全检查
- **质量门禁**: 基于安全规则的自动化质量管控
- **统一访问入口**: Nginx 反向代理提供统一访问体验

## 📁 目录结构
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