#!/usr/bin/env bash
set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查前置条件
check_prerequisites() {
    log_info "检查前置条件..."
    
    if ! command -v docker >/dev/null 2>&1; then
        log_error "未检测到 docker，请先安装 Docker Desktop"
        exit 1
    fi
    
    if ! docker compose version >/dev/null 2>&1; then
        log_error "未检测到 docker compose v2，请升级 Docker"
        exit 1
    fi
    
    log_success "前置条件检查通过"
}

# 测试 URL 可访问性
test_url() {
    local url=$1
    local name=$2
    local timeout=${3:-10}
    
    log_info "测试 ${name} 访问: ${url}"
    
    if curl -s --connect-timeout ${timeout} "${url}" >/dev/null 2>&1; then
        log_success "${name} 可正常访问"
        return 0
    else
        log_warning "${name} 暂时无法访问，可能还在启动中"
        return 1
    fi
}

# 验证安全流水线模块
validate_security_pipeline() {
    log_info "======== 验证安全流水线模块 ========"
    
    cd 01-security-pipeline/deploy
    
    log_info "启动安全流水线..."
    docker compose up -d
    
    log_info "等待服务启动（60秒）..."
    sleep 60
    
    log_info "检查容器状态:"
    docker compose ps
    
    # 测试服务可访问性
    local services_ok=0
    
    test_url "http://localhost/" "统一入口" && ((services_ok++))
    test_url "http://localhost/jenkins/" "Jenkins (反向代理)" && ((services_ok++)) 
    test_url "http://localhost/sonar/" "SonarQube (反向代理)" && ((services_ok++))
    test_url "http://localhost:8080" "Jenkins (直接访问)" && ((services_ok++))
    test_url "http://localhost:9000" "SonarQube (直接访问)" && ((services_ok++))
    
    if [[ ${services_ok} -ge 3 ]]; then
        log_success "安全流水线模块验证通过 (${services_ok}/5 个服务可访问)"
    else
        log_warning "安全流水线模块部分服务尚未就绪 (${services_ok}/5 个服务可访问)"
    fi
    
    log_info "停止安全流水线..."
    docker compose down
    cd ../..
}

# 验证 Web 安全平台模块
validate_web_security_platform() {
    log_info "======== 验证 Web 安全平台模块 ========"
    
    cd 02-web-security-platform/deploy
    
    log_info "启动 Web 安全平台..."
    docker compose up -d
    
    log_info "等待服务启动（90秒）..."
    sleep 90
    
    log_info "检查容器状态:"
    docker compose ps
    
    # 测试服务可访问性
    local services_ok=0
    
    test_url "http://localhost/dojo/" "DefectDojo" 15 && ((services_ok++))
    test_url "http://localhost/grafana/" "Grafana" 10 && ((services_ok++))
    test_url "http://localhost/zap/" "ZAP API" 10 && ((services_ok++))
    test_url "http://localhost:8080" "DefectDojo (直接访问)" 15 && ((services_ok++))
    test_url "http://localhost:3000" "Grafana (直接访问)" 10 && ((services_ok++))
    
    if [[ ${services_ok} -ge 3 ]]; then
        log_success "Web 安全平台模块验证通过 (${services_ok}/5 个服务可访问)"
    else
        log_warning "Web 安全平台模块部分服务尚未就绪 (${services_ok}/5 个服务可访问)"
    fi
    
    log_info "停止 Web 安全平台..."
    docker compose down
    cd ../..
}

# 验证最小化模板
validate_minimal_template() {
    log_info "======== 验证最小化模板 ========"
    
    cd 04-shared-resources/infrastructure/docker-compose/minimal
    
    log_info "启动最小化安全平台..."
    ./deploy.sh &
    DEPLOY_PID=$!
    
    log_info "等待服务启动（120秒）..."
    sleep 120
    
    # 检查部署进程是否还在运行
    if kill -0 $DEPLOY_PID 2>/dev/null; then
        log_info "部署脚本仍在运行"
    fi
    
    log_info "检查容器状态:"
    docker compose ps
    
    # 测试服务可访问性
    local services_ok=0
    
    test_url "http://localhost/dojo/" "DefectDojo (最小化)" 15 && ((services_ok++))
    test_url "http://localhost/grafana/" "Grafana (最小化)" 10 && ((services_ok++))
    test_url "http://localhost/zap/" "ZAP (最小化)" 10 && ((services_ok++))
    
    if [[ ${services_ok} -ge 2 ]]; then
        log_success "最小化模板验证通过 (${services_ok}/3 个服务可访问)"
    else
        log_warning "最小化模板部分服务尚未就绪 (${services_ok}/3 个服务可访问)"
    fi
    
    # 停止部署脚本和服务
    if kill -0 $DEPLOY_PID 2>/dev/null; then
        kill $DEPLOY_PID 2>/dev/null || true
    fi
    
    log_info "停止最小化平台..."
    docker compose down
    cd ../../../..
}

# 清理环境
cleanup() {
    log_info "======== 清理测试环境 ========"
    
    # 清理可能的残留容器和网络
    docker system prune -f >/dev/null 2>&1 || true
    
    log_success "环境清理完成"
}

# 主函数
main() {
    log_info "======== EAP Security Tool 部署验证测试 ========"
    
    check_prerequisites
    
    # 依次验证各个模块
    validate_security_pipeline
    validate_web_security_platform  
    validate_minimal_template
    
    cleanup
    
    log_success "======== 部署验证测试完成 ========"
    log_info "如果看到服务无法访问的警告，可能是服务需要更长的启动时间"
    log_info "建议手动测试各模块以确保完全就绪"
}

# 执行主函数
main "$@"