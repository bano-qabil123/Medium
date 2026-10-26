-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE claps ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_followed_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE drafts ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES POLICIES
-- ============================================

-- Users can view public profiles
CREATE POLICY "Public profiles are viewable by all"
ON profiles FOR SELECT
USING (
  auth.uid() = id OR 
  EXISTS (SELECT 1 FROM articles WHERE author_id = id AND status = 'published' AND visibility = 'public')
);

-- Users can create their own profile
CREATE POLICY "Users can create their own profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete their own profile"
ON profiles FOR DELETE
USING (auth.uid() = id);

-- ============================================
-- ARTICLES POLICIES
-- ============================================

-- Public articles are readable by all
CREATE POLICY "Public articles are readable by all"
ON articles FOR SELECT
USING (
  visibility = 'public' OR 
  visibility = 'unlisted' OR 
  author_id = auth.uid() OR
  EXISTS (SELECT 1 FROM user_follows WHERE follower_id = auth.uid() AND following_id = author_id)
);

-- Users can create their own articles
CREATE POLICY "Users can create their own articles"
ON articles FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Users can update their own articles
CREATE POLICY "Users can update their own articles"
ON articles FOR UPDATE
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);

-- Users can delete their own articles
CREATE POLICY "Users can delete their own articles"
ON articles FOR DELETE
USING (auth.uid() = author_id);

-- ============================================
-- CLAPS POLICIES
-- ============================================

-- Users can view claps on articles
CREATE POLICY "Users can view claps on articles"
ON claps FOR SELECT
USING (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND (visibility = 'public' OR author_id = auth.uid()))
);

-- Users can add claps to articles
CREATE POLICY "Users can add claps to articles"
ON claps FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND visibility = 'public')
);

-- Users can update their own claps
CREATE POLICY "Users can update their own claps"
ON claps FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own claps
CREATE POLICY "Users can delete their own claps"
ON claps FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- BOOKMARKS POLICIES
-- ============================================

-- Users can view their own bookmarks
CREATE POLICY "Users can view their own bookmarks"
ON bookmarks FOR SELECT
USING (auth.uid() = user_id);

-- Users can create bookmarks
CREATE POLICY "Users can create bookmarks"
ON bookmarks FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND (visibility = 'public' OR author_id = auth.uid()))
);

-- Users can delete their own bookmarks
CREATE POLICY "Users can delete their own bookmarks"
ON bookmarks FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- HIGHLIGHTS POLICIES
-- ============================================

-- Users can view their own highlights
CREATE POLICY "Users can view their own highlights"
ON highlights FOR SELECT
USING (auth.uid() = user_id);

-- Users can create highlights
CREATE POLICY "Users can create highlights"
ON highlights FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND (visibility = 'public' OR author_id = auth.uid()))
);

-- Users can delete their own highlights
CREATE POLICY "Users can delete their own highlights"
ON highlights FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- TAGS POLICIES
-- ============================================

-- Tags are viewable by all
CREATE POLICY "Tags are viewable by all"
ON tags FOR SELECT
USING (true);

-- Users can create tags
CREATE POLICY "Users can create tags"
ON tags FOR INSERT
WITH CHECK (true);

-- ============================================
-- ARTICLE_TAGS POLICIES
-- ============================================

-- Article tags are viewable by all
CREATE POLICY "Article tags are viewable by all"
ON article_tags FOR SELECT
USING (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND (visibility = 'public' OR author_id = auth.uid()))
);

-- Users can add tags to their own articles
CREATE POLICY "Users can add tags to their own articles"
ON article_tags FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND author_id = auth.uid())
);

-- Users can remove tags from their own articles
CREATE POLICY "Users can remove tags from their own articles"
ON article_tags FOR DELETE
USING (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND author_id = auth.uid())
);

-- ============================================
-- USER_FOLLOWED_TAGS POLICIES
-- ============================================

-- Users can view their own followed tags
CREATE POLICY "Users can view their own followed tags"
ON user_followed_tags FOR SELECT
USING (auth.uid() = user_id);

-- Users can follow tags
CREATE POLICY "Users can follow tags"
ON user_followed_tags FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can unfollow tags
CREATE POLICY "Users can unfollow tags"
ON user_followed_tags FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- ARTICLE_VIEWS POLICIES
-- ============================================

-- Users can view article views (for analytics)
CREATE POLICY "Users can view article views for their articles"
ON article_views FOR SELECT
USING (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND author_id = auth.uid())
);

-- Anyone can create article views
CREATE POLICY "Anyone can create article views"
ON article_views FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND visibility = 'public')
);

-- ============================================
-- COMMENTS POLICIES
-- ============================================

-- Users can view comments on public articles
CREATE POLICY "Users can view comments on public articles"
ON comments FOR SELECT
USING (
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND (visibility = 'public' OR author_id = auth.uid()))
);

-- Users can create comments on public articles
CREATE POLICY "Users can create comments on public articles"
ON comments FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (SELECT 1 FROM articles WHERE id = article_id AND visibility = 'public')
);

-- Users can update their own comments
CREATE POLICY "Users can update their own comments"
ON comments FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete their own comments"
ON comments FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- USER_FOLLOWS POLICIES
-- ============================================

-- Users can view who they follow and who follows them
CREATE POLICY "Users can view their own follows"
ON user_follows FOR SELECT
USING (auth.uid() = follower_id OR auth.uid() = following_id);

-- Users can follow other users
CREATE POLICY "Users can follow other users"
ON user_follows FOR INSERT
WITH CHECK (auth.uid() = follower_id);

-- Users can unfollow users
CREATE POLICY "Users can unfollow users"
ON user_follows FOR DELETE
USING (auth.uid() = follower_id);

-- ============================================
-- DRAFTS POLICIES
-- ============================================

-- Users can view their own drafts
CREATE POLICY "Users can view their own drafts"
ON drafts FOR SELECT
USING (auth.uid() = user_id);

-- Users can create drafts
CREATE POLICY "Users can create drafts"
ON drafts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own drafts
CREATE POLICY "Users can update their own drafts"
ON drafts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own drafts
CREATE POLICY "Users can delete their own drafts"
ON drafts FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to increment article views
CREATE OR REPLACE FUNCTION increment_article_views(article_id_param UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE articles 
  SET views = views + 1 
  WHERE id = article_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment claps count
CREATE OR REPLACE FUNCTION increment_claps_count(article_id_param UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE articles 
  SET claps_count = claps_count + 1 
  WHERE id = article_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement claps count
CREATE OR REPLACE FUNCTION decrement_claps_count(article_id_param UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE articles 
  SET claps_count = GREATEST(claps_count - 1, 0) 
  WHERE id = article_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get trending articles (last 7 days)
CREATE OR REPLACE FUNCTION get_trending_articles(limit_param INTEGER DEFAULT 10)
RETURNS TABLE (
  id UUID,
  title TEXT,
  slug TEXT,
  cover_image_url TEXT,
  author_id UUID,
  claps_count INTEGER,
  views INTEGER,
  published_at TIMESTAMPTZ,
  read_time_minutes INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id, a.title, a.slug, a.cover_image_url, a.author_id, 
    a.claps_count, a.views, a.published_at, a.read_time_minutes
  FROM articles a
  WHERE a.status = 'published' 
    AND a.visibility = 'public'
    AND a.published_at >= NOW() - INTERVAL '7 days'
  ORDER BY 
    (a.claps_count * 0.5 + a.views * 0.3 + (EXTRACT(EPOCH FROM (NOW() - a.published_at)) / 3600) * 0.2) DESC
  LIMIT limit_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get personalized feed
CREATE OR REPLACE FUNCTION get_personalized_feed(
  user_id_param UUID,
  limit_param INTEGER DEFAULT 10,
  offset_param INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  slug TEXT,
  content TEXT,
  excerpt TEXT,
  cover_image_url TEXT,
  author_id UUID,
  status TEXT,
  visibility TEXT,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  read_time_minutes INTEGER,
  views INTEGER,
  claps_count INTEGER,
  comments_count INTEGER,
  highlights_count INTEGER,
  author_username TEXT,
  author_avatar_url TEXT,
  author_display_name TEXT,
  is_bookmarked BOOLEAN,
  is_clapped BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  -- 50% from followed authors
  SELECT 
    a.*, 
    p.username as author_username,
    p.avatar_url as author_avatar_url,
    p.display_name as author_display_name,
    EXISTS(SELECT 1 FROM bookmarks b WHERE b.user_id = user_id_param AND b.article_id = a.id) as is_bookmarked,
    EXISTS(SELECT 1 FROM claps c WHERE c.user_id = user_id_param AND c.article_id = a.id) as is_clapped
  FROM articles a
  JOIN profiles p ON a.author_id = p.id
  JOIN user_follows uf ON p.id = uf.following_id AND uf.follower_id = user_id_param
  WHERE a.status = 'published' 
    AND a.visibility = 'public'
    AND a.author_id != user_id_param
  ORDER BY a.published_at DESC
  LIMIT (limit_param * 0.5)::INTEGER
  
  UNION ALL
  
  -- 30% from followed tags
  SELECT 
    a.*, 
    p.username as author_username,
    p.avatar_url as author_avatar_url,
    p.display_name as author_display_name,
    EXISTS(SELECT 1 FROM bookmarks b WHERE b.user_id = user_id_param AND b.article_id = a.id) as is_bookmarked,
    EXISTS(SELECT 1 FROM claps c WHERE c.user_id = user_id_param AND c.article_id = a.id) as is_clapped
  FROM articles a
  JOIN profiles p ON a.author_id = p.id
  JOIN article_tags at ON a.id = at.article_id
  JOIN user_followed_tags uft ON at.tag_id = uft.tag_id AND uft.user_id = user_id_param
  WHERE a.status = 'published' 
    AND a.visibility = 'public'
    AND a.author_id != user_id_param
  ORDER BY a.published_at DESC
  LIMIT (limit_param * 0.3)::INTEGER
  
  UNION ALL
  
  -- 20% trending
  SELECT 
    a.*, 
    p.username as author_username,
    p.avatar_url as author_avatar_url,
    p.display_name as author_display_name,
    EXISTS(SELECT 1 FROM bookmarks b WHERE b.user_id = user_id_param AND b.article_id = a.id) as is_bookmarked,
    EXISTS(SELECT 1 FROM claps c WHERE c.user_id = user_id_param AND c.article_id = a.id) as is_clapped
  FROM articles a
  JOIN profiles p ON a.author_id = p.id
  WHERE a.status = 'published' 
    AND a.visibility = 'public'
    AND a.author_id != user_id_param
    AND a.published_at >= NOW() - INTERVAL '7 days'
  ORDER BY 
    (a.claps_count * 0.5 + a.views * 0.3 + (EXTRACT(EPOCH FROM (NOW() - a.published_at)) / 3600) * 0.2) DESC
  LIMIT (limit_param * 0.2)::INTEGER
  
  OFFSET offset_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user analytics
CREATE OR REPLACE FUNCTION get_user_analytics(author_id_param UUID)
RETURNS TABLE (
  total_articles BIGINT,
  total_views BIGINT,
  total_claps BIGINT,
  total_comments BIGINT,
  total_bookmarks BIGINT,
  total_followers BIGINT,
  most_popular_article_title TEXT,
  most_popular_article_views BIGINT,
  most_popular_article_claps BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*) FROM articles WHERE author_id = author_id_param AND status = 'published') as total_articles,
    (SELECT COALESCE(SUM(views), 0) FROM articles WHERE author_id = author_id_param) as total_views,
    (SELECT COALESCE(SUM(claps_count), 0) FROM articles WHERE author_id = author_id_param) as total_claps,
    (SELECT COUNT(*) FROM comments WHERE article_id IN (SELECT id FROM articles WHERE author_id = author_id_param)) as total_comments,
    (SELECT COUNT(*) FROM bookmarks WHERE article_id IN (SELECT id FROM articles WHERE author_id = author_id_param)) as total_bookmarks,
    (SELECT COUNT(*) FROM user_follows WHERE following_id = author_id_param) as total_followers,
    (SELECT a.title FROM articles a WHERE a.author_id = author_id_param ORDER BY a.views DESC LIMIT 1) as most_popular_article_title,
    (SELECT a.views FROM articles a WHERE a.author_id = author_id_param ORDER BY a.views DESC LIMIT 1) as most_popular_article_views,
    (SELECT a.claps_count FROM articles a WHERE a.author_id = author_id_param ORDER BY a.claps_count DESC LIMIT 1) as most_popular_article_claps;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search articles
CREATE OR REPLACE FUNCTION search_articles(
  query_param TEXT,
  tag_param TEXT DEFAULT NULL,
  author_param TEXT DEFAULT NULL,
  limit_param INTEGER DEFAULT 10,
  offset_param INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  slug TEXT,
  excerpt TEXT,
  cover_image_url TEXT,
  author_id UUID,
  claps_count INTEGER,
  views INTEGER,
  published_at TIMESTAMPTZ,
  read_time_minutes INTEGER,
  author_username TEXT,
  author_avatar_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id, a.title, a.slug, a.excerpt, a.cover_image_url, a.author_id, 
    a.claps_count, a.views, a.published_at, a.read_time_minutes,
    p.username as author_username,
    p.avatar_url as author_avatar_url
  FROM articles a
  JOIN profiles p ON a.author_id = p.id
  WHERE a.status = 'published' 
    AND a.visibility = 'public'
    AND (
      query_param IS NULL 
      OR (
        a.title ILIKE '%' || query_param || '%' 
        OR a.content ILIKE '%' || query_param || '%' 
        OR a.excerpt ILIKE '%' || query_param || '%'
      )
    )
    AND (tag_param IS NULL OR EXISTS (
      SELECT 1 FROM article_tags at 
      JOIN tags t ON at.tag_id = t.id 
      WHERE at.article_id = a.id AND t.slug = tag_param
    ))
    AND (author_param IS NULL OR p.username = author_param)
  ORDER BY 
    ts_rank(
      setweight(to_tsvector('english', a.title), 'A') ||
      setweight(to_tsvector('english', a.excerpt), 'B') ||
      setweight(to_tsvector('english', a.content), 'C'),
      plainto_tsquery('english', query_param)
    ) DESC,
    a.published_at DESC
  LIMIT limit_param
  OFFSET offset_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
