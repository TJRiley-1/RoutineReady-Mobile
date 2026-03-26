# RoutineReady Mobile — Claude Code Instructions

## What This Is

Visual classroom routine display app for children — shows predictable daily schedules on classroom screens to reduce transition anxiety, especially for autistic learners. Built in Flutter targeting Web, iOS (iPad), and Android (tablets).

## Architecture

| Layer | Technology |
|---|---|
| Framework | Flutter 3.32.2 (Web, iOS, Android) |
| State management | Riverpod (flutter_riverpod) |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Storage) |
| Hosting | Vercel (web build + landing page) |
| Payments | RevenueCat (App Store/Play Store) + Stripe (schools/web) |

### Site Structure (Vercel)
- `/` — Standalone HTML landing page with Sanity.io visual editing (NOT Flutter — Sanity requires DOM)
- `/app` — Flutter web build (classroom display + admin panel)

### Key Directories
```
lib/
  config/       — Supabase URL + anon key, theme constants
  models/       — Data classes with fromJson/toJson
  providers/    — Riverpod providers (auth, school data, realtime, sessions)
  screens/      — Auth, display modes, admin panel, mode select
  widgets/      — Shared display and admin components
  utils/        — Time calculations, theme helpers
  data/         — Preset themes, icons, transitions, defaults
public/         — Landing page HTML/CSS (served at root, separate from Flutter)
assets/fonts/   — Twinkl handwriting fonts (3 families, 5 weights each)
```

## Commands

```bash
# Run locally
flutter run -d chrome                    # Web
flutter run -d <device-id>               # iOS/Android

# Build
flutter build web --release --base-href "/app/"

# Deploy to Vercel (ALWAYS use this, never bare `vercel deploy`)
./deploy.sh                              # Build + deploy production
./deploy.sh preview                      # Build + deploy preview
./deploy.sh --skip-build                 # Deploy existing build only

# Analyze
flutter analyze
flutter test
```

## Platform Priority

1. **Web first** — pilot schools use ultra-wide displays via browser
2. **Android + iOS in parallel** — after web is solid
3. **Raspberry Pi is NOT part of this project** — removed from scope

## Important Rules

- **Landing page must NEVER be Flutter.** Flutter renders to `<canvas>`, Sanity visual editing requires HTML DOM.
- **Always use `./deploy.sh`** for Vercel deploys. `vercel deploy` alone fails because `vercel.json` buildCommand tries to run `build.sh` server-side.
- **Supabase anon key is public by design** — it's a client-side key. Security relies on Row Level Security (RLS) policies in the database.
- **Question approach before building** — flag architectural incompatibilities upfront rather than building the wrong thing.
- **No over-engineering** — build what's needed for the current task. This app needs to ship.

## Free vs Paid Tier

- **Free:** 5-task limit, in-memory only (no Supabase writes), all display modes + preset themes, no templates/schedules/custom themes/images/backup
- **Paid:** Full features, Supabase persistence, unlimited tasks, realtime sync, image upload, custom themes

## Supabase

- **Project:** zbazllzzhiugpyzalntv.supabase.co
- **Auth:** Email/password via Supabase Auth
- **Realtime:** Subscriptions on `active_timeline`, `display_settings`, `custom_themes`
- **Critical:** RLS policies must be added to all tables before production launch

## Fonts

Three Twinkl handwriting font families bundled in `assets/fonts/`:
- TwinklCursiveLooped (5 weights)
- TwinklCursiveUnlooped (5 weights)
- TwinklPrecursive (5 weights)

## Testing

No test suite exists yet. Priority areas for tests:
- `time_utils.dart` — task progress calculations
- Display engine — rendering correctness
- Auth flow — login/signup/session management
