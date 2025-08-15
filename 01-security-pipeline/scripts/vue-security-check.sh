#!/bin/bash

# Vue.js 前端安全配置检查脚本
# 用于检查Vue应用的安全配置和依赖

set -e

echo "=== Vue.js 前端安全配置检查 ==="

# 检查项目根目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误: 未找到package.json文件"
    exit 1
fi

echo "✅ 发现package.json文件"

# 1. 检查Vue版本和框架依赖
echo "\n🔍 检查Vue框架版本..."
VUE_VERSION=$(grep -E '"vue":|"@vue/cli":|"vite":' package.json 2>/dev/null || echo "")
if [ -n "$VUE_VERSION" ]; then
    echo "✅ 发现Vue相关依赖:"
    echo "$VUE_VERSION"
    
    # 检查Vue版本是否过旧
    if grep -q '"vue": "[12]\.' package.json 2>/dev/null; then
        echo "⚠️  警告: 检测到Vue 1.x或2.x版本，建议升级到Vue 3.x"
    fi
else
    echo "❌ 错误: 未发现Vue相关依赖"
    exit 1
fi

# 2. 检查已知的高危依赖包
echo "\n🔍 检查高危依赖包..."
HIGH_RISK_DEPS=("lodash" "moment" "jquery" "bootstrap" "axios")
for dep in "${HIGH_RISK_DEPS[@]}"; do
    if grep -q "\"$dep\"" package.json 2>/dev/null; then
        echo "⚠️  发现依赖: $dep - 请确保使用最新版本"
    fi
done

# 3. 检查开发依赖中的安全工具
echo "\n🔍 检查安全相关开发依赖..."
SECURITY_TOOLS=("eslint-plugin-security" "@typescript-eslint/eslint-plugin" "helmet")
for tool in "${SECURITY_TOOLS[@]}"; do
    if grep -q "\"$tool\"" package.json 2>/dev/null; then
        echo "✅ 发现安全工具: $tool"
    else
        echo "⚠️  建议添加安全工具: $tool"
    fi
done

# 4. 检查环境变量配置
echo "\n🔍 检查环境变量配置..."
if [ -f ".env" ] || [ -f ".env.local" ] || [ -f ".env.production" ]; then
    echo "✅ 发现环境变量配置文件"
    
    # 检查是否有敏感信息泄露
    ENV_FILES=(".env" ".env.local" ".env.production" ".env.development")
    for env_file in "${ENV_FILES[@]}"; do
        if [ -f "$env_file" ]; then
            # 检查是否包含明文密码、token等
            SENSITIVE_VARS=$(grep -iE "password|secret|token|key" "$env_file" 2>/dev/null || echo "")
            if [ -n "$SENSITIVE_VARS" ]; then
                echo "⚠️  警告: $env_file 中发现可能的敏感信息"
                echo "   建议: 确保生产环境不暴露敏感配置"
            fi
        fi
    done
else
    echo "ℹ️  信息: 未发现环境变量配置文件"
fi

# 5. 检查Vue Router配置安全
echo "\n🔍 检查Vue Router配置..."
ROUTER_CONFIG=$(find src/ -name "*.js" -o -name "*.ts" -o -name "*.vue" 2>/dev/null | xargs grep -l "vue-router\|createRouter" 2>/dev/null || echo "")
if [ -n "$ROUTER_CONFIG" ]; then
    echo "✅ 发现Vue Router配置"
    
    # 检查路由守卫
    ROUTE_GUARDS=$(grep -E "beforeEach|beforeResolve|beforeEnter" $ROUTER_CONFIG 2>/dev/null || echo "")
    if [ -n "$ROUTE_GUARDS" ]; then
        echo "✅ 发现路由守卫配置"
    else
        echo "⚠️  建议: 添加路由守卫进行权限控制"
    fi
fi

# 6. 检查HTTP请求安全配置
echo "\n🔍 检查HTTP请求配置..."
HTTP_CONFIG=$(find src/ -name "*.js" -o -name "*.ts" 2>/dev/null | xargs grep -l "axios\|fetch\|XMLHttpRequest" 2>/dev/null || echo "")
if [ -n "$HTTP_CONFIG" ]; then
    echo "✅ 发现HTTP请求配置"
    
    # 检查HTTPS使用
    HTTP_USAGE=$(grep -E "http://" $HTTP_CONFIG 2>/dev/null || echo "")
    if [ -n "$HTTP_USAGE" ]; then
        echo "⚠️  警告: 发现HTTP协议使用，生产环境建议使用HTTPS"
    fi
    
    # 检查请求拦截器
    INTERCEPTORS=$(grep -E "interceptors|withCredentials" $HTTP_CONFIG 2>/dev/null || echo "")
    if [ -n "$INTERCEPTORS" ]; then
        echo "✅ 发现请求拦截器配置"
    else
        echo "⚠️  建议: 配置请求拦截器处理认证和错误"
    fi
fi

# 7. 检查CSP和安全头配置
echo "\n🔍 检查内容安全策略(CSP)配置..."
CSP_CONFIG=$(find public/ -name "index.html" 2>/dev/null | xargs grep -l "Content-Security-Policy" 2>/dev/null || echo "")
if [ -n "$CSP_CONFIG" ]; then
    echo "✅ 发现CSP配置"
else
    echo "⚠️  建议: 在index.html中添加Content-Security-Policy头"
fi

# 8. 检查构建配置安全
echo "\n🔍 检查构建配置..."
if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    echo "✅ 发现Vite配置文件"
    VITE_CONFIG=$(find . -name "vite.config.*" 2>/dev/null)
    
    # 检查开发服务器配置
    DEV_SERVER=$(grep -E "server:|host:|port:" $VITE_CONFIG 2>/dev/null || echo "")
    if echo "$DEV_SERVER" | grep -q "host.*0.0.0.0"; then
        echo "⚠️  警告: 开发服务器配置为监听所有接口，注意安全风险"
    fi
elif [ -f "vue.config.js" ]; then
    echo "✅ 发现Vue CLI配置文件"
    VUE_CONFIG="vue.config.js"
    
    # 检查开发服务器配置
    DEV_SERVER=$(grep -E "devServer|host|port" $VUE_CONFIG 2>/dev/null || echo "")
    if echo "$DEV_SERVER" | grep -q "host.*0.0.0.0"; then
        echo "⚠️  警告: 开发服务器配置为监听所有接口，注意安全风险"
    fi
fi

# 9. 检查TypeScript配置
echo "\n🔍 检查TypeScript配置..."
if [ -f "tsconfig.json" ]; then
    echo "✅ 发现TypeScript配置"
    
    # 检查严格模式
    STRICT_MODE=$(grep -E '"strict".*true|"noImplicitAny".*true' tsconfig.json 2>/dev/null || echo "")
    if [ -n "$STRICT_MODE" ]; then
        echo "✅ TypeScript严格模式已启用"
    else
        echo "⚠️  建议: 启用TypeScript严格模式提高代码安全性"
    fi
fi

# 10. 检查ESLint安全规则
echo "\n🔍 检查ESLint安全配置..."
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ]; then
    echo "✅ 发现ESLint配置"
    
    ESLINT_CONFIG=$(find . -name ".eslintrc.*" -o -name "eslint.config.*" 2>/dev/null)
    SECURITY_RULES=$(grep -E "eslint-plugin-security|@typescript-eslint" $ESLINT_CONFIG 2>/dev/null || echo "")
    if [ -n "$SECURITY_RULES" ]; then
        echo "✅ 发现ESLint安全规则配置"
    else
        echo "⚠️  建议: 添加eslint-plugin-security插件"
    fi
else
    echo "⚠️  建议: 添加ESLint配置进行代码质量检查"
fi

echo "\n=== Vue.js 前端安全检查完成 ==="
echo "\n📋 Vue前端安全建议:"
echo "1. 使用最新版本的Vue.js和相关依赖"
echo "2. 配置Content-Security-Policy防止XSS攻击"
echo "3. 实施适当的路由守卫和权限控制"
echo "4. 使用HTTPS协议进行数据传输"
echo "5. 配置请求拦截器处理认证和错误"
echo "6. 启用TypeScript严格模式"
echo "7. 使用ESLint安全插件进行代码检查"
echo "8. 定期更新依赖包，修复已知漏洞"
echo "9. 避免在前端代码中硬编码敏感信息"
echo "10. 配置适当的CORS策略"