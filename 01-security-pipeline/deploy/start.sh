#!/usr/bin/env bash
set -euo pipefail

# 检查前置条件
check_prerequisites() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[ERROR] 未检测到 docker，请先安装 Docker Desktop" >&2
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "[ERROR] 未检测到 docker compose v2，请升级 Docker" >&2
    exit 1
  fi
}

# 启动安全流水线
start_pipeline() {
  echo "[INFO] 启动内部开发安全流水线..."
  docker compose up -d
  
  echo "[INFO] 等待服务启动..."
  sleep 30
  
  echo "[INFO] 服务状态："
  docker compose ps
  
  echo ""
  echo "访问地址："
  echo "- 统一入口: http://localhost/"
  echo "- Jenkins:   http://localhost/jenkins/ (需要初始密码)"
  echo "- SonarQube: http://localhost/sonar/ (admin/admin)"
  echo "- 直接访问："
  echo "  - Jenkins:   http://localhost:8080"
  echo "  - SonarQube: http://localhost:9000"
  echo ""
  echo "获取 Jenkins 初始密码："
  echo "docker exec security-pipeline-jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
}

check_prerequisites
start_pipeline
