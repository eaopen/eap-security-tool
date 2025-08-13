# 推广用语与对外传播素材（Marketing Copy)

本文档汇总本项目对外传播所需的关键文案与素材，便于在 GitHub About、社交媒体、展示页、海报等场景复用与扩展。

---

## 1) 一句话电梯文案（用于社交预览/封面）
一键部署的企业应用安全平台：从代码安全到 Web 漏洞管理，5 分钟完成演示与评估。

## 2) 仓库短描述（80–120 字）
企业应用安全工具平台：聚焦演示与评估，默认 Docker Compose 一键部署；中小企业开箱即用，覆盖 DevSecOps/代码与依赖安全/Web 扫描与漏洞管理的关键能力。

## 3) 仓库长描述（用于仓库 About 或 README 首屏摘要）
EAP Security Tool 专注于企业前后端分离系统的安全检测与评估，提供两套核心方案：内部开发安全流水线（DevSecOps/SAST/SCA）与 Web 安全评估平台（自动化扫描/漏洞管理/可视化）。项目以“演示与评估优先”为导向，默认采用 Docker Compose 一键启动，帮助中小企业以最低门槛获得可用安全能力；大型企业可将其作为选型评估参考，后续与现有设施对接或演进到生产环境。

5 分钟即可完成演示：
- 进入目录：`cd 04-shared-resources/infrastructure/docker-compose/minimal`
- 一键启动：`bash deploy.sh`
- 访问统一入口：DefectDojo/Grafana/ZAP 即刻验证能力与价值

## 4) README 顶部短标语（可选）
一键上手的企业安全工具平台：演示评估优先，中小企业开箱即用。

## 5) 三大价值主张（Value Proposition）
- 一键体验：提供 minimal 方案一键部署，快速展示能力闭环。
- 工具齐备：覆盖“代码安全—依赖安全—Web 扫描—漏洞管理—可视化”的关键链路。
- 可持续演进：支持复用企业现有 PostgreSQL/Redis/网关/CI 等设施，平滑从 PoC 演进生产。

## 6) 目标用户（Who is it for）
- 安全或研发团队：快速验证 DevSecOps/SAST/SCA/自动化扫描/漏洞管理的可行性与价值。
- 中小企业/业务团队：以最低门槛搭建基础安全能力，快速获得可用产出。
- 大型企业安全团队：作为 PoC 参考，结合 Kubernetes、SSO、审计与监控进行企业级落地。

## 7) 推荐 Topics（用于仓库搜索曝光）
- devsecops, security, docker-compose, sast, sca, zap, defectdojo, jenkins, gitlab, cicd, vulnerability-management, security-platform, opensource, grafana, poc

## 8) 社交媒体/海报用短句（可轮播）
1. 5 分钟上手，一键部署企业安全工具平台。
2. 从代码到 Web 漏洞管理，关键能力开箱即用。
3. 面向演示与评估而生，中小企业的第一套安全工具。
4. 一条命令跑通 DevSecOps 与自动化扫描。
5. 开源可延展，PoC 到生产的平滑路径。
6. 统一入口：DefectDojo/Grafana/ZAP，直接可见价值。
7. 轻量依赖，单机也能跑的安全平台。
8. 与现有 Jenkins/GitLab/SSO 无缝衔接（可选）。
9. 可视化洞察安全态势，漏洞管理不再分散。
10. 为团队展示、内训与试点而生的标准工具箱。

## 9) 行动号召（CTA）
- 立即体验：进入 minimal 目录，一键启动
- Star 项目：帮助更多团队发现并使用
- 分享给团队：用于评估、试点与培训

## 10) 使用场景（Where to use）
- PoC/招标/选型评估演示
- 内部试点与快速能力验证
- 安全培训/工作坊/演示日

## 11) 放置与配置建议（Maintainer Checklist）
- GitHub → Settings → General → Description：粘贴“仓库短描述”。
- GitHub → Settings → General → Topics：添加上文推荐 Topics。
- GitHub → Settings → General → Social preview：上传预览图，并在图中放入“一句话电梯文案”。
- README 首屏：可放“短标语 + 5 分钟快速演示与评估”段落，保持首屏即上手。

## 12) 现成素材引用
- 一键演示路径：`04-shared-resources/infrastructure/docker-compose/minimal` → `bash deploy.sh`
- 入口地址（示例环境）：
  - DefectDojo: http://localhost/dojo/
  - Grafana: http://localhost/grafana/
  - ZAP API: http://localhost/zap/

---

如需英文版文案、社交海报图（OG Image）或多语言版本，请提出需求，我将基于本模板输出对应素材。