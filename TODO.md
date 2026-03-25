# RoutineReady — Release Checklist

Minimum standard: feature parity with the current web application at routineready.co.uk.

Status key: `[ ]` = not started, `[~]` = partially done, `[x]` = complete

---

## All Platforms (Shared Flutter Code)

These must be completed before ANY platform can release.

### Authentication & Onboarding
- [~] **Login screen** — sign-in works, but missing:
  - [ ] Free tier signup tab (email + password, 6+ char validation)
  - [ ] Account creation with `plan: 'free'` in subscriptions table
  - [ ] Duplicate account detection with helpful error
  - [ ] Tab switching UI between "Sign In" and "Try Free"
- [x] **Setup wizard** — PAID ONLY: 3-step flow (school, class/teacher, device name)
  - [ ] Gate behind paid subscription — free users skip straight to basic editor
- [ ] **Guided tour** — PAID ONLY, not implemented at all:
  - [ ] Auto-start after setup completion
  - [ ] Step-by-step walkthrough of Display Settings and Theme Selector
  - [ ] Auto-scroll to relevant sections
  - [ ] Completion tracking (stored in display_settings.setup_guide_completed)
  - [ ] Restart option in User Settings

### Free Tier
- [ ] Free tier state management:
  - [ ] 5-task limit enforcement with toast warning and upgrade prompt
  - [ ] **No persistence** — data is held in memory only, lost when app closes
  - [ ] No Supabase storage (no writes to templates, active_timeline, weekly_schedules, etc.)
  - [ ] Free tier banner displayed at top of app ("Free plan — 5 tasks, no saving. Upgrade for full access.")
  - [ ] Disable: backup/restore, image upload, custom themes, weekly schedule, templates
  - [ ] All 7 preset themes available
  - [ ] All 3 display modes available
  - [ ] Twinkl fonts available
  - [ ] Basic task editing only (text + icon, no images)

### Display Modes
- [~] **Horizontal mode** — works, but check:
  - [x] Start/end time cards with accent color
  - [x] Task cards with icon, name, duration
  - [x] Current task scale-up and glow
  - [x] Past task opacity reduction
  - [ ] Smooth transition animations (1000ms for state changes)
- [~] **Multi-row mode** — works, but missing:
  - [x] Snake path direction (alternating L-R, R-L per row)
  - [x] 80% dimension scaling vs horizontal mode
  - [x] Row time indicators
- [~] **Auto-pan mode** — works, but verify:
  - [x] Top/bottom banners with images
  - [x] CURRENT TASK / NEXT TASK labels
  - [x] Countdown timer ("X Minutes Remaining")
  - [x] "All done!" message when schedule complete
  - [x] Tile height slider working (30-80%)

### Task System
- [~] **Task cards** — display works, but:
  - [ ] Conditional rendering by task type (text vs icon vs image) — currently not cleanly separated
- [~] **Task editor modal** — basic editing works, but missing:
  - [ ] Image upload capability (need `image_picker` package in pubspec.yaml)
  - [ ] File size validation (warn >500KB, block >2MB)
  - [ ] Image preview with remove button
  - [ ] Base64 conversion for image storage
- [x] **Icon library** — 23 icons mapped to Lucide

### Transition Indicators
- [x] Progress line with gradient fill, moving dot, background track
- [x] Mascot road with gradient surface, dashes, animated sprite
- [x] Configurable surface presets (6 types)
- [x] Configurable sprite presets (10 emojis)
- [ ] Custom sprite image upload (PNG/SVG/GIF, 40x40px)
- [ ] Custom banner image upload for auto-pan mode

### Admin Panel
- [x] Toolbar with Save, Save as Template, Display Settings, Theme, User Settings, Exit
- [x] Unsaved changes banner
- [ ] Task overflow warning — red alert when tasks exceed display capacity
- [ ] Display capacity calculation (max tasks based on width/height/mode)

### Theme Editor
- [x] Theme editor modal — all controls implemented:
  - [x] Theme name input
  - [x] Start-from-preset chips
  - [x] Background gradient colors (top/bottom)
  - [x] Card border color and background color
  - [x] Glow color and accent color
  - [x] Corner style dropdown
  - [x] Font family dropdown (system + 3 Twinkl families)
  - [x] Enhanced current border toggle
  - [x] Live preview panel with selected font
  - [x] Border width slider (1-6px)
  - [x] Font weight dropdown (Light to Extra Bold)
  - [x] Font transform toggle (UPPERCASE)
  - [x] Theme emoji selector (12 emoji options)
  - [x] Tick/dot colors (completed, current, upcoming pickers)
  - [x] Progress line gradient colors (start, end, background)
  - [x] Current task background overlay color picker

### Weekly Schedule
- [~] Weekly schedule grid — basic assignment works, but:
  - [x] Mon-Fri day cards
  - [x] Today indicator badge
  - [x] Assign template to day
  - [x] Remove template from day
  - [x] Load template button
  - [x] **Auto-load today's template on app startup** — loads from weekly schedule on data init
  - [x] Template name, time range, and task count shown on assigned day cards

### Display Settings Modal
- [x] Mode selector (horizontal/multi-row/auto-pan)
- [x] Transition type selector
- [x] Sprite picker and surface picker
- [x] Resolution presets and custom W/H
- [x] Scale slider
- [x] Banner heights and clock toggle
- [x] Auto-pan tile height slider (30-80%)
- [x] Rows slider for multi-row mode (max calculated from display height)
- [x] Path direction selector for multi-row (sequential vs snake)
- [ ] Display capacity info section

### User Settings
- [~] User settings modal — partially complete:
  - [x] Email display
  - [x] Password reset
  - [x] Edit setup info (school/class/teacher/device)
  - [x] Reset to default
  - [x] Sign out
  - [x] Backup export (clipboard JSON)
  - [x] Restore from clipboard paste
  - [ ] **Display name editing** with save button
  - [ ] **Backup as file download** (.json file with school-class-date naming)
  - [ ] **Restore from file** (file picker, not just clipboard paste)
  - [ ] **Guided tour restart button**
  - [ ] Backup validation (check for version & exportDate fields)

### Notifications
- [~] Toast notification widget exists, but:
  - [ ] **Auto-dismiss** (4s for info/success, 6s for error/warning)
  - [ ] **Global notification system** — currently individual SnackBars, web has a central toast

### Data & Performance
- [ ] **Debounced saves** — display settings and theme changes should debounce 800ms before writing to Supabase
- [ ] **Display update interval** — currently 1 second, web uses 100ms. Consider 100-500ms for smoother progress bars
- [ ] **Unsaved changes warning** — prevent navigation away if unsaved

### Device Auto-Detection (new feature beyond web parity)
- [ ] Auto-detect screen size and aspect ratio at launch
- [ ] Auto-select optimal display mode based on device (needs discussion on thresholds)
- [ ] Mobile phone handling (admin-only? or compact display?)
- [ ] Orientation change handling across all form factors

---

## iOS (iPad)

### App Store Requirements
- [ ] App icon (1024x1024 + all required sizes)
- [ ] Launch screen / splash screen
- [ ] App Store listing metadata (title, description, keywords, category: Education)
- [ ] App Store screenshots (iPad Pro 12.9", iPad Pro 11")
- [ ] Privacy policy URL (required by Apple)
- [ ] App review information (demo account credentials for reviewer)
- [ ] Age rating (likely 4+, educational)

### iOS-Specific Functionality
- [ ] Bundle identifier configured (e.g. com.routineready.app)
- [ ] Minimum iOS version set appropriately
- [ ] Guided Access documentation/instructions for teachers (iPad kiosk mode)
- [ ] Test on physical iPad (display mode + admin mode)
- [ ] Test orientation locking (landscape in display, any in admin)
- [ ] Test immersive mode hides status bar in display mode
- [ ] Test Twinkl fonts render correctly on iOS
- [ ] Test image upload via iOS photo picker (once implemented)
- [ ] Test background/foreground lifecycle (realtime reconnection)
- [ ] Verify `flutter_secure_storage` works for device ID on iOS
- [ ] Test on iPad Mini, iPad Air, iPad Pro (various sizes)

### iOS Build & Deploy
- [ ] Apple Developer account configured ($99/year)
- [ ] Provisioning profiles and certificates set up
- [ ] TestFlight build uploaded for beta testing
- [ ] Archive and upload to App Store Connect
- [ ] App Store review submission

---

## Android (Tablets)

### Play Store Requirements
- [ ] App icon (512x512 + adaptive icon assets)
- [ ] Feature graphic (1024x500)
- [ ] Launch screen / splash screen
- [ ] Play Store listing metadata (title, description, category: Education)
- [ ] Play Store screenshots (7" tablet, 10" tablet)
- [ ] Privacy policy URL (required by Google)
- [ ] Content rating questionnaire completed
- [ ] Data safety section completed

### Android-Specific Functionality
- [ ] Application ID configured (e.g. com.routineready.app)
- [ ] Minimum SDK version set appropriately
- [ ] Test immersive sticky mode hides system bars in display mode
- [ ] Test orientation locking (landscape in display, any in admin)
- [ ] Test on physical Android tablet (display mode + admin mode)
- [ ] Test Twinkl fonts render correctly on Android
- [ ] Test image upload via Android file picker (once implemented)
- [ ] Test background/foreground lifecycle (realtime reconnection)
- [ ] Verify `flutter_secure_storage` works for device ID on Android
- [ ] Test on various Android tablet sizes and API levels
- [ ] Signing key generated and stored securely
- [ ] ProGuard / R8 rules if needed

### Android Build & Deploy
- [ ] Google Play Developer account configured ($25 one-time)
- [ ] App signing key registered with Play Console
- [ ] Internal testing track build uploaded
- [ ] Open/closed beta testing
- [ ] Production release submission

---

## Web (Browser-Based)

The Flutter web build replaces the current React app. The domain routineready.co.uk will serve the Flutter app instead.

### Hosting Migration (React → Flutter on Vercel)
Current setup: React/Vite app in `RoutineReady.co.uk-Web` repo auto-deploys to Vercel on push.

Migration steps:
- [ ] Decide on URL structure:
  - **Option A**: Flutter web at `routineready.co.uk/` (replaces React entirely)
  - **Option B**: Flutter web at `routineready.co.uk/app`, keep a landing page at root
- [ ] Add Vercel configuration to this repo:
  - [ ] Create `vercel.json` with SPA rewrites (`"source": "/(.*)", "destination": "/index.html"`)
  - [ ] Set Vercel build command: `flutter build web --base-href "/"` (or `/app/` for Option B)
  - [ ] Set Vercel output directory: `build/web`
  - [ ] Set Vercel install command: install Flutter SDK in build environment (or use Docker/custom build)
- [ ] **Option 1 — Vercel with Flutter**: Use a custom build script or Vercel build image that installs Flutter. Vercel doesn't natively support Flutter, so you'd need:
  - A `build.sh` script that installs Flutter SDK and runs `flutter build web`
  - OR pre-build locally/in GitHub Actions and deploy the `build/web` output
- [ ] **Option 2 — GitHub Actions + Vercel** (recommended):
  - [ ] Create `.github/workflows/deploy-web.yml`:
    - Trigger on push to `main`
    - Install Flutter SDK
    - Run `flutter build web --base-href "/"`
    - Deploy `build/web` to Vercel using `vercel --prod` CLI
  - [ ] Store Vercel token as GitHub secret
- [ ] Connect this repo (`RoutineReady-Mobile`) to the Vercel project (replacing old repo)
  - OR disconnect old repo and connect new one in Vercel dashboard
- [ ] Update DNS / Vercel domain settings if needed (routineready.co.uk)
- [ ] Verify deployment works end-to-end
- [ ] Archive or delete the old `RoutineReady.co.uk-Web` Vercel deployment
- [ ] Keep old React repo as archive (don't delete — has git history)

### Web-Specific Functionality
- [ ] Test in Chrome, Firefox, Safari, Edge
- [ ] Test fullscreen behavior (F11)
- [ ] Test Twinkl fonts load correctly in web build
- [ ] Test image upload via web file picker (once implemented)
- [ ] Test on standard monitor (1920x1080, 16:9)
- [ ] Test on ultra-wide display (2560x1080, 21:9) if available
- [ ] Test display scaling at various browser zoom levels
- [ ] Verify keyboard/mouse navigation works for admin mode
- [ ] Test backup file download works in browser (once implemented)
- [ ] Ensure no CORS issues with Supabase from production domain
- [ ] Test on mobile browser (Chrome iOS, Chrome Android) — admin mode at minimum

### Web Performance
- [ ] Verify tree-shaking is reducing bundle size (confirmed: icons reduced 99%)
- [ ] Measure initial load time (target: <5 seconds on broadband)
- [ ] Test memory usage over extended display periods (hours)
- [ ] Ensure no memory leaks from timer intervals or realtime subscriptions

---

## Supabase / Backend (Required for All Platforms)

- [ ] Run all migrations from `supabase_migrations.sql`
- [ ] Enable `pg_cron` extension in Supabase dashboard
- [ ] Schedule stale session cleanup: `SELECT cron.schedule('cleanup-stale-sessions', '*/5 * * * *', 'SELECT cleanup_stale_sessions()')`
- [ ] Verify RLS policies work correctly for all tables
- [ ] Verify realtime subscriptions fire for active_timeline and display_settings changes
- [ ] Test multi-device sync end-to-end (admin edits → display updates <2 seconds)
- [ ] Test display slot enforcement (exceed limit → denied → admin-only works)
- [ ] Create default subscription row for new signups (free plan, 1 display slot)
- [ ] Verify backup export/import round-trip preserves all data

---

## Paywall — Free / Paid Model

### Confirmed Tier Structure

**Free Plan** — try before you buy, no commitment
- 5 task limit
- No data persistence (lost when app closes)
- No Supabase storage — everything runs in-memory only
- All 3 display modes
- All 7 preset themes
- Twinkl fonts
- No setup wizard, no guided tour
- No templates, no weekly schedule
- No image upload, no custom themes
- No backup/restore

**Paid Plan (pricing TBD)** — full access to everything
- Unlimited tasks
- Full Supabase persistence (all data saved)
- Setup wizard + guided tour
- Templates + weekly schedule
- Custom themes + image upload + custom sprites
- Backup/restore
- Multiple display slots
- Realtime sync across devices
- Support and assisted setup

### Decisions Still Needed
- [ ] **Pricing**: Monthly vs annual? Per-classroom? (e.g. £3-5/month or £30-50/year)
- [ ] **Free trial of paid**: Offer X days free trial of paid features before requiring payment? Or just the permanent free tier above?
- [ ] **Plan name**: "Classroom Pro"? "Routine Ready Plus"? Just "Paid"?

### Payment Providers
- **iOS**: Apple In-App Purchase (required — Apple takes 30%)
- **Android**: Google Play Billing (required — Google takes 15-30%)
- **Web**: Stripe (direct, ~2.9% fees)
- Apple/Google **require** their billing systems for digital goods sold within their apps
- **Cross-platform sync**: User pays on one platform, it works everywhere
  - Store subscription status in Supabase `subscriptions` table (already exists)
  - RevenueCat (`purchases_flutter` package) manages Apple/Google/Stripe from one SDK
  - Server-side receipt validation via Supabase Edge Function or RevenueCat webhooks

### Implementation Steps
- [ ] Add `purchases_flutter` (RevenueCat) package to pubspec.yaml
- [ ] Configure RevenueCat project (Apple, Google, Stripe entitlements)
- [ ] Build subscription status provider (reads plan from `subscriptions` table)
- [ ] Build free tier state management:
  - [ ] In-memory-only data provider (no Supabase writes)
  - [ ] 5-task limit enforcement
  - [ ] Feature gate checks: block save, templates, weekly schedule, custom themes, image upload, backup
  - [ ] Free tier banner with upgrade CTA
- [ ] Build upgrade/pricing screen (shown from banner or when hitting limits)
- [ ] Build "upgrade to save your work" prompt when free user tries to close app with tasks
- [ ] Add upgrade prompts at each gated feature (contextual, not annoying)
- [ ] Server-side receipt validation (RevenueCat webhook → updates `subscriptions` table)
- [ ] On successful payment: create school record, run setup wizard, enable persistence
- [ ] Test purchase flow on iOS (sandbox), Android (test tracks), and web (Stripe test mode)
- [ ] Test downgrade/expiry: what happens when subscription lapses? (read-only? or back to free?)

---

## Final QA (All Platforms)

### Free Tier Testing
- [ ] Sign up as free user → lands in basic editor (no setup wizard)
- [ ] Can add up to 5 tasks, blocked on 6th with upgrade prompt
- [ ] Can switch display modes and themes (presets only)
- [ ] Close and reopen app → all data is gone (no persistence)
- [ ] Cannot access: templates, weekly schedule, custom themes, image upload, backup/restore
- [ ] Free banner visible with upgrade CTA
- [ ] Upgrade button leads to payment flow

### Paid Tier Testing
- [ ] Purchase subscription → setup wizard launches
- [ ] Full end-to-end: setup → configure display → add tasks → save → view on display
- [ ] Test all 7 preset themes render correctly on all display modes
- [ ] Test custom theme creation and application
- [ ] Test all 23 icons display correctly
- [ ] Test all 10 sprite emojis animate on mascot road
- [ ] Test all 6 surface presets render correctly
- [ ] Test weekly schedule: assign templates to days, verify auto-load
- [ ] Test template CRUD: create, load, assign, delete
- [ ] Test task CRUD: add, edit duration, change icon, reorder, delete
- [ ] Test image upload for tasks and banners
- [ ] Test backup export/import round-trip
- [ ] Test offline → reconnection flow on each platform
- [ ] Test sign out → sign back in preserves all data
- [ ] Test concurrent admin + display sessions on same account

### Cross-Platform Subscription
- [ ] Pay on iOS → subscription active on Android and web
- [ ] Pay on Android → subscription active on iOS and web
- [ ] Pay on web (Stripe) → subscription active on iOS and Android
- [ ] Subscription expires → user reverts to free tier behaviour
- [ ] Test purchase flow on iOS (sandbox), Android (test tracks), web (Stripe test mode)

### General
- [ ] Verify no console errors or warnings in production builds
- [ ] Verify no data leaks between free and paid state
