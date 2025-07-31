package com.hmall.gateway.filter;

import com.hmall.common.utils.JwtTool;
import com.hmall.gateway.config.AuthProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

/**
 * 认证过滤器测试
 * 
 * @author hmall
 */
@ExtendWith(MockitoExtension.class)
class AuthGlobalFilterTest {
    
    @Mock
    private JwtTool jwtTool;
    
    @Mock
    private GatewayFilterChain filterChain;
    
    private AuthGlobalFilter authGlobalFilter;
    private AuthProperties authProperties;
    
    @BeforeEach
    void setUp() {
        authProperties = new AuthProperties();
        authProperties.setExcludePaths(Arrays.asList("/test/**", "/actuator/**"));
        authGlobalFilter = new AuthGlobalFilter(jwtTool, authProperties);
        
        when(filterChain.filter(any(ServerWebExchange.class))).thenReturn(Mono.empty());
    }
    
    @Test
    void testExcludePath() {
        // 测试排除路径
        ServerHttpRequest request = MockServerHttpRequest.get("/test/hello").build();
        ServerWebExchange exchange = MockServerWebExchange.from(request);
        
        Mono<Void> result = authGlobalFilter.filter(exchange, filterChain);
        
        StepVerifier.create(result)
                .verifyComplete();
    }
    
    @Test
    void testValidToken() {
        // 测试有效token
        when(jwtTool.parseToken("valid-token")).thenReturn(123L);
        
        ServerHttpRequest request = MockServerHttpRequest.get("/users/me")
                .header(HttpHeaders.AUTHORIZATION, "valid-token")
                .build();
        ServerWebExchange exchange = MockServerWebExchange.from(request);
        
        Mono<Void> result = authGlobalFilter.filter(exchange, filterChain);
        
        StepVerifier.create(result)
                .verifyComplete();
    }
    
    @Test
    void testMissingToken() {
        // 测试缺少token
        ServerHttpRequest request = MockServerHttpRequest.get("/users/me").build();
        ServerWebExchange exchange = MockServerWebExchange.from(request);
        
        Mono<Void> result = authGlobalFilter.filter(exchange, filterChain);
        
        StepVerifier.create(result)
                .verifyComplete();
    }
}
