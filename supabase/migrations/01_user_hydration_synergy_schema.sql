-- =============================================================================
-- Infinity Wellness: User Credentials, Health Profile & 1-on-1 Friend Synergy
-- Migration 01: Profiles, Hydration Logs, Synergy Pairs & Realtime Nudges
-- (100% Idempotent - Safe to run & re-run multiple times in Supabase SQL Editor)
-- =============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. Profiles Table (User Credentials & Health Biometrics)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT DEFAULT 'Infinity Member',
    avatar_url TEXT,
    gender TEXT DEFAULT 'Prefer not to say',
    age INT DEFAULT 22,
    weight_kg NUMERIC(5,2) DEFAULT 68.0,
    height_cm NUMERIC(5,2) DEFAULT 175.0,
    activity_level TEXT DEFAULT 'Moderate Active',
    daily_water_goal_ml INT DEFAULT 2600,
    wellness_points_balance INT DEFAULT 500,
    invite_code TEXT UNIQUE,
    current_streak INT DEFAULT 0,
    is_onboarded BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure newly added columns exist if table was previously created
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT 'Prefer not to say';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS age INT DEFAULT 22;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS weight_kg NUMERIC(5,2) DEFAULT 68.0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS height_cm NUMERIC(5,2) DEFAULT 175.0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS activity_level TEXT DEFAULT 'Moderate Active';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS daily_water_goal_ml INT DEFAULT 2600;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS wellness_points_balance INT DEFAULT 500;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_streak INT DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_onboarded BOOLEAN DEFAULT false;

-- Index for fast invite code lookups
CREATE INDEX IF NOT EXISTS idx_profiles_invite_code ON public.profiles(invite_code);

-- Generate random 6-character alphanumeric invite code helper function
CREATE OR REPLACE FUNCTION public.generate_unique_invite_code()
RETURNS TEXT AS $$
DECLARE
    characters TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    result TEXT := '';
    i INT;
BEGIN
    FOR i IN 1..6 LOOP
        result := result || substr(characters, floor(random() * length(characters) + 1)::INT, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-create profile on auth.users sign up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_invite_code TEXT;
    code_exists BOOLEAN := TRUE;
BEGIN
    -- Ensure unique invite code
    WHILE code_exists LOOP
        new_invite_code := public.generate_unique_invite_code();
        SELECT EXISTS (SELECT 1 FROM public.profiles WHERE invite_code = new_invite_code) INTO code_exists;
    END LOOP;

    INSERT INTO public.profiles (
        id,
        email,
        display_name,
        avatar_url,
        invite_code,
        weight_kg,
        height_cm,
        activity_level,
        daily_water_goal_ml,
        wellness_points_balance,
        current_streak,
        is_onboarded,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        COALESCE(NEW.email, ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(COALESCE(NEW.email, 'User'), '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture', ''),
        new_invite_code,
        68.0,
        175.0,
        'Moderate Active',
        2600,
        500, -- Welcome bonus points
        0,
        false,
        now(),
        now()
    ) ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        display_name = COALESCE(EXCLUDED.display_name, public.profiles.display_name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url),
        updated_at = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind trigger to auth.users safely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- -----------------------------------------------------------------------------
-- 2. Hydration Logs Table (Personal Water Intake Sessions)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.hydration_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount_ml INT NOT NULL CHECK (amount_ml > 0),
    beverage_type TEXT DEFAULT 'Pure Water',
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    logged_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure log_date exists if table was previously created
ALTER TABLE public.hydration_logs ADD COLUMN IF NOT EXISTS log_date DATE DEFAULT CURRENT_DATE;
UPDATE public.hydration_logs SET log_date = DATE(logged_at) WHERE log_date IS NULL;

CREATE INDEX IF NOT EXISTS idx_hydration_logs_user_date ON public.hydration_logs(user_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_hydration_logs_user_log_date ON public.hydration_logs(user_id, log_date, logged_at DESC);

-- -----------------------------------------------------------------------------
-- 3. Friend Synergy Pairs Table (Strictly 1-on-1 Mutual Accountability)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.friend_synergy_pairs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_b_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('pending', 'active', 'rejected', 'disconnected')),
    streak_count INT NOT NULL DEFAULT 0,
    last_synced_date DATE,
    theme_key TEXT DEFAULT 'love',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT no_self_pairing CHECK (user_a_id <> user_b_id)
);

-- Unique pairing constraint (unordered pair check)
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_active_pair
    ON public.friend_synergy_pairs (LEAST(user_a_id, user_b_id), GREATEST(user_a_id, user_b_id))
    WHERE status IN ('pending', 'active');

-- -----------------------------------------------------------------------------
-- 4. Synergy Nudges Table (Realtime Water & Screen Break Alerts)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.synergy_nudges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    nudge_type TEXT NOT NULL CHECK (nudge_type IN ('hydrate', 'screen_break', 'cheer')),
    message TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_synergy_nudges_receiver ON public.synergy_nudges(receiver_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- 5. Saved Posts Table (Personal Bookmarks)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.saved_feed_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    post_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT DEFAULT 'General',
    author_name TEXT DEFAULT 'Infinity Author',
    saved_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_user_saved_post UNIQUE (user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_feed_posts_user ON public.saved_feed_posts(user_id, saved_at DESC);

-- -----------------------------------------------------------------------------
-- 6. Row Level Security (RLS) Policies (Idempotent Drop + Create)
-- -----------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hydration_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_synergy_pairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.synergy_nudges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_feed_posts ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
DROP POLICY IF EXISTS "Users can view all registered profiles for pairing" ON public.profiles;
CREATE POLICY "Users can view all registered profiles for pairing"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Hydration Logs Policies
DROP POLICY IF EXISTS "Users can view own and partner hydration logs" ON public.hydration_logs;
CREATE POLICY "Users can view own and partner hydration logs"
    ON public.hydration_logs FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.friend_synergy_pairs
            WHERE status = 'active'
              AND ((user_a_id = auth.uid() AND user_b_id = hydration_logs.user_id)
                OR (user_b_id = auth.uid() AND user_a_id = hydration_logs.user_id))
        )
    );

DROP POLICY IF EXISTS "Users can insert their own hydration logs" ON public.hydration_logs;
CREATE POLICY "Users can insert their own hydration logs"
    ON public.hydration_logs FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete their own hydration logs" ON public.hydration_logs;
CREATE POLICY "Users can delete their own hydration logs"
    ON public.hydration_logs FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());

-- Friend Synergy Pairs Policies
DROP POLICY IF EXISTS "Users can view synergy pairs they belong to" ON public.friend_synergy_pairs;
CREATE POLICY "Users can view synergy pairs they belong to"
    ON public.friend_synergy_pairs FOR SELECT
    TO authenticated
    USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert synergy pairs" ON public.friend_synergy_pairs;
CREATE POLICY "Users can insert synergy pairs"
    ON public.friend_synergy_pairs FOR INSERT
    TO authenticated
    WITH CHECK (user_a_id = auth.uid() OR user_b_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their synergy pairs" ON public.friend_synergy_pairs;
CREATE POLICY "Users can update their synergy pairs"
    ON public.friend_synergy_pairs FOR UPDATE
    TO authenticated
    USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- Synergy Nudges Policies
DROP POLICY IF EXISTS "Users can view nudges where they are sender or receiver" ON public.synergy_nudges;
CREATE POLICY "Users can view nudges where they are sender or receiver"
    ON public.synergy_nudges FOR SELECT
    TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid());

DROP POLICY IF EXISTS "Users can send nudges" ON public.synergy_nudges;
CREATE POLICY "Users can send nudges"
    ON public.synergy_nudges FOR INSERT
    TO authenticated
    WITH CHECK (sender_id = auth.uid());

DROP POLICY IF EXISTS "Receivers can mark nudges as read" ON public.synergy_nudges;
CREATE POLICY "Receivers can mark nudges as read"
    ON public.synergy_nudges FOR UPDATE
    TO authenticated
    USING (receiver_id = auth.uid());

-- Saved Posts Policies
DROP POLICY IF EXISTS "Users can view own saved posts" ON public.saved_feed_posts;
CREATE POLICY "Users can view own saved posts"
    ON public.saved_feed_posts FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can save posts" ON public.saved_feed_posts;
CREATE POLICY "Users can save posts"
    ON public.saved_feed_posts FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can remove saved posts" ON public.saved_feed_posts;
CREATE POLICY "Users can remove saved posts"
    ON public.saved_feed_posts FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 7. Supabase Realtime Publication Setup (Safe Block)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'hydration_logs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.hydration_logs;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'synergy_nudges'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.synergy_nudges;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'friend_synergy_pairs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.friend_synergy_pairs;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'profiles'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'saved_feed_posts'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.saved_feed_posts;
    END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 8. Schema Permissions for API roles (anon & authenticated)
-- -----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated;
