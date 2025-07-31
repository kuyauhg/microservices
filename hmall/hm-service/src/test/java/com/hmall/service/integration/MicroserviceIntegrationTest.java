package com.hmall.service.integration;

import com.hmall.client.CartClient;
import com.hmall.client.ItemClient;
import com.hmall.domain.dto.ItemDTO;
import com.hmall.domain.dto.OrderDetailDTO;
import com.hmall.domain.dto.OrderFormDTO;
import com.hmall.service.IOrderService;
import com.hmall.common.utils.UserContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 微服务集成测试类
 * 测试主服务与商品服务、购物车服务之间的通信
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public class MicroserviceIntegrationTest {

    @Autowired
    private ItemClient itemClient;

    @Autowired
    private CartClient cartClient;

    @Autowired
    private IOrderService orderService;

    @BeforeEach
    public void setUp() {
        // 设置测试用户ID
        UserContext.setUser(1L);
    }

    @Test
    public void testItemClientQueryItemByIds() {
        // 测试通过Feign客户端调用商品服务
        List<Long> ids = Arrays.asList(317578L, 317580L);
        
        // 执行远程调用
        List<ItemDTO> items = itemClient.queryItemByIds(ids);
        
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
        
        ItemDTO item2 = items.stream()
                .filter(item -> item.getId().equals(317580L))
                .findFirst()
                .orElse(null);
        assertNotNull(item2);
        assertEquals("RIMOWA 26寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4", item2.getName());
    }

    @Test
    public void testItemClientDeductStock() {
        // 准备测试数据
        List<OrderDetailDTO> items = Arrays.asList(
                new OrderDetailDTO().setItemId(317578L).setNum(1),
                new OrderDetailDTO().setItemId(317580L).setNum(1)
        );
        
        // 获取扣减前的库存
        List<ItemDTO> beforeItems = itemClient.queryItemByIds(Arrays.asList(317578L, 317580L));
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
        assertDoesNotThrow(() -> itemClient.deductStock(items));
        
        // 验证库存是否正确扣减
        List<ItemDTO> afterItems = itemClient.queryItemByIds(Arrays.asList(317578L, 317580L));
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
    }

    @Test
    public void testCartClientDeleteCartItemByIds() {
        // 测试通过Feign客户端调用购物车服务删除商品
        List<Long> itemIds = Arrays.asList(317578L, 317580L);
        
        // 执行远程调用（删除购物车中的商品）
        assertDoesNotThrow(() -> cartClient.deleteCartItemByIds(itemIds));
    }

    @Test
    public void testOrderServiceCreateOrderWithMicroservices() {
        // 测试订单服务使用微服务创建订单
        // 准备订单数据
        OrderFormDTO orderFormDTO = new OrderFormDTO();
        orderFormDTO.setAddressId(1L);
        orderFormDTO.setPaymentType(1);
        
        List<OrderDetailDTO> details = Arrays.asList(
                new OrderDetailDTO().setItemId(317578L).setNum(1),
                new OrderDetailDTO().setItemId(317580L).setNum(1)
        );
        orderFormDTO.setDetails(details);
        
        // 获取创建订单前的库存
        List<ItemDTO> beforeItems = itemClient.queryItemByIds(Arrays.asList(317578L, 317580L));
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
        
        // 执行创建订单
        Long orderId = orderService.createOrder(orderFormDTO);
        
        // 验证订单创建成功
        assertNotNull(orderId);
        assertTrue(orderId > 0);
        
        // 验证库存是否正确扣减（通过商品服务）
        List<ItemDTO> afterItems = itemClient.queryItemByIds(Arrays.asList(317578L, 317580L));
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
        
        // 注意：购物车清理功能也会通过CartClient调用购物车服务
        // 这里我们主要验证整个流程不会抛出异常
    }

    @Test
    public void testServiceDiscoveryAndLoadBalancing() {
        // 测试服务发现和负载均衡
        // 多次调用同一个服务，验证服务发现机制正常工作
        for (int i = 0; i < 5; i++) {
            List<ItemDTO> items = itemClient.queryItemByIds(Arrays.asList(317578L));
            assertNotNull(items);
            assertFalse(items.isEmpty());
        }
    }

    @Test
    public void testFeignClientErrorHandling() {
        // 测试Feign客户端的错误处理
        // 查询不存在的商品ID
        List<ItemDTO> items = itemClient.queryItemByIds(Arrays.asList(999999L));
        assertNotNull(items);
        assertTrue(items.isEmpty());
        
        // 删除不存在的购物车商品
        assertDoesNotThrow(() -> cartClient.deleteCartItemByIds(Arrays.asList(999999L)));
    }
}
