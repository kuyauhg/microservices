package com.hmall.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 简化版网关启动类
 */
@SpringBootApplication
@EnableDiscoveryClient
public class SimpleGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(SimpleGatewayApplication.class, args);
    }
}
