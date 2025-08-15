# Vue.js 前端安全最佳实践指南

## 概述

本指南提供Vue.js应用程序的安全最佳实践，涵盖开发、构建和部署各个阶段的安全考虑。

## 1. 依赖管理安全

### 1.1 依赖版本管理
- 使用最新稳定版本的Vue.js和相关依赖
- 定期运行`npm audit`检查已知漏洞
- 使用`retire.js`检测过时的JavaScript库

### 1.2 依赖安装安全
```bash
# 检查依赖漏洞
npm audit

# 自动修复低危漏洞
npm audit fix

# 检查过时依赖
npx retire
```

## 2. 代码安全

### 2.1 XSS防护
- 避免使用`v-html`指令，如必须使用请确保内容已经过滤
- 使用Vue的默认文本插值`{{ }}`自动转义
- 配置Content-Security-Policy头

```vue
<!-- 危险：直接使用v-html -->
<div v-html="userInput"></div>

<!-- 安全：使用文本插值 -->
<div>{{ userInput }}</div>

<!-- 安全：使用已过滤的内容 -->
<div v-html="sanitizedContent"></div>
```

### 2.2 路由安全
- 实施路由守卫进行权限控制
- 验证路由参数和查询字符串
- 避免在URL中传递敏感信息

```typescript
// 路由守卫示例
router.beforeEach((to, from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const isAuthenticated = store.getters.isAuthenticated
  
  if (requiresAuth && !isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})
```

### 2.3 HTTP请求安全
- 使用HTTPS协议
- 配置请求拦截器处理认证
- 验证响应数据
- 设置适当的超时时间

```typescript
// Axios安全配置
const apiClient = axios.create({
  baseURL: 'https://api.example.com',
  timeout: 10000,
  withCredentials: true
})

// 请求拦截器
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截器
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // 处理未授权访问
      router.push('/login')
    }
    return Promise.reject(error)
  }
)
```

## 3. 构建和部署安全

### 3.1 环境变量管理
- 使用环境变量管理配置
- 避免在前端代码中硬编码敏感信息
- 生产环境移除调试信息

```bash
# .env.production
VITE_API_URL=https://api.production.com
VITE_APP_NAME=MyApp

# 注意：不要在前端暴露敏感信息
# VITE_SECRET_KEY=xxx  # 错误示例
```

### 3.2 Content Security Policy
在`public/index.html`中配置CSP头：

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data: https:; 
               connect-src 'self' https://api.example.com;">
```

### 3.3 安全头配置
配置Web服务器添加安全头：

```nginx
# Nginx配置示例
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## 4. 开发工具配置

### 4.1 ESLint安全规则
使用`eslint-plugin-security`插件：

```bash
npm install --save-dev eslint-plugin-security
```

### 4.2 TypeScript严格模式
在`tsconfig.json`中启用严格模式：

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## 5. 安全检查清单

- [ ] 使用最新版本的Vue.js和依赖
- [ ] 配置ESLint安全规则
- [ ] 启用TypeScript严格模式
- [ ] 实施路由守卫
- [ ] 配置Content-Security-Policy
- [ ] 使用HTTPS协议
- [ ] 配置请求拦截器
- [ ] 避免使用v-html
- [ ] 定期进行依赖审计
- [ ] 移除生产环境的调试信息
- [ ] 配置适当的CORS策略
- [ ] 验证用户输入
- [ ] 实施适当的错误处理

## 6. 持续安全监控

### 6.1 自动化安全检查
在CI/CD流水线中集成安全检查：

```yaml
# GitHub Actions示例
name: Security Check
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm audit
      - run: npm run lint:security
      - run: npx retire
```

### 6.2 定期安全评估
- 每月进行依赖漏洞扫描
- 季度进行代码安全审查
- 年度进行渗透测试

## 参考资源

- [Vue.js安全指南](https://vuejs.org/guide/best-practices/security.html)
- [OWASP前端安全清单](https://owasp.org/www-project-frontend-security-checklist/)
- [Content Security Policy指南](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)