# 注意：该设置文件用于本地/演示环境，请在生产中进行加固与审计
import os

SECRET_KEY = os.environ.get('DD_SECRET_KEY', 'change-me')
DEBUG = os.environ.get('DD_DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('DD_ALLOWED_HOSTS', '*').split(',')
TIME_ZONE = os.environ.get('DD_TIME_ZONE', 'Asia/Shanghai')

# 数据库配置通过环境变量 DD_DATABASE_URL 提供
# Celery broker 通过 DD_CELERY_BROKER_URL 提供

# 审计日志
ENABLE_AUDITLOG = os.environ.get('DD_ENABLE_AUDITLOG', 'True') == 'True'

# 其他常见设置可按需补充