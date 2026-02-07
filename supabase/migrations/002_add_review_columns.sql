-- Migration: Add last_reviewed_at and good_multiplier for per-section review system

-- Add last_reviewed_at to mastered_items
ALTER TABLE mastered_items
ADD COLUMN IF NOT EXISTS last_reviewed_at TIMESTAMP WITH TIME ZONE;

-- Add good_multiplier to user_settings
ALTER TABLE user_settings
ADD COLUMN IF NOT EXISTS good_multiplier FLOAT DEFAULT 1.5;

-- Update existing rows to have a good_multiplier default
UPDATE user_settings SET good_multiplier = 1.5 WHERE good_multiplier IS NULL;
