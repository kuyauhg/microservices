package com.hmall.pay.config;

import com.hmall.common.utils.UserContext;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FeignConfig {

    @Bean
    public RequestInterceptor requestInterceptor() {
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                // 获取当前用户的JWT token并传递给下游服务
                Long userId = UserContext.getUser();
                if (userId != null) {
                    // 从请求头中获取token并传递
                    // 这里我们需要从当前请求中获取authorization头
                    // 由于这是在Feign调用中，我们需要从ThreadLocal或其他方式获取token
                    // 暂时先不处理，让我们看看是否有其他方式
                }
            }
        };
    }
}
