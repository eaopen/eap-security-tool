# 内部开发安全流水线

基于 Jenkins + SonarQube 的 DevSecOps 安全流水线，提供代码质量分析、安全扫描和持续集成能力。现已支持Spring Boot和Vue.js项目的安全检查。

## 🚀 功能特性

- **静态代码扫描 (SAST)**: SonarQube 代码质量与安全分析
- **依赖漏洞扫描 (SCA)**: OWASP Dependency Check 组件安全检测
- **CI/CD 安全集成**: Jenkins 流水线自动化安全检查
- **质量门禁**: 基于安全规则的自动化质量管控
- **统一访问入口**: Nginx 反向代理提供统一访问体验
- **多技术栈支持**: Spring Boot后端 + Vue.js前端安全检查

## 📁 目录结构

```
01-security-pipeline/
├── deploy/
│   ├── docker-compose.yml
│   └── configs/
├── scripts/
│   ├── spring-boot-security-check.sh    # Spring Boot安全检查
│   └── vue-security-check.sh            # Vue.js安全检查
├── templates/
│   ├── pom-security-plugins.xml         # Maven安全插件配置
│   ├── vue-security-package.json        # Vue项目安全依赖配置
│   ├── eslintrc-security.js             # ESLint安全规则
│   ├── vite-security.config.ts          # Vite安全配置
│   ├── dependency-check-suppressions.xml
│   └── spotbugs-security-include.xml
└── docs/
    ├── architecture.md
    ├── operations.md
    ├── spring-boot-usage-guide.md
    └── vue-security-guide.md             # Vue.js安全最佳实践
```


## 基础设施准备

- 默认推荐：使用 `<mcfolder name="minimal" path="04-shared-resources/infrastructure/docker-compose/minimal"></mcfolder>` 一键启动基础组件（PostgreSQL/Redis/Nginx/Grafana/ZAP/DefectDojo），完成选型评估后再进行个性化集成。
- 若您的企业已有 Jenkins/GitLab CI/SonarQube 等：建议复用现有环境，参考 `<mcfile name="README.md" path="04-shared-resources/infrastructure/README.md"></mcfile>` 的"复用现有环境"。
- 需要模块独立部署：可使用本模块的 deploy/ 目录独立启动。

## 快速开始

### 1. 环境准备

- Docker 20.10+、Docker Compose 2.0+
- JDK 8+/11+ (Spring Boot项目)
- Node.js 16+ (Vue.js项目)

### 2. 启动服务

```bash
cd deploy
docker compose up -d
```

### 3. Spring Boot项目安全检查

```bash
# 在Spring Boot项目根目录执行
bash /path/to/01-security-pipeline/scripts/spring-boot-security-check.sh
```

### 4. Vue.js项目安全检查

```bash
# 在Vue.js项目根目录执行
bash /path/to/01-security-pipeline/scripts/vue-security-check.sh
```

### 5. 配置项目

- 在 Jenkins 中导入示例 Jenkinsfile
- 在 GitLab 中添加示例 CI 配置
- 根据项目类型应用相应的安全配置模板

## 安全检查功能

### Spring Boot安全检查

- ✅ Spring Security依赖检查
- ✅ Actuator端点安全配置
- ✅ 数据库连接安全
- ✅ HTTPS配置检查
- ✅ CORS配置验证
- ✅ 日志安全配置
- ✅ 安全头配置

### Vue.js安全检查

- ✅ Vue框架版本检查
- ✅ 高危依赖包检测
- ✅ 安全开发工具检查
- ✅ 环境变量安全配置
- ✅ Vue Router安全配置
- ✅ HTTP请求安全检查
- ✅ CSP内容安全策略
- ✅ 构建配置安全
- ✅ TypeScript严格模式
- ✅ ESLint安全规则

## 使用建议

### 通用建议

- 在构建前执行依赖缓存以加速 SCA
- 将质量门禁 (Quality Gate) 接入流水线阻断高危漏洞合并
- 针对不同分支设置差异化扫描策略（主分支全量、特性分支增量）

### Spring Boot项目

- 确保生产环境启用HTTPS
- 限制Actuator端点暴露
- 使用环境变量管理敏感配置
- 配置适当的CORS策略

### Vue.js项目

- 使用最新版本的Vue.js和相关依赖
- 配置Content-Security-Policy防止XSS攻击
- 实施适当的路由守卫和权限控制
- 启用TypeScript严格模式
- 使用ESLint安全插件进行代码检查

## 相关文档

- `<mcfile name="architecture.md" path="01-security-pipeline/docs/architecture.md"></mcfile>`：架构与组件说明
- `<mcfile name="operations.md" path="01-security-pipeline/docs/operations.md"></mcfile>`：日常运维与故障排查
- `<mcfile name="spring-boot-usage-guide.md" path="01-security-pipeline/docs/spring-boot-usage-guide.md"></mcfile>`：Spring Boot使用指南
- `<mcfile name="vue-security-guide.md" path="01-security-pipeline/docs/vue-security-guide.md"></mcfile>`：Vue.js安全最佳实践
