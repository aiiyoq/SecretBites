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

-- 创建索引
CREATE INDEX idx_users_unique_id ON users(unique_id);
CREATE INDEX idx_reviews_user_id ON restaurant_reviews(user_id);
CREATE INDEX idx_reviews_restaurant_uid ON restaurant_reviews(restaurant_uid);
CREATE INDEX idx_reviews_created_at ON restaurant_reviews(created_at);

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