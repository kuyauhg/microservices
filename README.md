# HMall 微服务电商项目

## 📖 项目简介

HMall是一个基于Spring Cloud微服务架构的电商平台，从单体应用重构为微服务架构。项目采用了现代化的技术栈，实现了用户管理、商品管理、购物车、订单管理、支付等核心电商功能。

## 🏗️ 架构概览

### 微服务架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   用户服务       │    │   商品服务       │    │   购物车服务     │
│ hm-user-service │    │hm-product-service│    │ hm-cart-service │
│    Port: 8083   │    │    Port: 8081   │    │    Port: 8082   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┐    ┌─────────────────┐
         │   交易服务       │    │   支付服务       │
         │ hm-trade-service│    │ hm-pay-service  │
         │    Port: 8084   │    │    Port: 8085   │
         └─────────────────┘    └─────────────────┘
                                 │
         ┌─────────────────┐    ┌─────────────────┐
         │   主服务         │    │   公共模块       │
         │   hm-service    │    │   hm-common     │
         │    Port: 8080   │    │                 │
         └─────────────────┘    └─────────────────┘
```

## 🛠️ 技术栈

### 后端技术
- **Spring Boot**: 2.7.12
- **Spring Cloud**: 2021.0.3
- **Spring Cloud Alibaba**: 2021.0.4.0
- **Nacos**: 2.0.3 (服务发现与配置管理)
- **OpenFeign**: 服务间通信
- **MyBatis Plus**: 3.4.3 (ORM框架)
- **MySQL**: 8.0.23
- **JWT**: 身份认证
- **Maven**: 项目构建

### 开发工具
- **JDK**: 11+
- **IDE**: IntelliJ IDEA / Eclipse
- **API文档**: Swagger/OpenAPI

## 🚀 快速开始

### 环境要求
- JDK 11+
- Maven 3.6+
- MySQL 8.0+
- Nacos 2.0.3

### 1. 克隆项目
```bash
git clone https://github.com/your-username/hmall-microservices.git
cd hmall-microservices
```

### 2. 数据库配置
创建以下数据库：
- `hm-user` (用户服务)
- `hm-product` (商品服务) 
- `hm-cart` (购物车服务)
- `hm-trade` (交易服务)
- `hm-pay` (支付服务)

### 3. 启动Nacos
```bash
# 下载并启动Nacos
sh startup.sh -m standalone
```
访问: http://localhost:8848/nacos (用户名/密码: nacos/nacos)

### 4. 启动微服务
按以下顺序启动服务：

```bash
# 1. 启动用户服务
cd hmall/hm-user-service
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang.invoke=ALL-UNNAMED"

# 2. 启动商品服务
cd hmall/hm-product-service  
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang.invoke=ALL-UNNAMED"

# 3. 启动购物车服务
cd hmall/hm-cart-service
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang.invoke=ALL-UNNAMED"

# 4. 启动交易服务
cd hmall/hm-trade-service
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang.invoke=ALL-UNNAMED"

# 5. 启动支付服务
cd hmall/hm-pay-service
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang.invoke=ALL-UNNAMED"
```

## 📋 服务端口

| 服务名称 | 端口 | 描述 |
|---------|------|------|
| hm-user-service | 8083 | 用户管理服务 |
| hm-product-service | 8081 | 商品管理服务 |
| hm-cart-service | 8082 | 购物车服务 |
| hm-trade-service | 8084 | 交易订单服务 |
| hm-pay-service | 8085 | 支付服务 |
| hm-service | 8080 | 主服务(遗留) |

## 🔧 配置说明

### 数据库配置
```yaml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3307/数据库名?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
    username: root
    password: 123456
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### Nacos配置
```yaml
spring:
  cloud:
    nacos:
      server-addr: 127.0.0.1:8848
      discovery:
        namespace: dev
```

## 🧪 API测试

### 用户登录
```bash
curl -X POST "http://127.0.0.1:8083/users/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "jack", "password": "123"}'
```

### 创建订单
```bash
curl -X POST "http://127.0.0.1:8084/orders" \
  -H "Content-Type: application/json" \
  -H "authorization: <JWT-TOKEN>" \
  -d '{
    "addressId": 1,
    "paymentType": 1,
    "details": [{"itemId": 317578, "num": 1}]
  }'
```

## 🐛 已知问题

请查看 [GitHub Issues](https://github.com/your-username/hmall-microservices/issues) 了解当前已知问题和解决进度。

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 [Issue](https://github.com/your-username/hmall-microservices/issues)
- 发送邮件至: your.email@example.com

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！
