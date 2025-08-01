package com.hmall.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 网关应用启动测试
 * 
 * @author hmall
 */
@SpringBootTest(classes = SimpleGatewayApplication.class)
@ActiveProfiles("test")
class GatewayApplicationTest {
    
    @Test
    void contextLoads() {
        // 测试Spring上下文是否能正常加载
    }
}
