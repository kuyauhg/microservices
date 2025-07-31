#!/bin/bash

# 微服务启动脚本
# 用于启动所有微服务进行测试

echo "开始启动微服务..."

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java环境，请先安装Java 11或更高版本"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven环境，请先安装Maven"
    exit 1
fi

# 设置工作目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "当前工作目录: $SCRIPT_DIR"

# 编译所有模块
echo "正在编译项目..."
mvn clean compile -DskipTests

if [ $? -ne 0 ]; then
    echo "错误: 项目编译失败"
    exit 1
fi

echo "编译完成"

# 创建日志目录
mkdir -p logs

# 启动用户服务 (端口: 8083)
echo "启动用户服务 (hm-user-service) - 端口: 8083"
cd hm-user-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/user-service.log 2>&1 &
USER_PID=$!
echo "用户服务 PID: $USER_PID"
cd ..

# 等待用户服务启动
sleep 10

# 启动商品服务 (端口: 8081)
echo "启动商品管理服务 (hm-product-service) - 端口: 8081"
cd hm-product-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/product-service.log 2>&1 &
PRODUCT_PID=$!
echo "商品服务 PID: $PRODUCT_PID"
cd ..

# 等待商品服务启动
sleep 10

# 启动购物车服务 (端口: 8082)
echo "启动购物车服务 (hm-cart-service) - 端口: 8082"
cd hm-cart-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/cart-service.log 2>&1 &
CART_PID=$!
echo "购物车服务 PID: $CART_PID"
cd ..

# 等待购物车服务启动
sleep 10

# 启动交易服务 (端口: 8084)
echo "启动交易服务 (hm-trade-service) - 端口: 8084"
cd hm-trade-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/trade-service.log 2>&1 &
TRADE_PID=$!
echo "交易服务 PID: $TRADE_PID"
cd ..

# 等待交易服务启动
sleep 10

# 启动支付服务 (端口: 8085)
echo "启动支付服务 (hm-pay-service) - 端口: 8085"
cd hm-pay-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/pay-service.log 2>&1 &
PAY_PID=$!
echo "支付服务 PID: $PAY_PID"
cd ..

# 保存PID到文件
echo "$USER_PID" > logs/user-service.pid
echo "$PRODUCT_PID" > logs/product-service.pid
echo "$CART_PID" > logs/cart-service.pid
echo "$TRADE_PID" > logs/trade-service.pid
echo "$PAY_PID" > logs/pay-service.pid

echo ""
echo "所有服务启动完成！"
echo "服务信息:"
echo "- 用户服务: http://localhost:8083 (PID: $USER_PID)"
echo "- 商品管理服务: http://localhost:8081 (PID: $PRODUCT_PID)"
echo "- 购物车服务: http://localhost:8082 (PID: $CART_PID)"
echo "- 交易服务: http://localhost:8084 (PID: $TRADE_PID)"
echo "- 支付服务: http://localhost:8085 (PID: $PAY_PID)"
echo ""
echo "日志文件位置:"
echo "- 用户服务日志: logs/user-service.log"
echo "- 商品服务日志: logs/product-service.log"
echo "- 购物车服务日志: logs/cart-service.log"
echo "- 交易服务日志: logs/trade-service.log"
echo "- 支付服务日志: logs/pay-service.log"
echo ""
echo "停止所有服务请运行: ./stop-services.sh"
echo ""
echo "等待服务完全启动 (约60秒)..."
sleep 60

# 检查服务健康状态
echo "检查服务健康状态..."

# 检查用户服务
if curl -s http://localhost:8083/actuator/health > /dev/null 2>&1; then
    echo "✓ 用户服务 (8083) - 运行正常"
else
    echo "✗ 用户服务 (8083) - 可能未正常启动，请查看 logs/user-service.log"
fi

# 检查商品服务
if curl -s http://localhost:8081/actuator/health > /dev/null 2>&1; then
    echo "✓ 商品管理服务 (8081) - 运行正常"
else
    echo "✗ 商品管理服务 (8081) - 可能未正常启动，请查看 logs/product-service.log"
fi

# 检查购物车服务
if curl -s http://localhost:8082/actuator/health > /dev/null 2>&1; then
    echo "✓ 购物车服务 (8082) - 运行正常"
else
    echo "✗ 购物车服务 (8082) - 可能未正常启动，请查看 logs/cart-service.log"
fi

# 检查交易服务
if curl -s http://localhost:8084/actuator/health > /dev/null 2>&1; then
    echo "✓ 交易服务 (8084) - 运行正常"
else
    echo "✗ 交易服务 (8084) - 可能未正常启动，请查看 logs/trade-service.log"
fi

# 检查支付服务
if curl -s http://localhost:8085/actuator/health > /dev/null 2>&1; then
    echo "✓ 支付服务 (8085) - 运行正常"
else
    echo "✗ 支付服务 (8085) - 可能未正常启动，请查看 logs/pay-service.log"
fi

echo ""
echo "微服务启动脚本执行完成！"
echo ""
echo "🚀 所有服务已启动，可以开始使用："
echo "   - API文档: http://localhost:8081/doc.html (商品服务)"
echo "   - API文档: http://localhost:8082/doc.html (购物车服务)"
echo "   - API文档: http://localhost:8083/doc.html (用户服务)"
echo "   - API文档: http://localhost:8084/doc.html (交易服务)"
echo "   - API文档: http://localhost:8085/doc.html (支付服务)"
echo ""
echo "如果服务未正常启动，请查看对应的日志文件进行排查。"
