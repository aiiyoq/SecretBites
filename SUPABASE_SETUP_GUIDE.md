# Supabase 设置指南

## 1. 创建 Supabase 项目

1. 访问 [supabase.com](https://supabase.com)
2. 注册/登录账户
3. 点击 "New Project"
4. 填写项目信息：
   - 项目名称：`restaurant-map-app`
   - 数据库密码：设置一个强密码
   - 地区：选择离你最近的地区

## 2. 配置数据库

### 执行数据库脚本
1. 在项目仪表板中，进入 "SQL Editor"
2. 复制 `database_schema.sql` 文件中的所有内容
3. 粘贴到 SQL Editor 中并执行

### 数据库表结构
- **users**: 用户表（存储用户信息）
- **restaurant_reviews**: 餐厅评分表（存储用户对餐厅的评分）

## 3. 获取 API 密钥

1. 在项目仪表板中，进入 "Settings" > "API"
2. 复制以下信息：
   - Project URL
   - anon public key

## 4. 更新前端配置

编辑 `supabase_config.js` 文件，替换为你的实际配置：

```javascript
const SUPABASE_CONFIG = {
    URL: 'https://your-project-id.supabase.co', // 你的项目URL
    ANON_KEY: 'your-anon-key' // 你的匿名公钥
};
```

## 5. 配置 Row Level Security (RLS)

为了安全起见，需要配置 RLS 策略。在 SQL Editor 中执行：

```sql
-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_reviews ENABLE ROW LEVEL SECURITY;

-- 用户表策略
CREATE POLICY "Users can view all users" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can insert themselves" ON users
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update themselves" ON users
    FOR UPDATE USING (true);

-- 餐厅点评表策略
CREATE POLICY "Users can view their own reviews" ON restaurant_reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own reviews" ON restaurant_reviews
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own reviews" ON restaurant_reviews
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete their own reviews" ON restaurant_reviews
    FOR DELETE USING (true);
```

## 6. 测试应用

1. 打开 `index_friends.html` 文件
2. 点击 "注册" 按钮创建账户
3. 测试各项功能：
   - 用户注册/登录
   - 餐厅搜索
   - 添加评分
   - 查看评分列表

## 功能特性

### 用户系统
- ✅ 用户注册（昵称 + 自定义唯一标识符 + 密码）
- ✅ 用户登录（唯一标识符 + 密码）
- ✅ 用户会话管理
- ✅ 密码安全存储

### 餐厅评分系统
- ✅ 餐厅搜索和评分
- ✅ 评分数据持久化存储
- ✅ 评分列表显示
- ✅ 评分统计功能

### 地图功能
- ✅ 百度地图集成
- ✅ 餐厅搜索
- ✅ 评分标记显示

## 数据存储说明

### 用户数据 (users 表)
```sql
- id: UUID (主键)
- nickname: VARCHAR(50) (昵称)
- unique_id: VARCHAR(20) (唯一标识符)
- password_hash: VARCHAR(255) (密码哈希)
- avatar_url: TEXT (头像URL)
- created_at: TIMESTAMP (创建时间)
- last_active: TIMESTAMP (最后活跃时间)
```

### 餐厅评分数据 (restaurant_reviews 表)
```sql
- id: UUID (主键)
- user_id: UUID (用户ID，外键)
- restaurant_uid: VARCHAR(100) (餐厅唯一ID)
- restaurant_name: VARCHAR(200) (餐厅名称)
- restaurant_address: TEXT (餐厅地址)
- restaurant_city: VARCHAR(100) (城市)
- restaurant_area: VARCHAR(100) (区域)
- rating: VARCHAR(20) (评分等级)
- review_text: TEXT (点评文字)
- latitude: DECIMAL(10,8) (纬度)
- longitude: DECIMAL(11,8) (经度)
- tags: TEXT[] (标签数组)
- is_public: BOOLEAN (是否公开)
- created_at: TIMESTAMP (创建时间)
- updated_at: TIMESTAMP (更新时间)
```

## 安全注意事项

1. **密码安全**: 当前使用明文存储密码，生产环境应使用 bcrypt 等哈希算法
2. **API 密钥**: 不要将 API 密钥提交到公共代码仓库
3. **RLS 策略**: 确保正确配置行级安全策略
4. **数据验证**: 在应用层添加输入验证

## 扩展建议

1. **密码哈希**: 集成 bcrypt 进行密码加密
2. **图片上传**: 添加用户头像和餐厅照片功能
3. **好友系统**: 实现用户好友关系
4. **实时通知**: 使用 Supabase Realtime 实现实时功能
5. **离线支持**: 使用 Service Worker 实现离线功能
6. **数据备份**: 定期备份数据库数据

## 故障排除

### 常见问题

1. **连接错误**: 检查 Supabase URL 和 API 密钥是否正确
2. **权限错误**: 确认 RLS 策略配置正确
3. **数据不显示**: 检查用户是否已登录
4. **评分保存失败**: 检查网络连接和数据库权限

### 调试方法

1. 打开浏览器开发者工具查看控制台错误
2. 检查 Supabase 仪表板中的日志
3. 使用 `console.log()` 调试数据流
4. 验证数据库表结构和数据 