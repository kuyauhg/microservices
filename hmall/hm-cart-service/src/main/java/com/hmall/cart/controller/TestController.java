package com.hmall.cart.controller;

import com.hmall.cart.domain.vo.CartVO;
import com.hmall.cart.service.ICartService;
import com.hmall.common.utils.UserContext;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Api(tags = "测试相关接口")
@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestController {
    private final ICartService cartService;

    @ApiOperation("测试查询购物车列表（模拟用户1）")
    @GetMapping("/carts")
    public List<CartVO> testQueryMyCarts(){
        // 模拟设置用户ID为1
        UserContext.setUser(1L);
        try {
            return cartService.queryMyCarts();
        } finally {
            UserContext.removeUser();
        }
    }
}
