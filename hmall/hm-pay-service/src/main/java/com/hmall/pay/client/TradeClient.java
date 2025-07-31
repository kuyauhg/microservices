package com.hmall.pay.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;

@FeignClient("hm-trade-service")
public interface TradeClient {
    
    @PutMapping("/orders/{orderId}/pay")
    void markOrderPaySuccess(@PathVariable("orderId") Long orderId);
}
