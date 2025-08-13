# 共享资源 (Shared Resources)

> 说明：基础设施作为共享附录提供，聚焦主线功能不被弱化；同时提供中小企业开箱即用与演示评估的一键入口。

此目录汇聚了平台的共享资源，包括基础设施部署方案、安全模板、术语词汇、工具知识库等。

## 🚀 快速部署（基础设施）

使用统一的基础设施方案一键启动整个平台：

```bash
# 进入基础设施目录
cd infrastructure/docker-compose/minimal

# 启动完整平台
bash deploy.sh

# 访问服务
# - DefectDojo: http://localhost/dojo/
# - Grafana: http://localhost/grafana/
# - ZAP API: http://localhost/zap/
```

详细说明请参考：<mcfile name="README.md" path="04-shared-resources/infrastructure/README.md"></mcfile>

## 📁 目录结构

```
04-shared-resources/
├── infrastructure/               # 基础设施与环境准备
│   ├── docker-compose/          # 容器化部署方案
│   └── docs/                    # 环境要求与配置说明
├── glossary/                    # 术语词汇表
├── templates/                   # 模板文件
│   ├── incident-response-plan.md
│   ├── pentest-report.md
│   └── security-review-checklist.md
├── tools-knowledge-base.md      # 工具知识库
└── security-resources-links.md  # 安全资源链接
```

## 📖 内容说明

### 基础设施 (infrastructure/)
提供统一的 Docker Compose 部署方案，支持中小型企业开箱即用，大型企业可作为选型评估参考。

### 模板文件 (templates/)
- **事件响应计划**: 安全事件处理流程模板
- **渗透测试报告**: 标准化测试报告格式
- **安全审查清单**: 代码/系统安全检查要点

### 工具知识库 (tools-knowledge-base.md)
汇总各类安全工具的功能特性、部署方式、性能评估、成本分析等信息。

### 安全资源链接 (security-resources-links.md)
精选的安全相关学习资源、工具下载、标准规范等外部链接。

## 🤝 贡献指南

欢迎贡献以下内容：
- 新的安全工具评估与使用经验
- 企业级安全模板与最佳实践
- 部署方案的优化与扩展
- 安全资源的整理与分类

请确保所有贡献内容：
- 准确性可验证
- 实用性强
- 格式规范
- 及时更新