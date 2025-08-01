# SecretBites 餐厅地图评分应用 - 技术文档

## 项目概述

**SecretBites** 是一个基于Web的餐厅地图评分应用，集成了百度地图API和Supabase数据库，为用户提供餐厅搜索、评分、分享和社交功能。该项目采用现代化的前端技术栈，实现了完整的用户认证、数据管理和社交互动功能。

### 项目亮点
- 🗺️ **地图集成**: 深度集成百度地图API，提供直观的地理位置服务
- 👥 **社交功能**: 完整的好友系统，支持用户互动和评分分享
- 📊 **数据可视化**: 实时评分统计和筛选功能
- 🔐 **安全认证**: 基于Supabase的用户认证和数据安全
- 📱 **响应式设计**: 适配多种设备尺寸的现代化UI

## 技术架构

### 整体架构图
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端应用层     │    │    API服务层     │    │   数据存储层     │
│                 │    │                 │    │                 │
│ • HTML5/CSS3    │◄──►│ • Supabase API  │◄──►│ • PostgreSQL    │
│ • JavaScript    │    │ • 百度地图API    │    │ • 实时数据库     │
│ • 响应式UI      │    │ • 自定义API      │    │ • 文件存储       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 架构特点
- **前后端分离**: 纯前端应用，通过API与后端服务交互
- **云原生**: 基于Supabase云服务，无需自建服务器
- **实时性**: 支持实时数据同步和通知
- **可扩展性**: 模块化设计，易于功能扩展

## 技术栈详解

### 前端技术栈
| 技术 | 版本 | 用途 | 优势 |
|------|------|------|------|
| **HTML5** | 最新 | 页面结构 | 语义化标签，SEO友好 |
| **CSS3** | 最新 | 样式设计 | Flexbox/Grid布局，响应式设计 |
| **JavaScript** | ES6+ | 业务逻辑 | 现代语法，模块化开发 |
| **百度地图API** | 最新 | 地图服务 | 中文地图数据，丰富的POI信息 |

### 后端技术栈
| 技术 | 版本 | 用途 | 优势 |
|------|------|------|------|
| **Supabase** | 最新 | 后端服务 | 开箱即用的BaaS服务 |
| **PostgreSQL** | 13+ | 数据库 | 强大的关系型数据库 |
| **Row Level Security** | - | 数据安全 | 细粒度的权限控制 |
| **Real-time** | - | 实时功能 | WebSocket实时通信 |

### 开发工具
- **版本控制**: Git + GitHub
- **代码编辑器**: VS Code
- **API测试**: 浏览器开发者工具
- **数据库管理**: Supabase Dashboard

## 核心功能模块

### 1. 用户认证模块
**技术实现**: 基于Supabase Auth的自定义认证系统

#### 功能特性
- 用户注册（昵称 + 用户名 + 密码）
- 用户登录和会话管理
- 用户状态持久化
- 安全的密码存储

#### 技术要点
```javascript
// 用户注册示例
async function registerUser(nickname, uniqueId, password) {
    const { data, error } = await supabase
        .from('users')
        .insert([{
            nickname: nickname,
            unique_id: uniqueId,
            password_hash: password // 生产环境应使用bcrypt
        }]);
}
```

#### 安全考虑
- 密码哈希存储（生产环境需使用bcrypt）
- Row Level Security (RLS) 策略
- 会话管理和超时机制

### 2. 地图服务模块
**技术实现**: 百度地图API深度集成

#### 功能特性
- 餐厅搜索和POI展示
- 地图标记和交互
- 地理位置服务
- 自定义标记样式

#### 技术要点
```javascript
// 地图初始化
const map = new BMap.Map("map");
const point = new BMap.Point(116.404, 39.915);
map.centerAndZoom(point, 15);

// 餐厅搜索
const local = new BMap.LocalSearch(map, {
    onSearchComplete: function(results) {
        // 处理搜索结果
    }
});
```

#### 性能优化
- 地图瓦片缓存
- 标记聚合优化
- 异步数据加载

### 3. 评分系统模块
**技术实现**: 基于PostgreSQL的数据存储和查询

#### 功能特性
- 餐厅评分（超爱、喜欢、一般、不会再去了）
- 评分数据持久化
- 评分统计和分析
- 评分筛选和搜索

#### 数据库设计
```sql
CREATE TABLE restaurant_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    restaurant_uid VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(200) NOT NULL,
    rating VARCHAR(20) NOT NULL,
    review_text TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    tags TEXT[],
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, restaurant_uid)
);
```

#### 查询优化
- 复合索引优化
- 分页查询
- 缓存策略

### 4. 社交功能模块
**技术实现**: 完整的好友关系管理系统

#### 功能特性
- 好友关系管理
- 好友请求系统
- 用户搜索功能
- 评分分享和查看

#### 数据库设计
```sql
-- 好友关系表
CREATE TABLE friendships (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id)
);

-- 好友请求表
CREATE TABLE friend_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### API设计
```javascript
class FriendshipAPI {
    // 获取好友列表
    async getFriendsList(userId) { /* ... */ }
    
    // 发送好友请求
    async sendFriendRequest(senderId, receiverId, message) { /* ... */ }
    
    // 处理好友请求
    async acceptFriendRequest(requestId, receiverId) { /* ... */ }
    
    // 获取好友评分
    async getFriendsReviews(userId, friendIds) { /* ... */ }
}
```

### 5. 数据可视化模块
**技术实现**: 基于Canvas和SVG的数据展示

#### 功能特性
- 评分统计图表
- 地图标记聚合
- 实时数据更新
- 交互式筛选

#### 技术要点
```javascript
// 评分统计
function generateRatingStats(reviews) {
    const stats = {
        '超爱': 0, '喜欢': 0, '一般': 0, '不会再去了': 0
    };
    reviews.forEach(review => {
        stats[review.rating]++;
    });
    return stats;
}
```

## 数据库设计

### 表结构设计
1. **users表**: 用户基本信息
2. **restaurant_reviews表**: 餐厅评分数据
3. **friendships表**: 好友关系
4. **friend_requests表**: 好友请求

### 索引优化
```sql
-- 用户表索引
CREATE INDEX idx_users_unique_id ON users(unique_id);

-- 评分表索引
CREATE INDEX idx_reviews_user_id ON restaurant_reviews(user_id);
CREATE INDEX idx_reviews_restaurant_uid ON restaurant_reviews(restaurant_uid);
CREATE INDEX idx_reviews_created_at ON restaurant_reviews(created_at);

-- 好友关系索引
CREATE INDEX idx_friendships_both_users ON friendships(user_id, friend_id);
```

### 数据安全
- **Row Level Security (RLS)**: 细粒度权限控制
- **数据验证**: 应用层和数据库层双重验证
- **备份策略**: 定期数据备份

## 性能优化

### 前端优化
1. **资源加载优化**
   - 地图API异步加载
   - CSS/JS文件压缩
   - 图片懒加载

2. **交互性能优化**
   - 防抖和节流
   - 虚拟滚动
   - 缓存策略

3. **用户体验优化**
   - 加载状态提示
   - 错误处理机制
   - 响应式设计

### 后端优化
1. **数据库优化**
   - 索引策略
   - 查询优化
   - 连接池管理

2. **API优化**
   - 分页查询
   - 数据缓存
   - 异步处理

## 安全考虑

### 数据安全
- **密码安全**: 哈希存储（生产环境需使用bcrypt）
- **API安全**: 密钥管理和访问控制
- **数据验证**: 输入验证和SQL注入防护

### 权限控制
- **RLS策略**: 数据库级别的权限控制
- **用户隔离**: 用户数据隔离
- **操作审计**: 关键操作日志记录

## 部署和运维

### 部署架构
```
GitHub Repository
       ↓
   GitHub Pages / Vercel
       ↓
   Supabase Cloud
       ↓
   PostgreSQL Database
```

### 监控和维护
- **性能监控**: 页面加载时间、API响应时间
- **错误监控**: 前端错误捕获、后端日志分析
- **用户分析**: 用户行为数据收集

## 项目亮点和技术难点

### 技术亮点
1. **地图集成**: 深度集成百度地图API，实现复杂的POI搜索和标记管理
2. **实时数据**: 基于Supabase的实时数据同步功能
3. **社交系统**: 完整的好友关系管理系统，包括请求处理和数据共享
4. **响应式设计**: 适配多种设备尺寸的现代化UI设计

### 技术难点及解决方案
1. **地图性能优化**
   - 问题: 大量标记导致地图卡顿
   - 解决: 实现标记聚合和分页加载

2. **数据一致性**
   - 问题: 好友关系的双向性维护
   - 解决: 数据库约束和事务处理

3. **实时通信**
   - 问题: 好友请求的实时通知
   - 解决: Supabase Realtime功能

4. **用户体验**
   - 问题: 复杂交互的用户体验优化
   - 解决: 加载状态、错误处理和响应式设计

## 扩展计划

### 短期计划
1. **移动端优化**: 开发PWA应用
2. **图片上传**: 支持用户头像和餐厅照片
3. **推荐系统**: 基于用户行为的餐厅推荐

### 长期计划
1. **AI集成**: 智能餐厅推荐和评分预测
2. **多语言支持**: 国际化功能
3. **第三方集成**: 外卖平台API集成

## 总结

SecretBites项目展示了现代Web应用开发的完整技术栈，涵盖了前端开发、后端服务、数据库设计、API开发、安全控制等多个技术领域。项目采用云原生架构，具有良好的可扩展性和维护性，为后续功能扩展奠定了坚实基础。

### 技术收获
- 掌握了现代前端开发技术栈
- 深入理解了云服务架构设计
- 积累了完整的项目开发经验
- 提升了问题解决和技术选型能力

### 项目价值
- 解决了用户餐厅选择和分享的实际需求
- 展示了完整的技术解决方案
- 体现了工程化思维和代码质量意识
- 为求职提供了有力的技术证明 