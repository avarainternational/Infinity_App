import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';

class ProfileAchievement {
  const ProfileAchievement({
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

class ProfileController extends BaseController {
  AuthService? get _authService =>
      Get.isRegistered<AuthService>() ? AuthService.to : null;

  // User Account (Reactive to Supabase AuthService)
  late final RxString userName =
      (_authService?.userName.value.isNotEmpty == true
              ? _authService!.userName.value
              : 'Alex Morgan')
          .obs;
  late final RxString userEmail =
      (_authService?.userEmail.value.isNotEmpty == true
              ? _authService!.userEmail.value
              : 'alex.morgan@infinitywellness.io')
          .obs;
  late final RxString avatarUrl = _authService?.avatarUrl ?? ''.obs;
  final memberTier = 'Infinity Wellness Explorer'.obs;

  // ---------------------------------------------------------------------------
  // Achievements & Badges
  // ---------------------------------------------------------------------------
  final achievements = <ProfileAchievement>[
    const ProfileAchievement(
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
    const ProfileAchievement(
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
    const ProfileAchievement(
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
    const ProfileAchievement(
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
    const ProfileAchievement(
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
    const ProfileAchievement(
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

  int get unlockedAchievementsCount =>
      achievements.where((a) => a.isUnlocked).length;

  @override
  void onInit() {
    super.onInit();
    final auth = _authService;
    if (auth != null) {
      ever(auth.userName, (val) {
        if (val.isNotEmpty) userName.value = val;
      });
      ever(auth.userEmail, (val) {
        if (val.isNotEmpty) userEmail.value = val;
      });
    }
  }

  Future<void> signOut() async {
    final auth = _authService;
    if (auth != null) {
      await auth.signOut();
    }
  }

  // Health Metrics
  final weightKg = 68.0.obs;
  final heightCm = 175.0.obs;
  final activityLevel = 'Moderate Active'.obs;
  final activityOptions = const [
    'Sedentary (Low)',
    'Light Active',
    'Moderate Active',
    'Very Active (Athletic)',
  ];

  // 1-on-1 Synergy Partner
  final partnerName = 'Jamie Lee'.obs;
  final partnerEmail = 'jamie.lee@infinitywellness.io'.obs;
  final partnerStatus = 'Active & Synced'.obs;
  final synergyStreakDays = 12.obs;

  // Notification Preferences
  final hydrationRemindersEnabled = true.obs;
  final partnerNudgesEnabled = true.obs;

  // Smart Dynamic Water Goal Calculation
  int get calculatedDailyGoalMl {
    final baseMl = weightKg.value * 35;
    int activityBonus = 0;
    if (activityLevel.value.contains('Moderate')) {
      activityBonus = 300;
    } else if (activityLevel.value.contains('Very')) {
      activityBonus = 600;
    } else if (activityLevel.value.contains('Light')) {
      activityBonus = 150;
    }
    return (baseMl + activityBonus).round();
  }

  void updateWeight(double newWeight) {
    weightKg.value = newWeight;
  }

  void updateHeight(double newHeight) {
    heightCm.value = newHeight;
  }

  void setActivityLevel(String level) {
    activityLevel.value = level;
  }
}
