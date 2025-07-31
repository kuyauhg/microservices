package com.hmall.product.service;

import com.hmall.product.domain.dto.ItemDTO;
import com.hmall.product.domain.dto.OrderDetailDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 商品服务测试类
 */
@SpringBootTest
@ActiveProfiles("test")
public class ItemServiceTest {

    @Autowired
    private IItemService itemService;

    @Test
    public void testQueryItemByIds() {
        // 准备测试数据
        List<Long> ids = Arrays.asList(317578L, 317580L);
        
        // 执行测试
        List<ItemDTO> items = itemService.queryItemByIds(ids);
        
        // 验证结果
        assertNotNull(items);
        assertEquals(2, items.size());
        
        // 验证商品信息
        ItemDTO item1 = items.stream()
                .filter(item -> item.getId().equals(317578L))
                .findFirst()
                .orElse(null);
        assertNotNull(item1);
        assertEquals("RIMOWA 21寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4", item1.getName());
        assertEquals(28900, item1.getPrice());
        
        ItemDTO item2 = items.stream()
                .filter(item -> item.getId().equals(317580L))
                .findFirst()
                .orElse(null);
        assertNotNull(item2);
        assertEquals("RIMOWA 26寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4", item2.getName());
        assertEquals(28600, item2.getPrice());
    }

    @Test
    public void testDeductStock() {
        // 准备测试数据
        List<OrderDetailDTO> items = Arrays.asList(
                new OrderDetailDTO().setItemId(317578L).setNum(1),
                new OrderDetailDTO().setItemId(317580L).setNum(1)
        );
        
        // 获取扣减前的库存
        List<ItemDTO> beforeItems = itemService.queryItemByIds(Arrays.asList(317578L, 317580L));
        int beforeStock1 = beforeItems.stream()
                .filter(item -> item.getId().equals(317578L))
                .findFirst()
                .map(ItemDTO::getStock)
                .orElse(0);
        int beforeStock2 = beforeItems.stream()
                .filter(item -> item.getId().equals(317580L))
                .findFirst()
                .map(ItemDTO::getStock)
                .orElse(0);
        
        // 执行库存扣减
        assertDoesNotThrow(() -> itemService.deductStock(items));
        
        // 验证库存是否正确扣减
        List<ItemDTO> afterItems = itemService.queryItemByIds(Arrays.asList(317578L, 317580L));
        int afterStock1 = afterItems.stream()
                .filter(item -> item.getId().equals(317578L))
                .findFirst()
                .map(ItemDTO::getStock)
                .orElse(0);
        int afterStock2 = afterItems.stream()
                .filter(item -> item.getId().equals(317580L))
                .findFirst()
                .map(ItemDTO::getStock)
                .orElse(0);
        
        assertEquals(beforeStock1 - 1, afterStock1);
        assertEquals(beforeStock2 - 1, afterStock2);
        
        // 恢复库存（为了不影响其他测试）
        List<OrderDetailDTO> restoreItems = Arrays.asList(
                new OrderDetailDTO().setItemId(317578L).setNum(-1),
                new OrderDetailDTO().setItemId(317580L).setNum(-1)
        );
        // 注意：这里需要手动恢复库存，因为我们的updateStock方法是减法操作
        // 在实际测试中，应该使用事务回滚或测试数据库
    }

    @Test
    public void testQueryItemByIdsWithEmptyList() {
        // 测试空列表
        List<ItemDTO> items = itemService.queryItemByIds(Arrays.asList());
        assertNotNull(items);
        assertTrue(items.isEmpty());
    }

    @Test
    public void testQueryItemByIdsWithNonExistentIds() {
        // 测试不存在的商品ID
        List<Long> ids = Arrays.asList(999999L, 888888L);
        List<ItemDTO> items = itemService.queryItemByIds(ids);
        assertNotNull(items);
        assertTrue(items.isEmpty());
    }
}
