# UI Context

## Direction

**Infinity Wellness** uses a modern, refreshing visual language inspired by youth-focused wellness companions and premium digital health experiences. The aesthetic reflects purity, vitality, and health literacy through a crisp white/neutral foundation accented by refreshing oceanic blues, vibrant aquas, and energizing wellness tones.

## Visual Hierarchy

- **Background**: Soft neutral light background (`AppColors.background`) providing a clean canvas.
- **Surfaces**: Crisp white elevated cards and sheets (`AppColors.surface`) with subtle shadows and clean border delineation.
- **Typography**: Bold, high-contrast black/dark charcoal text for effortless readability across headings and body copy. No illegible low-contrast text.
- **Brand Accents**:
  - **Primary**: Ocean / Wellness Blue (`#0284C7` / `#0369A1`) reflecting Infinity Water's purity and health focus.
  - **Secondary / Aqua**: Vibrant Mint / Aqua Teal (`#0D9488` / `#14B8A6`) for hydration rings and health metrics.
  - **Accent / Streak**: Energizing Amber / Coral (`#F59E0B` / `#F97316`) for active streaks and synergy badges.
  - **Badge / Verified**: Medical Violet / Indigo (`#6366F1`) for verified medical contributor badges.

## Color Tokens

| Token Role | Color Name | Hex Code | Purpose |
| --- | --- | --- | --- |
| `AppColors.primary` / `accent` | Vibrant Blue (Logo Primary) | `#00A3FF` | Main action buttons, active states. |
| `AppColors.primaryDark` | Vibrant Blue Dark | `#005C99` | Dark mode primary, header/footer backgrounds. |
| `AppColors.primarySoft` / `accentSoft` | Vibrant Blue Soft | `#E0F7FF` | Highlight backgrounds, secondary buttons. |
| `AppColors.violet` / `secondary` | Bold Violet (Logo Accent) | `#6200EE` | Secondary actions, synergy features. |
| `AppColors.violetSoft` | Violet Soft | `#E0CCFF` | Complementary highlights, background tints. |
| `AppColors.background` | Clean Cool Grey | `#EFF0F2` | Main app background. |
| `AppColors.surface` | Pure White | `#FFFFFF` | Card backgrounds, list items. |
| `AppColors.textPrimary` / `textSecondary` | Pure Black / Deep Grey | `#000000` | Main text color. |
| `AppColors.border` | Simple Grey | `#CCCCCC` | Divider lines, input borders. |

## Super App Navigation Shell

The bottom navigation bar provides frictionless access to the five main pillars:

1. **Home** (`Icons.home_rounded`): Daily snapshot, streak overview, quick-launch mini-app widgets.
2. **Feed** (`Icons.newspaper_rounded`): Verified health news, myth-busting content, and ecosystem announcements.
3. **Mini-App Store** (`Icons.apps_rounded`): Directory of functional mini-app modules with quick launch and pin capabilities.
4. **Wallet** (`Icons.account_balance_wallet_rounded`): Wellness Points balance, streak perks, and redemption directory.
5. **Profile** (`Icons.person_rounded`): Health metrics (weight, height, activity level, dynamic hydration goal), partner settings.

## Mini-App UI Specifications

### 1. Medical News & Myth-Busting Feed
- **Header Filter**: Toggle between "All Articles", "Myth vs. Fact", and "Health Q&A".
- **Article Card**: Thumbnail, title, reading time, medical contributor badge ("Verified by Med Student").
- **Myth vs. Fact Card**: Interactive split card showing the popular myth (red/coral accent) vs. evidence-based medical fact (green/teal accent) with expandable detailed explanation.
- **Q&A Section**: Searchable health literacy questions with verified medical answers and an "Ask a Question" floating modal.

### 2. Smart Hydration Reminder
- **Intake Visualizer**: Interactive circular or fluid wave progress ring showing current intake vs. dynamic daily goal (e.g., `1,800 / 2,600 ml - 69%`).
- **Quick-Log Buttons**: One-tap pill buttons for standard volumes (+250ml Glass, +500ml Bottle, +750ml Sports Bottle, Custom).
- **Goal Calculator Card**: Visual sliders for weight, height, and activity level displaying live recalculation of the recommended daily water goal.
- **Timeline**: Hourly hydration breakdown showing logged intervals.

### 3. Friend Synergy (1-on-1)
- **Partner Card**: Connected partner profile, online/recent status, and their live hydration goal progress ring.
- **Synergy Streak Banner**: Vibrant shared streak counter with flame/water synergy icon (requires both users to hit daily goals).
- **Mutual Nudge Controls**: Quick-action cards to send instant interactive nudges ("💧 Time to Hydrate", "👀 Screen Break Time").
- **Realtime Sync Indicator**: Live pulse badge showing instant synchronization status via Supabase Realtime.

## Accessibility & Responsiveness

- Minimum touch target size of 48x48 dp for all buttons and interactive chips.
- Support responsive layout scaling across compact and large mobile screens using `SafeArea` and scrollable containers.
- Strong text contrast adhering to WCAG AA guidelines.
