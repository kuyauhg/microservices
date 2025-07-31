#!/bin/bash

# 微服务停止脚本
# 用于停止所有微服务

echo "开始停止微服务..."

# 设置工作目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 停止服务函数
stop_service() {
    local service_name=$1
    local pid_file=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo "停止 $service_name (PID: $pid)..."
            kill $pid
            
            # 等待进程结束
            local count=0
            while ps -p $pid > /dev/null 2>&1 && [ $count -lt 30 ]; do
                sleep 1
                count=$((count + 1))
            done
            
            if ps -p $pid > /dev/null 2>&1; then
                echo "强制停止 $service_name (PID: $pid)..."
                kill -9 $pid
            fi
            
            echo "✓ $service_name 已停止"
        else
            echo "✓ $service_name 进程不存在"
        fi
        rm -f "$pid_file"
    else
        echo "✓ $service_name PID文件不存在"
    fi
}

# 停止所有服务 (按相反顺序停止，避免依赖问题)
stop_service "支付服务" "logs/pay-service.pid"
stop_service "交易服务" "logs/trade-service.pid"
stop_service "购物车服务" "logs/cart-service.pid"
stop_service "商品管理服务" "logs/product-service.pid"
stop_service "用户服务" "logs/user-service.pid"

# 额外检查并停止可能遗留的Java进程
echo ""
echo "检查是否有遗留的服务进程..."

# 查找可能的Spring Boot应用进程
SPRING_PIDS=$(ps aux | grep -E "(hm-user-service|hm-product-service|hm-cart-service|hm-trade-service|hm-pay-service)" | grep -v grep | awk '{print $2}')

if [ -n "$SPRING_PIDS" ]; then
    echo "发现遗留的服务进程，正在清理..."
    for pid in $SPRING_PIDS; do
        echo "停止进程 PID: $pid"
        kill $pid 2>/dev/null
    done

    sleep 3

    # 强制停止仍在运行的进程
    REMAINING_PIDS=$(ps aux | grep -E "(hm-user-service|hm-product-service|hm-cart-service|hm-trade-service|hm-pay-service)" | grep -v grep | awk '{print $2}')
    if [ -n "$REMAINING_PIDS" ]; then
        echo "强制停止遗留进程..."
        for pid in $REMAINING_PIDS; do
            echo "强制停止进程 PID: $pid"
            kill -9 $pid 2>/dev/null
        done
    fi
fi

echo ""
echo "所有微服务已停止！"

# 显示端口占用情况
echo ""
echo "检查端口占用情况:"
for port in 8081 8082 8083 8084 8085; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo "⚠️  端口 $port 仍被占用:"
        lsof -i :$port
    else
        echo "✓ 端口 $port 已释放"
    fi
done

echo ""
echo "微服务停止脚本执行完成！"
