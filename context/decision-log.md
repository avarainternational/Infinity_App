# Decision Log

This log records architectural, product, and technical decisions shaping **Infinity Wellness** (by Infinity Water).

## 2026-08-19 — Pivot to Infinity Wellness (by Infinity Water)

### Decision
Transition the entire project from the Builder Uni prototype to **Infinity Wellness**, a digital health companion for youths and young adults created by Infinity Water.

### Reason
Align the product vision with public health and wellness, promoting digital health literacy, mutual accountability, and daily well-being rather than direct commercial product sales.

### Result
- Product Name: **Infinity Wellness** (by Infinity Water).
- Replaced all legacy domain concepts with Infinity Wellness terminology.
- Overhauled all context and specification documents.

## 2026-08-19 — Adopt the Super App Pattern Architecture

### Decision
Structure the mobile application as a Super App comprising a native navigation shell (Home, Feed, Mini-App Store, Wallet, Profile) and isolated functional Mini-Apps.

### Reason
Allows scalable expansion of health and wellness micro-modules without bloating the main app shell or entangling distinct domain logic.

### Result
- Established a 5-tab bottom navigation shell.
- Established `lib/app/features/mini_apps/` for isolated functional modules.
- Created launchpad and pinning mechanisms between the Mini-App Store and the Home dashboard.

## 2026-08-19 — Define Phase 1 Mini-App Scope

### Decision
Launch Phase 1 with exactly three focused Mini-Apps:
1. **Medical News & Myth-Busting Feed**
2. **Smart Hydration Reminder**
3. **Friend Synergy (1-on-1)**

### Result
- Concentrates engineering and UX design on high-impact health literacy, hydration tracking, and mutual accountability before introducing further modules.

## 2026-08-19 — Strict 1-on-1 Constraint for Friend Synergy

### Decision
Friend Synergy is explicitly restricted to 1-on-1 partner connections (best friends, partners). Group, squad, or multi-user challenges are strictly out of scope.

### Reason
1-on-1 mutual accountability creates strong personal commitment and simplifies UX, eliminating the social fatigue and coordination friction common in large groups.

### Result
- Data model and UI are tailored specifically for pair synergy, mutual nudges, and shared synergy streaks.

## 2026-08-19 — Supabase Backend as a Service with Realtime Sync

### Decision
Use Supabase (Auth, PostgreSQL, Realtime, Storage) as the exclusive backend infrastructure.

### Reason
- Supabase Auth provides frictionless onboarding.
- PostgreSQL handles relational data models (partner links, hydration logs, news items).
- Supabase Realtime provides instant live synchronization for Friend Synergy nudges and partner goal updates without requiring manual polling or complex custom WebSocket servers.

### Constraints & Guardrails
- Generic UI widgets must never invoke Supabase directly; all access must flow through typed repositories and services.
- Only client-safe anon keys are used in the Flutter app.
- PostgreSQL Row Level Security (RLS) policies enforce all access control.
- Service-role keys are strictly prohibited in the client.

## 2026-08-24 — Inline QR Scanner on Send Tab in Wallet Screen

### Decision
Embed the live camera QR scanner directly in the Send tab of the Transfer & Receive hub on the Wallet screen, replacing the static card and external navigation button.

### Reason
Reduces friction when transferring Wellness Points to friends, enabling instant scanning on the same screen while automatically releasing camera hardware when switching tabs or backgrounding the app.

### Result
- `_InlineWalletScanner` starts camera preview immediately when switching to the Send tab.
- Added viewfinder reticle overlay, animated scanning line, torch toggle, dynamic scanning status, and clipboard paste fallback.
- Camera lifecycle is synchronized with app lifecycle and shell navigation.

## 2026-08-19 — Ecosystem Wallet for Wellness Points

### Decision
Introduce an in-app Wallet dedicated to "Wellness Points" accrued through maintaining hydration streaks and completing wellness goals.

### Reason
Provides positive gamification and loyalty incentives redeemable for brand perks without using cryptocurrency or Web3 complexity.

## 2026-08-19 — Supabase Authentication with Google OAuth Exclusive Sign-In

### Decision
Connect Supabase authentication to the app with **Google OAuth** as the exclusive sign-in method.

### Reason
- Simplifies the onboarding flow for youths and young adults to a single frictionless tap.
- Eliminates password fatigue and friction while ensuring secure OAuth 2.0 PKCE authentication.
- Automatically populates user profile identity (name, email, avatar).

### Result
- Added `supabase_flutter` dependency and configured deep link schemes (`io.supabase.infinitywellness://login-callback/`) across Android and iOS.
- Implemented `SupabaseService` and `AuthService` with reactive session streaming and state management.
- Built a modern, branded `LoginScreen` with the "Continue with Google" button and informative fallback for development/explorer mode.
- Integrated profile screen with reactive user session data and Sign Out confirmation.

## 2026-09-02 — Adopt Option 1 (Shadcn) Wallet Design System

### Decision
Adopt the **Option 1 — Shadcn Wallet Design System** direction as the standard UI architecture across the Ecosystem Wallet.

### Reason
- Provides a clean, minimalist, high-contrast, professional mobile interface with clear typographic hierarchy (Plus Jakarta Sans & Inter).
- Replaces heavy ambient gradients with a crisp slate canvas (`#F8FAFC`), pure white card surfaces (`#FFFFFF`), subtle 1px borders (`#E2E8F0`), and soft shadows.
- Features prominent Royal Blue (`#2563EB`) points balances, high-contrast streak badges (`#16A34A`), smooth animated segmented control tabs, and integrated inline QR scanning.

### Result
- Added dedicated `WalletColors`, `WalletSpacing`, `WalletRadius`, `WalletShadows`, and `WalletTextStyles` design tokens in `wallet_ui_metrics.dart`.
- Refactored `WalletScreen`, `SectionCard`, `WalletReceiveScreen`, `WalletSendScreen`, `WalletSendReviewScreen`, `WalletTransactionHistoryScreen`, and `WalletSendScanScreen` to strictly adhere to the Option 1 Shadcn design specifications.

## 2026-09-07 — Resilient 1-on-1 Synergy Linking & Live Hydration Meter Sync

### Decision
Enhance `SynergyRepositoryImpl`, `PartnerDetailController`, and `HomeController` to provide idempotent bidirectional pairing, resilient single-row queries, real-time hydration meter sync, and complete timeline log retrieval.

### Reason
- Resolves crashes caused by duplicate key violations on `idx_unique_active_pair` when partner B enters partner A's invite code.
- Resolves Postgrest exceptions caused by `.maybeSingle()` when multiple pairing attempts occurred.
- Corrects timezone-induced data loss in partner daily water intake calculations by matching on `log_date`.
- Ensures `hasActivePartner` and `HomeController.partners` are updated instantly without popping screens unexpectedly.

### Result
- `SynergyRepositoryImpl.connectPartnerWithCode`: checks for existing pairs in both directions first, reactivates existing pairs instead of crashing, and deactivates any other active pairs for the user.
- `SynergyRepositoryImpl.getActivePair`: uses `.order('created_at', ascending: false).limit(1)`.
- `SynergyRepositoryImpl.getPartnerTodayIntake`: matches `log_date.eq.$dateStr` and timestamp range, with local repository fallback.
- Added `getPartnerTodayWaterLogs` and `getPartnerPastDays` for live timelines.
- `HomeController`: reactive `SynergyPartner` (`intakeMl`, `goalMl`), subscribes to Supabase Realtime so Home screen gauge updates dynamically.
- `PartnerDetailScreen`: graceful empty states for logs and reminders, user invite code display in connection dialog, and safe disconnect action.

## 2026-09-07 — Native Notifications, Dynamic Daily Goal & 1 Sip Amount Customization

### Decision
1. Implement a real notification system utilizing `flutter_local_notifications` with timezone-aware scheduling, instant 1-on-1 partner synergy nudges, and milestone celebration alerts.
2. Implement user-configurable daily water goals with preset shortcuts, visual sliders, and instant biometric recalculations (based on weight, height, age, gender, and activity level).
3. Implement user-configurable "1 Sip" quick-log amount (persisted locally and synced with the floating droplet quick-action).
4. Implement comprehensive biometric hydration calibration on signup/login.

### Reason
- Eliminates placeholder/dummy reminders with genuine local push notifications on Android & iOS.
- Empowers users to personalize their hydration target and vessel sizes to match their personal bottles and cups.
- Provides scientific, personalized hydration recommendations based on biometrics right from user onboarding.

### Result
- Added `NotificationService` with dedicated Android channels, permission handling, periodic zoned hydration reminders (8 AM - 10 PM), and instant nudges.
- Enhanced `UserProfileModel.computeRecommendedGoal` with multi-factor biometrics (weight, height, age, gender, activity level).
- Added `updateDailyGoal` and `updateSipAmount` across `HydrationDetailController`, `ProfileController`, and `UserRepositoryImpl`.
- Connected floating water droplet quick-log to reactive `sipAmountMl`.
- Realtime partner nudges trigger instant native device notifications.
- All 48 test suites passing.

## 2026-09-09 — Cloudflare Worker Reverse-Proxy for Supabase Access Without VPN

### Decision
Direct Supabase initialization and configuration through a Cloudflare Worker reverse-proxy endpoint (`https://supabase-proxy-infinity-wellness.avarainternational.workers.dev`) while preserving public anon credentials.

### Reason
- Direct network traffic to `*.supabase.co` domains is throttled or completely blocked by local ISPs/telecoms in certain target regions (e.g., Myanmar), requiring users to enable a third-party VPN to authenticate or sync data.
- Routing requests through Cloudflare Workers bypasses domain-level and IP-level firewall blocks, allowing all app users to access Supabase Auth, PostgreSQL REST endpoints, and Realtime WebSocket channels without needing a VPN.

### Result
- Added direct `Supabase.initialize` in `lib/main.dart` pointing to `https://supabase-proxy-infinity-wellness.avarainternational.workers.dev`.
- Updated `assets/config/supabase_config.local.json`, `assets/config/supabase_config.example.json`, and `lib/app/core/config/supabase_config.dart`.
- Updated `SupabaseService.init()` to safely reuse any pre-existing `Supabase.instance`, ensuring seamless interoperability and avoiding double-initialization runtime errors.

## 2026-09-09 — Interactive Feed Detail Screen & Media Normalization

### Decision
1. Transform feed post cards in both `FeedScreen` and `HomeScreen` into clickable interactive elements navigating to a dedicated `FeedDetailScreen` (`Routes.feedDetail`).
2. Implement `ImageUrlHelper` to dynamically normalize Supabase storage URLs through the active Cloudflare proxy.
3. Equip the detail screen with reactive Bookmarking (`saved_feed_posts`), Liking with dynamic counters, and formatted snippet sharing.

### Reason
- Users need to read full health literacy articles, examine Myth vs. Fact evidence breakdowns, and save posts to their personal library.
- Media URLs stored in Supabase point to `*.supabase.co`, which were blocked without a proxy in Myanmar.

### Result
- Added `Routes.feedDetail`, `FeedDetailBinding`, `FeedDetailController`, and `FeedDetailScreen`.
- Wrapped feed cards in `FeedScreen` and `HomeScreen` with `Material` and `InkWell`.
- Added 9 new unit and widget tests in `test/feed_detail_test.dart` (total 57 test suites passing).

