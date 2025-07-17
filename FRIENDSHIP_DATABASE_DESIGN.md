# 好友功能数据库设计

## 概述
本文档描述了餐厅评分地图应用中好友功能的数据库设计，包括表结构、索引、约束和视图。

## 表结构设计

### 1. friendships 表（好友关系表）
存储已确认的好友关系。

**字段说明：**
- `id`: 主键，UUID类型
- `user_id`: 用户ID，外键引用users表
- `friend_id`: 好友ID，外键引用users表
- `created_at`: 好友关系建立时间

**约束：**
- `UNIQUE(user_id, friend_id)`: 防止重复的好友关系
- `CHECK (user_id != friend_id)`: 防止用户和自己成为好友
- 外键约束：删除用户时级联删除相关好友关系

**设计思路：**
- 好友关系是双向的，但只需要存储一条记录
- 查询时可以通过UNION查询获取双向关系

### 2. friend_requests 表（好友请求表）
存储待处理的好友请求。

**字段说明：**
- `id`: 主键，UUID类型
- `sender_id`: 发送者ID，外键引用users表
- `receiver_id`: 接收者ID，外键引用users表
- `status`: 请求状态（pending/accepted/rejected）
- `message`: 好友请求的附加消息
- `created_at`: 请求创建时间
- `updated_at`: 请求更新时间

**约束：**
- `CHECK (sender_id != receiver_id)`: 防止向自己发送请求
- `UNIQUE(sender_id, receiver_id, status)`: 同一用户对同一用户只能有一个特定状态的请求
- 外键约束：删除用户时级联删除相关请求

**设计思路：**
- 支持请求状态管理，便于跟踪请求处理过程
- 允许附加消息，提升用户体验
- 唯一约束确保数据一致性

## 索引设计

### friendships 表索引
- `idx_friendships_user_id`: 按用户ID查询好友
- `idx_friendships_friend_id`: 按好友ID查询
- `idx_friendships_both_users`: 复合索引，优化双向查询

### friend_requests 表索引
- `idx_friend_requests_sender_id`: 查询用户发送的请求
- `idx_friend_requests_receiver_id`: 查询用户接收的请求
- `idx_friend_requests_status`: 按状态筛选请求
- `idx_friend_requests_created_at`: 按时间排序

## 视图设计

### 1. user_friends 视图
提供用户好友列表的完整信息，包括双向关系。

**查询逻辑：**
```sql
-- 查询用户作为发起方的好友关系
SELECT user_id, friend_id FROM friendships WHERE user_id = ?
UNION
-- 查询用户作为接收方的好友关系
SELECT friend_id as user_id, user_id as friend_id FROM friendships WHERE friend_id = ?
```

### 2. pending_friend_requests 视图
提供待处理好友请求的完整信息。

**特点：**
- 只显示状态为pending的请求
- 包含发送者和接收者的完整信息
- 便于前端直接使用

## 触发器

### 更新时间触发器
- 自动更新 `friend_requests` 表的 `updated_at` 字段
- 确保数据修改时间的准确性

## 数据完整性

### 级联删除
- 删除用户时自动删除相关的好友关系和请求
- 确保数据一致性

### 业务约束
- 防止自引用（用户不能和自己成为好友）
- 防止重复关系
- 状态值限制

## 性能考虑

### 查询优化
- 复合索引支持常见查询模式
- 视图提供预计算的复杂查询结果

### 扩展性
- UUID主键支持分布式部署
- 时间戳字段支持数据分析和清理

## 使用示例

### 获取用户好友列表
```sql
SELECT * FROM user_friends WHERE user_id = 'user-uuid';
```

### 获取待处理的好友请求
```sql
SELECT * FROM pending_friend_requests WHERE receiver_id = 'user-uuid';
```

### 添加好友关系
```sql
INSERT INTO friendships (user_id, friend_id) VALUES ('user1-uuid', 'user2-uuid');
```

### 发送好友请求
```sql
INSERT INTO friend_requests (sender_id, receiver_id, message) 
VALUES ('user1-uuid', 'user2-uuid', '你好，我想加你为好友');
```

## 下一步
1. 执行 `add_friendship_tables.sql` 创建表结构
2. 开发后端API接口
3. 实现前端好友管理界面
4. 集成到现有评分筛选系统 