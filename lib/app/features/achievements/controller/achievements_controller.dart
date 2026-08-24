import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

class AchievementItem {
  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.pointsReward,
    required this.progress,
    required this.progressLabel,
    required this.isUnlocked,
    required this.tier,
    this.unlockedDate,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int pointsReward;
  final double progress;
  final String progressLabel;
  final bool isUnlocked;
  final String tier;
  final String? unlockedDate;
}

class AchievementsController extends BaseController {
  final selectedFilter = 'All'.obs;
  final filterTabs = const ['All', 'Unlocked', 'In Progress'];

  final achievements = <AchievementItem>[
    const AchievementItem(
      id: 'ach-1',
      title: 'Hydration Hero',
      description: 'Hit your daily water intake goal for 7 consecutive days.',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF00A3FF),
      pointsReward: 50,
      progress: 1.0,
      progressLabel: '7 / 7 days',
      isUnlocked: true,
      tier: 'Gold',
      unlockedDate: 'Unlocked Aug 18',
    ),
    const AchievementItem(
      id: 'ach-2',
      title: '1-on-1 Synergy Master',
      description:
          'Maintained a 10-day mutual synergy streak with your partner.',
      icon: Icons.people_alt_rounded,
      color: Color(0xFF0084D1),
      pointsReward: 100,
      progress: 1.0,
      progressLabel: '12 / 10 days',
      isUnlocked: true,
      tier: 'Gold',
      unlockedDate: 'Unlocked Aug 21',
    ),
    const AchievementItem(
      id: 'ach-3',
      title: 'Myth Buster Scholar',
      description:
          'Explored 5 verified health literacy and myth-busting articles.',
      icon: Icons.school_rounded,
      color: Color(0xFF7C3AED),
      pointsReward: 40,
      progress: 1.0,
      progressLabel: '5 / 5 articles',
      isUnlocked: true,
      tier: 'Silver',
      unlockedDate: 'Unlocked Aug 22',
    ),
    const AchievementItem(
      id: 'ach-4',
      title: 'Hydration Sprint Champion',
      description:
          'Complete 14 consecutive days of smart hydration goal logging.',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B),
      pointsReward: 150,
      progress: 0.85,
      progressLabel: '12 / 14 days',
      isUnlocked: false,
      tier: 'Platinum',
    ),
    const AchievementItem(
      id: 'ach-5',
      title: 'Digital Screen-Break Habit',
      description:
          'Take 20 mutual posture & eye-relaxation breaks with your partner.',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF10B981),
      pointsReward: 75,
      progress: 0.60,
      progressLabel: '12 / 20 breaks',
      isUnlocked: false,
      tier: 'Bronze',
    ),
    const AchievementItem(
      id: 'ach-6',
      title: 'Century Hydration Club',
      description: 'Log 100 total water intake sessions in Infinity Wellness.',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFF06B6D4),
      pointsReward: 300,
      progress: 0.34,
      progressLabel: '34 / 100 logs',
      isUnlocked: false,
      tier: 'Diamond',
    ),
  ].obs;

  List<AchievementItem> get filteredAchievements {
    if (selectedFilter.value == 'Unlocked') {
      return achievements.where((a) => a.isUnlocked).toList();
    } else if (selectedFilter.value == 'In Progress') {
      return achievements.where((a) => !a.isUnlocked).toList();
    }
    return achievements;
  }

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  int get totalPointsEarned => achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + a.pointsReward);

  void openAchievementDetail(AchievementItem achievement) {
    Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: achievement.color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  color: achievement.color,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSlate,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBadgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tier: ${achievement.tier}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.streakOrangeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${achievement.pointsReward} Points',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.streakOrangeDeep,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.back<void>(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryVibrant,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
