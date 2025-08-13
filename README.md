# 企业应用安全工具平台 (EAP Security Tool)

[![Status](https://img.shields.io/badge/status-active-green.svg)](https://github.com)

专业级企业应用安全平台：DevSecOps 实战就绪 · Compose 一键部署 · 5 分钟上手评估。

**技术特色**：GitLab + Jenkins + SonarQube + ZAP + DefectDojo + Grafana 全栈集成 · 统一 PostgreSQL/Redis 存储 · Nginx 反向代理统一入口 · 开源工具企业级编排 · 支持 ARM64/x86 双架构部署。

## 项目定位与目标

- 演示与评估优先：以“快速上手—展示能力—评估选型”为核心，采用 Docker Compose 一键部署。
- 中小企业开箱即用：最少依赖、统一入口、可在单机或轻量级服务器快速落地。
- 模块化可演进：可单独启用“Web 安全评估平台”或“内部安全流水线”，并平滑迁移到企业现有环境。

## 适用人群

- 安全或研发团队：需要快速验证 DevSecOps/SAST/SCA/自动化扫描/漏洞管理的可行性与价值。
- 中小企业/业务团队：希望以最低门槛搭建基础安全能力，快速获得可用产出。
- 大型企业安全团队：将本项目作为 PoC 参考，后续结合 Kubernetes、SSO、审计与监控进行企业级落地。

## 🎯 核心系统

### 01. 内部开发安全流水线 (Security Pipeline)

**GitLab + Jenkins + SonarQube** 构建的 DevSecOps 安全检查系统

**核心能力**：

- 🔍 代码静态安全分析 (SAST)
- 📦 依赖漏洞扫描 (SCA)
- 🔄 CI/CD 安全集成
- 🐳 容器化部署与管理

### 02. Web 安全评估平台 (Web Security Platform)

基于开源工具的企业级 Web 网站安全评估系统

**核心能力**：

- 🚀 自动化漏洞扫描
- 📊 漏洞管理与跟踪
- 👥 团队协作与报告
- ✅ 合规性检查

## 📁 目录结构

```
eap-security-tool/
├── 01-security-pipeline/         # DevSecOps 安全流水线
│   ├── deploy/                   # 部署配置
│   ├── ci/                       # CI/CD 配置
│   └── docs/                     # 架构与运维文档
├── 02-web-security-platform/     # Web 安全评估平台
│   ├── deploy/                   # 容器化部署
│   ├── services/                 # 服务组件
│   └── docs/                     # 系统文档
├── 03-security-knowledge/         # 安全知识库
│   ├── network-security/         # 网络安全
│   ├── appsec/                   # 应用安全
│   ├── compliance/               # 合规标准
│   └── threat-intelligence/      # 威胁情报
└── 04-shared-resources/          # 共享资源
    ├── infrastructure/           # 基础设施与部署方案
    ├── glossary/                 # 术语词汇
    ├── templates/                # 模板文件
    └── tools/                    # 工具集合
```

## 🚀 快速开始

### 一键部署（Docker Compose）

```bash
# 1. 克隆仓库
git clone https://github.com/your-org/eap-security-tool.git
cd eap-security-tool

# 2. 启动完整平台（使用共享基础设施）
cd 04-shared-resources/infrastructure/docker-compose/minimal
bash deploy.sh

# 3. 访问服务
# - DefectDojo: http://localhost/dojo/
# - Grafana: http://localhost/grafana/
# - ZAP API: http://localhost/zap/
```

**系统要求**: Docker 20.10+ / Docker Compose 2.0+ / 4 核 8GB 内存（推荐 8 核 16GB）

### 模块独立部署（可选）

- **仅启动 Web 安全评估**: `cd 02-web-security-platform/deploy && docker compose up -d`
- **仅启动安全流水线**: 参考 `01-security-pipeline/README.md`

### ⚡ 快速演示与评估（5 分钟）

- 前置条件：Docker 20.10+、Docker Compose 2.0+（本地或一台测试服务器）
- 一键启动：

  ```bash
  cd 04-shared-resources/infrastructure/docker-compose/minimal
  bash deploy.sh
  ```
- 访问统一入口：

  - DefectDojo: http://localhost/dojo/
  - Grafana: http://localhost/grafana/
  - ZAP API: http://localhost/zap/
- 快速评估清单：

  - 使用 ZAP 对测试站点发起一次主动扫描
  - 在 DefectDojo 中查看漏洞导入与去重、评级与指派
  - 在 Grafana 看到扫描趋势面板与基础可观测性
- 可验证动作（命令级）：

  1) 触发一次 ZAP 主动扫描（示例目标为外部测试站点，请确保已获得授权）
     ```bash
     curl -s "http://localhost/zap/JSON/ascan/action/scan/?url=http://testfire.net&recurse=true&inScopeOnly=false&scanPolicyName=&method=&postData=&contextId="
     ```
  2) 将 ZAP 报告导入 DefectDojo（假设已获取 API Key 与 Engagement ID：100）
     ```bash
     curl -X POST "http://localhost/dojo/api/v2/import-scan/" \
       -H "Authorization: Token <DOJO_API_KEY>" \
       -F "scan_type=ZAP Scan" \
       -F "file=@02-web-security-platform/testdata/zap-sample.json" \
       -F "engagement=100"
     ```
  3) 导入 Grafana Dashboard（在 Grafana → Dashboards → Import，粘贴 JSON）
     - 参考模板：首次部署可在 Grafana 内创建简单的 PostgreSQL 连接面板

提示：以上命令仅用于演示路径，生产环境请开启认证/使用 HTTPS/限制来源 IP，并根据实际目标调整扫描范围与强度。

- 停止/清理：
  ```bash
  # 在 minimal 目录
  docker compose down
  ```

## 📖 使用指南

### 文档规范

每个模块采用统一结构：

- **概述 (Overview)** - 功能简介与特性
- **快速开始 (Quick Start)** - 安装部署指南
- **架构设计 (Architecture)** - 系统设计与组件
- **使用手册 (User Guide)** - 详细操作说明
- **最佳实践 (Best Practices)** - 配置与优化
- **故障排查 (Troubleshooting)** - 常见问题解决

### 信息标准

所有工具和知识条目包含：

- ✨ **功能概述** - 核心能力与适用场景
- 🔧 **部署方式** - 安装配置与集成方法
- 📊 **性能评估** - 准确率、性能开销、资源需求
- 💰 **成本分析** - 开源/商业许可、维护成本
- 🏢 **企业适配** - 权限管理、审计、合规支持

## 🤝 贡献指南

### 贡献流程

1. **Fork** 本仓库到个人账户
2. **创建分支** 进行功能开发或文档优化
3. **提交更改** 遵循提交信息规范
4. **发起 PR** 详细说明更改内容

### 提交规范

- **feat**: 新功能或工具添加
- **docs**: 文档更新或优化
- **fix**: 问题修复或配置调整
- **refactor**: 代码或结构重构

### 内容标准

- 📝 **准确性**: 确保技术信息准确可验证
- 🔗 **引用**: 第三方资料须标注来源
- 🎯 **实用性**: 提供具体可操作的指导
- 🔄 **时效性**: 定期更新工具版本和漏洞库

## 📋 路线图

### v0.1 — 演示可用（当前）

- [X] Docker Compose minimal 一键启动（统一入口：Nginx + PostgreSQL/Redis）
- [X] Web 安全评估平台最小闭环：ZAP → DefectDojo → Grafana 面板
- [X] 内部安全流水线基础：GitLab + Jenkins + SonarQube（示例 CI/Jenkinsfile）
- [X] 5 分钟演示文档与营销文案（`<mcfile name="marketing-copy.md" path="04-shared-resources/marketing-copy.md"></mcfile>`）

### v0.2 — 集成增强

- [ ] DefectDojo 与流水线结果自动对接（API 导入与去重策略）
- [ ] ZAP 扫描作业模板与剧本（目标资产/范围/强度预设）
- [ ] Grafana 统一看板优化（扫描趋势、漏洞分布、TopN 资产）
- [ ] 共享基础设施优化：环境变量集中化、ARM64 镜像适配清单

### v0.3 — 生产化准备

- [ ] 复用企业设施指南（PostgreSQL/Redis/SSO/网关/CI）与示例配置
- [ ] 安全基线：默认禁用弱口令、密钥替换、最小权限与网络隔离示例
- [ ] 备份与恢复脚本（数据库/配置/报告）
- [ ] 监控与告警对接（Prometheus/Alertmanager 参考配置）

### v1.0 — 稳定首发

- [ ] 文档稳定版与操作手册（中文/英文）
- [ ] 平台可插拔适配层（扫描器/数据解析/导入导出接口）
- [ ] 扩展部署样例（Kubernetes 清单与策略建议）

备注：路线图不承诺具体时间点，按照版本目标交付，欢迎通过 Issue/PR 参与共建。

## ⚖️ 免责声明

本仓库内容仅用于：

- 🎓 **学习研究** - 安全技术学习与研究
- 🔒 **合规自查** - 企业内部安全评估
- 🛡️ **防御建设** - 安全防护体系构建

**重要提醒**：

- 请在合法授权范围内使用所有工具和方法
- 禁止将本仓库内容用于非法攻击活动
- 使用风险由使用者自行承担

## 📞 联系方式

- 📧 **问题反馈**: 通过 GitHub Issues 提交
- 💬 **讨论交流**: 使用 GitHub Discussions
- 📖 **文档协作**: 欢迎提交 Pull Request

---

⭐ **如果这个项目对您有帮助，请给我们一个 Star！**

## 🏗️ 企业级定制

**默认配置适用于中小型企业开箱即用**。对于大型企业或有特殊需求的场景：

- **快速评估**: 使用当前 Docker Compose 方案进行选型验证
- **高可用部署**: 可基于当前配置扩展为 Kubernetes 部署
- **企业集成**: 支持对接现有 LDAP/SSO、企业数据库、监控系统
- **合规定制**: 可根据等保、ISO27001 等标准进行安全加固

详细企业级配置请参考各模块的 `docs/operations.md` 文档以及 `04-shared-resources/infrastructure/` 中的部署方案。
