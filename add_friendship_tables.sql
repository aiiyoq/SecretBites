-- 添加好友功能相关的表结构
-- 执行此文件前请确保已存在 users 表

-- 好友关系表
CREATE TABLE IF NOT EXISTS friendships (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- 确保好友关系是双向的，且不会重复
    UNIQUE(user_id, friend_id),
    -- 确保不能和自己成为好友
    CHECK (user_id != friend_id)
);

-- 好友请求表
CREATE TABLE IF NOT EXISTS friend_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    message TEXT, -- 好友请求的附加消息
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- 确保不能向自己发送好友请求
    CHECK (sender_id != receiver_id),
    -- 同一用户对同一用户只能有一个待处理的请求
    UNIQUE(sender_id, receiver_id, status)
);

-- 好友关系索引
CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_both_users ON friendships(user_id, friend_id);

-- 好友请求索引
CREATE INDEX IF NOT EXISTS idx_friend_requests_sender_id ON friend_requests(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver_id ON friend_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON friend_requests(status);
CREATE INDEX IF NOT EXISTS idx_friend_requests_created_at ON friend_requests(created_at);

-- 更新时间的触发器（如果不存在）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为好友请求表添加更新时间触发器
DROP TRIGGER IF EXISTS update_friend_requests_updated_at ON friend_requests;
CREATE TRIGGER update_friend_requests_updated_at 
    BEFORE UPDATE ON friend_requests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 添加一些有用的视图和函数

-- 获取用户好友列表的视图
CREATE OR REPLACE VIEW user_friends AS
SELECT 
    u.id as user_id,
    u.nickname as user_nickname,
    u.unique_id as user_unique_id,
    u.avatar_url as user_avatar,
    f.id as friend_id,
    f.nickname as friend_nickname,
    f.unique_id as friend_unique_id,
    f.avatar_url as friend_avatar,
    fs.created_at as friendship_created_at
FROM users u
JOIN friendships fs ON u.id = fs.user_id
JOIN users f ON fs.friend_id = f.id
UNION
SELECT 
    u.id as user_id,
    u.nickname as user_nickname,
    u.unique_id as user_unique_id,
    u.avatar_url as user_avatar,
    f.id as friend_id,
    f.nickname as friend_nickname,
    f.unique_id as friend_unique_id,
    f.avatar_url as friend_avatar,
    fs.created_at as friendship_created_at
FROM users u
JOIN friendships fs ON u.id = fs.friend_id
JOIN users f ON fs.user_id = f.id;

-- 获取待处理好友请求的视图
CREATE OR REPLACE VIEW pending_friend_requests AS
SELECT 
    fr.id as request_id,
    fr.sender_id,
    s.nickname as sender_nickname,
    s.unique_id as sender_unique_id,
    s.avatar_url as sender_avatar,
    fr.receiver_id,
    r.nickname as receiver_nickname,
    r.unique_id as receiver_unique_id,
    r.avatar_url as receiver_avatar,
    fr.message,
    fr.created_at
FROM friend_requests fr
JOIN users s ON fr.sender_id = s.id
JOIN users r ON fr.receiver_id = r.id
WHERE fr.status = 'pending'; 