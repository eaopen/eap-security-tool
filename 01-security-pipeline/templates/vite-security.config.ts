import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

/**
 * Vite安全配置模板
 * 包含安全相关的构建和开发服务器配置
 */
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  
  // 开发服务器安全配置
  server: {
    // 仅监听本地接口，避免暴露到外网
    host: '127.0.0.1',
    port: 3000,
    // 启用HTTPS（开发环境可选）
    // https: true,
    
    // CORS配置
    cors: {
      origin: ['http://localhost:3000', 'https://localhost:3000'],
      credentials: true
    },
    
    // 代理配置（用于API请求）
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        secure: true, // 验证SSL证书
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  },
  
  // 构建配置
  build: {
    // 生成source map用于调试，生产环境可关闭
    sourcemap: false,
    
    // 代码分割配置
    rollupOptions: {
      output: {
        // 手动分割代码块
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          utils: ['axios', 'lodash']
        }
      }
    },
    
    // 压缩配置
    minify: 'terser',
    terserOptions: {
      compress: {
        // 移除console和debugger
        drop_console: true,
        drop_debugger: true
      }
    }
  },
  
  // 环境变量配置
  define: {
    // 只暴露以VITE_开头的环境变量
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version)
  },
  
  // 预览服务器配置（用于构建后预览）
  preview: {
    host: '127.0.0.1',
    port: 4173,
    cors: true
  }
})