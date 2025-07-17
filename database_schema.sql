-- 用户表
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nickname VARCHAR(50) NOT NULL,
    unique_id VARCHAR(20) UNIQUE NOT NULL, -- 用户自定义的唯一标识
    password_hash VARCHAR(255) NOT NULL, -- 密码哈希
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 餐厅点评表
CREATE TABLE restaurant_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    restaurant_uid VARCHAR(100) NOT NULL, -- 百度地图POI的UID
    restaurant_name VARCHAR(200) NOT NULL,
    restaurant_address TEXT,
    restaurant_city VARCHAR(100),
    restaurant_area VARCHAR(100),
    rating VARCHAR(20) NOT NULL, -- 超爱、喜欢、一般、不会再去了
    review_text TEXT, -- 可选点评文字
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    tags TEXT[], -- 标签数组
    is_public BOOLEAN DEFAULT true, -- 是否公开给好友看
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, restaurant_uid)
);

-- 好友关系表
CREATE TABLE friendships (
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
CREATE TABLE friend_requests (
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

-- 创建索引
CREATE INDEX idx_users_unique_id ON users(unique_id);
CREATE INDEX idx_reviews_user_id ON restaurant_reviews(user_id);
CREATE INDEX idx_reviews_restaurant_uid ON restaurant_reviews(restaurant_uid);
CREATE INDEX idx_reviews_created_at ON restaurant_reviews(created_at);

-- 好友关系索引
CREATE INDEX idx_friendships_user_id ON friendships(user_id);
CREATE INDEX idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX idx_friendships_both_users ON friendships(user_id, friend_id);

-- 好友请求索引
CREATE INDEX idx_friend_requests_sender_id ON friend_requests(sender_id);
CREATE INDEX idx_friend_requests_receiver_id ON friend_requests(receiver_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);
CREATE INDEX idx_friend_requests_created_at ON friend_requests(created_at);

-- 更新时间的触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_restaurant_reviews_updated_at 
    BEFORE UPDATE ON restaurant_reviews 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_friend_requests_updated_at 
    BEFORE UPDATE ON friend_requests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 