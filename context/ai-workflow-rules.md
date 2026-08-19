# AI Workflow Rules

## Required Reading

Before making meaningful architectural or implementation changes, read:

1. `AGENTS.md`
2. `context/current-state.md`
3. `context/project-overview.md`
4. `context/architecture.md`
5. `context/code-standards.md`
6. `context/ui-context.md`
7. `context/progress-tracker.md`
8. `context/decision-log.md`

Always verify current state against actual workspace files.

## Scope Discipline

- **Brand & Domain**: Always use **Infinity Wellness** (by Infinity Water) domain terminology.
- **Super App Pattern**: Maintain clean separation between the native navigation shell (Home, Feed, Mini-App Store, Wallet, Profile) and isolated Mini-Apps (`features/mini_apps/`).
- **Friend Synergy Constraint**: Friend Synergy is strictly 1-on-1. Never introduce squads, guilds, tribes, or multi-user group logic.
- **Wallet Domain**: Use "Wellness Points" and "Streak Perks". Avoid crypto, tokens, or Web3 jargon.
- **Backend Access**: Do not embed raw Supabase queries or network calls in generic widgets; always use typed repositories and services.
- **Honesty in Documentation**: Clearly distinguish between mock UI, completed logic, and planned integration. Do not claim features are live until implemented and verified.

## Implementation Rules & Guardrails

- **Architecture**: Retain Flutter + GetX foundation (`BaseController`, `BaseView`, Bindings, `AppPages`, `AppRoutes`).
- **Feature Modularity**: Mini-apps must reside in dedicated directories under `lib/app/features/mini_apps/` with self-contained bindings, controllers, and screens.
- **Security**: Supabase access must use client-safe anon keys with PostgreSQL Row Level Security (RLS). Never commit service-role keys or admin secrets.
- **State & Data Flow**: UI -> Controller (`BaseController`) -> Repository -> Data Service (`SupabaseService` / Local).

## UI & Design Rules

- **Palette**: Clean, modern, youth-oriented wellness aesthetic (Ocean Blue `#0284C7`, Mint/Teal `#0D9488`, Amber `#F59E0B`, Medical Violet `#6366F1`).
- **Surfaces**: Crisp white cards (`AppColors.surface`) over soft neutral background (`AppColors.background`).
- **Legibility**: High-contrast dark charcoal/black text (`AppColors.textPrimary`). Never introduce illegible low-contrast or dim gray body text.
- **Tokens**: Use centralized tokens from `AppColors`, `AppDimens`, `AppTheme`, `AppString`, and `AppImages`.

## Verification Rules

Run verification commands independently from the project root:

```powershell
flutter pub get
flutter analyze
flutter test --reporter expanded
```

For Android builds:
```powershell
flutter build apk --debug
```

Never combine tests and builds into a single chained shell command.

## Git Rules

- Primary branch: `main`
- Inspect working tree and diffs before committing.
- Keep commits focused and clean.
- Never rewrite shared history or force-push unless explicitly requested.
