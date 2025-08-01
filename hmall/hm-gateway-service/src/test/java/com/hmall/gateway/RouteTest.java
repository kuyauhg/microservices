package com.hmall.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.test.context.ActiveProfiles;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 路由配置测试
 *
 * @author hmall
 */
@SpringBootTest(classes = SimpleGatewayApplication.class)
@ActiveProfiles("test")
class RouteTest {

    @Autowired
    private RouteLocator routeLocator;

    @Test
    void testRouteConfiguration() {
        Flux<org.springframework.cloud.gateway.route.Route> routes = routeLocator.getRoutes();

        // 收集所有路由ID
        List<String> routeIds = routes.map(route -> route.getId())
                .collect(Collectors.toList())
                .block();

        // 验证路由数量
        assertNotNull(routeIds);
        assertEquals(5, routeIds.size(), "应该有5个路由");

        // 验证包含所有预期的路由
        assertTrue(routeIds.contains("hm-product-service"), "应该包含商品服务路由");
        assertTrue(routeIds.contains("hm-user-service"), "应该包含用户服务路由");
        assertTrue(routeIds.contains("hm-cart-service"), "应该包含购物车服务路由");
        assertTrue(routeIds.contains("hm-trade-service"), "应该包含交易服务路由");
        assertTrue(routeIds.contains("hm-pay-service"), "应该包含支付服务路由");
    }
}
