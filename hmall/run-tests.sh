#!/bin/bash

# 微服务测试运行脚本
# 用于运行所有微服务的测试用例

echo "开始运行微服务测试..."

# 设置工作目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "当前工作目录: $SCRIPT_DIR"

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven环境，请先安装Maven"
    exit 1
fi

# 创建测试报告目录
mkdir -p test-reports

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 运行测试函数
run_test() {
    local module_name=$1
    local module_path=$2
    
    echo ""
    echo "========================================="
    echo "运行 $module_name 测试"
    echo "========================================="
    
    cd "$module_path"
    
    # 运行测试
    mvn test -Dspring.profiles.active=local
    local test_result=$?
    
    # 统计测试结果
    if [ $test_result -eq 0 ]; then
        echo "✓ $module_name 测试通过"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "✗ $module_name 测试失败"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # 复制测试报告
    if [ -d "target/surefire-reports" ]; then
        cp -r target/surefire-reports "../test-reports/${module_name}-reports"
    fi
    
    cd "$SCRIPT_DIR"
    
    return $test_result
}

# 首先安装父POM和公共模块到本地仓库
echo "正在安装父POM和依赖模块..."
mvn clean install -DskipTests -N  # 只安装父POM
if [ $? -ne 0 ]; then
    echo "错误: 父POM安装失败"
    exit 1
fi

cd hm-common
mvn clean install -DskipTests
if [ $? -ne 0 ]; then
    echo "错误: hm-common 模块安装失败"
    exit 1
fi
cd "$SCRIPT_DIR"
echo "依赖模块安装完成"

# 编译所有模块
echo "正在编译项目..."
mvn clean compile -DskipTests

if [ $? -ne 0 ]; then
    echo "错误: 项目编译失败"
    exit 1
fi

echo "编译完成"

# 运行各模块测试
echo ""
echo "开始运行测试用例..."

# 1. 运行商品服务测试
run_test "商品管理服务" "hm-product-service"
PRODUCT_TEST_RESULT=$?

# 2. 运行购物车服务测试
run_test "购物车服务" "hm-cart-service"
CART_TEST_RESULT=$?

# 3. 运行主服务测试
run_test "主服务" "hm-service"
MAIN_TEST_RESULT=$?

# 输出测试总结
echo ""
echo "========================================="
echo "测试结果总结"
echo "========================================="
echo "总测试模块数: $TOTAL_TESTS"
echo "通过模块数: $PASSED_TESTS"
echo "失败模块数: $FAILED_TESTS"
echo ""

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo "🎉 所有测试都通过了！"
    echo ""
    echo "微服务重构验证成功："
    echo "✓ 商品管理服务功能正常"
    echo "✓ 购物车服务功能正常"
    echo "✓ 服务间通信正常"
    echo "✓ 数据库分离成功"
    echo "✓ Feign客户端调用正常"
else
    echo "❌ 有测试失败，请检查以下模块："
    
    if [ $PRODUCT_TEST_RESULT -ne 0 ]; then
        echo "- 商品管理服务测试失败"
    fi
    
    if [ $CART_TEST_RESULT -ne 0 ]; then
        echo "- 购物车服务测试失败"
    fi
    
    if [ $MAIN_TEST_RESULT -ne 0 ]; then
        echo "- 主服务测试失败"
    fi
fi

echo ""
echo "测试报告位置: test-reports/"
echo "详细的测试报告请查看各模块的 target/surefire-reports/ 目录"

# 生成简单的HTML测试报告
cat > test-reports/summary.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>微服务测试报告</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .success { color: green; }
        .failure { color: red; }
        .module { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>微服务重构测试报告</h1>
        <p>生成时间: $(date)</p>
    </div>
    
    <h2>测试结果概览</h2>
    <ul>
        <li>总测试模块数: $TOTAL_TESTS</li>
        <li class="success">通过模块数: $PASSED_TESTS</li>
        <li class="failure">失败模块数: $FAILED_TESTS</li>
    </ul>
    
    <h2>各模块测试结果</h2>
    <div class="module">
        <h3>商品管理服务 (hm-product-service)</h3>
        <p class="$([ $PRODUCT_TEST_RESULT -eq 0 ] && echo 'success' || echo 'failure')">
            $([ $PRODUCT_TEST_RESULT -eq 0 ] && echo '✓ 测试通过' || echo '✗ 测试失败')
        </p>
    </div>
    
    <div class="module">
        <h3>购物车服务 (hm-cart-service)</h3>
        <p class="$([ $CART_TEST_RESULT -eq 0 ] && echo 'success' || echo 'failure')">
            $([ $CART_TEST_RESULT -eq 0 ] && echo '✓ 测试通过' || echo '✗ 测试失败')
        </p>
    </div>
    
    <div class="module">
        <h3>主服务 (hm-service)</h3>
        <p class="$([ $MAIN_TEST_RESULT -eq 0 ] && echo 'success' || echo 'failure')">
            $([ $MAIN_TEST_RESULT -eq 0 ] && echo '✓ 测试通过' || echo '✗ 测试失败')
        </p>
    </div>
</body>
</html>
EOF

echo "HTML测试报告: test-reports/summary.html"

# 返回适当的退出码
if [ $FAILED_TESTS -eq 0 ]; then
    exit 0
else
    exit 1
fi
