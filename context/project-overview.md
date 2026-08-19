# Project Overview

## Product

**Infinity Wellness** (by Infinity Water) is a digital health companion for youths and young adults. It positions Infinity Water as a brand deeply invested in public health and wellness by prioritizing health literacy, mutual accountability, and lifestyle well-being over direct commercial product sales.

## Target Audience

Youths and young adults who want to improve their daily lifestyle habits, stay hydrated, maintain accountability with close friends/partners, and consume verified health information without falling prey to social media misinformation.

## Core Architecture: The Super App Pattern

The application uses a highly modular bottom-navigation native shell hosting both core lifecycle views and an isolated Mini-App ecosystem:

1. **Home**: A personalized dashboard displaying a daily wellness snapshot, active streaks (individual & synergy), and quick-launch widgets for pinned mini-apps.
2. **Feed**: The central hub for wellness content discovery, community discussions, and announcements from the Infinity Wellness ecosystem.
3. **Mini-App Store / Live**: The directory where users discover, pin, and launch dedicated functional mini-app modules.
4. **Wallet**: A digital ecosystem wallet for collecting "Wellness Points" through daily streaks and completed goals, redeemable for brand perks and ecosystem rewards.
5. **Profile**: User account settings, health metrics (weight, height, activity level, dynamic hydration targets), and partner connection settings.

## Mini-App Store (Phase 1 Modules)

For the initial launch, the Mini-App Store contains three dedicated applications:

### Mini-App 1: Medical News & Myth-Busting Feed
- **Concept**: A verified content platform curated exclusively by medical students and health professionals.
- **Purpose**: Combats false social media health news and provides a reliable, engaging source of wellness information.
- **Features**:
  - Bite-sized, evidence-based articles on physical and mental wellness.
  - Interactive "Myth vs. Fact" breakdowns to debunk trending misinformation.
  - Public Q&A capabilities to foster digital health literacy.

### Mini-App 2: Smart Hydration Reminder
- **Concept**: A personalized daily hydration tracker and reminder engine.
- **Features**:
  - **Smart Calculator**: Generates dynamic daily water goals based on user weight, height, and activity level.
  - **One-Tap Logging**: Frictionless quick-logging interface for recording water intake.
  - **Automated Notifications**: Timely, localized push notifications to keep users hydrated throughout the day.

### Mini-App 3: Friend Synergy (1-on-1)
- **Concept**: A mutual accountability tool built exclusively for 1-on-1 relationships (partners, best friends).
- **Scope Restriction**: Strictly 1-on-1 accountability. No group or squad functionality.
- **Features**:
  - **Mutual Nudges**: Manual, interactive alerts sent to a partner to remind them to hydrate or take a screen break.
  - **Shared Streaks**: A connected "Synergy Streak" system where both individuals must hit their daily goals to keep the streak alive.
  - **Partner Dashboard**: Synced real-time view allowing users to check their partner's daily progress instantly.

## Technical Infrastructure & Backend

- **Backend as a Service (BaaS)**: Supabase powers the entire backend infrastructure.
- **Database**: PostgreSQL (via Supabase) with relational data models linking user profiles, 1-on-1 partner connections, hydration logs, and news feed content.
- **Authentication**: Supabase Auth for seamless login, sign-up, and onboarding.
- **Real-Time Sync**: Supabase Realtime enables instant partner UI updates when a friend logs water or sends a nudge without page refreshes.
- **Frontend Stack**: Flutter + GetX routing, state management, and dependency injection, preserving a clean separation between the native shell and mini-app modules.

## Out of Scope (Phase 1)

- Group/squad/multi-user challenges (Friend Synergy is strictly 1-on-1).
- Direct e-commerce or commercial water sales flows.
- Complex third-party wearable integrations (prioritizing frictionless manual and smart tracking).
- Service-role key usage in client applications.

## Success Criteria

1. Clear, modular Super App navigation across Home, Feed, Mini-App Store, Wallet, and Profile.
2. Complete standalone flows for the 3 Phase 1 Mini-Apps (Medical News, Hydration, Friend Synergy).
3. Instant 1-on-1 real-time sync for nudges and partner progress via Supabase Realtime.
4. Robust local hydration logging and dynamic goal calculation.
5. High-contrast, youth-oriented, refreshing wellness design system respecting strict architecture guardrails.
