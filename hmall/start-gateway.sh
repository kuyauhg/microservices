#!/bin/bash

# API网关服务单独启动脚本
# 用于快速启动网关服务进行测试

echo "启动API网关服务..."

# 设置工作目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查前置条件
echo "检查前置条件..."

# 检查Nacos
if ! curl -s http://127.0.0.1:8848/nacos > /dev/null 2>&1; then
    echo "❌ Nacos服务未启动，请先启动Nacos (端口: 8848)"
    exit 1
fi
echo "✓ Nacos服务正常"

# 检查Redis
if ! redis-cli -h 127.0.0.1 -p 6379 ping > /dev/null 2>&1; then
    echo "⚠️  Redis服务未启动，限流功能将不可用"
else
    echo "✓ Redis服务正常"
fi

# 创建日志目录
mkdir -p logs

# 编译项目
echo "编译网关服务..."
cd hm-gateway-service
if ! mvn clean compile > /dev/null 2>&1; then
    echo "❌ 编译失败，请检查代码"
    exit 1
fi
echo "✓ 编译完成"

# 启动网关服务
echo "启动API网关服务 (端口: 8080)..."
nohup mvn spring-boot:run -Dspring-boot.run.profiles=local > ../logs/gateway-service.log 2>&1 &
GATEWAY_PID=$!
echo $GATEWAY_PID > ../logs/gateway-service.pid

echo "网关服务 PID: $GATEWAY_PID"
echo "日志文件: logs/gateway-service.log"

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查服务状态
if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✓ 网关服务启动成功"
    echo ""
    echo "🚀 API网关服务已启动："
    echo "   - 网关地址: http://localhost:8080"
    echo "   - 健康检查: http://localhost:8080/actuator/health"
    echo "   - 路由信息: http://localhost:8080/actuator/gateway/routes"
    echo "   - 监控指标: http://localhost:8080/actuator/metrics"
    echo ""
    echo "停止服务请运行: kill $GATEWAY_PID"
else
    echo "❌ 网关服务启动失败，请查看日志: logs/gateway-service.log"
    exit 1
fi
