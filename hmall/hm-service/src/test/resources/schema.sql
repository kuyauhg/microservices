-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(128) NOT NULL COMMENT '密码，加密存储',
    phone VARCHAR(20) COMMENT '手机号',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    status INT DEFAULT 1 COMMENT '使用状态（1正常 2冻结）',
    balance INT DEFAULT NULL COMMENT '账户余额'
);

-- 订单表
CREATE TABLE IF NOT EXISTS `order` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    total_fee INT NOT NULL COMMENT '订单的总金额，单位为分',
    payment_type TINYINT DEFAULT 1 COMMENT '支付类型，1、支付宝，2、微信',
    user_id BIGINT NOT NULL COMMENT '用户id',
    status TINYINT DEFAULT 1 COMMENT '订单状态，1、未付款 2、已付款,未发货 3、已发货,未确认 4、确认收货，交易成功 5、交易取消，订单关闭 6、交易结束，已评价',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 订单详情表
CREATE TABLE IF NOT EXISTS order_detail (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL COMMENT '订单id',
    item_id BIGINT NOT NULL COMMENT '商品id',
    num INT NOT NULL COMMENT '商品购买数量',
    title VARCHAR(256) NOT NULL COMMENT '商品标题',
    price INT NOT NULL COMMENT '商品单价，单位：分',
    image VARCHAR(200) COMMENT '商品图片',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 地址表
CREATE TABLE IF NOT EXISTS address (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    province VARCHAR(10) COMMENT '省',
    city VARCHAR(10) COMMENT '市',
    town VARCHAR(10) COMMENT '县/区',
    mobile VARCHAR(255) COMMENT '手机',
    street VARCHAR(255) COMMENT '详细地址',
    contact VARCHAR(255) COMMENT '联系人',
    is_default BOOLEAN COMMENT '是否是默认 1默认 0否',
    notes VARCHAR(255) COMMENT '备注',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 支付订单表
CREATE TABLE IF NOT EXISTS pay_order (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    biz_order_no BIGINT NOT NULL COMMENT '业务订单号',
    pay_order_no BIGINT NOT NULL DEFAULT 0 COMMENT '支付单号',
    biz_user_id BIGINT NOT NULL COMMENT '支付用户id',
    pay_channel_code VARCHAR(30) NOT NULL DEFAULT '0' COMMENT '支付渠道编码',
    amount INT NOT NULL COMMENT '支付金额，单位分',
    pay_type TINYINT NOT NULL DEFAULT 5 COMMENT '支付类型，1：h5,2:小程序，3：公众号，4：扫码，5：余额支付',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '支付状态，0：待提交，1:待支付，2：支付超时或取消，3：支付成功',
    expand_json VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '拓展字段，用于传递不同渠道单独处理的字段',
    result_code VARCHAR(20) DEFAULT '' COMMENT '第三方返回业务码',
    result_msg VARCHAR(50) DEFAULT '' COMMENT '第三方返回提示信息',
    pay_success_time TIMESTAMP DEFAULT NULL COMMENT '支付成功时间',
    pay_over_time TIMESTAMP NOT NULL COMMENT '支付超时时间',
    qr_code_url VARCHAR(255) DEFAULT NULL COMMENT '支付二维码链接',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    creater BIGINT NOT NULL DEFAULT 0 COMMENT '创建人',
    updater BIGINT NOT NULL DEFAULT 0 COMMENT '更新人',
    is_delete BOOLEAN NOT NULL DEFAULT FALSE COMMENT '逻辑删除'
);
