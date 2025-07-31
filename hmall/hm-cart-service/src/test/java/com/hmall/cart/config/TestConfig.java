package com.hmall.cart.config;

import com.hmall.cart.client.ItemClient;
import com.hmall.cart.domain.dto.ItemDTO;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 测试配置类，提供Mock的ItemClient
 */
@TestConfiguration
public class TestConfig {

    @Bean
    @Primary
    public ItemClient mockItemClient() {
        return new ItemClient() {
            @Override
            public List<ItemDTO> queryItemByIds(Collection<Long> ids) {
                // 返回Mock数据
                return ids.stream().map(id -> {
                    ItemDTO item = new ItemDTO();
                    item.setId(id);
                    item.setName("Test Item " + id);
                    item.setPrice(1000);
                    item.setStock(100);
                    item.setStatus(1);
                    item.setImage("test.jpg");
                    item.setCategory("测试分类");
                    item.setBrand("测试品牌");
                    item.setSpec("{}");
                    return item;
                }).collect(Collectors.toList());
            }
        };
    }
}
