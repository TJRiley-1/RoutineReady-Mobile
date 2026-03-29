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
- [x] Delete account page published at routineready.co.uk/delete-account.html
- [x] Vercel deployment: ./deploy.sh with --prebuilt, Git integration disconnected
- [x] Landing page: Sanity CMS visual editing, standalone HTML
- [x] Google Play Console: app created, 10/11 app info steps complete
- [x] RevenueCat project created (RoutineReady)

---

## Remaining — Step-by-Step Launch Order

### Phase A: Web Launch (first platform to ship)

**A1. Build & test the web app**
- [ ] Test web on Chrome, Firefox, Safari, Edge
- [ ] Test ultrawide display (2560x1080)
- [ ] Test multi-device sync end-to-end (admin edits → display updates <2s)
- [ ] Test kiosk mode: web fullscreen (Chromium)

**A2. Stripe setup (web payments)**
- [ ] Create Stripe account (if not already done)
- [ ] Add Stripe app to RevenueCat project
- [ ] Create Stripe products: monthly (£4.99), annual (£34.99), lifetime (£89.99)
- [ ] Map Stripe products to RevenueCat `pro` entitlement
- [ ] Add RevenueCat web API key to revenuecat_config.dart
- [ ] Set REVENUECAT_WEBHOOK_SECRET in Supabase Edge Function env vars
- [ ] Test Stripe purchase flow in test mode

**A3. Paywall & upgrade prompts (web)**
- [ ] Paywall UI: custom web paywall (Stripe checkout)
- [ ] Upgrade prompts at gated features (contextual, not annoying)
- [ ] Test subscription expiry → user reverts to free tier

**A4. Polish**
- [ ] Device auto-detection: auto-detect screen aspect ratio at launch
- [ ] Auto-select display mode (horizontal for ultrawide, auto-pan for tablets)
- [ ] Display capacity info in display settings
- [ ] Task overflow warning
- [ ] Unsaved changes warning on navigation

**A5. School setup**
- [ ] Admin tool to create school accounts manually
- [ ] School subscription includes admin access (no App Store sub needed)
- [ ] School pricing page or contact form on landing page

**A6. Deploy web to pilot schools**
- [ ] Final testing on pilot school hardware
- [ ] Go live at routineready.co.uk/app

---

### Phase B: Android Launch (after web is stable)

**B1. Build the APK/AAB**
- [ ] Android signing key (upload keystore)
- [ ] Build release AAB
- [ ] Upload first AAB to Play Console internal testing track

**B2. Play Console setup (requires uploaded build)**
- [ ] Add Google Play service account JSON to RevenueCat (API access appears after first upload)
- [ ] Create Play Store subscription products: monthly (£4.99), annual (£34.99)
- [ ] Create Play Store in-app product: lifetime (£89.99)
- [ ] Map Google Play products to RevenueCat `pro` entitlement
- [ ] Create RevenueCat offering with monthly/annual/lifetime packages
- [ ] Add RevenueCat Google API key to revenuecat_config.dart

**B3. Store listing assets**
- [ ] App icon (512x512 adaptive for Android)
- [ ] Play Store screenshots (7" tablet, 10" tablet)
- [ ] Play Store feature graphic (1024x500)
- [ ] Splash screen / launch screen
- [ ] Complete store listing (metadata already drafted)

**B4. Android testing**
- [ ] Test on physical Android tablet (display + admin)
- [ ] Test kiosk mode: Android immersive
- [ ] Test purchase flow: Google Play test tracks
- [ ] Content rating + data safety section in Play Console
- [ ] Orientation handling across form factors

**B5. Android release**
- [ ] Internal testing → closed testing → production release
- [ ] Play Store production release

---

### Phase C: iOS / iPad Launch (after Android)

**C1. Apple Developer setup**
- [ ] Apple Developer account ($99/year)
- [ ] Add Apple App Store app to RevenueCat project
- [ ] Create App Store Connect app entry

**C2. Build**
- [ ] iOS provisioning profiles + certificates
- [ ] Build IPA / TestFlight build

**C3. App Store products**
- [ ] Create App Store subscription products: monthly (£4.99), annual (£34.99)
- [ ] Create App Store in-app purchase: lifetime (£89.99)
- [ ] Map Apple products to RevenueCat `pro` entitlement
- [ ] Add RevenueCat Apple API key to revenuecat_config.dart

**C4. Store listing assets**
- [ ] App icon (1024x1024 for iOS)
- [ ] App Store screenshots (iPad Pro 12.9", iPad Pro 11")
- [ ] App Store metadata (title, description, keywords, category)

**C5. iOS testing**
- [ ] Test on physical iPad (display + admin)
- [ ] Test kiosk mode: iPad Guided Access
- [ ] Test purchase flow: sandbox (iOS)
- [ ] Teacher links App Store subscription to existing school account

**C6. iOS release**
- [ ] App Store review submission
- [ ] App Store production release

---

### Ongoing (any phase)

**Backup & restore**
- [ ] Backup as file download (.json)
- [ ] Restore from file picker

**Customisation**
- [ ] Custom sprite image upload
- [ ] Custom banner image upload

**Test suite**
- [ ] time_utils.dart — task progress calculations
- [ ] Display engine — rendering correctness
- [ ] Auth flow — login/signup/session management
- [ ] Subscription provider — free/paid/school source logic
