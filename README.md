# Language Study App 🐻

A cozy, warm-themed language-learning app built with Flutter, featuring **Kuma-san** — an
animated study-bear mascot who reacts to your progress, cheers you on, and chats with you.

## Features

- **Spaced-repetition reviews** with an adaptive scheduling algorithm
- **Vocabulary, kanji, and sentence** decks
- **Conversation practice** with Kuma-san (offline fallback engine; AI mode optional)
- **Achievements, stats, and streaks**
- **Customizable Kuma** with unlockable skins and seasonal outfits
- **Supabase sync** with full offline support (falls back to local storage)

## Tech stack

- Flutter (stable channel) · Provider state management
- Supabase (auth + database) with `shared_preferences` offline fallback

## Running locally

```bash
flutter pub get
flutter run
```

To run the web build locally:

```bash
flutter run -d chrome
```

## Configuration

Two config files are git-ignored and must be supplied locally:

- `lib/supabase_config.dart` — Supabase URL + anon key (the anon key is safe to expose
  publicly **only if Row Level Security is enabled** on your tables).
- `lib/config/api_keys.dart` — optional Claude API key for AI conversation mode. **Never
  ship this in a web build** — a web build compiles to public JavaScript. The AI feature is
  disabled by default; route it through a backend (e.g. a Supabase Edge Function) before
  enabling it on the web.

## Web deployment

The app auto-deploys to GitHub Pages via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)
on every push to `main`. Live site:

> https://hotpocket1177.github.io/language-learning-app/

One-time setup:

1. **Settings → Pages → Build and deployment → Source:** select **GitHub Actions**.
2. **Settings → Secrets and variables → Actions** — add two repository secrets so the
   build can recreate the git-ignored `supabase_config.dart`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

The workflow leaves the Claude API key empty, so AI conversation mode stays off on the
public web build (the offline fallback engine still works).
