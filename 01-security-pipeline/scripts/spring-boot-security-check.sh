#!/bin/bash

# Spring Boot 安全配置检查脚本
# 用于检查Spring Boot应用的安全配置

set -e

echo "=== Spring Boot 安全配置检查 ==="

# 检查项目根目录
if [ ! -f "pom.xml" ] && [ ! -f "build.gradle" ]; then
    echo "❌ 错误: 未找到Maven或Gradle构建文件"
    exit 1
fi

echo "✅ 发现构建文件"

# 1. 检查Spring Security依赖
echo "\n🔍 检查Spring Security依赖..."
if grep -q "spring-boot-starter-security" pom.xml 2>/dev/null || grep -q "spring-boot-starter-security" build.gradle 2>/dev/null; then
    echo "✅ 发现Spring Security依赖"
else
    echo "⚠️  警告: 未发现Spring Security依赖，建议添加安全框架"
fi

# 2. 检查Actuator端点安全配置
echo "\n🔍 检查Actuator端点配置..."
ACTUATOR_CONFIG=$(find src/ -name "*.properties" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | xargs grep -l "management.endpoints" 2>/dev/null || echo "")
if [ -n "$ACTUATOR_CONFIG" ]; then
    echo "✅ 发现Actuator配置文件: $ACTUATOR_CONFIG"
    
    # 检查是否暴露了敏感端点
    EXPOSED_ENDPOINTS=$(grep "management.endpoints.web.exposure.include" $ACTUATOR_CONFIG 2>/dev/null || echo "")
    if echo "$EXPOSED_ENDPOINTS" | grep -q "\*"; then
        echo "❌ 危险: 发现暴露所有Actuator端点的配置"
        echo "   建议: 仅暴露必要的端点，如 health,info"
    else
        echo "✅ Actuator端点配置相对安全"
    fi
else
    echo "ℹ️  信息: 未发现Actuator配置"
fi

# 3. 检查数据库连接安全
echo "\n🔍 检查数据库连接配置..."
DB_CONFIG=$(find src/ -name "*.properties" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | xargs grep -l "datasource" 2>/dev/null || echo "")
if [ -n "$DB_CONFIG" ]; then
    echo "✅ 发现数据库配置文件: $DB_CONFIG"
    
    # 检查是否有硬编码密码
    HARDCODED_PWD=$(grep -E "password\s*[:=]\s*[^$]" $DB_CONFIG 2>/dev/null || echo "")
    if [ -n "$HARDCODED_PWD" ]; then
        echo "❌ 危险: 发现硬编码数据库密码"
        echo "   建议: 使用环境变量或配置中心管理敏感信息"
    else
        echo "✅ 数据库密码配置相对安全"
    fi
fi

# 4. 检查HTTPS配置
echo "\n🔍 检查HTTPS配置..."
HTTPS_CONFIG=$(find src/ -name "*.properties" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | xargs grep -l "server.ssl" 2>/dev/null || echo "")
if [ -n "$HTTPS_CONFIG" ]; then
    echo "✅ 发现HTTPS配置"
else
    echo "⚠️  警告: 未发现HTTPS配置，生产环境建议启用HTTPS"
fi

# 5. 检查CORS配置
echo "\n🔍 检查CORS配置..."
CORS_CONFIG=$(find src/ -name "*.java" 2>/dev/null | xargs grep -l "@CrossOrigin\|CorsConfiguration" 2>/dev/null || echo "")
if [ -n "$CORS_CONFIG" ]; then
    echo "✅ 发现CORS配置文件: $CORS_CONFIG"
    
    # 检查是否允许所有来源
    ALLOW_ALL=$(grep -E "allowedOrigins.*\*|@CrossOrigin.*origins.*\*" $CORS_CONFIG 2>/dev/null || echo "")
    if [ -n "$ALLOW_ALL" ]; then
        echo "❌ 危险: 发现允许所有来源的CORS配置"
        echo "   建议: 限制允许的来源域名"
    else
        echo "✅ CORS配置相对安全"
    fi
fi

# 6. 检查日志配置
echo "\n🔍 检查日志配置..."
LOG_CONFIG=$(find src/ -name "logback*.xml" -o -name "log4j*.xml" -o -name "*.properties" -o -name "*.yml" 2>/dev/null | xargs grep -l "logging" 2>/dev/null || echo "")
if [ -n "$LOG_CONFIG" ]; then
    echo "✅ 发现日志配置"
    
    # 检查是否记录敏感信息
    SENSITIVE_LOG=$(grep -iE "password|token|secret" $LOG_CONFIG 2>/dev/null || echo "")
    if [ -n "$SENSITIVE_LOG" ]; then
        echo "⚠️  警告: 日志配置中可能包含敏感信息记录"
    fi
fi

# 7. 检查安全头配置
echo "\n🔍 检查安全头配置..."
SECURITY_HEADERS=$(find src/ -name "*.java" 2>/dev/null | xargs grep -l "HttpSecurity\|SecurityConfig" 2>/dev/null || echo "")
if [ -n "$SECURITY_HEADERS" ]; then
    echo "✅ 发现安全配置类: $SECURITY_HEADERS"
    
    # 检查常见安全头
    HEADERS_CHECK=$(grep -E "headers\(\)|frameOptions\(\)|contentTypeOptions\(\)|xssProtection\(\)" $SECURITY_HEADERS 2>/dev/null || echo "")
    if [ -n "$HEADERS_CHECK" ]; then
        echo "✅ 发现安全头配置"
    else
        echo "⚠️  建议: 添加安全头配置 (X-Frame-Options, X-Content-Type-Options等)"
    fi
fi

echo "\n=== Spring Boot 安全检查完成 ==="
echo "\n📋 安全建议:"
echo "1. 确保生产环境启用HTTPS"
echo "2. 限制Actuator端点暴露"
echo "3. 使用环境变量管理敏感配置"
echo "4. 配置适当的CORS策略"
echo "5. 启用安全头防护"
echo "6. 定期更新依赖版本"
echo "7. 实施适当的认证和授权机制"