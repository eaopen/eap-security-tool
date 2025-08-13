# 运维与故障排查（Operations）

## 部署
- 使用 Docker Compose 启动 SonarQube、Jenkins 等服务
- 配置 Jenkins Agent（Docker-in-Docker 可选）

## 常见问题
- SonarQube 无法访问：检查端口、防火墙与容器健康状态
- 依赖库 NVD 更新慢：配置本地镜像或缓存目录
- 构建时间过长：优化缓存与并发设置