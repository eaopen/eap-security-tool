# 架构与组件（Architecture）

- 代码托管与 CI：GitLab + Jenkins
- 静态分析：SonarQube（Quality Gate）
- 依赖扫描：OWASP Dependency-Check / Trivy
- 构建与发布：容器化构建、镜像扫描与部署

## 流水线建议
- 主分支全量扫描，特性分支增量扫描
- 质量门禁（阻断高危问题合并）
- 构建缓存优化 SCA 扫描时间