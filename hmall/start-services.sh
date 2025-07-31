#!/bin/bash

# 微服务启动脚本
# 用于启动所有微服务进行测试

echo "开始启动微服务..."

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java环境，请先安装Java 8或更高版本"
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

# 启动主服务 (端口: 8080)
echo "启动主服务 (hm-service) - 端口: 8080"
cd hm-service
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/main-service.log 2>&1 &
MAIN_PID=$!
echo "主服务 PID: $MAIN_PID"
cd ..

# 保存PID到文件
echo "$PRODUCT_PID" > logs/product-service.pid
echo "$CART_PID" > logs/cart-service.pid
echo "$MAIN_PID" > logs/main-service.pid

echo ""
echo "所有服务启动完成！"
echo "服务信息:"
echo "- 商品管理服务: http://localhost:8081 (PID: $PRODUCT_PID)"
echo "- 购物车服务: http://localhost:8082 (PID: $CART_PID)"
echo "- 主服务: http://localhost:8080 (PID: $MAIN_PID)"
echo ""
echo "日志文件位置:"
echo "- 商品服务日志: logs/product-service.log"
echo "- 购物车服务日志: logs/cart-service.log"
echo "- 主服务日志: logs/main-service.log"
echo ""
echo "停止所有服务请运行: ./stop-services.sh"
echo ""
echo "等待服务完全启动 (约30秒)..."
sleep 30

# 检查服务健康状态
echo "检查服务健康状态..."

# 检查商品服务
if curl -s http://localhost:8081/actuator/health > /dev/null 2>&1; then
    echo "✓ 商品管理服务 (8081) - 运行正常"
else
    echo "✗ 商品管理服务 (8081) - 可能未正常启动"
fi

# 检查购物车服务
if curl -s http://localhost:8082/actuator/health > /dev/null 2>&1; then
    echo "✓ 购物车服务 (8082) - 运行正常"
else
    echo "✗ 购物车服务 (8082) - 可能未正常启动"
fi

# 检查主服务
if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✓ 主服务 (8080) - 运行正常"
else
    echo "✗ 主服务 (8080) - 可能未正常启动"
fi

echo ""
echo "微服务启动脚本执行完成！"
echo "如果服务未正常启动，请查看对应的日志文件进行排查。"
