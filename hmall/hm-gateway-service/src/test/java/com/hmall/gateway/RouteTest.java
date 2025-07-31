package com.hmall.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.test.context.ActiveProfiles;
import reactor.core.publisher.Flux;
import reactor.test.StepVerifier;

/**
 * 路由配置测试
 * 
 * @author hmall
 */
@SpringBootTest
@ActiveProfiles("test")
class RouteTest {
    
    @Autowired
    private RouteLocator routeLocator;
    
    @Test
    void testRouteConfiguration() {
        Flux<org.springframework.cloud.gateway.route.Route> routes = routeLocator.getRoutes();
        
        StepVerifier.create(routes)
                .expectNextMatches(route -> "test-service".equals(route.getId()))
                .thenCancel()
                .verify();
    }
}
