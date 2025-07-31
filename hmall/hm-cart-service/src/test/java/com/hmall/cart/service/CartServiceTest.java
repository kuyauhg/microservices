package com.hmall.cart.service;

import com.hmall.cart.CartApplication;
import com.hmall.cart.config.TestConfig;
import com.hmall.cart.domain.dto.CartFormDTO;
import com.hmall.cart.domain.vo.CartVO;
import com.hmall.common.utils.UserContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 购物车服务测试类
 */
@SpringBootTest(classes = {CartApplication.class, TestConfig.class},
               properties = {"spring.cloud.openfeign.enabled=false"})
@ActiveProfiles("test")
@Transactional // 使用事务回滚，避免测试数据污染
public class CartServiceTest {

    @Autowired
    private ICartService cartService;

    @BeforeEach
    public void setUp() {
        // 设置测试用户ID
        UserContext.setUser(1L);
    }

    @Test
    public void testAddItem2Cart() {
        // 准备测试数据
        CartFormDTO cartFormDTO = new CartFormDTO();
        cartFormDTO.setItemId(317578L);
        cartFormDTO.setName("RIMOWA 21寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4");
        cartFormDTO.setSpec("{\"颜色\": \"红色\", \"尺码\": \"21寸\"}");
        cartFormDTO.setPrice(28900);
        cartFormDTO.setImage("https://m.360buyimg.com/mobilecms/s720x720_jfs/t6934/364/1195375010/84676/e9f2c55f/597ece38N0ddcbc77.jpg!q70.jpg.webp");
        
        // 执行测试
        assertDoesNotThrow(() -> cartService.addItem2Cart(cartFormDTO));
        
        // 验证结果
        List<CartVO> carts = cartService.queryMyCarts();
        assertNotNull(carts);
        assertFalse(carts.isEmpty());
        
        // 查找添加的商品
        CartVO addedCart = carts.stream()
                .filter(cart -> cart.getItemId().equals(317578L))
                .findFirst()
                .orElse(null);
        assertNotNull(addedCart);
        assertEquals("RIMOWA 21寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4", addedCart.getName());
        assertEquals(28900, addedCart.getPrice());
    }

    @Test
    public void testAddSameItemTwice() {
        // 准备测试数据
        CartFormDTO cartFormDTO = new CartFormDTO();
        cartFormDTO.setItemId(317580L);
        cartFormDTO.setName("RIMOWA 26寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4");
        cartFormDTO.setSpec("{\"颜色\": \"蓝色\", \"尺码\": \"26寸\"}");
        cartFormDTO.setPrice(28600);
        cartFormDTO.setImage("https://m.360buyimg.com/mobilecms/s720x720_jfs/t6934/364/1195375010/84676/e9f2c55f/597ece38N0ddcbc77.jpg!q70.jpg.webp");
        
        // 第一次添加
        assertDoesNotThrow(() -> cartService.addItem2Cart(cartFormDTO));
        
        // 获取第一次添加后的数量
        List<CartVO> cartsAfterFirst = cartService.queryMyCarts();
        CartVO cartAfterFirst = cartsAfterFirst.stream()
                .filter(cart -> cart.getItemId().equals(317580L))
                .findFirst()
                .orElse(null);
        assertNotNull(cartAfterFirst);
        int firstNum = cartAfterFirst.getNum();
        
        // 第二次添加相同商品
        assertDoesNotThrow(() -> cartService.addItem2Cart(cartFormDTO));
        
        // 验证数量是否增加
        List<CartVO> cartsAfterSecond = cartService.queryMyCarts();
        CartVO cartAfterSecond = cartsAfterSecond.stream()
                .filter(cart -> cart.getItemId().equals(317580L))
                .findFirst()
                .orElse(null);
        assertNotNull(cartAfterSecond);
        assertEquals(firstNum + 1, cartAfterSecond.getNum());
    }

    @Test
    public void testQueryMyCarts() {
        // 先添加一些测试数据
        CartFormDTO cartFormDTO1 = new CartFormDTO();
        cartFormDTO1.setItemId(317578L);
        cartFormDTO1.setName("Test Item 1");
        cartFormDTO1.setSpec("{}");
        cartFormDTO1.setPrice(1000);
        cartFormDTO1.setImage("test1.jpg");
        
        CartFormDTO cartFormDTO2 = new CartFormDTO();
        cartFormDTO2.setItemId(317580L);
        cartFormDTO2.setName("Test Item 2");
        cartFormDTO2.setSpec("{}");
        cartFormDTO2.setPrice(2000);
        cartFormDTO2.setImage("test2.jpg");
        
        cartService.addItem2Cart(cartFormDTO1);
        cartService.addItem2Cart(cartFormDTO2);
        
        // 执行测试
        List<CartVO> carts = cartService.queryMyCarts();
        
        // 验证结果
        assertNotNull(carts);
        assertTrue(carts.size() >= 2);
        
        // 验证商品信息是否正确填充（通过Feign调用商品服务）
        for (CartVO cart : carts) {
            assertNotNull(cart.getNewPrice());
            assertNotNull(cart.getStatus());
            assertNotNull(cart.getStock());
        }
    }

    @Test
    public void testRemoveByItemIds() {
        // 先添加测试数据
        CartFormDTO cartFormDTO = new CartFormDTO();
        cartFormDTO.setItemId(317578L);
        cartFormDTO.setName("Test Item");
        cartFormDTO.setSpec("{}");
        cartFormDTO.setPrice(1000);
        cartFormDTO.setImage("test.jpg");
        
        cartService.addItem2Cart(cartFormDTO);
        
        // 验证添加成功
        List<CartVO> cartsBeforeRemove = cartService.queryMyCarts();
        boolean existsBeforeRemove = cartsBeforeRemove.stream()
                .anyMatch(cart -> cart.getItemId().equals(317578L));
        assertTrue(existsBeforeRemove);
        
        // 执行删除
        cartService.removeByItemIds(Arrays.asList(317578L));
        
        // 验证删除成功
        List<CartVO> cartsAfterRemove = cartService.queryMyCarts();
        boolean existsAfterRemove = cartsAfterRemove.stream()
                .anyMatch(cart -> cart.getItemId().equals(317578L));
        assertFalse(existsAfterRemove);
    }

    @Test
    public void testRemoveByItemIdsWithEmptyList() {
        // 测试空列表删除
        assertDoesNotThrow(() -> cartService.removeByItemIds(Arrays.asList()));
    }

    @Test
    public void testRemoveByItemIdsWithNonExistentIds() {
        // 测试删除不存在的商品ID
        assertDoesNotThrow(() -> cartService.removeByItemIds(Arrays.asList(999999L, 888888L)));
    }
}
