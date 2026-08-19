# Progress Tracker

Last synchronized: 2026-08-19

## Completed

### Product Definition & Context
- [x] Adopted **Infinity Wellness** (by Infinity Water) Product Requirements Document (PRD).
- [x] Defined Super App pattern (Native Shell + Mini-App Store + 3 Phase-1 Mini-Apps).
- [x] Overhauled all context and specification documents:
  - `AGENTS.md`
  - `context/project-overview.md`
  - `context/current-state.md`
  - `context/architecture.md`
  - `context/code-standards.md`
  - `context/ui-context.md`
  - `context/progress-tracker.md`
  - `context/decision-log.md`
  - `context/ai-workflow-rules.md`
- [x] Retained architectural guardrails (Flutter + GetX, `BaseController`, `BaseView`, Bindings, typed repositories, RLS security).

## Roadmap & Next Phases

### Phase 1: Super App Native Shell Architecture
- [ ] Restructure feature modules (`features/home`, `features/feed`, `features/mini_app_store`, `features/wallet`, `features/profile`).
- [ ] Implement 5-tab Super App bottom navigation.
- [ ] Build **Home Dashboard** with daily wellness snapshot, streak counter, and mini-app quick-launch widget grid.
- [ ] Build **Feed Screen** with ecosystem announcements and curated health discovery.
- [ ] Build **Mini-App Store Screen** with module directory and pin/launch actions.
- [ ] Build **Profile Screen** with health metrics inputs (weight, height, activity level).
- [ ] Build **Wallet Screen** with Wellness Points balance and streak perks overview.

### Phase 2: Mini-App 1 — Medical News & Myth-Busting Feed
- [ ] Create `features/mini_apps/medical_news/` module.
- [ ] Implement bite-sized medical article feed with reading time and author verification badges.
- [ ] Implement interactive "Myth vs. Fact" toggle/flip cards.
- [ ] Implement digital health literacy Q&A browser and question submission dialog.

### Phase 3: Mini-App 2 — Smart Hydration Reminder
- [ ] Create `features/mini_apps/hydration/` module.
- [ ] Implement dynamic daily water goal calculator based on user health metrics.
- [ ] Build circular/wave intake visualizer with dynamic progress percentage.
- [ ] Build frictionless 1-tap quick log buttons (+250ml, +500ml, +750ml, custom amount).
- [ ] Build daily intake timeline and history.
- [ ] Set up local automated push notification reminders.

### Phase 4: Mini-App 3 — Friend Synergy (1-on-1)
- [ ] Create `features/mini_apps/friend_synergy/` module (strictly 1-on-1; no groups).
- [ ] Build 1-on-1 partner connection and status card.
- [ ] Build Mutual Nudge interactive action triggers (Hydrate nudge, Screen break nudge).
- [ ] Build connected Synergy Streak logic (both users must hit daily goals).
- [ ] Build synced real-time Partner Progress Dashboard.

### Phase 5: Supabase BaaS & Realtime Integration
- [ ] Set up typed repository layer (`lib/app/data/repositories/`).
- [ ] Connect Supabase Auth for user registration and onboarding.
- [ ] Connect PostgreSQL tables with RLS policies for profiles, hydration logs, and news items.
- [ ] Implement Supabase Realtime subscriptions for 1-on-1 Friend Synergy nudges and live sync.

### Phase 6: Ecosystem Wallet & Wellness Points
- [ ] Implement points accrual rules for streak maintenance and daily goal completion.
- [ ] Build points ledger history and perk catalog.

## Current Limitations

- Runtime is currently transitioning from prototype screens to the Infinity Wellness Super App structure.
- Supabase services and Realtime channels will be connected via typed repositories in Phase 5.
- Notification engine requires local device permissions setup.

## Do Not Claim Yet

- Live Supabase Realtime partner synchronization until Phase 5 is completed.
- Direct wearable device syncing (Apple Health / Google Fit).
- Multi-user or squad/group synergy (out of scope by design).
- Real monetary or crypto transactions (Wellness Points are in-app ecosystem reward tokens).
