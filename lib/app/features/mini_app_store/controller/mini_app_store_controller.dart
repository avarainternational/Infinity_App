import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

class MiniAppModule {
  MiniAppModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.features,
    required this.version,
    bool isPinned = true,
  }) : isPinned = isPinned.obs;

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final IconData icon;
  final int colorHex;
  final List<String> features;
  final String version;
  final RxBool isPinned;
}

class MiniAppStoreController extends BaseController {
  final selectedFilter = 'All'.obs;
  final filterCategories = const [
    'All',
    'Health Literacy',
    'Vitality & Intake',
    'Mutual Accountability',
  ];

  final miniApps = <MiniAppModule>[
    MiniAppModule(
      id: 'medical-news',
      title: 'Medical News & Myths',
      subtitle: 'Curated by medical students & doctors',
      category: 'Health Literacy',
      description:
          'Combat false health trends with verified evidence-based articles, interactive Myth vs. Fact breakdowns, and digital health Q&A.',
      icon: Icons.article_rounded,
      colorHex: 0xFF6200EE,
      features: [
        'Evidence-based wellness articles',
        'Interactive Myth vs. Fact cards',
        'Public health literacy Q&A',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
    MiniAppModule(
      id: 'smart-hydration',
      title: 'Smart Hydration Reminder',
      subtitle: 'Dynamic water goals & intake logger',
      category: 'Vitality & Intake',
      description:
          'Smart daily water calculator based on your weight, height, and activity level. One-tap logging and automated push reminders.',
      icon: Icons.water_drop_rounded,
      colorHex: 0xFF00A3FF,
      features: [
        'Dynamic smart water calculator',
        'Frictionless 1-tap logging',
        'Automated local push notifications',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
    MiniAppModule(
      id: 'friend-synergy',
      title: 'Friend Synergy (1-on-1)',
      subtitle: 'Mutual accountability for pairs',
      category: 'Mutual Accountability',
      description:
          'Dedicated 1-on-1 accountability for partners or best friends. Send mutual nudges, build shared Synergy Streaks, and view synced real-time progress.',
      icon: Icons.people_alt_rounded,
      colorHex: 0xFF005C99,
      features: [
        'Mutual hydration & screen break nudges',
        'Shared Synergy Streak system',
        'Real-time synced partner dashboard',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
  ].obs;

  List<MiniAppModule> get filteredMiniApps {
    if (selectedFilter.value == 'All') return miniApps;
    return miniApps.where((m) => m.category == selectedFilter.value).toList();
  }

  void togglePin(String id) {
    final app = miniApps.firstWhereOrNull((m) => m.id == id);
    if (app != null) {
      app.isPinned.toggle();
      Get.snackbar(
        app.isPinned.value ? 'Pinned to Home' : 'Unpinned from Home',
        '${app.title} will ${app.isPinned.value ? "now appear" : "no longer appear"} on your Home quick-launch.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void launchModule(MiniAppModule app) {
    Get.snackbar(
      'Opening ${app.title}',
      'Launching module sandbox (${app.version})...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
