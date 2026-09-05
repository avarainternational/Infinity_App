# Current State

Last synchronized: 2026-08-19

## Project Pivot & Truth

The project is pivoting from the old Builder Uni workspace companion to **Infinity Wellness** (by Infinity Water) based on the approved Product Requirements Document (PRD).

Canonical project identity:
- **Product Name**: Infinity Wellness (by Infinity Water)
- **Architecture Pattern**: Super App with native shell and isolated Mini-Apps

## Runtime Truth

The app runs on Flutter Material 3 with GetX routing, dependency injection, and reactive state management.

The repository is structured to migrate from the initial monolithic prototype shell into modular features:
- **Shell Features**:
  - `Home`: Daily wellness snapshot, active streaks, pinned mini-app quick-launch.
  - `Feed`: Medical news, myth-busting content, and ecosystem announcements.
  - `Mini-App Store`: Functional module directory (Medical News, Smart Hydration, Friend Synergy).
  - `Wallet`: Wellness Points and streak perks.
  - `Profile`: User settings, health metrics (weight, height, activity level), and account management.
- **Phase 1 Mini-App Modules**:
  1. `Medical News & Myth-Busting Feed` (articles, Myth vs. Fact, health Q&A)
  2. `Smart Hydration Reminder` (smart calculator, one-tap log, automated push reminders)
  3. `Friend Synergy (1-on-1)` (mutual nudges, shared synergy streaks, real-time partner dashboard)

## Transition Status

1. **Context & PRD Alignment**: Completed context files alignment (`AGENTS.md`, `project-overview.md`, `current-state.md`, `architecture.md`, `code-standards.md`, `ui-context.md`, `progress-tracker.md`, `decision-log.md`, `ai-workflow-rules.md`).
2. **UI & Navigation Migration**: Established the 5-tab Super App shell (Home, Feed, Mini-App Store, Wallet, Profile) with dynamic startup routing (`Routes.login` for unauthenticated sessions, `Routes.shell` for authenticated sessions).
3. **Authentication & Supabase**: Integrated live `supabase_flutter` with Email & Password sign-in / sign-up (including biometrics onboarding for weight, height, activity level, and calculated daily water goal), Google OAuth, deep-link callback filters (`io.supabase.infinitywellness://login-callback/`), reactive `AuthService`, and instant PostgreSQL profile synchronization. Package name migrated to `com.infinitywellness.app`.
4. **Domain Logic & Data Layer**: Typed repositories (`UserRepository`, `HydrationRepository`, `SynergyRepository`) backed by Supabase PostgreSQL and Realtime subscriptions with offline fallbacks.

## Implementation Guardrails

- Maintain Flutter + GetX foundation (`BaseController`, `BaseView`, Bindings, centralized routes).
- Keep domain logic in typed repositories/services under `lib/app/data/` or `lib/app/services/`.
- Keep widgets free of direct Supabase client calls.
- Enforce PostgreSQL Row Level Security (RLS) with public anon credentials; never use service keys.
- Preserve clean separation of Mini-Apps under `lib/app/features/mini_apps/`.
- Maintain crisp typography, high legibility, and refreshing brand aesthetics.

## Verification Status

All changes must pass:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
