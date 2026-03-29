# RoutineReady — Release Checklist

Status key: `[ ]` = not started, `[~]` = in progress, `[x]` = complete

---

## Completed

- [x] Login screen with Sign In / Create Account tabs
- [x] Signup flow with duplicate detection, friendly errors
- [x] Auto-switch to Create Account tab from ?mode=signup URL
- [x] Setup wizard (paid users only)
- [x] Onboarding spotlight tour (6 steps, auto-triggers on first visit, replayable from User Settings)
- [x] Free tier: in-memory only, 5-task limit, feature gating, free tier banner
- [x] All 3 display modes (horizontal, multi-row, auto-pan)
- [x] Smooth animations: crossfade, auto-scroll, 500ms update interval
- [x] Task editor with image upload, icon picker, duration controls
- [x] Transition indicators: progress line + mascot road
- [x] Admin panel: toolbar, save, templates, weekly schedule, display settings, theme chooser/editor
- [x] User settings: account, setup info, backup/restore, sign out
- [x] RLS policies on all Supabase tables
- [x] Supabase migrations: display_sessions, subscriptions, realtime, triggers, pg_cron cleanup
- [x] Realtime sync with exponential backoff reconnection
- [x] Debounced saves (800ms) for display settings, timeline, custom themes
- [x] Security headers on Vercel (X-Content-Type-Options, X-Frame-Options, etc.)
- [x] XSS fix on landing page (esc() for all dynamic innerHTML)
- [x] RevenueCat SDK integration + subscription provider (3-source: manual, RevenueCat, free)
- [x] RevenueCat webhook Edge Function deployed
- [x] Package name set: uk.co.routineready.app (Android + iOS)
- [x] Android billing permission + FlutterFragmentActivity
- [x] Privacy policy published at routineready.co.uk/privacy.html
- [x] Vercel deployment: ./deploy.sh with --prebuilt, Git integration disconnected
- [x] Landing page: Sanity CMS visual editing, standalone HTML

---

## Remaining — Priority Order

### App Store & Play Store Assets
- [ ] App icon (1024x1024 for iOS, 512x512 adaptive for Android)
- [ ] Splash screen / launch screen
- [ ] App Store screenshots (iPad Pro 12.9", iPad Pro 11")
- [ ] Play Store screenshots (7" tablet, 10" tablet)
- [ ] Play Store feature graphic (1024x500)
- [ ] App Store metadata (title, description, keywords, category)
- [ ] Play Store metadata (already drafted — needs icon/screenshots to submit)

### RevenueCat & Payments
- [ ] Apple Developer account ($99/year) — needed for iOS + App Store
- [ ] RevenueCat project created with Apple, Google, Web (Stripe) apps
- [ ] Create products: monthly (£4.99), annual (£34.99), lifetime (£89.99)
- [ ] Create entitlement: "pro" mapped to all products
- [ ] Create offering with monthly/annual/lifetime packages
- [ ] Add API keys to revenuecat_config.dart
- [ ] Set REVENUECAT_WEBHOOK_SECRET in Supabase Edge Function env vars
- [ ] Paywall UI: native on mobile, custom on web
- [ ] Upgrade prompts at gated features (contextual, not annoying)
- [ ] Test purchase flow: sandbox (iOS), test tracks (Android), test mode (Stripe)
- [ ] Test subscription expiry → user reverts to free tier

### School Setup Flow
- [ ] Admin tool for you to create school accounts manually
- [ ] School subscription includes admin access (no App Store sub needed)
- [ ] Teacher links App Store subscription to existing school account
- [ ] School pricing page or contact form on landing page

### Device Auto-Detection
- [ ] Auto-detect screen aspect ratio at launch
- [ ] Auto-select display mode (horizontal for ultrawide, auto-pan for tablets)
- [ ] Orientation handling across form factors

### Platform Testing
- [ ] Test on physical iPad (display + admin)
- [ ] Test on physical Android tablet (display + admin)
- [ ] Test web on Chrome, Firefox, Safari, Edge
- [ ] Test ultrawide display (2560x1080)
- [ ] Test multi-device sync end-to-end (admin edits → display updates <2s)
- [ ] Test display slot enforcement
- [ ] Test kiosk mode: Android immersive, iPad Guided Access, web fullscreen

### Build & Deploy
- [ ] iOS: provisioning profiles, certificates, TestFlight build
- [ ] Android: signing key, internal testing track build
- [ ] Android: content rating + data safety section in Play Console
- [ ] App Store review submission
- [ ] Play Store production release

### Polish
- [ ] Display capacity info in display settings
- [ ] Task overflow warning
- [ ] Backup as file download (.json)
- [ ] Restore from file picker
- [ ] Custom sprite image upload
- [ ] Custom banner image upload
- [ ] Unsaved changes warning on navigation

### Test Suite
- [ ] time_utils.dart — task progress calculations
- [ ] Display engine — rendering correctness
- [ ] Auth flow — login/signup/session management
- [ ] Subscription provider — free/paid/school source logic
