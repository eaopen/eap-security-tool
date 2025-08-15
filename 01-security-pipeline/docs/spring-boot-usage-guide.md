# Spring Boot 安全检查流水线使用指南

## 📋 概述

本指南详细介绍如何在Spring Boot项目中集成和使用DevSecOps安全检查流水线，实现代码质量分析、安全扫描和持续集成的自动化安全检查。

## 🎯 功能特性

- ✅ **静态代码分析 (SAST)**: SonarQube + SpotBugs + FindSecBugs
- ✅ **依赖漏洞扫描 (SCA)**: OWASP Dependency Check
- ✅ **容器安全扫描**: Trivy 镜像安全检测
- ✅ **Spring Boot专项检查**: 配置安全、端点安全、认证授权
- ✅ **质量门禁**: 自动化安全规则管控
- ✅ **持续集成**: Jenkins 流水线自动化

## 🚀 快速开始

### 1. 环境准备

#### 系统要求
- Docker 20.10+
- Docker Compose 2.0+
- JDK 11+ 或 JDK 17+
- Maven 3.6+ 或 Gradle 7+
- Git 2.0+

#### 启动安全流水线环境

```bash
# 克隆项目
git clone <your-repo-url>
cd eap-security-tool/01-security-pipeline

# 启动所有服务
cd deploy
docker-compose up -d

# 检查服务状态
docker-compose ps
```

#### 服务访问地址

| 服务 | 地址 | 默认账号 |
|------|------|----------|
| Jenkins | http://localhost/jenkins | admin/admin123 |
| SonarQube | http://localhost/sonar | admin/admin |
| Nginx | http://localhost | - |

### 2. Spring Boot项目配置

#### 2.1 添加安全插件到 pom.xml

将以下配置添加到您的Spring Boot项目的 `pom.xml` 文件中：

```xml
<properties>
    <!-- 安全扫描相关版本 -->
    <dependency-check-maven.version>8.4.0</dependency-check-maven.version>
    <spotbugs-maven-plugin.version>4.7.3.0</spotbugs-maven-plugin.version>
    <jacoco-maven-plugin.version>0.8.8</jacoco-maven-plugin.version>
    <sonar-maven-plugin.version>3.9.1.2184</sonar-maven-plugin.version>
</properties>

<build>
    <plugins>
        <!-- OWASP 依赖检查插件 -->
        <plugin>
            <groupId>org.owasp</groupId>
            <artifactId>dependency-check-maven</artifactId>
            <version>${dependency-check-maven.version}</version>
            <configuration>
                <failBuildOnCVSS>7</failBuildOnCVSS>
                <formats>
                    <format>HTML</format>
                    <format>JSON</format>
                    <format>XML</format>
                </formats>
                <suppressionFiles>
                    <suppressionFile>security/dependency-check-suppressions.xml</suppressionFile>
                </suppressionFiles>
                <autoUpdate>true</autoUpdate>
            </configuration>
            <executions>
                <execution>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>

        <!-- SpotBugs 静态分析插件 -->
        <plugin>
            <groupId>com.github.spotbugs</groupId>
            <artifactId>spotbugs-maven-plugin</artifactId>
            <version>${spotbugs-maven-plugin.version}</version>
            <configuration>
                <effort>Max</effort>
                <threshold>Low</threshold>
                <xmlOutput>true</xmlOutput>
                <failOnError>true</failOnError>
                <includeFilterFile>security/spotbugs-security-include.xml</includeFilterFile>
                <plugins>
                    <plugin>
                        <groupId>com.h3xstream.findsecbugs</groupId>
                        <artifactId>findsecbugs-plugin</artifactId>
                        <version>1.12.0</version>
                    </plugin>
                </plugins>
            </configuration>
        </plugin>

        <!-- JaCoCo 代码覆盖率插件 -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>${jacoco-maven-plugin.version}</version>
            <executions>
                <execution>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>

        <!-- SonarQube 插件 -->
        <plugin>
            <groupId>org.sonarsource.scanner.maven</groupId>
            <artifactId>sonar-maven-plugin</artifactId>
            <version>${sonar-maven-plugin.version}</version>
        </plugin>
    </plugins>
</build>

<!-- 安全相关依赖 -->
<dependencies>
    <!-- Spring Security -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <!-- Spring Security Test -->
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Actuator 安全监控 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

#### 2.2 创建安全配置目录

在项目根目录创建 `security/` 目录并添加配置文件：

```bash
mkdir -p security
```

**创建依赖检查抑制文件** `security/dependency-check-suppressions.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!-- 依赖检查抑制配置文件 -->
    <!-- 用于抑制已知的误报或已接受的风险 -->
    
    <!-- 示例：抑制测试依赖的漏洞 -->
    <!--
    <suppress>
        <notes><![CDATA[
            测试依赖，不会部署到生产环境
        ]]></notes>
        <packageUrl regex="true">^pkg:maven/junit/junit@.*$</packageUrl>
    </suppress>
    -->
</suppressions>
```

**创建SpotBugs安全规则文件** `security/spotbugs-security-include.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
    <!-- SpotBugs 安全规则配置 -->
    
    <!-- 包含所有安全相关的检查 -->
    <Match>
        <Bug category="SECURITY"/>
    </Match>
    
    <!-- SQL注入检查 -->
    <Match>
        <Bug pattern="SQL_INJECTION_SPRING_JDBC"/>
    </Match>
    
    <!-- XSS检查 -->
    <Match>
        <Bug pattern="XSS_REQUEST_PARAMETER_TO_SEND_ERROR"/>
    </Match>
    
    <!-- 路径遍历检查 -->
    <Match>
        <Bug pattern="PATH_TRAVERSAL_IN"/>
    </Match>
    
    <!-- 命令注入检查 -->
    <Match>
        <Bug pattern="COMMAND_INJECTION"/>
    </Match>
    
    <!-- 弱加密检查 -->
    <Match>
        <Bug pattern="WEAK_MESSAGE_DIGEST_MD5"/>
    </Match>
    
    <!-- 硬编码密码检查 -->
    <Match>
        <Bug pattern="HARD_CODE_PASSWORD"/>
    </Match>
</FindBugsFilter>
```

#### 2.3 配置 SonarQube 项目属性

在项目根目录创建 `sonar-project.properties`：

```properties
# SonarQube 项目配置
sonar.projectKey=your-spring-boot-project
sonar.projectName=Your Spring Boot Project
sonar.projectVersion=1.0.0

# 源码和测试目录
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes
sonar.java.libraries=target/dependency/*.jar

# 覆盖率报告
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml

# 排除文件
sonar.exclusions=**/*Application.java,**/config/**,**/dto/**
sonar.test.exclusions=**/test/**

# 编码
sonar.sourceEncoding=UTF-8

# 质量门禁
sonar.qualitygate.wait=true
```

### 3. Spring Boot 安全配置最佳实践

#### 3.1 Actuator 安全配置

在 `application.yml` 中配置Actuator端点：

```yaml
# Actuator 安全配置
management:
  endpoints:
    web:
      exposure:
        # 仅暴露必要的端点
        include: health,info,metrics
      base-path: /actuator
  endpoint:
    health:
      show-details: when-authorized
    info:
      enabled: true
  security:
    enabled: true

# Spring Security 配置
spring:
  security:
    user:
      name: ${ACTUATOR_USERNAME:admin}
      password: ${ACTUATOR_PASSWORD:admin123}
      roles: ACTUATOR
```

#### 3.2 数据库安全配置

```yaml
# 数据库连接配置
spring:
  datasource:
    url: ${DB_URL:jdbc:mysql://localhost:3306/mydb}
    username: ${DB_USERNAME:user}
    password: ${DB_PASSWORD:password}
    driver-class-name: com.mysql.cj.jdbc.Driver
    # 连接池配置
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
  
  # JPA 安全配置
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: false
        use_sql_comments: false
```

#### 3.3 HTTPS 和安全头配置

```yaml
# HTTPS 配置
server:
  port: 8443
  ssl:
    enabled: true
    key-store: ${SSL_KEYSTORE:classpath:keystore.p12}
    key-store-password: ${SSL_KEYSTORE_PASSWORD:changeit}
    key-store-type: PKCS12
    key-alias: ${SSL_KEY_ALIAS:tomcat}
```

**Spring Security 配置类**：

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * 配置HTTP安全策略
     * @param http HttpSecurity对象
     * @return SecurityFilterChain
     * @throws Exception 配置异常
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // CSRF 保护
            .csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()))
            
            // 安全头配置
            .headers(headers -> headers
                .frameOptions().deny()
                .contentTypeOptions().and()
                .xssProtection().and()
                .httpStrictTransportSecurity(hstsConfig -> hstsConfig
                    .maxAgeInSeconds(31536000)
                    .includeSubdomains(true)
                )
            )
            
            // 会话管理
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .maximumSessions(1)
                .maxSessionsPreventsLogin(false)
            )
            
            // 授权配置
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .requestMatchers("/actuator/**").hasRole("ACTUATOR")
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated()
            );
            
        return http.build();
    }

    /**
     * 配置密码编码器
     * @return BCryptPasswordEncoder
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    /**
     * 配置CORS策略
     * @return CorsConfigurationSource
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("https://*.yourdomain.com"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

### 4. Jenkins 流水线配置

#### 4.1 创建 Jenkinsfile

在项目根目录创建 `Jenkinsfile`：

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8'
        jdk 'JDK-11'
    }
    
    environment {
        SPRING_PROFILES_ACTIVE = 'security-scan'
        SONAR_PROJECT_KEY = "your-spring-boot-project"
        MAVEN_OPTS = '-Xmx2g -XX:+UseG1GC'
    }
    
    stages {
        stage('环境准备') {
            steps {
                echo '准备Spring Boot安全扫描环境...'
                sh 'java -version'
                sh 'mvn -version'
            }
        }
        
        stage('代码检出') {
            steps {
                checkout scm
                sh 'ls -la'
            }
        }
        
        stage('编译构建') {
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }
        
        stage('安全扫描') {
            parallel {
                stage('静态代码分析 (SAST)') {
                    steps {
                        script {
                            def scannerHome = tool 'SonarQube Scanner'
                            withSonarQubeEnv('SonarQube') {
                                sh """
                                    mvn sonar:sonar \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                    -Dsonar.qualitygate.wait=true
                                """
                            }
                        }
                    }
                }
                
                stage('依赖漏洞扫描 (SCA)') {
                    steps {
                        sh """
                            mvn org.owasp:dependency-check-maven:check \
                            -DfailBuildOnCVSS=7 \
                            -Dformats=HTML,JSON,XML
                        """
                    }
                }
                
                stage('SpotBugs 安全检查') {
                    steps {
                        sh 'mvn com.github.spotbugs:spotbugs-maven-plugin:check'
                    }
                }
            }
        }
        
        stage('安全测试') {
            steps {
                sh """
                    # 运行安全相关的单元测试
                    mvn test -Dtest=**/*SecurityTest
                    
                    # 生成测试覆盖率报告
                    mvn jacoco:report
                """
            }
        }
        
        stage('质量门禁') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "质量门禁失败: ${qg.status}"
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // 发布测试报告
            publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
            
            // 发布覆盖率报告
            publishCoverage adapters: [jacocoAdapter('target/site/jacoco/jacoco.xml')], 
                           sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
            
            // 发布依赖检查报告
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target',
                reportFiles: 'dependency-check-report.html',
                reportName: '依赖漏洞扫描报告'
            ])
            
            // 发布SpotBugs报告
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target',
                reportFiles: 'spotbugsXml.html',
                reportName: 'SpotBugs安全检查报告'
            ])
        }
        
        failure {
            emailext (
                subject: "Spring Boot安全扫描失败: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "构建失败，请检查安全扫描结果。\n\n构建URL: ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

### 5. 本地安全检查

#### 5.1 运行安全检查脚本

```bash
# 下载并运行Spring Boot安全检查脚本
curl -O https://raw.githubusercontent.com/your-repo/eap-security-tool/main/01-security-pipeline/scripts/spring-boot-security-check.sh
chmod +x spring-boot-security-check.sh
./spring-boot-security-check.sh
```

#### 5.2 手动执行安全扫描

```bash
# 1. 依赖漏洞扫描
mvn org.owasp:dependency-check-maven:check

# 2. SpotBugs 安全检查
mvn com.github.spotbugs:spotbugs-maven-plugin:check

# 3. SonarQube 本地分析
mvn sonar:sonar -Dsonar.host.url=http://localhost:9000

# 4. 生成测试覆盖率报告
mvn clean test jacoco:report

# 5. 查看报告
open target/dependency-check-report.html
open target/spotbugsXml.html
open target/site/jacoco/index.html
```

### 6. 容器化部署安全

#### 6.1 安全的 Dockerfile

```dockerfile
# 使用官方OpenJDK基础镜像
FROM openjdk:17-jre-slim

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 设置工作目录
WORKDIR /app

# 复制应用文件
COPY target/*.jar app.jar

# 更改文件所有者
RUN chown -R appuser:appuser /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动应用
ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "app.jar"]
```

#### 6.2 容器安全扫描

```bash
# 构建镜像
docker build -t your-spring-boot-app:latest .

# 使用Trivy扫描镜像
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/workspace aquasec/trivy:latest \
    image --format json --output /workspace/trivy-report.json \
    your-spring-boot-app:latest

# 查看扫描结果
cat trivy-report.json | jq '.Results[].Vulnerabilities[] | select(.Severity == "HIGH" or .Severity == "CRITICAL")'
```

### 7. 监控和告警

#### 7.1 应用监控配置

```yaml
# application-prod.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true
    metrics:
      enabled: true

# 日志配置
logging:
  level:
    org.springframework.security: INFO
    org.springframework.web.filter.CommonsRequestLoggingFilter: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/application.log
    max-size: 10MB
    max-history: 30
```

#### 7.2 安全事件监控

```java
@Component
@Slf4j
public class SecurityEventListener {

    /**
     * 监听认证成功事件
     * @param event 认证成功事件
     */
    @EventListener
    public void handleAuthenticationSuccess(AuthenticationSuccessEvent event) {
        String username = event.getAuthentication().getName();
        String clientIp = getClientIp();
        log.info("用户登录成功: username={}, clientIp={}", username, clientIp);
    }

    /**
     * 监听认证失败事件
     * @param event 认证失败事件
     */
    @EventListener
    public void handleAuthenticationFailure(AbstractAuthenticationFailureEvent event) {
        String username = event.getAuthentication().getName();
        String clientIp = getClientIp();
        String reason = event.getException().getMessage();
        log.warn("用户登录失败: username={}, clientIp={}, reason={}", username, clientIp, reason);
    }

    /**
     * 监听访问拒绝事件
     * @param event 访问拒绝事件
     */
    @EventListener
    public void handleAccessDenied(AuthorizationDeniedEvent event) {
        String username = event.getAuthentication().getName();
        String resource = event.getAuthorizationDecision().toString();
        log.warn("访问被拒绝: username={}, resource={}", username, resource);
    }

    /**
     * 获取客户端IP地址
     * @return 客户端IP
     */
    private String getClientIp() {
        // 实现获取客户端IP的逻辑
        return "unknown";
    }
}
```

### 8. 故障排查

#### 8.1 常见问题及解决方案

**问题1: SonarQube 连接失败**
```bash
# 检查SonarQube服务状态
docker-compose ps sonarqube

# 查看SonarQube日志
docker-compose logs sonarqube

# 重启SonarQube服务
docker-compose restart sonarqube
```

**问题2: 依赖检查数据库更新失败**
```bash
# 手动更新依赖检查数据库
mvn org.owasp:dependency-check-maven:update-only

# 清理并重新检查
mvn org.owasp:dependency-check-maven:purge
mvn org.owasp:dependency-check-maven:check
```

**问题3: Jenkins 构建失败**
```bash
# 检查Jenkins日志
docker-compose logs jenkins

# 检查Jenkins工作空间权限
docker exec -it security-pipeline-jenkins ls -la /var/jenkins_home/workspace/

# 重启Jenkins服务
docker-compose restart jenkins
```

#### 8.2 性能优化建议

1. **Maven 构建优化**：
   ```xml
   <properties>
       <maven.compiler.source>11</maven.compiler.source>
       <maven.compiler.target>11</maven.compiler.target>
       <maven.compiler.release>11</maven.compiler.release>
       <maven.test.skip>false</maven.test.skip>
       <skipITs>false</skipITs>
   </properties>
   ```

2. **SonarQube 分析优化**：
   ```properties
   # 排除不必要的文件
   sonar.exclusions=**/target/**,**/node_modules/**,**/*.min.js
   
   # 限制分析范围
   sonar.sources=src/main/java
   sonar.tests=src/test/java
   ```

3. **依赖检查优化**：
   ```xml
   <configuration>
       <skipProvidedScope>true</skipProvidedScope>
       <skipRuntimeScope>false</skipRuntimeScope>
       <skipTestScope>true</skipTestScope>
   </configuration>
   ```

### 9. 最佳实践总结

#### 9.1 安全开发规范

- ✅ **输入验证**: 对所有用户输入进行验证和清理
- ✅ **输出编码**: 防止XSS攻击，对输出进行适当编码
- ✅ **参数化查询**: 使用PreparedStatement防止SQL注入
- ✅ **最小权限原则**: 用户和服务只获得必要的最小权限
- ✅ **安全配置**: 禁用不必要的功能和端点
- ✅ **错误处理**: 不在错误信息中暴露敏感信息
- ✅ **日志记录**: 记录安全相关事件，但不记录敏感数据

#### 9.2 持续安全改进

1. **定期更新依赖**: 及时更新第三方库和框架版本
2. **安全培训**: 定期进行开发团队安全培训
3. **代码审查**: 将安全检查纳入代码审查流程
4. **渗透测试**: 定期进行安全渗透测试
5. **监控告警**: 建立完善的安全监控和告警机制

#### 9.3 合规性检查

- 🔒 **数据保护**: 符合GDPR、CCPA等数据保护法规
- 🔒 **行业标准**: 遵循OWASP Top 10、CWE等安全标准
- 🔒 **审计日志**: 保留完整的安全审计日志
- 🔒 **访问控制**: 实施基于角色的访问控制(RBAC)

## 📞 支持与反馈

如果您在使用过程中遇到问题或有改进建议，请通过以下方式联系我们：

- 📧 邮箱: security-team@yourcompany.com
- 🐛 问题反馈: [GitHub Issues](https://github.com/your-repo/eap-security-tool/issues)
- 📖 文档更新: [Wiki](https://github.com/your-repo/eap-security-tool/wiki)

---

**最后更新**: 2024年1月
**版本**: v1.0.0
**维护团队**: DevSecOps安全团队