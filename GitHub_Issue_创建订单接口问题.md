# 🐛 Bug Report: 创建订单接口因JWT认证配置导致数据库插入失败

## 📋 问题描述
交易服务(hm-trade-service)的创建订单接口 `POST /orders` 返回HTTP 500错误，无法正常创建订单。

## 🔍 复现步骤
1. 启动所有相关微服务 (user-service, product-service, cart-service, trade-service)
2. 获取有效的JWT token
3. 调用创建订单接口：
   ```bash
   curl -X POST "http://127.0.0.1:8084/orders" \
     -H "Content-Type: application/json" \
     -H "authorization: <valid-jwt-token>" \
     -d '{
       "addressId": 1,
       "paymentType": 1,
       "details": [{"itemId": 317578, "num": 1}]
     }'
   ```

## ❌ 预期结果 vs 实际结果
- **预期**: 返回新创建的订单ID
- **实际**: 返回HTTP 500错误

## 📝 错误日志
```
java.sql.SQLException: Field 'user_id' doesn't have a default value
### SQL: INSERT INTO `order` ( id, total_fee, payment_type, status ) VALUES ( ?, ?, ?, ? )
### Cause: java.sql.SQLException: Field 'user_id' doesn't have a default value
```

## 🔧 根本原因
JWT认证配置问题导致用户上下文丢失：

1. **问题代码位置**: `OrderServiceImpl.java:67`
   ```java
   order.setUserId(UserContext.getUser()); // UserContext.getUser() 返回 null
   ```

2. **配置冲突**: 在 `MvcConfig.java` 中为了让支付服务能够调用标记订单已支付接口，错误地排除了所有订单相关路径的JWT认证：
   ```java
   registration.excludePathPatterns("/orders/*"); // 这导致创建订单接口也无需认证
   ```

## 💡 解决方案
需要精确控制哪些接口需要认证，哪些不需要：

### 方案A: 为支付服务专门创建无需认证的接口
```java
@PutMapping("/{orderId}/pay")  // 支付服务专用，无需认证
public void markOrderPaySuccessForPayment(@PathVariable("orderId") Long orderId)
```

### 方案B: 在MvcConfig中精确配置排除路径
```java
registration.excludePathPatterns("/orders/*/pay"); // 只排除支付相关接口
```

## 🌍 环境信息
- **Spring Boot**: 2.7.12
- **Spring Cloud**: 2021.0.3
- **Spring Cloud Alibaba**: 2021.0.4.0
- **数据库**: MySQL 8.0.23
- **服务发现**: Nacos 2.0.3

## 📁 相关文件
- `hmall/hm-trade-service/src/main/java/com/hmall/trade/config/MvcConfig.java`
- `hmall/hm-trade-service/src/main/java/com/hmall/trade/service/impl/OrderServiceImpl.java`
- `hmall/hm-trade-service/src/main/java/com/hmall/trade/controller/OrderController.java`
- `hmall/hm-pay-service/src/main/java/com/hmall/pay/client/TradeClient.java`

## 🏷️ 标签
`bug` `authentication` `microservices` `spring-boot` `jwt` `database`

## ⚡ 优先级
**High** - 影响核心业务功能（订单创建）

## 📊 影响范围
- 用户无法创建订单
- 影响整个电商流程的核心功能
- 阻塞订单相关的集成测试

## 🔄 当前状态
- [x] 问题已识别和分析
- [x] 解决方案已设计
- [ ] 解决方案实施中
- [ ] 测试验证
- [ ] 问题关闭

