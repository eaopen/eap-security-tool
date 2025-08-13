# Web 安全评估平台 (Web Security Platform)

> 定位：演示与评估优先，默认采用 Docker Compose 一键启动；中小企业开箱即用，亦可复用企业现有数据库/认证/网关。

基于开源工具构建的企业级 Web 安全评估平台，聚焦以下能力：
- 自动化漏洞扫描
- 漏洞管理与跟踪
- 团队协作
- 合规性检查

## 目录结构
```
02-web-security-platform/
├── deploy/
│   ├── docker-compose.yml
│   └── configs/
├── services/
│   ├── scanner/           # 扫描引擎（如 ZAP, Nuclei）
│   ├── vuln-manager/      # 漏洞管理（如 DefectDojo）
│   ├── auth/              # 统一认证（SSO/OIDC）
│   └── ui/                # 平台前端
└── docs/
    ├── architecture.md
    └── operations.md
```

## 基础设施准备
- 默认推荐：使用 <mcfolder name="minimal" path="04-shared-resources/infrastructure/docker-compose/minimal"></mcfolder> 一键启动并访问统一入口。
- 复用现有环境（可选）：参考 <mcfile name="README.md" path="04-shared-resources/infrastructure/README.md"></mcfile> 的“复用现有环境”。

## 快速开始（容器化）
- 前置条件：Docker 20.10+、Docker Compose 2.0+
- 启动：
  ```bash
  cd 02-web-security-platform/deploy
  docker compose up -d
  ```
- 访问：
  - DefectDojo: http://localhost/dojo/
  - Grafana: http://localhost/grafana/
  - ZAP API: http://localhost/zap/
- 关闭：
  ```bash
  docker compose down
  ```
- 安全备注：演示级配置，不适用于生产；生产化请参阅 docs/operations.md，替换密钥、开启 SSL、最小化权限并加固网络策略。

## 最佳实践
- 结合 Jenkins/Airflow 实现定时扫描与结果导入
- 使用 DefectDojo 进行漏洞去重、评级与修复跟踪
- 集成企业登录（OIDC）与消息通知（企业微信/邮件）

## 相关文档
- docs/architecture.md：架构设计
- docs/operations.md：运维与操作指南
- docs/integrations.md：工具联动与接口对接
- docs/playbooks.md：作业剧本与操作指引
- docs/data-model.md：统一数据模型（资产/漏洞/扫描任务/可视化）
- docs/web-security-platform-architecture-zh.md：整体方案概览（中文）

## 字段对齐快速校验（本地）

- 准备
  - 在 docs/integrations.md 的“附录C：最小可运行示例文件”中，将示例内容另存为以下文件（路径仅为建议，便于管理）：
    - 02-web-security-platform/testdata/zap-sample.json
    - 02-web-security-platform/testdata/openvas-sample.xml（可选）
    - 02-web-security-platform/testdata/dependency-check-sample.json（可选）
    - 02-web-security-platform/testdata/lynis-sample.txt（可选）
    - 02-web-security-platform/testdata/gitleaks-sample.json（可选）
  - 将“附录C.7 校验脚本示例（Python）”保存为：
    - 02-web-security-platform/scripts/validate_alignment.py

- 运行
  - 在项目根目录执行：
    ```bash
    cd 02-web-security-platform
    python3 scripts/validate_alignment.py
    ```
  - 若样例文件不在当前工作目录，请调整脚本中的样例文件路径，或将运行目录切换到样例所在目录。

- 预期输出（示例）
  - 若校验通过，将看到类似输出：
    ```
    ✓ ZAP 漏洞校验通过: Cross Site Scripting (Reflected)
    ```

- 提示
  - 脚本仅使用 Python 标准库（json、xml.etree），无需额外依赖。
  - 建议在对接真实解析器前，先用这些示例完成字段映射的单元测试与联调。
  - 解析更多扫描器时，可参考 [docs/data-model.md](docs/data-model.md) 的“样例对象”与字段定义，补充校验逻辑。