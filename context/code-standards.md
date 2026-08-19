# Code Standards

## General

- Keep changes focused, clean, and architecturally sound.
- Use explicit Dart types; avoid `dynamic` and raw JSON maps in business logic.
- Prefer immutable data models and `const` widget constructors.
- Strictly separate UI widgets, state controllers, and data services/repositories.
- Fix root causes rather than introducing temporary hacks.
- Format all Dart files with `dart format`.
- Maintain clean analysis (`flutter analyze`); resolve lints properly rather than suppressing them.

## Flutter and GetX

- State controllers must extend `BaseController`.
- Top-level screens and feature views extend `BaseView<T>` and implement `buildView()`.
- Register dependencies via feature-specific `Bindings` classes using `Get.lazyPut` or `Get.put`.
- Use reactive state observables (`.obs` and `Obx`) for dynamic UI updates.
- Never place Supabase client calls, network requests, or database logic directly inside widgets.
- Use centralized route definitions in `AppRoutes` and `AppPages`.

## Feature Organization

Follow the Super App modular layout:

```text
features/{feature_or_mini_app}/
├── binding/
├── controller/
├── screen/
├── widget/
└── (optional) model/
```

- Native Shell views reside in `lib/app/features/{home,feed,mini_app_store,wallet,profile}/`.
- Mini-Apps reside in `lib/app/features/mini_apps/{medical_news,hydration,friend_synergy}/`.
- Shared UI components belong in `lib/app/widget/`.
- Shared repositories and data providers belong in `lib/app/data/`.

## Domain Naming & Rules

- **Brand**: `Infinity Wellness` (by Infinity Water).
- **Core Shell**: `Home`, `Feed`, `Mini-App Store`, `Wallet`, `Profile`.
- **Mini-App 1**: `Medical News`, `Myth vs. Fact`, `Health Literacy Q&A`.
- **Mini-App 2**: `Smart Hydration`, `Water Intake Log`, `Daily Water Goal`, `Smart Calculator`.
- **Mini-App 3**: `Friend Synergy`, `Partner`, `1-on-1 Synergy`, `Mutual Nudge`, `Synergy Streak`.
  - **Strict Constraint**: Friend Synergy is strictly 1-on-1. Do not introduce squad, guild, clan, or group functionality.
- **Wallet & Perks**: `Wellness Points`, `Streak Perks`, `Ecosystem Wallet`. Avoid crypto/Web3 terminology.
- **Health Metrics**: `Weight`, `Height`, `Activity Level`, `Dynamic Hydration Goal`.

## Data, Supabase & Realtime Standards

- Map database snake_case columns to typed camelCase Dart models using `fromJson` / `toJson`.
- Data flows: `UI Widget` -> `Controller` -> `Repository` -> `SupabaseService` / `LocalDatabase`.
- Supabase Realtime listeners should be lifecycle-managed within controllers (subscribe on `onInit()`, unsubscribe on `onClose()`).
- Supabase client authorization must strictly rely on PostgreSQL Row Level Security (RLS).
- Never commit or bundle Supabase service-role keys or admin secrets in client code.

## Design & Resources

- Centralize all styling tokens:
  - `AppColors`: Palette (refreshing blues/aquas, energetic accents, clean neutrals).
  - `AppTheme`: Material 3 theme configurations, button styles, input decorations.
  - `AppDimens`: Standard paddings, border radii, icon sizes, heights.
  - `AppString`: Localized and reusable user-facing strings.
  - `AppImages`: Static asset and icon paths.
- Avoid hardcoded magic numbers and arbitrary color hex codes inside widget files.

## Testing & Quality

- Unit tests for smart calculators, models, and controllers in `test/`.
- Widget tests for critical user interactions (logging water, switching tabs, myth vs. fact toggle).
- Run commands independently:

```powershell
flutter analyze
flutter test --reporter expanded
```
