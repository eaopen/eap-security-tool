-- 初始化 DefectDojo 与 Grafana 数据库
CREATE DATABASE grafana;

-- 允许 defectdojo 用户访问 grafana（演示环境）
GRANT ALL PRIVILEGES ON DATABASE grafana TO defectdojo;