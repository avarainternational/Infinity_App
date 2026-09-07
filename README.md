# Infinity Wellness (by Infinity Water)

Reward Shop configuration, Capacitor packaging, Flutter hosting, offline behavior and Vercel operations are documented in [`context/reward-shop-capacitor-guide.md`](context/reward-shop-capacitor-guide.md).

Infinity Wellness is a Flutter mobile digital health and wellness companion designed for youths and young adults. It prioritizes health literacy, mutual accountability, and well-being through a modular Super App pattern featuring a central shell and isolated Mini-Apps.

## Super App Architecture

1. **Super App Native Shell**:
   - **Home**: Daily wellness snapshot, smart hydration meter, active streaks, quick mini-app shortcuts, wellness banners.
   - **Feed**: 16:9 graphic challenges, evidence-based medical news cards with YouTube thumbnail styling, and interactive Leaderboard with top 3 podiums.
   - **Mini-App Store**: Clean white background directory with vertical category sections and app launcher icons.
   - **Wallet**: Ecosystem wallet for Wellness Points, streak perks, and Rewards Shop portal.
   - **Profile**: Health metrics (weight, height, activity level, calculated daily goal), 3-icon achievements showcase portal, 1-on-1 partner sync, and account settings.

2. **Isolated Mini-Apps**:
   - **Smart Hydration Reminder** (`/hydration-detail`): Dynamic water goal calculation and intake logging.
   - **Friend Synergy (1-on-1)** (`/partner-detail`): Dedicated mutual accountability, partner nudges, and shared Synergy Streaks.
   - **Medical News & Myths** (`/feed`): Evidence-based articles and Myth vs. Fact interactive breakdowns.
   - **Wellness Rewards Shop** (`/rewards-shop`): Product catalog for smart UV-C bottles, electrolyte drops, streak freeze shields, and discount vouchers.
   - **Achievements & Badges** (`/achievements`): Milestone badges, progress tracking, and extra points rewards.

3. **Backend & Security**:
   - Supabase Auth, PostgreSQL, and Realtime sync.
   - Row Level Security (RLS) with client-safe anonymous keys.
