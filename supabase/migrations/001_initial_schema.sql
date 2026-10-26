-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Users profile table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT DEFAULT 'https://api.dicebear.com/7.x/avataaars/svg?seed=default',
  website TEXT,
  twitter TEXT,
  instagram TEXT,
  linkedin TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Articles table
CREATE TABLE IF NOT EXISTS articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  content TEXT NOT NULL,
  excerpt TEXT,
  cover_image_url TEXT,
  author_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  visibility TEXT DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'unlisted')),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  read_time_minutes INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  claps_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  highlights_count INTEGER DEFAULT 0
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_articles_updated_at ON articles;
CREATE TRIGGER update_articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Claps table
CREATE TABLE IF NOT EXISTS claps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, article_id)
);

-- Bookmarks table
CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, article_id)
);

-- Highlights table
CREATE TABLE IF NOT EXISTS highlights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  start_index INTEGER NOT NULL,
  end_index INTEGER NOT NULL,
  color TEXT DEFAULT 'FFFFD700',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  articles_count INTEGER DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Article Tags (junction table)
CREATE TABLE IF NOT EXISTS article_tags (
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (article_id, tag_id)
);

-- User Followed Tags
CREATE TABLE IF NOT EXISTS user_followed_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, tag_id)
);

-- Article Views
CREATE TABLE IF NOT EXISTS article_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  referrer TEXT,
  device_info TEXT
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Follows (for following authors)
CREATE TABLE IF NOT EXISTS user_follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- Drafts table (for auto-save)
CREATE TABLE IF NOT EXISTS drafts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT,
  cover_image_url TEXT,
  tags TEXT[],
  excerpt TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to update drafts
CREATE OR REPLACE FUNCTION update_drafts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_drafts_updated_at ON drafts;
CREATE TRIGGER update_drafts_updated_at
  BEFORE UPDATE ON drafts
  FOR EACH ROW
  EXECUTE FUNCTION update_drafts_updated_at();

-- Function to update comments updated_at
CREATE OR REPLACE FUNCTION update_comments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW
  EXECUTE FUNCTION update_comments_updated_at();

-- Function to update claps updated_at
CREATE OR REPLACE FUNCTION update_claps_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_claps_updated_at ON claps;
CREATE TRIGGER update_claps_updated_at
  BEFORE UPDATE ON claps
  FOR EACH ROW
  EXECUTE FUNCTION update_claps_updated_at();
