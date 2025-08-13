# 最小化安全平台部署

轻量级的安全评估平台，适用于资源受限环境或快速概念验证。包含 DefectDojo、OWASP ZAP 和 Grafana 核心组件。

## 🚀 快速部署

### 前置要求
- Docker Desktop (4GB+ 内存推荐)
- Docker Compose V2

### 一键启动
```bash
cd 04-shared-resources/infrastructure/docker-compose/minimal
./deploy.sh
```

## 📊 包含服务

| 服务 | 版本 | 端口 | 访问路径 |
|------|------|------|----------|
| DefectDojo | latest | 8080 | http://localhost/dojo/ |
| Grafana | latest | 3000 | http://localhost/grafana/ |
| OWASP ZAP | stable | 8090 | http://localhost/zap/ |
| PostgreSQL | 14-alpine | 5432 | - |
| Redis | 7-alpine | 6379 | - |
| Nginx | alpine | 80 | http://localhost/ |

## 🔧 默认凭据

- **DefectDojo**: admin / admin
- **Grafana**: admin / admin123
- **数据库密码**: defectdojo123
- **Redis 密码**: redis123

## ⚠️  注意事项

1. **仅用于演示**: 此配置使用默认密码，不适合生产环境
2. **资源消耗**: 建议至少 4GB 可用内存
3. **数据持久化**: 使用 Docker 卷存储，容器删除后数据保留
4. **网络配置**: 使用 bridge 网络，适合单机部署

## 🛠️ 自定义配置

如需生产级别部署，请参考完整模块：
- 安全流水线: `01-security-pipeline/`
- Web 安全平台: `02-web-security-platform/`

## 📚 快速上手

1. 访问 DefectDojo 创建第一个产品
2. 使用 ZAP API 进行漏洞扫描
3. 在 Grafana 中查看安全数据可视化