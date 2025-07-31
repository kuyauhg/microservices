-- 测试数据
INSERT INTO `user` (id, username, password, phone, create_time, update_time, status, balance) VALUES
(1, 'Jack', '$2a$10$6ptTq3V9XfaJmFYwYT2W9ud377BUkEWk.whf.iQ.0sX5F.L497rAC', '13900112224', '2017-08-19 20:50:21', '2017-08-19 20:50:21', 1, 1000000),
(2, 'Rose', '$2a$10$6ptTq3V9XfaJmFYwYT2W9ud377BUkEWk.whf.iQ.0sX5F.L497rAC', '13900112223', '2017-08-19 21:00:23', '2017-08-19 21:00:23', 1, 1000000),
(3, 'Hope', '$2a$10$6ptTq3V9XfaJmFYwYT2W9ud377BUkEWk.whf.iQ.0sX5F.L497rAC', '13900112222', '2017-08-19 22:37:44', '2017-08-19 22:37:44', 1, 1000000),
(4, 'Thomas', '$2a$10$6ptTq3V9XfaJmFYwYT2W9ud377BUkEWk.whf.iQ.0sX5F.L497rAC', '17701265258', '2017-08-19 23:44:45', '2017-08-19 23:44:45', 1, 1000000);

INSERT INTO address (id, user_id, province, city, town, mobile, street, contact, is_default, notes) VALUES
(59, 1, '北京', '北京', '朝阳区', '13900112222', '金燕龙办公楼', '李嘉诚', false, NULL),
(60, 1, '北京', '北京', '朝阳区', '13700221122', '修正大厦', '李佳红', false, NULL),
(61, 1, '上海', '上海', '浦东新区', '13301212233', '航头镇航头路', '李佳星', true, NULL),
(63, 1, '广东', '佛山', '永春', '13301212233', '永春武馆', '李小龙', false, NULL);

INSERT INTO `order` (id, total_fee, payment_type, user_id, status, create_time) VALUES
(123865420, 327900, 3, 2, 1, '2021-07-28 11:01:41'),
(1654779387523936258, 135800, 3, 1, 1, '2023-05-06 09:25:24'),
(1654782927348740097, 135800, 3, 1, 1, '2023-05-06 09:39:28'),
(1658434251768471554, 120000, 3, 1, 1, '2023-05-16 11:28:32'),
(1658453559437434882, 55400, 3, 1, 1, '2023-05-16 12:45:15'),
(1659160216593354754, 156000, 3, 1, 1, '2023-05-18 11:33:16');

INSERT INTO order_detail (id, order_id, item_id, num, title, price, image) VALUES
(1, 123865420, 317578, 1, 'RIMOWA 21寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4', 28900, 'https://m.360buyimg.com/mobilecms/s720x720_jfs/t6934/364/1195375010/84676/e9f2c55f/597ece38N0ddcbc77.jpg!q70.jpg.webp'),
(2, 123865420, 317580, 2, 'RIMOWA 26寸托运箱拉杆箱 SALSA AIR系列果绿色 820.70.36.4', 28600, 'https://m.360buyimg.com/mobilecms/s720x720_jfs/t6934/364/1195375010/84676/e9f2c55f/597ece38N0ddcbc77.jpg!q70.jpg.webp'),
(3, 1654779387523936258, 546872, 1, '博兿（BOYI）拉杆包男23英寸大容量旅行包户外手提休闲拉杆袋 BY09186黑灰色', 27500, 'https://m.360buyimg.com/mobilecms/s720x720_jfs/t3301/221/3887995271/90563/bf2cadb/57f9fbf4N8e47c225.jpg!q70.jpg.webp');
