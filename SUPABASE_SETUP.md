# Supabase Setup Instructions

Complete guide to set up Supabase for your Language Study App with authentication and cloud sync.

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project" or "Sign In" if you have an account
3. Click "New Project"
4. Fill in the details:
   - **Name**: `language-study-app` (or your preferred name)
   - **Database Password**: Create a strong password (save it somewhere safe!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is perfect to start
5. Click "Create new project"
6. Wait 1-2 minutes for project to be set up

## Step 2: Get API Keys

1. In your Supabase project dashboard, click on **Settings** (gear icon) in the left sidebar
2. Go to **API** section
3. You'll need these two values:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key**: Long string starting with `eyJ...`

4. **IMPORTANT**: Create a file `lib/supabase_config.dart` with your credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

**⚠️ SECURITY NOTE**: Add `lib/supabase_config.dart` to your `.gitignore` file to keep your keys private!

Add this line to `.gitignore`:
```
lib/supabase_config.dart
```

## Step 3: Set Up Database Schema

1. In Supabase dashboard, go to **SQL Editor** in the left sidebar
2. Click "New query"
3. Copy and paste the SQL below
4. Click "Run" to execute

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES TABLE
-- ============================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- USER STATS TABLE
-- ============================================
CREATE TABLE user_stats (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  total_xp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_study_date TIMESTAMP WITH TIME ZONE,
  selected_language TEXT DEFAULT 'ja',
  total_words_learned INTEGER DEFAULT 0,
  total_sentences_learned INTEGER DEFAULT 0,
  total_kanji_learned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_stats
CREATE POLICY "Users can view own stats"
  ON user_stats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
  ON user_stats FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats"
  ON user_stats FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- MASTERED ITEMS TABLE
-- ============================================
CREATE TABLE mastered_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  item_id TEXT NOT NULL,
  item_type TEXT NOT NULL, -- 'vocabulary', 'sentence', 'kanji'
  language_code TEXT NOT NULL, -- 'ja', 'es', 'cs', 'de', 'fr'
  japanese_text TEXT NOT NULL,
  romaji_text TEXT,
  english_text TEXT NOT NULL,
  category TEXT,
  user_note TEXT,
  mastered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, item_id, language_code)
);

-- Enable Row Level Security
ALTER TABLE mastered_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for mastered_items
CREATE POLICY "Users can view own mastered items"
  ON mastered_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mastered items"
  ON mastered_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mastered items"
  ON mastered_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own mastered items"
  ON mastered_items FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- PRACTICE ITEMS TABLE
-- ============================================
CREATE TABLE practice_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  item_id TEXT NOT NULL,
  item_type TEXT NOT NULL, -- 'vocabulary', 'sentence'
  language_code TEXT NOT NULL,
  japanese_text TEXT NOT NULL,
  romaji_text TEXT,
  english_text TEXT NOT NULL,
  category TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, item_id, language_code)
);

-- Enable Row Level Security
ALTER TABLE practice_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for practice_items
CREATE POLICY "Users can view own practice items"
  ON practice_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own practice items"
  ON practice_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own practice items"
  ON practice_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own practice items"
  ON practice_items FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to automatically create user_stats when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'username', 'Student'));

  INSERT INTO public.user_stats (user_id)
  VALUES (NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call handle_new_user on signup
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at
    BEFORE UPDATE ON user_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX idx_mastered_items_user_id ON mastered_items(user_id);
CREATE INDEX idx_mastered_items_language ON mastered_items(user_id, language_code);
CREATE INDEX idx_practice_items_user_id ON practice_items(user_id);
CREATE INDEX idx_practice_items_language ON practice_items(user_id, language_code);
```

## Step 4: Configure Email Authentication

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Make sure **Email** is enabled (it should be by default)
3. Configure email templates (optional):
   - Go to **Authentication** → **Email Templates**
   - Customize "Confirm signup", "Reset password" templates if desired

## Step 5: Configure App Settings

1. Go to **Authentication** → **URL Configuration**
2. Add your app's redirect URLs (for password reset, etc.):
   - For development: `http://localhost:3000`
   - For production: Add your actual domain

## Step 6: Test Database Connection

Run this query in SQL Editor to verify everything is set up:

```sql
SELECT
  (SELECT COUNT(*) FROM profiles) as profiles_count,
  (SELECT COUNT(*) FROM user_stats) as stats_count,
  (SELECT COUNT(*) FROM mastered_items) as mastered_count,
  (SELECT COUNT(*) FROM practice_items) as practice_count;
```

You should see all counts as 0 (empty tables ready to use).

## Step 7: Install Dependencies

Run in your Flutter project:

```bash
flutter pub get
```

## Step 8: Create Config File

Create `lib/supabase_config.dart` with your credentials (see Step 2).

Example:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGc...your-long-key-here';
}
```

## Step 9: Run Your App!

```bash
flutter run -d windows
```

Your app should now:
- Show the Welcome screen on first launch
- Allow users to sign up and sign in
- Automatically sync data to Supabase
- Support offline mode with local caching

## Troubleshooting

### "Invalid API key" error
- Double-check your `supabaseUrl` and `supabaseAnonKey` in `supabase_config.dart`
- Make sure there are no extra spaces or quotes

### "Row Level Security" errors
- Make sure all RLS policies were created successfully
- Check that the user is authenticated before accessing data

### Email not sending
- Check **Authentication** → **Email Templates** in Supabase dashboard
- For development, check the Supabase logs for email messages
- Consider using a custom SMTP provider in production

### Database connection issues
- Verify your internet connection
- Check Supabase project status at status.supabase.com
- Ensure your IP isn't blocked (Supabase allows all IPs by default)

## Security Best Practices

1. **Never commit** `supabase_config.dart` to version control
2. Use **environment variables** for production
3. Keep your **database password** secure
4. Regularly **review RLS policies**
5. Enable **2FA** on your Supabase account

## Next Steps

- Customize email templates in Supabase dashboard
- Add user avatars (use Supabase Storage)
- Set up real-time subscriptions for live updates
- Monitor usage in Supabase dashboard

Enjoy your language learning app with cloud sync! 🚀📚
