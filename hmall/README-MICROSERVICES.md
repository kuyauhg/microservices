# 黑马商城微服务重构项目

## 项目概述

本项目将原有的单体电商应用重构为微服务架构，主要拆分出以下服务：

- **hm-product-service (商品管理服务)** - 端口: 8081
- **hm-cart-service (购物车服务)** - 端口: 8082  
- **hm-service (主服务)** - 端口: 8080，包含订单管理、用户管理、支付等功能

## 技术栈

- **Spring Boot 2.7.12** - 主框架
- **Spring Cloud 2021.0.3** - 微服务框架
- **Spring Cloud Alibaba 2021.0.4.0** - 阿里巴巴云组件
- **MyBatis Plus 3.4.3** - ORM框架
- **Nacos** - 服务发现与配置管理
- **OpenFeign** - 服务间通信
- **MySQL 8.0.23** - 数据库

## 项目结构

```
hmall/
├── hm-common/              # 公共模块
├── hm-product-service/     # 商品管理服务
├── hm-cart-service/        # 购物车服务
├── hm-service/             # 主服务
├── start-services.sh       # 启动所有服务脚本
├── stop-services.sh        # 停止所有服务脚本
├── run-tests.sh           # 运行测试脚本
└── README-MICROSERVICES.md # 本文档
```

## 数据库配置

项目使用三个独立的数据库：

- **hmall** - 主服务数据库（订单、用户、支付等）
- **hm-item** - 商品服务数据库
- **hm-cart** - 购物车服务数据库

请确保这三个数据库已创建并导入相应的SQL脚本。

## 环境要求

- Java 8 或更高版本
- Maven 3.6 或更高版本
- MySQL 8.0.23 或更高版本
- Nacos 服务器

## 快速开始

### 1. 环境准备

确保以下服务正在运行：
- MySQL 数据库服务
- Nacos 服务器 (默认端口: 8848)

### 2. 配置文件

在运行服务之前，请确保各服务的 `application-local.yaml` 配置文件中的数据库连接信息正确：

```yaml
hm:
  db:
    host: localhost  # 数据库主机
    pw: 123456      # 数据库密码
  nacos:
    addr: localhost:8848    # Nacos地址
    namespace: dev          # Nacos命名空间
```

### 3. 启动服务

使用提供的脚本启动所有服务：

```bash
./start-services.sh
```

该脚本会按顺序启动：
1. 商品管理服务 (端口: 8081)
2. 购物车服务 (端口: 8082)
3. 主服务 (端口: 8080)

### 4. 停止服务

```bash
./stop-services.sh
```

### 5. 运行测试

```bash
./run-tests.sh
```

该脚本会运行所有微服务的测试用例，并生成测试报告。

## 服务接口

### 商品管理服务 (hm-product-service:8081)

- `GET /items` - 根据ID批量查询商品
- `GET /items/{id}` - 根据ID查询单个商品
- `GET /items/page` - 分页查询商品
- `PUT /items/stock/deduct` - 扣减库存

### 购物车服务 (hm-cart-service:8082)

- `POST /carts` - 添加商品到购物车
- `GET /carts` - 查询购物车列表
- `PUT /carts` - 更新购物车
- `DELETE /carts/{id}` - 删除购物车商品
- `DELETE /carts` - 批量删除购物车商品

### 主服务 (hm-service:8080)

- 订单管理相关接口
- 用户管理相关接口
- 支付相关接口

## 服务间通信

项目使用 OpenFeign 实现服务间通信：

### ItemClient (商品服务客户端)
```java
@FeignClient(name = "hm-product-service")
public interface ItemClient {
    @GetMapping("/items")
    List<ItemDTO> queryItemByIds(@RequestParam("ids") Collection<Long> ids);
    
    @PutMapping("/items/stock/deduct")
    void deductStock(@RequestBody List<OrderDetailDTO> items);
}
```

### CartClient (购物车服务客户端)
```java
@FeignClient(name = "hm-cart-service")
public interface CartClient {
    @DeleteMapping("/carts")
    void deleteCartItemByIds(@RequestParam("ids") Collection<Long> ids);
}
```

## 测试说明

项目包含以下测试类：

### 1. 商品服务测试
- `ItemServiceTest` - 测试商品服务的核心功能
  - 批量查询商品
  - 库存扣减
  - 边界条件测试

### 2. 购物车服务测试
- `CartServiceTest` - 测试购物车服务的核心功能
  - 添加商品到购物车
  - 查询购物车列表
  - 删除购物车商品
  - 重复添加商品测试

### 3. 微服务集成测试
- `MicroserviceIntegrationTest` - 测试服务间通信
  - Feign客户端调用测试
  - 服务发现测试
  - 错误处理测试
  - 端到端业务流程测试

## 监控和日志

### 日志文件位置
- 商品服务日志: `logs/product-service.log`
- 购物车服务日志: `logs/cart-service.log`
- 主服务日志: `logs/main-service.log`

### 健康检查
各服务都提供了健康检查端点：
- 商品服务: `http://localhost:8081/actuator/health`
- 购物车服务: `http://localhost:8082/actuator/health`
- 主服务: `http://localhost:8080/actuator/health`

## 故障排查

### 常见问题

1. **服务启动失败**
   - 检查数据库连接配置
   - 确认Nacos服务器正在运行
   - 查看对应的日志文件

2. **服务间调用失败**
   - 检查服务是否都已启动
   - 确认Nacos中服务注册状态
   - 检查网络连接

3. **数据库连接问题**
   - 确认数据库服务正在运行
   - 检查数据库用户名密码
   - 确认数据库已创建并导入数据

### 调试技巧

1. 查看服务注册状态：访问 Nacos 控制台 `http://localhost:8848/nacos`
2. 查看服务日志：`tail -f logs/服务名.log`
3. 检查端口占用：`lsof -i :端口号`

## 重构总结

本次微服务重构实现了以下目标：

✅ **服务拆分** - 将单体应用拆分为独立的微服务
✅ **数据库分离** - 每个服务使用独立的数据库
✅ **服务发现** - 使用Nacos实现服务注册与发现
✅ **服务通信** - 使用Feign实现服务间HTTP调用
✅ **配置管理** - 独立的配置文件管理
✅ **测试覆盖** - 完整的单元测试和集成测试

## 后续优化建议

1. **API网关** - 添加统一的API网关
2. **配置中心** - 使用Nacos配置中心统一管理配置
3. **链路追踪** - 添加分布式链路追踪
4. **熔断降级** - 添加Hystrix或Sentinel熔断机制
5. **容器化部署** - 使用Docker容器化部署
6. **监控告警** - 添加Prometheus + Grafana监控

## 联系信息

如有问题，请查看日志文件或联系开发团队。
