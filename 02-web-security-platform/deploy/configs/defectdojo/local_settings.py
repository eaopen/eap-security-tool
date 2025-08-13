"""
DefectDojo 本地设置文件
用于 Docker 环境的自定义配置
"""
import os

# 基础配置
SECRET_KEY = os.environ.get('DD_SECRET_KEY', 'change-me-in-production')
DEBUG = os.environ.get('DD_DEBUG', 'False').lower() == 'true'
ALLOWED_HOSTS = os.environ.get('DD_ALLOWED_HOSTS', '*').split(',')

# 时区设置
TIME_ZONE = os.environ.get('DD_TIME_ZONE', 'Asia/Shanghai')
USE_TZ = True

# 数据库配置通过环境变量提供
# DD_DATABASE_URL 格式: postgresql://user:password@host:port/database

# Celery 配置通过环境变量提供  
# DD_CELERY_BROKER_URL 格式: redis://:password@host:port/db

# 审计日志设置
ENABLE_AUDITLOG = os.environ.get('DD_ENABLE_AUDITLOG', 'True').lower() == 'true'

# 文件上传设置
FILE_UPLOAD_MAX_MEMORY_SIZE = 100 * 1024 * 1024  # 100MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 100 * 1024 * 1024  # 100MB

# 安全设置
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = False  # 在反向代理环境中禁用
USE_X_FORWARDED_HOST = True
USE_X_FORWARDED_PORT = True

# 子路径支持 (通过环境变量设置)
FORCE_SCRIPT_NAME = os.environ.get('DD_FORCE_SCRIPT_NAME', '')
if FORCE_SCRIPT_NAME:
    STATIC_URL = FORCE_SCRIPT_NAME + '/static/'
    MEDIA_URL = FORCE_SCRIPT_NAME + '/media/'

# 缓存配置
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': os.environ.get('DD_CELERY_BROKER_URL', 'redis://localhost:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# 日志配置
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO' if not DEBUG else 'DEBUG',
    },
}

# API 配置
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 25
}