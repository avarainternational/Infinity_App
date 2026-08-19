import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

class PinnedMiniApp {
  const PinnedMiniApp({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.colorHex,
    required this.description,
  });

  final String id;
  final String title;
  final String category;
  final IconData icon;
  final int colorHex;
  final String description;
}

class HomeController extends BaseController {
  final userName = 'Alex'.obs;
  final userFullName = 'Alex Morgan'.obs;

  // Hydration Daily Snapshot
  final currentWaterMl = 1850.obs;
  final dailyGoalMl = 2600.obs;

  // Active Streaks
  final personalStreakDays = 7.obs;
  final synergyStreakDays = 12.obs;
  final partnerName = 'Jamie'.obs;

  // Ecosystem Points
  final wellnessPoints = 450.obs;

  // Pinned Mini-Apps
  final pinnedMiniApps = <PinnedMiniApp>[
    const PinnedMiniApp(
      id: 'medical-news',
      title: 'Medical News & Myths',
      category: 'Health Literacy',
      icon: Icons.article_rounded,
      colorHex: 0xFF6200EE,
      description: 'Bite-sized verified health articles and myth breakdowns.',
    ),
    const PinnedMiniApp(
      id: 'smart-hydration',
      title: 'Smart Hydration',
      category: 'Vitality & Intake',
      icon: Icons.water_drop_rounded,
      colorHex: 0xFF00A3FF,
      description: 'Smart daily water calculator & one-tap intake logger.',
    ),
    const PinnedMiniApp(
      id: 'friend-synergy',
      title: 'Friend Synergy (1-on-1)',
      category: 'Mutual Accountability',
      icon: Icons.people_alt_rounded,
      colorHex: 0xFF005C99,
      description: '1-on-1 partner nudges and shared synergy streaks.',
    ),
  ].obs;

  double get hydrationProgress {
    if (dailyGoalMl.value <= 0) return 0.0;
    return (currentWaterMl.value / dailyGoalMl.value).clamp(0.0, 1.0);
  }

  int get hydrationPercentage => (hydrationProgress * 100).toInt();

  void logWater(int amountMl) {
    currentWaterMl.value += amountMl;
    Get.snackbar(
      'Water Logged! 💧',
      '+$amountMl ml added. Total: ${currentWaterMl.value} / ${dailyGoalMl.value} ml',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
