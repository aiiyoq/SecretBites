# 好友功能API使用指南

## 概述
本文档详细说明了餐厅评分地图应用中好友功能的API使用方法，包括好友关系管理、好友请求处理、用户搜索和评分共享等功能。

## 快速开始

### 1. 引入API模块
```html
<!-- 引入Supabase -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="supabase_config.js"></script>

<!-- 引入好友API -->
<script src="friendship_api.js"></script>
```

### 2. 初始化API
```javascript
// 初始化Supabase客户端
const supabase = window.supabase.createClient(
    window.SUPABASE_CONFIG.URL,
    window.SUPABASE_CONFIG.ANON_KEY
);

// 创建好友API实例
const friendshipAPI = new FriendshipAPI(supabase);
```

## API功能详解

### 好友关系管理

#### 获取好友列表
```javascript
/**
 * 获取用户的好友列表
 * @param {string} userId - 用户ID
 * @returns {Promise<Array>} 好友列表
 */
const friends = await friendshipAPI.getFriendsList(userId);
```

**返回数据格式：**
```json
[
  {
    "user_id": "用户ID",
    "user_nickname": "用户昵称",
    "user_unique_id": "用户唯一标识",
    "user_avatar": "用户头像URL",
    "friend_id": "好友ID",
    "friend_nickname": "好友昵称",
    "friend_unique_id": "好友唯一标识",
    "friend_avatar": "好友头像URL",
    "friendship_created_at": "好友关系建立时间"
  }
]
```

#### 检查好友关系
```javascript
/**
 * 检查两个用户是否为好友
 * @param {string} userId1 - 用户1 ID
 * @param {string} userId2 - 用户2 ID
 * @returns {Promise<boolean>} 是否为好友
 */
const isFriend = await friendshipAPI.checkFriendship(userId1, userId2);
```

#### 删除好友
```javascript
/**
 * 删除好友关系
 * @param {string} userId - 当前用户ID
 * @param {string} friendId - 好友ID
 * @returns {Promise<boolean>} 是否成功
 */
const success = await friendshipAPI.removeFriend(userId, friendId);
```

### 好友请求管理

#### 发送好友请求
```javascript
/**
 * 发送好友请求
 * @param {string} senderId - 发送者ID
 * @param {string} receiverId - 接收者ID
 * @param {string} message - 请求消息（可选）
 * @returns {Promise<Object>} 请求结果
 */
const request = await friendshipAPI.sendFriendRequest(senderId, receiverId, "你好，我想加你为好友");
```

**返回数据格式：**
```json
{
  "id": "请求ID",
  "sender_id": "发送者ID",
  "receiver_id": "接收者ID",
  "message": "请求消息",
  "status": "pending",
  "created_at": "创建时间"
}
```

#### 获取收到的请求
```javascript
/**
 * 获取用户收到的待处理好友请求
 * @param {string} userId - 用户ID
 * @returns {Promise<Array>} 请求列表
 */
const receivedRequests = await friendshipAPI.getReceivedRequests(userId);
```

#### 获取发送的请求
```javascript
/**
 * 获取用户发送的待处理好友请求
 * @param {string} userId - 用户ID
 * @returns {Promise<Array>} 请求列表
 */
const sentRequests = await friendshipAPI.getSentRequests(userId);
```

#### 接受好友请求
```javascript
/**
 * 接受好友请求
 * @param {string} requestId - 请求ID
 * @param {string} receiverId - 接收者ID（当前用户）
 * @returns {Promise<Object>} 处理结果
 */
const result = await friendshipAPI.acceptFriendRequest(requestId, receiverId);
```

#### 拒绝好友请求
```javascript
/**
 * 拒绝好友请求
 * @param {string} requestId - 请求ID
 * @param {string} receiverId - 接收者ID（当前用户）
 * @returns {Promise<boolean>} 是否成功
 */
const success = await friendshipAPI.rejectFriendRequest(requestId, receiverId);
```

#### 取消发送的请求
```javascript
/**
 * 取消发送的好友请求
 * @param {string} requestId - 请求ID
 * @param {string} senderId - 发送者ID（当前用户）
 * @returns {Promise<boolean>} 是否成功
 */
const success = await friendshipAPI.cancelFriendRequest(requestId, senderId);
```

### 用户搜索

#### 搜索用户
```javascript
/**
 * 搜索用户（用于添加好友）
 * @param {string} searchTerm - 搜索关键词（昵称或unique_id）
 * @param {string} currentUserId - 当前用户ID（排除自己）
 * @returns {Promise<Array>} 用户列表
 */
const users = await friendshipAPI.searchUsers("张三", currentUserId);
```

**返回数据格式：**
```json
[
  {
    "id": "用户ID",
    "nickname": "用户昵称",
    "unique_id": "用户唯一标识",
    "avatar_url": "头像URL",
    "created_at": "注册时间"
  }
]
```

#### 根据unique_id获取用户
```javascript
/**
 * 根据unique_id获取用户信息
 * @param {string} uniqueId - 用户唯一标识
 * @returns {Promise<Object|null>} 用户信息
 */
const user = await friendshipAPI.getUserByUniqueId("user123");
```

### 好友评分管理

#### 获取好友评分
```javascript
/**
 * 获取好友的评分数据
 * @param {string} userId - 当前用户ID
 * @param {Array<string>} friendIds - 好友ID列表
 * @returns {Promise<Array>} 好友评分列表
 */
const friendIds = friends.map(friend => friend.friend_id);
const reviews = await friendshipAPI.getFriendsReviews(userId, friendIds);
```

#### 获取所有好友评分（包括自己）
```javascript
/**
 * 获取所有好友的评分数据（包括当前用户）
 * @param {string} userId - 当前用户ID
 * @returns {Promise<Array>} 所有评分列表
 */
const allReviews = await friendshipAPI.getAllFriendsReviews(userId);
```

**返回数据格式：**
```json
[
  {
    "id": "评分ID",
    "user_id": "用户ID",
    "restaurant_uid": "餐厅UID",
    "restaurant_name": "餐厅名称",
    "rating": "评分",
    "review_text": "点评文字",
    "created_at": "评分时间",
    "user": {
      "id": "用户ID",
      "nickname": "用户昵称",
      "unique_id": "用户唯一标识",
      "avatar_url": "头像URL"
    }
  }
]
```

## 使用示例

### 完整的好友添加流程
```javascript
// 1. 搜索用户
const users = await friendshipAPI.searchUsers("张三", currentUserId);

// 2. 检查是否已经是好友
const isFriend = await friendshipAPI.checkFriendship(currentUserId, users[0].id);

if (!isFriend) {
    // 3. 发送好友请求
    const request = await friendshipAPI.sendFriendRequest(
        currentUserId, 
        users[0].id, 
        "你好，我想加你为好友"
    );
    console.log('好友请求已发送');
} else {
    console.log('已经是好友了');
}
```

### 处理收到的好友请求
```javascript
// 1. 获取收到的请求
const receivedRequests = await friendshipAPI.getReceivedRequests(currentUserId);

// 2. 处理请求
for (const request of receivedRequests) {
    // 接受请求
    await friendshipAPI.acceptFriendRequest(request.request_id, currentUserId);
    console.log(`已接受 ${request.sender_nickname} 的好友请求`);
}
```

### 获取好友评分并显示
```javascript
// 1. 获取好友列表
const friends = await friendshipAPI.getFriendsList(currentUserId);

// 2. 获取好友评分
const friendIds = friends.map(friend => friend.friend_id);
const reviews = await friendshipAPI.getFriendsReviews(currentUserId, friendIds);

// 3. 显示评分
reviews.forEach(review => {
    console.log(`${review.user.nickname} 对 ${review.restaurant_name} 的评分: ${review.rating}`);
});
```

## 错误处理

### 常见错误类型
1. **已经是好友关系** - 尝试发送好友请求时
2. **已存在待处理的请求** - 重复发送请求时
3. **好友请求不存在** - 处理不存在的请求时
4. **数据库连接错误** - 网络或权限问题

### 错误处理示例
```javascript
try {
    const result = await friendshipAPI.sendFriendRequest(senderId, receiverId, message);
    console.log('请求发送成功:', result);
} catch (error) {
    if (error.message === '已经是好友关系') {
        console.log('该用户已经是你的好友');
    } else if (error.message === '已存在待处理的好友请求') {
        console.log('已向该用户发送过好友请求，请等待回复');
    } else {
        console.error('发送请求失败:', error.message);
    }
}
```

## 测试

### 使用测试页面
1. 打开 `friendship_api_test.html`
2. 设置当前用户ID
3. 测试各种API功能

### 测试要点
- 用户搜索功能
- 好友请求的发送和接收
- 好友关系的建立和删除
- 好友评分的获取和显示
- 错误情况的处理

## 注意事项

1. **权限控制** - 确保用户只能访问自己的数据
2. **数据一致性** - 好友关系的双向性
3. **性能优化** - 大量数据时的分页处理
4. **用户体验** - 友好的错误提示和加载状态

## 下一步

1. 集成到主应用中
2. 实现前端好友管理界面
3. 添加实时通知功能
4. 优化性能和用户体验 