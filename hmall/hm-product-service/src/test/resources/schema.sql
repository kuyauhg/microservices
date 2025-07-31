-- 商品表 (适配H2数据库)
CREATE TABLE IF NOT EXISTS item (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL COMMENT 'SKU名称',
    price INT NOT NULL DEFAULT 0 COMMENT '价格（分）',
    stock INT NOT NULL COMMENT '库存数量',
    image VARCHAR(200) COMMENT '商品图片',
    category VARCHAR(200) COMMENT '类目名称',
    brand VARCHAR(100) COMMENT '品牌名称',
    spec VARCHAR(200) COMMENT '规格',
    sold INT DEFAULT 0 COMMENT '销量',
    comment_count INT DEFAULT 0 COMMENT '评论数',
    isAD BOOLEAN DEFAULT FALSE COMMENT '是否是推广广告',
    status INT DEFAULT 2 COMMENT '商品状态 1-正常，2-下架，3-删除',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    creater BIGINT DEFAULT NULL COMMENT '创建人',
    updater BIGINT DEFAULT NULL COMMENT '修改人'
);
