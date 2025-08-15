/* eslint-env node */
require('@rushstack/eslint-patch/modern-module-resolution')

/**
 * Vue.js项目ESLint安全配置
 * 专注于安全相关的代码检查规则
 */
module.exports = {
  root: true,
  extends: [
    'plugin:vue/vue3-essential',
    'eslint:recommended',
    '@vue/eslint-config-typescript',
    'plugin:security/recommended'
  ],
  plugins: ['security'],
  parserOptions: {
    ecmaVersion: 'latest'
  },
  rules: {
    // 安全相关规则
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'error',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-non-literal-fs-filename': 'error',
    'security/detect-non-literal-require': 'error',
    'security/detect-possible-timing-attacks': 'error',
    'security/detect-pseudoRandomBytes': 'error',
    
    // Vue特定安全规则
    'vue/no-v-html': 'error', // 防止XSS攻击
    'vue/no-v-text-v-html-on-component': 'error',
    'vue/no-template-target-blank': 'error', // 防止target="_blank"安全问题
    
    // TypeScript安全规则
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-unsafe-assignment': 'error',
    '@typescript-eslint/no-unsafe-call': 'error',
    '@typescript-eslint/no-unsafe-member-access': 'error',
    '@typescript-eslint/no-unsafe-return': 'error',
    
    // 通用安全规则
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-new-func': 'error',
    'no-script-url': 'error',
    'no-alert': 'warn',
    'no-console': 'warn'
  },
  overrides: [
    {
      files: ['*.vue'],
      rules: {
        // Vue文件特定规则
        'vue/multi-word-component-names': 'off'
      }
    }
  ]
}