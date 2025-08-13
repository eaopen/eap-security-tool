#!/usr/bin/env bash
set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

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

# 启动 Web 安全平台
start_platform() {
    log_info "启动 Web 安全评估平台..."
    docker compose up -d
    
    log_info "等待服务启动（这可能需要 2-3 分钟）..."
    sleep 90
    
    log_info "服务状态："
    docker compose ps
    
    echo ""
    log_success "Web 安全评估平台已启动！"
    echo ""
    echo "访问地址："
    echo "- 统一入口:     http://localhost/"
    echo "- DefectDojo:   http://localhost/dojo/ (admin/admin)"
    echo "- Grafana:      http://localhost/grafana/ (admin/admin)"
    echo "- ZAP API:      http://localhost/zap/"
    echo ""
    echo "直接访问："
    echo "- DefectDojo:   http://localhost:8080"
    echo "- Grafana:      http://localhost:3000"
    echo "- ZAP:          http://localhost:8090"
    echo ""
    log_warning "首次启动 DefectDojo 需要初始化数据库，可能需要额外等待时间"
    echo ""
    echo "查看实时日志："
    echo "docker compose logs -f"
}

check_prerequisites
start_platform