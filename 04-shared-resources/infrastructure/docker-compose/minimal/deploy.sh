#!/usr/bin/env bash
set -euo pipefail

# 函数：检查 docker 与 compose 是否可用
check_prerequisites() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[ERROR] 未检测到 docker，请先安装 Docker Desktop 或 Docker Engine" >&2
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "[ERROR] 未检测到 docker compose v2，请升级 Docker 或安装 compose 插件" >&2
    exit 1
  fi
}

# 函数：启动最小化环境
start_stack() {
  echo "[INFO] 启动最小化安全平台..."
  docker compose up -d
  echo "[INFO] 启动完成："
  echo "- DefectDojo: http://localhost/dojo/"
  echo "- Grafana:   http://localhost/grafana/"
  echo "- ZAP API:   http://localhost/zap/"
}

# 函数：展示日志
show_logs() {
  docker compose ps
}

check_prerequisites
start_stack
show_logs