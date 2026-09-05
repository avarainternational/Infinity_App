import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/hydration/controller/hydration_detail_controller.dart';
import 'package:infinity_wellness/app/features/hydration/model/hydration_models.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class HydrationDetailScreen extends BaseView<HydrationDetailController> {
  const HydrationDetailScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletColors.background,
      appBar: _buildAppBar(context),
      body: Container(
        color: WalletColors.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          children: [
            // 1. Hero Gauge Card with Dynamic Theme
            _buildHeroGaugeCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 2. Personal Progress Bar Color Theme Selector (Warm, Love, Green, Energetic, Hot)
            _buildColorThemeSelector(context),
            const SizedBox(height: WalletSpacing.md),

            // 3. Beverage Category & Quick Intake Logger
            _buildQuickIntakeSection(context),
            const SizedBox(height: WalletSpacing.md),

            // 4. 7-Day Performance Analytics & History Chart
            _buildWeeklyAnalyticsSection(context),
            const SizedBox(height: WalletSpacing.md),

            // 5. Smart Daily Goal Calculator (Weight, Height & Activity Level)
            _buildSmartGoalCalculatorSection(context),
            const SizedBox(height: WalletSpacing.md),

            // 6. Today's Chronological Intake Timeline
            _buildTodayIntakeTimelineSection(context),
            const SizedBox(height: WalletSpacing.md),

            // 7. Automated Reminder Schedule & Notification Settings
            _buildReminderSettingsSection(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: controller.currentTheme.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Hydration Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Obx(
            () => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: controller.isRemindersEnabled.value
                      ? AppColors.cyanBadgeBg
                      : AppColors.neutralSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  controller.isRemindersEnabled.value
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: controller.isRemindersEnabled.value
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 20,
                ),
              ),
              onPressed: () => controller
                  .toggleReminders(!controller.isRemindersEnabled.value),
              tooltip: 'Toggle Hydration Reminders',
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Hero Gauge Card with Dynamic Theme
  // ---------------------------------------------------------------------------
  Widget _buildHeroGaugeCard(BuildContext context) {
    return Obx(() {
      final theme = controller.currentTheme;
      final current = controller.currentWaterMl.value;
      final goal = controller.dailyGoalMl.value;
      final progress = controller.progress;
      final percent = controller.percentage;
      final streak = controller.personalStreakDays.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Streak Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: theme.accentColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '$streak-Day Personal Streak Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Semicircle Gauge
            _buildThemedGauge(
              progress: progress,
              percent: percent,
              gradient: theme.gradient,
            ),
            const SizedBox(height: 8),

            const Text(
              'Total Water Intake Today',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$current / $goal ml',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              current >= goal
                  ? '🎉 Daily Goal Complete! Great hydration!'
                  : '${goal - current} ml remaining to hit target',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: current >= goal
                    ? AppColors.factGreen
                    : AppColors.textSubtitle,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 2. Personal Color Theme Selector (Warm, Love, Green, Energetic, Hot)
  // ---------------------------------------------------------------------------
  Widget _buildColorThemeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Personal Gauge Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select your favorite color gradient for your hydration meters:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // 5 Theme Chips
          Obx(() {
            final activeKey = controller.selectedThemeKey.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: PartnerThemes.all.map((theme) {
                final isSelected = activeKey == theme.key;

                return GestureDetector(
                  onTap: () => controller.setTheme(theme.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.accentColor.withValues(alpha: 0.12)
                          : AppColors.neutralSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.accentColor
                            : AppColors.borderLight,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: theme.gradient,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          theme.accentColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              isSelected ? Icons.check_rounded : theme.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          theme.name,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? theme.accentColor
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Beverage Category & Quick Intake Logger
  // ---------------------------------------------------------------------------
  Widget _buildQuickIntakeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Log Water & Beverages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Beverage Type Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Obx(
              () => Row(
                children: BeverageTypes.all.map((bev) {
                  final isSelected =
                      controller.selectedBeverage.value.id == bev.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.selectedBeverage.value = bev,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? bev.color.withValues(alpha: 0.15)
                              : AppColors.neutralSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? bev.color : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(bev.icon, size: 16, color: bev.color),
                            const SizedBox(width: 6),
                            Text(
                              bev.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.textDark
                                    : AppColors.textSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Log Buttons (+150ml, +250ml, +500ml, +750ml)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogPillButton(
                amount: 150,
                label: '150 ml',
                subtitle: 'Glass',
                icon: Icons.local_cafe_rounded,
              ),
              _buildLogPillButton(
                amount: 250,
                label: '250 ml',
                subtitle: 'Cup',
                icon: Icons.local_drink_rounded,
              ),
              _buildLogPillButton(
                amount: 500,
                label: '500 ml',
                subtitle: 'Bottle',
                icon: Icons.water_drop_rounded,
              ),
              _buildLogPillButton(
                amount: 750,
                label: '750 ml',
                subtitle: 'Tumbler',
                icon: Icons.sports_bar_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogPillButton({
    required int amount,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: () => controller.logIntake(amount),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F4FE), Color(0xFFCEEEFD)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cyanPillBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(height: 3),
                Text(
                  '+$label',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. 7-Day Performance Analytics & History Chart
  // ---------------------------------------------------------------------------
  Widget _buildWeeklyAnalyticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cyanBadgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.primary,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        '7-Day History',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.factGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.weeklyAdherencePercent.value}% Adherence',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.factGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Bar Chart
          Obx(() {
            final history = controller.weeklyHistory;
            const maxGraphMl = 3000.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.map((day) {
                final barHeight = ((day.intakeMl / maxGraphMl) * 90)
                    .clamp(14.0, 90.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(day.intakeMl / 1000).toStringAsFixed(1)}L',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: day.isReached
                            ? AppColors.factGreen
                            : AppColors.textSlate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 26,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: day.isReached
                              ? [AppColors.primary, AppColors.cyanGradientStart]
                              : [AppColors.disabled, AppColors.borderLight],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: day.isReached
                          ? const Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.check,
                                    size: 12, color: Colors.white),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day.dayLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 14),

          // Stat Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.neutralSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Daily Avg', '${controller.averageDailyMl.value} ml'),
                const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                        color: AppColors.borderLight, thickness: 1)),
                _buildStatPill('Streak', '${controller.personalStreakDays.value} Days 🔥'),
                const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                        color: AppColors.borderLight, thickness: 1)),
                _buildStatPill('Target Met', '5/6 Days'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSlate,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Smart Daily Goal Calculator (Weight, Height & Activity Level)
  // ---------------------------------------------------------------------------
  Widget _buildSmartGoalCalculatorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Smart Goal Calculator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Calibrated to your body weight, height, and activity level:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Metric Inputs (Weight, Height, Activity)
          Obx(() {
            return Column(
              children: [
                // Weight & Height Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Body Weight',
                        value: '${controller.userWeightKg.value.toInt()} kg',
                        icon: Icons.monitor_weight_outlined,
                        onTap: () {
                          // Quick increment cycle
                          controller.userWeightKg.value =
                              (controller.userWeightKg.value >= 90)
                                  ? 50.0
                                  : controller.userWeightKg.value + 2.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Height',
                        value: '${controller.userHeightCm.value.toInt()} cm',
                        icon: Icons.height_rounded,
                        onTap: () {
                          controller.userHeightCm.value =
                              (controller.userHeightCm.value >= 195)
                                  ? 160.0
                                  : controller.userHeightCm.value + 5.0;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Activity Level & Climate Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Activity Level',
                        value: controller.activityLevel.value,
                        icon: Icons.directions_run_rounded,
                        onTap: () {
                          if (controller.activityLevel.value.contains('+300')) {
                            controller.activityLevel.value =
                                'Intense Workout (+600 ml)';
                          } else if (controller.activityLevel.value
                              .contains('+600')) {
                            controller.activityLevel.value = 'Sedentary (+0 ml)';
                          } else {
                            controller.activityLevel.value =
                                'Moderate (+300 ml)';
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Calculated Output Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cyanPillBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recommended Intake',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSlate,
                            ),
                          ),
                          Text(
                            '${controller.calculatedRecommendedGoal} ml / day',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      FilledButton(
                        onPressed: controller.applyCalculatedGoal,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Goal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutralSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_vert_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Today's Chronological Intake Timeline
  // ---------------------------------------------------------------------------
  Widget _buildTodayIntakeTimelineSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Intake Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Timeline of every drink recorded today:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final logs = controller.intakeLogs;
            if (logs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No drinks logged today yet.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return Column(
              children: logs.map((log) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.neutralSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (log.iconColor ?? AppColors.primary)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                log.icon,
                                size: 16,
                                color: log.iconColor ?? AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.beverageType,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  log.timeStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSlate,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.cyanPillBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${log.amountMl} ml',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.textMuted),
                              onPressed: () => controller.deleteLog(log),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Remove log',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Automated Reminder Schedule & Notification Settings
  // ---------------------------------------------------------------------------
  Widget _buildReminderSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: AppColors.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Smart Push Reminders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Switch.adaptive(
                  value: controller.isRemindersEnabled.value,
                  onChanged: controller.toggleReminders,
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Gentle reminders throughout the day to stay consistently hydrated:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Interval Selector (60m, 90m, 120m)
          Obx(() {
            final activeInterval = controller.reminderIntervalMins.value;

            return Row(
              children: [60, 90, 120].map((mins) {
                final isSelected = activeInterval == mins;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => controller.reminderIntervalMins.value = mins,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.cyanActiveChip
                              : AppColors.neutralSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Every $mins min',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.textDark
                                  : AppColors.textSlate,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Semicircle Gauge with Dynamic Gradient
  // ---------------------------------------------------------------------------
  Widget _buildThemedGauge({
    required double progress,
    required int percent,
    required List<Color> gradient,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: 220,
          height: 120,
          child: CustomPaint(
            painter: _PersonalGaugePainter(
              progress: animatedProgress,
              strokeWidth: 14.0,
              gradientColors: gradient,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: gradient.first.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: gradient.first,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PersonalGaugePainter extends CustomPainter {
  const _PersonalGaugePainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = AppColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: gradientColors.length >= 2
            ? gradientColors
            : [gradientColors.first, gradientColors.first],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(rect, math.pi, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PersonalGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors;
  }
}
