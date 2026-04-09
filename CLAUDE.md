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

1. **Web first** — pilot schools use ultra-wide displays via browser (or Pi kiosk)
2. **Android** — native app if factory confirms GMS on built-in Android panels
3. **iOS** — iPad admin interface (lower priority)

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

## Hardware Deployment Context

- **Display hardware:** Wall-mounted ultra-wide stretch panel sourced from Chinese factories. Physical size target: 900-1200mm wide x 200-350mm high (aspect ratios roughly 2.6:1 to 6:1). Resolution TBD pending factory confirmation — will be non-standard ultra-wide.
- **Installation:** Tim installs all hardware personally. Schools never configure hardware themselves.
- **Two hardware routes under evaluation** (pending factory confirmation of GMS/Google Play Store support):
  - **Route A (preferred if GMS confirmed):** Display with built-in Android 11, GMS-certified. School installs native Flutter Android app from Google Play. The +$50 Android option from factory.
  - **Route B (fallback if GMS not confirmed):** Display-only panel driven by Raspberry Pi 5. Pi runs Chromium in kiosk mode pointing at the Flutter web build on Vercel. Pi outputs native resolution via custom `video=` parameter in `/boot/firmware/cmdline.txt` (e.g. `video=HDMI-A-1:3840x1080M@60D`). SD cards pre-configured by Tim and cloned per deployment.
- **Display is view-only.** Teachers manage schedules via their own laptop/phone on the web app. The physical display is mounted out of reach of children and cannot be touched.
- **Subscription model:** Hardware included in per-display monthly subscription. Tim personally installs each unit. Target: 6-20 classrooms in first 12 months.
- **Offline resilience is critical.** The display must continue showing the last known schedule if internet drops. Teachers being unable to make changes during an outage is acceptable — the display going blank is not. Implemented via `shared_preferences` caching in providers (`schedule_cache.dart`).
- **Ultra-wide layout:** The Flutter web app must render correctly across a range of ultra-wide aspect ratios (~2.6:1 to ~6:1). The timeline display is naturally suited to wide horizontal layouts but needs testing at these extreme ratios. Resolution and exact aspect ratio are not yet finalised.

## Testing

No test suite exists yet. Priority areas for tests:
- `time_utils.dart` — task progress calculations
- Display engine — rendering correctness
- Auth flow — login/signup/session management
