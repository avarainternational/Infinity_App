# Architecture Context

## Stack

| Layer | Technology | Role |
| --- | --- | --- |
| UI Framework | Flutter / Dart | Cross-platform mobile application |
| Design System | Material 3 + Custom Tokens | Modern wellness aesthetic, responsive layouts |
| State & DI | GetX (`BaseController`, `BaseView`, `Bindings`) | Reactive UI state, dependency injection, route navigation |
| BaaS & DB | Supabase (PostgreSQL, Auth, Realtime) | Cloud data store, authentication, live partner sync |
| Notifications | Flutter Local Notifications | Automated hydration reminders |
| Testing | `flutter_test` | Unit, controller, and widget smoke tests |

## Core Architecture: The Super App Pattern

The app is architected around a **Super App Native Shell** hosting core lifecycle views and an isolated **Mini-App Store**:

```text
lib/
├── app/
│   ├── core/
│   │   ├── base/               # BaseController, BaseView, BaseService
│   │   ├── theme/              # AppColors, AppTheme, AppDimens, AppTypography
│   │   ├── values/             # AppString, AppImages, AppConstants
│   │   └── utils/              # Calculator helpers, validators, date formatters
│   ├── routes/
│   │   ├── app_pages.dart      # Centralized GetPage definitions
│   │   └── app_routes.dart     # Route constant names
│   ├── data/
│   │   ├── models/             # Typed models (UserProfile, HydrationLog, PartnerSynergy, NewsItem, PointsEntry)
│   │   ├── repositories/       # Abstract and concrete repositories
│   │   └── services/           # SupabaseService, NotificationService, LocalStorageService
│   └── features/
│       ├── shell/              # Super App bottom navigation shell
│       ├── home/               # Daily wellness snapshot & quick-launch widgets
│       ├── feed/               # Community wellness feed & ecosystem news
│       ├── mini_app_store/     # Mini-app directory & launchpad
│       ├── wallet/             # Ecosystem Wellness Points & streak rewards
│       ├── profile/            # Health metrics (weight, height, activity), settings
│       └── mini_apps/          # Isolated mini-app modules
│           ├── medical_news/   # Mini-App 1: Articles, Myth vs. Fact, Q&A
│           ├── hydration/      # Mini-App 2: Smart Calculator, 1-Tap Log, Reminders
│           └── friend_synergy/ # Mini-App 3: 1-on-1 Nudges, Streaks, Realtime Sync
```

## Mini-App Modularity Rules

1. **Isolation**: Each mini-app in `features/mini_apps/` contains its own dedicated bindings, controllers, screens, and localized widgets.
2. **Launchpad Integration**: Mini-apps register their metadata (title, icon, route, description, color accent) with the `MiniAppStoreController` so they can be launched from the Store and pinned to the Home quick-launch dashboard.
3. **Decoupled State**: Mini-apps communicate with core services via typed repositories/services rather than directly mutating shell state.

## Backend & Data Architecture (Supabase)

### 1. Authentication & User Profile
- Handled via `Supabase.auth`.
- Profile table stores user identity and health metrics:
  - `id` (UUID, references auth.users)
  - `display_name`, `avatar_url`
  - `weight_kg`, `height_cm`, `activity_level` (sedentary, moderate, active, very active)
  - `daily_water_goal_ml` (computed via smart calculator)
  - `wellness_points_balance`

### 2. Smart Hydration Data
- `hydration_logs`: `id`, `user_id`, `amount_ml`, `logged_at`
- Query aggregated daily totals to compare against `daily_water_goal_ml`.

### 3. Friend Synergy (1-on-1 Realtime)
- **Strict 1-on-1 model**: `friend_synergy_pairs`:
  - `id`, `user_a_id`, `user_b_id`, `streak_count`, `last_synced_date`, `status` (pending, active)
- **Mutual Nudges**: `synergy_nudges`:
  - `id`, `sender_id`, `receiver_id`, `nudge_type` (`hydrate`, `screen_break`), `created_at`
- **Realtime Channel**: Subscribes to changes on `friend_synergy_pairs` and `synergy_nudges` filtered by the user's active 1-on-1 partner, triggering instant UI updates on nudges and partner goal progress.

### 4. Medical News & Myth-Busting
- `medical_news_items`:
  - `id`, `title`, `summary`, `content_body`, `category`, `type` (`article`, `myth_fact`, `qa`), `myth_statement`, `fact_statement`, `author_role` (e.g. "Medical Student, Year 4"), `published_at`

### 5. Ecosystem Wallet & Wellness Points
- `wellness_points_ledger`:
  - `id`, `user_id`, `points_delta`, `source` (`hydration_goal`, `synergy_streak`, `myth_quiz`), `description`, `created_at`

## Security & Architecture Guardrails

- **RLS (Row Level Security)**: All Supabase tables must enforce strict RLS policies tied to `auth.uid()`.
- **Public Client Safety**: Only Supabase anon keys are included in the mobile client. Service-role keys are strictly prohibited.
- **Service Layer Boundary**: UI widgets never call Supabase directly; all data requests flow through typed repository contracts (`HydrationRepository`, `SynergyRepository`, `NewsRepository`, `WalletRepository`, `ProfileRepository`).
- **Offline & Graceful Fallback**: Local caching/state persists hydration logs and feed caches to ensure a seamless offline experience.
