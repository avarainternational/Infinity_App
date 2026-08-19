# AGENTS.md

## Purpose

This repository contains **Infinity Wellness** (by Infinity Water), a Flutter mobile digital health companion for youths and young adults. It prioritizes health literacy, mutual accountability, and well-being through a modular Super App pattern featuring a central shell and isolated Mini-Apps.

The repository is transitioning its UI and service architecture to fulfill the Infinity Wellness Product Requirements Document (PRD).

## Required Context

Read these files before architectural or implementation work:

1. `context/current-state.md`
2. `context/project-overview.md`
3. `context/architecture.md`
4. `context/code-standards.md`
5. `context/ui-context.md`
6. `context/progress-tracker.md`
7. `context/decision-log.md`
8. `context/ai-workflow-rules.md`

`current-state.md` is the runtime source of truth. `decision-log.md` records why important choices were made.

## Product Scope & Core Architecture

### 1. The Super App Pattern (Native Shell)
- **Home**: Daily wellness snapshot, active streaks, quick-launch widgets for pinned mini-apps.
- **Feed**: Content discovery and ecosystem announcements.
- **Mini-App Store / Live**: Directory and launcher for functional mini-app modules.
- **Wallet**: Ecosystem wallet for Wellness Points and streak perks.
- **Profile**: User settings, health metrics (weight, height, activity level), and account management.

### 2. Mini-App Store (Phase 1 Modules)
- **Mini-App 1: Medical News & Myth-Busting Feed**
  - Bite-sized evidence-based articles curated by medical students and health professionals.
  - "Myth vs. Fact" interactive breakdowns.
  - Public Q&A capabilities for digital health literacy.
- **Mini-App 2: Smart Hydration Reminder**
  - Smart daily water goal calculator based on weight, height, and activity level.
  - One-tap water logging.
  - Timely automated push notifications.
- **Mini-App 3: Friend Synergy (1-on-1)**
  - Dedicated mutual accountability strictly for 1-on-1 relationships (partners / best friends; no groups/squads).
  - Mutual interactive Nudges (hydrate / screen break).
  - Shared "Synergy Streak" (both users must complete daily goals).
  - Real-time synced Partner Dashboard.

### 3. Backend & Infrastructure
- **Backend as a Service (BaaS)**: Supabase (Auth, PostgreSQL, Realtime, Storage).
- **Supabase Realtime**: Powers Friend Synergy real-time nudges and live sync.
- **Security**: PostgreSQL Row Level Security (RLS) with public client anon keys.

## Domain Language

Use the Infinity Wellness product terminology:

- `Infinity Wellness` (by Infinity Water)
- `Mini-App` / `Mini-App Store`
- `Medical News`, `Myth vs. Fact`, `Health Literacy Q&A`
- `Smart Hydration`, `Water Intake Log`, `Daily Water Goal`
- `Friend Synergy`, `Partner`, `1-on-1 Synergy`, `Mutual Nudge`, `Synergy Streak` (strictly 1-on-1; never use squad/group)
- `Wellness Points`, `Streak Perks`, `Ecosystem Wallet`
- `Health Metrics` (weight, height, activity level, calculated goal)

## Architecture Rules & Guardrails

- **Framework & State**: Flutter + GetX (`BaseController`, `BaseView`, Bindings, centralized routes).
- **Modularity**: Mini-apps must be organized as modular feature packages with clear boundaries (`features/mini_apps/...`).
- **Resource Management**: Keep styling and tokens in `AppColors`, `AppDimens`, `AppString`, `AppImages`, and `AppTheme`.
- **Data Boundary**: Access Supabase exclusively through typed services and repositories; generic UI widgets must never invoke Supabase directly.
- **Security**: Supabase access must use client-safe anon keys protected by RLS. Never commit service-role keys, private tokens, or secrets.
- **Context Integrity**: Update context files whenever runtime scope, architecture, data contracts, or design rules materially change.

## Design Rules

- Clean, modern, youth-oriented wellness aesthetic with high legibility.
- White cards and surfaces over a clean, neutral background.
- Crisp, high-contrast typography; do not introduce dim/gray body text without approval.
- Refreshing brand color palette (vibrant blues/teals reflecting Infinity Water, supported by energetic accents).
- Seamless transitions between the native shell (Home, Feed, Mini-App Store, Wallet, Profile) and isolated Mini-Apps.

## Verification

Run Flutter verification commands independently from the project root:

```powershell
flutter pub get
flutter analyze
flutter test test\widget_test.dart --reporter expanded
```

For an Android artifact:

```powershell
flutter build apk --debug
```

Do not combine test and build commands into a single long shell invocation.

## Git

- Primary branch: `main`
- Keep commits focused and keep the working tree clean before publishing.
- Never rewrite shared history or force-push unless explicitly requested.
