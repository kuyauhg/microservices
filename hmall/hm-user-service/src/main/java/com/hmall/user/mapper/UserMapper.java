package com.hmall.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hmall.user.domain.po.User;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

/**
 * <p>
 * 用户表 Mapper 接口
 * </p>
 *
 * @author 虎哥
 * @since 2023-05-05
 */
public interface UserMapper extends BaseMapper<User> {

    @Update("UPDATE user SET balance = balance - #{money} WHERE id = #{id}")
    void updateMoney(@Param("id") Long id, @Param("money") Integer money);
}
