-- Migration: Add Spaced Repetition System (SRS) columns to mastered_items
-- Run this in your Supabase SQL Editor

-- Add SRS columns to mastered_items table
ALTER TABLE mastered_items
ADD COLUMN IF NOT EXISTS next_review_date DATE,
ADD COLUMN IF NOT EXISTS review_interval INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS times_reviewed INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS ease_factor FLOAT DEFAULT 2.5;

-- Set default next_review_date for existing items (tomorrow)
UPDATE mastered_items
SET next_review_date = CURRENT_DATE + INTERVAL '1 day'
WHERE next_review_date IS NULL;

-- Create index for efficient review queries
CREATE INDEX IF NOT EXISTS idx_mastered_items_review
ON mastered_items(user_id, language_code, next_review_date);

-- Create user_settings table for SRS preferences
CREATE TABLE IF NOT EXISTS user_settings (
  user_id UUID REFERENCES auth.users PRIMARY KEY,
  new_words_per_day INTEGER DEFAULT 10,
  review_words_per_day INTEGER DEFAULT 20,
  auto_add_to_practice BOOLEAN DEFAULT true,
  easy_multiplier FLOAT DEFAULT 2.5,
  hard_multiplier FLOAT DEFAULT 1.2,
  min_interval INTEGER DEFAULT 1,
  max_interval INTEGER DEFAULT 365,
  daily_reminder_enabled BOOLEAN DEFAULT false,
  daily_reminder_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on user_settings
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- RLS policy: Users can only access their own settings
CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at on user_settings
DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Grant access to authenticated users
GRANT ALL ON user_settings TO authenticated;
