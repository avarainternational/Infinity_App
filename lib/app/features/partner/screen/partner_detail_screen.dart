import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/partner/controller/partner_detail_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';

class PartnerDetailScreen extends BaseView<PartnerDetailController> {
  const PartnerDetailScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.ambientGradientColors,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
          children: [
            // 1. Partner Main Snapshot & Dynamic Gauge
            _buildPartnerHeroCard(context),
            const SizedBox(height: 18),

            // 2. Progress Bar Color Theme Selector (Warm, Love, Green, Energetic, Hot)
            _buildColorThemeSelector(context),
            const SizedBox(height: 18),

            // 3. Past 3 Days Goal History
            _buildPast3DaysSection(context),
            const SizedBox(height: 18),

            // 4. Reminder Timeline (When did you remind him/her?)
            _buildReminderTimelineSection(context),
            const SizedBox(height: 18),

            // 5. Water Intake Timeline (When did she/he drink water?)
            _buildWaterIntakeSection(context),
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
              child: Icon(
                controller.currentTheme.icon,
                color: controller.currentTheme.accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              controller.partnerName.value,
              style: const TextStyle(
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
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.cyanBadgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: controller.sendNudge,
            tooltip: 'Nudge Partner',
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Partner Hero Card with Dynamic Theme Gauge
  // ---------------------------------------------------------------------------
  Widget _buildPartnerHeroCard(BuildContext context) {
    return Obx(() {
      final theme = controller.currentTheme;
      final current = controller.partnerIntakeMl.value;
      final goal = controller.partnerGoalMl.value;
      final progress = controller.progress;
      final percent = controller.percentage;

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
            // Top Badge: Synergy Streak
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
                    '12-Day Synergy Streak Active',
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
            _buildThemedGauge(progress: progress, percent: percent, gradient: theme.gradient),
            const SizedBox(height: 8),

            Text(
              'Today\'s Hydration Status',
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // Quick Action Row
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.sendNudge,
                    icon: const Icon(Icons.water_drop_rounded, size: 16),
                    label: const Text('Send Hydration Nudge'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 2. Color Theme Selector (Warm, Love, Green, Energetic, Hot)
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
                'Change Progress Bar Theme',
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
            'Personalize the progress bar colors for this partner:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // 5 Theme Option Chips
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        // Gradient Circle Preview
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
                                      color: theme.accentColor.withValues(alpha: 0.4),
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
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? theme.accentColor : AppColors.textDark,
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
  // 3. Past 3 Days Goal History (Did she/he reach the goal?)
  // ---------------------------------------------------------------------------
  Widget _buildPast3DaysSection(BuildContext context) {
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
                      Icons.history_rounded,
                      color: AppColors.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Past 3 Days Goal Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.factGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3/3 Reached 🎯',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.factGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Records List
          Obx(() {
            final days = controller.pastDays;
            return Column(
              children: days.map((record) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neutralSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.iceBlueBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  record.isReached
                                      ? Icons.check_circle_rounded
                                      : Icons.hourglass_top_rounded,
                                  size: 18,
                                  color: record.isReached
                                      ? AppColors.factGreen
                                      : AppColors.streakOrange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${record.dayLabel} (${record.dateStr})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: record.isReached
                                    ? AppColors.factGreenBg
                                    : AppColors.streakOrangeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                record.isReached
                                    ? 'Goal Reached (${record.percentage}%)'
                                    : '${record.percentage}% Logged',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: record.isReached
                                      ? AppColors.factGreen
                                      : AppColors.streakOrangeDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: record.progress.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: AppColors.gaugeTrack,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              record.isReached
                                  ? AppColors.factGreen
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${record.intakeMl} ml logged',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Goal: ${record.goalMl} ml',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSlate,
                                fontWeight: FontWeight.w600,
                              ),
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
  // 4. Reminders & Nudges Sent (When did you remind him/her?)
  // ---------------------------------------------------------------------------
  Widget _buildReminderTimelineSection(BuildContext context) {
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
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Reminders Sent to Partner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Timeline of mutual nudges & hydration alerts you sent:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final reminders = controller.reminderLogs;
            return Column(
              children: reminders.map((rem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.cyanPillBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rem.timeStr,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rem.message,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  // 5. Water Intake Timeline (When did she/he drink water?)
  // ---------------------------------------------------------------------------
  Widget _buildWaterIntakeSection(BuildContext context) {
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
                  Icons.local_drink_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Partner Water Log (Today)',
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
            'Detailed log of every intake recorded today:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final logs = controller.waterLogs;
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
                                color: AppColors.cyanBadgeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.label,
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
  // Custom Gauge Painter with Dynamic Theme Gradient
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
            painter: _PartnerGaugePainter(
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

class _PartnerGaugePainter extends CustomPainter {
  const _PartnerGaugePainter({
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
  bool shouldRepaint(covariant _PartnerGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors;
  }
}
