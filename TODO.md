# RoutineReady Mobile — Outstanding Tasks

## Device & Display Auto-Detection (needs discussion + implementation)
- [ ] Design auto-detection logic: read screen size and aspect ratio at launch, auto-select the best display mode (horizontal, multi-row, auto-pan)
- [ ] Define breakpoint thresholds (e.g. >3:1 → horizontal, 4:3 → auto-pan, 16:9 → horizontal or multi-row)
- [ ] Decide whether auto-detection overrides saved settings or acts as a smart default the user can override
- [ ] iPad-specific UX: Guided Access integration notes, landscape/portrait handling, split admin/display considerations
- [ ] Mobile phone UX: admin-only? compact display mode? or block display mode entirely on small screens?
- [ ] Handle orientation changes gracefully across all form factors
- [ ] Test on real devices: iPad, Android tablet, phone, ultra-wide via Pi

## Bundle Twinkl Handwriting Fonts
- [ ] Copy font files from `/Users/triley/Projects/RoutineReady.co.uk-Web/public/fonts/` into `assets/fonts/`
  - TwinklCursiveLooped (Bold, Light, Regular, Semibold, Thin)
  - TwinklCursiveUnlooped (Bold, Light, Regular, Semibold, Thin)
  - TwinklPrecursive (Bold, Light, Regular, Semibold, Thin)
- [ ] Register all font families in `pubspec.yaml`
- [ ] Wire font selection in theme editor to use these fonts
- [ ] Ensure fonts render correctly on iOS, Android, and web

## App Icons & Splash Screens
- [ ] Design or source app icon
- [ ] Generate platform-specific icon sets (iOS, Android, web favicon)
- [ ] Configure splash screen (Android, iOS)

## Supabase / Backend
- [ ] Enable `pg_cron` extension in Supabase dashboard
- [ ] Run the `cleanup_stale_sessions()` cron schedule: `SELECT cron.schedule('cleanup-stale-sessions', '*/5 * * * *', 'SELECT cleanup_stale_sessions()')`
- [ ] Run all migrations from `supabase_migrations.sql` if not already applied

## Web Deployment
- [ ] Configure hosting for `routineready.co.uk/display` to serve the Flutter web build
- [ ] Verify `--base-href "/display/"` works correctly in production
- [ ] Test Chromium `--kiosk` mode on Raspberry Pi

## Testing & QA
- [ ] Test on physical iPad (display mode + admin mode)
- [ ] Test on Android tablet
- [ ] Test on mobile phone (expected: admin-only flow)
- [ ] Test on Raspberry Pi with Chromium kiosk
- [ ] Test realtime sync: edit on admin device → display updates within 2 seconds
- [ ] Test display slot enforcement: exceed slot limit → denied → admin-only still works
- [ ] Test backup export/import round-trip
- [ ] Test offline → reconnection flow

## Minor Polish
- [ ] Resolve 6 info-level lints (unnecessary underscores, null-aware suggestion) — cosmetic only
- [ ] iOS Guided Access documentation/guidance for teachers
