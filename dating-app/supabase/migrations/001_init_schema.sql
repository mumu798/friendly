-- 交友网站数据库初始化脚本
-- 基于Supabase PostgreSQL

-- 1. 用户资料表（扩展Supabase Auth用户）
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    nickname TEXT NOT NULL,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    birthday DATE,
    city TEXT,
    bio TEXT,
    interests JSONB DEFAULT '[]'::jsonb,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 点赞表
CREATE TABLE IF NOT EXISTS public.likes (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    target_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, target_id)
);

-- 3. 匹配表
CREATE TABLE IF NOT EXISTS public.matches (
    id BIGSERIAL PRIMARY KEY,
    user_a UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_b UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_a, user_b)
);

-- 4. 消息表
CREATE TABLE IF NOT EXISTS public.messages (
    id BIGSERIAL PRIMARY KEY,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    type TEXT CHECK (type IN ('text', 'image')) DEFAULT 'text',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 动态表（可选功能）
CREATE TABLE IF NOT EXISTS public.posts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT,
    images JSONB DEFAULT '[]'::jsonb,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. 动态点赞表
CREATE TABLE IF NOT EXISTS public.post_likes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- 创建索引优化查询性能
CREATE INDEX idx_likes_user_id ON public.likes(user_id);
CREATE INDEX idx_likes_target_id ON public.likes(target_id);
CREATE INDEX idx_matches_user_a ON public.matches(user_a);
CREATE INDEX idx_matches_user_b ON public.matches(user_b);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON public.messages(receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at);
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_post_likes_post_id ON public.post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON public.post_likes(user_id);

-- 启用行级安全（RLS）
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- 创建RLS策略

-- 用户资料策略
CREATE POLICY "用户可查看所有公开资料" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "用户只能更新自己的资料" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "用户只能插入自己的资料" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 点赞策略
CREATE POLICY "用户可查看所有点赞" ON public.likes
    FOR SELECT USING (true);

CREATE POLICY "用户只能创建自己的点赞" ON public.likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户只能删除自己的点赞" ON public.likes
    FOR DELETE USING (auth.uid() = user_id);

-- 匹配策略
CREATE POLICY "用户可查看自己的匹配" ON public.matches
    FOR SELECT USING (auth.uid() = user_a OR auth.uid() = user_b);

-- 消息策略
CREATE POLICY "用户只能查看与自己相关的消息" ON public.messages
    FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "用户只能发送消息" ON public.messages
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "用户只能更新自己发送的消息" ON public.messages
    FOR UPDATE USING (auth.uid() = sender_id);

-- 动态策略
CREATE POLICY "用户可查看所有动态" ON public.posts
    FOR SELECT USING (true);

CREATE POLICY "用户只能创建自己的动态" ON public.posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户只能更新自己的动态" ON public.posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "用户只能删除自己的动态" ON public.posts
    FOR DELETE USING (auth.uid() = user_id);

-- 动态点赞策略
CREATE POLICY "用户可查看所有动态点赞" ON public.post_likes
    FOR SELECT USING (true);

CREATE POLICY "用户只能点赞一次" ON public.post_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户只能取消自己的点赞" ON public.post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- 创建自动更新updated_at的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要自动更新的表创建触发器
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建新用户自动插入profiles的触发器
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, nickname)
    VALUES (NEW.id, NEW.email);
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 授予权限给anon和authenticated角色
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- 创建存储桶用于用户头像
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- 创建存储桶用于动态图片
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('posts', 'posts', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']);