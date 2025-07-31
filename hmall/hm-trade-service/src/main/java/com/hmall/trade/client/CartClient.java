package com.hmall.trade.client;

import com.hmall.domain.dto.OrderDetailDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient("hm-cart-service")
public interface CartClient {
    @GetMapping("/carts")
    List<OrderDetailDTO> queryMyCarts();

    @DeleteMapping("/carts")
    void deleteCartItemByIds(@RequestParam("ids") List<Long> ids);
}
