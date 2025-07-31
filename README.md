# HMall 微服务电商项目

## 📖 项目简介

HMall是一个基于Spring Cloud微服务架构的电商平台，从单体应用重构为微服务架构。项目采用了现代化的技术栈，实现了用户管理、商品管理、购物车、订单管理、支付等核心电商功能。

## 🏗️ 架构概览

### 微服务架构
```
                    ┌─────────────────┐
                    │   公共模块       │
                    │   hm-common     │
                    │  (依赖库)        │
                    └─────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   用户服务       │    │   商品服务       │    │   购物车服务     │
│ hm-user-service │    │hm-product-service│    │ hm-cart-service │
│    Port: 8083   │    │    Port: 8081   │    │    Port: 8082   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
            │                │                │
            └────────────────┼────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
┌─────────────────┐    ┌─────────────────┐    │
│   交易服务       │    │   支付服务       │    │
│ hm-trade-service│    │ hm-pay-service  │    │
│    Port: 8084   │    │    Port: 8085   │    │
└─────────────────┘    └─────────────────┘    │
                                              │
                    ┌─────────────────┐       │
                    │   服务发现       │       │
                    │     Nacos       │◄──────┘
                    │   Port: 8848    │
                    └─────────────────┘
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
- **Knife4j**: API文档生成

### 开发工具
- **JDK**: 11+
- **IDE**: IntelliJ IDEA / Eclipse
- **API文档**: Knife4j (Swagger增强版)
- **版本控制**: Git

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
创建以下数据库并导入对应的SQL文件：
- `hm-user` (用户服务) - 导入 `hm-user.sql`
- `hm-item` (商品服务) - 导入 `hm-item.sql`
- `hm-cart` (购物车服务) - 导入 `hm-cart.sql`
- `hm-trade` (交易服务) - 导入 `hm-trade.sql`
- `hm-pay` (支付服务) - 导入 `hm-pay.sql`

### 3. 启动Nacos
```bash
# 下载并启动Nacos
sh startup.sh -m standalone
```
访问: http://localhost:8848/nacos (用户名/密码: nacos/nacos)

### 4. 启动微服务

#### 方式一：使用启动脚本（推荐）
```bash
cd hmall
chmod +x start-services.sh
./start-services.sh
```

#### 方式二：手动启动服务
按以下顺序启动服务：

```bash
# 1. 启动用户服务
cd hmall/hm-user-service
mvn spring-boot:run -Dspring-boot.run.profiles=local

# 2. 启动商品服务
cd hmall/hm-product-service
mvn spring-boot:run -Dspring-boot.run.profiles=local

# 3. 启动购物车服务
cd hmall/hm-cart-service
mvn spring-boot:run -Dspring-boot.run.profiles=local

# 4. 启动交易服务
cd hmall/hm-trade-service
mvn spring-boot:run -Dspring-boot.run.profiles=local

# 5. 启动支付服务
cd hmall/hm-pay-service
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

#### 停止所有服务
```bash
cd hmall
./stop-services.sh
```

## 📋 服务端口

| 服务名称 | 端口 | 描述 | API文档 |
|---------|------|------|---------|
| **hm-gateway-service** | **8080** | **API网关服务** | **http://localhost:8080/actuator** |
| hm-user-service | 8083 | 用户管理服务 | http://localhost:8083/doc.html |
| hm-product-service | 8081 | 商品管理服务 | http://localhost:8081/doc.html |
| hm-cart-service | 8082 | 购物车服务 | http://localhost:8082/doc.html |
| hm-trade-service | 8084 | 交易订单服务 | http://localhost:8084/doc.html |
| hm-pay-service | 8085 | 支付服务 | http://localhost:8085/doc.html |
| Nacos | 8848 | 服务发现与配置中心 | http://localhost:8848/nacos |

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

### 方式一：使用API文档界面（推荐）
启动服务后，访问各服务的API文档进行测试：
- 用户服务: http://localhost:8083/doc.html
- 商品服务: http://localhost:8081/doc.html
- 购物车服务: http://localhost:8082/doc.html
- 交易服务: http://localhost:8084/doc.html
- 支付服务: http://localhost:8085/doc.html

### 方式二：使用curl命令

#### 用户登录
```bash
curl -X POST "http://127.0.0.1:8083/users/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "jack", "password": "123"}'
```

#### 查询商品列表
```bash
curl -X GET "http://127.0.0.1:8081/items/page?pageNo=1&pageSize=10"
```

#### 添加商品到购物车
```bash
curl -X POST "http://127.0.0.1:8082/carts" \
  -H "Content-Type: application/json" \
  -H "authorization: <JWT-TOKEN>" \
  -d '{"itemId": 317578, "num": 1}'
```

#### 创建订单
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

### 方式三：运行集成测试
```bash
cd hmall
./run-tests.sh
```

## � 项目结构

```
hmall/
├── hm-common/              # 公共模块 - 提供通用工具类和配置
│   ├── src/main/java/com/hmall/common/
│   │   ├── domain/         # 通用实体类 (R, PageQuery, PageDTO等)
│   │   ├── utils/          # 工具类 (BeanUtils, CollUtils, JwtTool等)
│   │   ├── config/         # 通用配置类
│   │   └── advice/         # 全局异常处理
│   └── pom.xml
├── hm-gateway-service/     # API网关服务 - 统一入口、路由、认证、限流
├── hm-user-service/        # 用户服务 - 用户管理、认证
├── hm-product-service/     # 商品服务 - 商品管理、库存
├── hm-cart-service/        # 购物车服务 - 购物车管理
├── hm-trade-service/       # 交易服务 - 订单管理
├── hm-pay-service/         # 支付服务 - 支付处理
├── start-services.sh       # 启动所有服务脚本
├── start-gateway.sh        # 单独启动网关服务脚本
├── stop-services.sh        # 停止所有服务脚本
├── run-tests.sh           # 运行测试脚本
└── pom.xml                # 父级POM文件
```

## 🔧 核心功能

### 用户服务 (hm-user-service)
- 用户注册、登录
- JWT令牌生成和验证
- 用户信息管理
- 余额管理

### 商品服务 (hm-product-service)
- 商品信息管理
- 商品分页查询
- 库存管理
- 库存扣减

### 购物车服务 (hm-cart-service)
- 购物车商品添加
- 购物车列表查询
- 购物车商品更新/删除
- 批量操作

### 交易服务 (hm-trade-service)
- 订单创建
- 订单状态管理
- 订单查询
- 与其他服务集成

### 支付服务 (hm-pay-service)
- 支付单生成
- 余额支付
- 支付状态管理
- 支付回调处理

## �🐛 已知问题

请查看 [GitHub Issues](https://github.com/your-username/hmall-microservices/issues) 了解当前已知问题和解决进度。

## 🚨 常见问题

### 1. 服务启动失败
- 检查Java版本是否为11+
- 确认MySQL数据库已启动并创建相应数据库
- 检查Nacos是否正常运行
- 查看对应服务的日志文件

### 2. 服务间调用失败
- 确认所有服务都已注册到Nacos
- 检查服务发现配置是否正确
- 验证网络连接和端口占用情况

### 3. 数据库连接问题
- 检查数据库连接配置
- 确认数据库用户权限
- 验证数据库表是否正确创建

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
