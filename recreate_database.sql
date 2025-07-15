-- 完整的数据库重建脚本
-- 请在 Supabase SQL Editor 中执行此脚本

-- 1. 删除可能存在的旧表（如果存在）
DROP TABLE IF EXISTS restaurant_reviews CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. 删除可能存在的旧策略
DROP POLICY IF EXISTS "Users can view all users" ON users;
DROP POLICY IF EXISTS "Users can insert themselves" ON users;
DROP POLICY IF EXISTS "Users can update themselves" ON users;
DROP POLICY IF EXISTS "Users can view their own reviews" ON restaurant_reviews;
DROP POLICY IF EXISTS "Users can insert their own reviews" ON restaurant_reviews;
DROP POLICY IF EXISTS "Users can update their own reviews" ON restaurant_reviews;
DROP POLICY IF EXISTS "Users can delete their own reviews" ON restaurant_reviews;
DROP POLICY IF EXISTS "Enable all operations for users" ON users;
DROP POLICY IF EXISTS "Enable all operations for restaurant_reviews" ON restaurant_reviews;

-- 3. 创建用户表
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nickname VARCHAR(50) NOT NULL,
    unique_id VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 创建餐厅点评表
CREATE TABLE restaurant_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    restaurant_uid VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(200) NOT NULL,
    restaurant_address TEXT,
    restaurant_city VARCHAR(100),
    restaurant_area VARCHAR(100),
    rating VARCHAR(20) NOT NULL,
    review_text TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    tags TEXT[],
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, restaurant_uid)
);

-- 5. 创建索引
CREATE INDEX idx_users_unique_id ON users(unique_id);
CREATE INDEX idx_reviews_user_id ON restaurant_reviews(user_id);
CREATE INDEX idx_reviews_restaurant_uid ON restaurant_reviews(restaurant_uid);
CREATE INDEX idx_reviews_created_at ON restaurant_reviews(created_at);

-- 6. 创建更新时间触发器
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

-- 7. 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_reviews ENABLE ROW LEVEL SECURITY;

-- 8. 创建简化的 RLS 策略（允许所有操作）
CREATE POLICY "Enable all operations for users" ON users
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all operations for restaurant_reviews" ON restaurant_reviews
    FOR ALL USING (true) WITH CHECK (true);

-- 9. 验证表创建
SELECT 'Tables created successfully' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'restaurant_reviews'); 