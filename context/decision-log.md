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

## 2026-08-19 — Ecosystem Wallet for Wellness Points

### Decision
Introduce an in-app Wallet dedicated to "Wellness Points" accrued through maintaining hydration streaks and completing wellness goals.

### Reason
Provides positive gamification and loyalty incentives redeemable for brand perks without using cryptocurrency or Web3 complexity.

## 2026-08-19 — Retain Flutter + GetX Architectural Foundation

### Decision
Preserve Flutter with GetX state management, dependency injection, and centralized routing (`BaseController`, `BaseView`, Bindings, `AppPages`, `AppRoutes`).

### Reason
The established foundation provides clean reactive state management, predictable navigation, and decoupled testability across shell views and mini-apps.
