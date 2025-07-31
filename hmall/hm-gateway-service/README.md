# 黑马商城API网关服务

## 概述

hm-gateway-service是黑马商城的API网关服务，基于Spring Cloud Gateway构建，提供统一的API入口、路由转发、认证授权、限流熔断等功能。

## 核心功能

### 1. 路由转发
- **用户服务路由**: `/users/**`, `/addresses/**` → `hm-user-service`
- **商品服务路由**: `/items/**` → `hm-product-service`  
- **购物车服务路由**: `/carts/**` → `hm-cart-service`
- **交易服务路由**: `/orders/**` → `hm-trade-service`
- **支付服务路由**: `/pay-orders/**` → `hm-pay-service`

### 2. 负载均衡
- 基于Ribbon实现客户端负载均衡
- 支持多种负载均衡策略（轮询、随机、权重等）
- 自动服务发现和健康检查

### 3. 认证授权
- JWT Token统一验证
- 支持白名单路径配置
- 自动传递用户信息给下游服务

### 4. 限流熔断
- **Redis限流**: 基于令牌桶算法的分布式限流
- **Sentinel熔断**: 服务熔断和降级保护
- **多维度限流**: 支持IP、用户、路径等多种限流策略

### 5. 跨域处理
- 统一CORS配置
- 支持预检请求
- 可配置允许的域名、方法、头部

### 6. 日志监控
- 请求响应日志记录
- 性能指标监控
- 健康检查端点
- Prometheus指标导出

## 技术栈

- **Spring Boot**: 2.7.12
- **Spring Cloud Gateway**: 2021.0.3
- **Spring Cloud Alibaba**: 2021.0.4.0
- **Nacos**: 服务发现与配置中心
- **Redis**: 分布式限流
- **Sentinel**: 熔断降级
- **Micrometer**: 指标监控

## 配置说明

### 端口配置
- **服务端口**: 8080
- **管理端口**: 8080/actuator

### 环境变量
```yaml
hm:
  nacos:
    addr: 127.0.0.1:8848    # Nacos地址
    namespace: dev          # 命名空间
  redis:
    host: 127.0.0.1        # Redis地址
    port: 6379             # Redis端口
    password:              # Redis密码
```

### 限流配置
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: hm-user-service
          filters:
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 10    # 令牌补充速率
                redis-rate-limiter.burstCapacity: 20    # 令牌桶容量
                key-resolver: "#{@ipKeyResolver}"       # 限流Key解析器
```

### 认证配置
```yaml
hm:
  auth:
    excludePaths:           # 白名单路径
      - /users/login
      - /users/register
      - /items/**
      - /actuator/**
```

## 启动方式

### 1. 前置条件
确保以下服务已启动：
- MySQL数据库
- Nacos服务器 (8848端口)
- Redis服务器 (6379端口)

### 2. 本地启动
```bash
cd hmall/hm-gateway-service
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

### 3. 使用启动脚本
```bash
cd hmall
./start-services.sh
```

## API文档

### 健康检查
```bash
# 基础健康检查
GET http://localhost:8080/actuator/health

# 详细健康信息
GET http://localhost:8080/actuator/health/gateway
```

### 路由信息
```bash
# 查看所有路由
GET http://localhost:8080/actuator/gateway/routes

# 查看特定路由
GET http://localhost:8080/actuator/gateway/routes/{route_id}
```

### 监控指标
```bash
# Prometheus指标
GET http://localhost:8080/actuator/prometheus

# 应用指标
GET http://localhost:8080/actuator/metrics
```

## 测试验证

### 1. 路由测试
```bash
# 测试用户服务路由
curl -X GET "http://localhost:8080/users/1"

# 测试商品服务路由  
curl -X GET "http://localhost:8080/items/page?pageNo=1&pageSize=10"

# 测试购物车服务路由
curl -X GET "http://localhost:8080/carts" \
  -H "authorization: <JWT-TOKEN>"
```

### 2. 认证测试
```bash
# 无Token访问受保护资源（应返回401）
curl -X GET "http://localhost:8080/carts"

# 有效Token访问
curl -X GET "http://localhost:8080/carts" \
  -H "authorization: <VALID-JWT-TOKEN>"
```

### 3. 限流测试
```bash
# 快速发送多个请求测试限流
for i in {1..30}; do
  curl -X GET "http://localhost:8080/items/1" &
done
```

## 故障排查

### 1. 常见问题

**服务启动失败**
- 检查Nacos连接配置
- 确认Redis服务状态
- 查看启动日志：`logs/hm-gateway-service.log`

**路由不生效**
- 检查目标服务是否已注册到Nacos
- 验证路由配置是否正确
- 查看网关日志中的路由信息

**认证失败**
- 检查JWT配置是否正确
- 验证Token格式和有效性
- 确认白名单路径配置

**限流异常**
- 检查Redis连接状态
- 验证限流配置参数
- 查看Sentinel控制台

### 2. 日志查看
```bash
# 查看网关日志
tail -f hmall/logs/hm-gateway-service/hm-gateway-service.log

# 查看错误日志
grep "ERROR" hmall/logs/hm-gateway-service/hm-gateway-service.log
```

### 3. 监控检查
```bash
# 检查服务健康状态
curl http://localhost:8080/actuator/health

# 查看路由状态
curl http://localhost:8080/actuator/gateway/routes
```

## 性能优化

### 1. 连接池配置
```yaml
spring:
  redis:
    lettuce:
      pool:
        max-active: 16      # 最大连接数
        max-idle: 8         # 最大空闲连接
        min-idle: 0         # 最小空闲连接
```

### 2. 超时配置
```yaml
spring:
  cloud:
    gateway:
      httpclient:
        connect-timeout: 3000    # 连接超时
        response-timeout: 10s    # 响应超时
```

### 3. JVM参数
```bash
-Xms512m -Xmx1024m -XX:+UseG1GC
```

## 安全建议

1. **生产环境配置**
   - 修改默认JWT密钥
   - 配置具体的CORS域名
   - 启用HTTPS

2. **限流策略**
   - 根据业务场景调整限流参数
   - 配置不同服务的差异化限流
   - 监控限流效果

3. **日志安全**
   - 避免记录敏感信息
   - 定期清理日志文件
   - 配置日志级别

## 联系信息

如有问题，请查看日志文件或联系开发团队。
