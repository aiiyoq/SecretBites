# 餐厅地图评分应用

一个基于百度地图的餐厅搜索和评分应用，支持用户注册、登录和餐厅评分功能。

## 功能特性

### 🗺️ 地图功能
- 百度地图集成
- 餐厅搜索功能
- 评分标记显示
- 地图交互操作

### 👤 用户系统
- 用户注册（昵称 + 用户名 + 密码）
- 用户登录
- 会话管理
- 用户状态显示

### ⭐ 评分系统
- 餐厅评分（超爱、喜欢、一般、不会再去了）
- 评分数据持久化存储
- 评分列表显示
- 评分统计功能
- 评分筛选功能

### 📱 界面特性
- 响应式设计
- 可折叠信息面板
- 美观的用户界面
- 实时状态更新

## 技术栈

- **前端**: HTML5, CSS3, JavaScript (ES6+)
- **地图**: 百度地图 API
- **数据库**: Supabase (PostgreSQL)
- **认证**: 自定义用户认证系统

## 文件结构

```
myrestaurantmap/
├── index_friends.html          # 主应用文件
├── test_supabase.html          # Supabase 连接测试
├── supabase_config.js          # Supabase 配置文件
├── database_schema.sql         # 数据库架构
├── SUPABASE_SETUP_GUIDE.md     # Supabase 设置指南
└── README.md                   # 项目说明
```

## 快速开始

### 1. 设置 Supabase

1. 访问 [supabase.com](https://supabase.com) 创建项目
2. 在 SQL Editor 中执行 `database_schema.sql` 文件内容
3. 获取项目 URL 和 API 密钥

### 2. 配置应用

编辑 `supabase_config.js` 文件：

```javascript
const SUPABASE_CONFIG = {
    URL: 'https://your-project-id.supabase.co',
    ANON_KEY: 'your-anon-key'
};
```

### 3. 配置 RLS 策略

在 Supabase SQL Editor 中执行：

```sql
-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_reviews ENABLE ROW LEVEL SECURITY;

-- 用户表策略
CREATE POLICY "Users can view all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert themselves" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update themselves" ON users FOR UPDATE USING (true);

-- 餐厅点评表策略
CREATE POLICY "Users can view their own reviews" ON restaurant_reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert their own reviews" ON restaurant_reviews FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own reviews" ON restaurant_reviews FOR UPDATE USING (true);
CREATE POLICY "Users can delete their own reviews" ON restaurant_reviews FOR DELETE USING (true);
```

### 4. 测试连接

打开 `test_supabase.html` 文件，测试 Supabase 连接和基本功能。

### 5. 运行应用

打开 `index_friends.html` 文件开始使用应用。

## 数据库结构

### users 表
- `id`: UUID (主键)
- `nickname`: VARCHAR(50) (昵称)
- `unique_id`: VARCHAR(20) (唯一标识符)
- `password_hash`: VARCHAR(255) (密码哈希)
- `avatar_url`: TEXT (头像URL)
- `created_at`: TIMESTAMP (创建时间)
- `last_active`: TIMESTAMP (最后活跃时间)

### restaurant_reviews 表
- `id`: UUID (主键)
- `user_id`: UUID (用户ID，外键)
- `restaurant_uid`: VARCHAR(100) (餐厅唯一ID)
- `restaurant_name`: VARCHAR(200) (餐厅名称)
- `restaurant_address`: TEXT (餐厅地址)
- `restaurant_city`: VARCHAR(100) (城市)
- `restaurant_area`: VARCHAR(100) (区域)
- `rating`: VARCHAR(20) (评分等级)
- `review_text`: TEXT (点评文字)
- `latitude`: DECIMAL(10,8) (纬度)
- `longitude`: DECIMAL(11,8) (经度)
- `tags`: TEXT[] (标签数组)
- `is_public`: BOOLEAN (是否公开)
- `created_at`: TIMESTAMP (创建时间)
- `updated_at`: TIMESTAMP (更新时间)

## 使用说明

### 用户注册/登录
1. 点击右上角的"注册"或"登录"按钮
2. 填写相应信息完成注册或登录
3. 登录后可以开始使用评分功能

### 餐厅搜索
1. 在顶部搜索框输入餐厅名称
2. 点击搜索按钮或按回车键
3. 搜索结果会显示在右侧信息面板中

### 餐厅评分
1. 点击搜索结果中的餐厅或地图上的标记
2. 在餐厅详情页面选择评分等级
3. 评分会自动保存到数据库

### 查看评分
1. 点击地图空白处显示评分列表
2. 使用筛选器查看不同等级的评分
3. 点击统计按钮查看评分统计

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

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！ 