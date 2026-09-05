import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';

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
    'Rewards & Gear',
  ];

  final miniApps = <MiniAppModule>[
    MiniAppModule(
      id: 'medical-news',
      title: 'News',
      subtitle: 'Medical news & myth-busting',
      category: 'Health Literacy',
      description:
          'Combat false health trends with verified evidence-based articles, interactive Myth vs. Fact breakdowns, and digital health Q&A.',
      icon: Icons.article_rounded,
      colorHex: 0xFF2563EB,
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
      title: 'Hydration',
      subtitle: 'Smart daily water logger',
      category: 'Vitality & Intake',
      description:
          'Smart daily water calculator based on your weight, height, and activity level. One-tap logging and automated push reminders.',
      icon: Icons.water_drop_rounded,
      colorHex: 0xFF0284C7,
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
      title: 'Synergy',
      subtitle: '1-on-1 partner accountability',
      category: 'Mutual Accountability',
      description:
          'Dedicated 1-on-1 accountability for partners or best friends. Send mutual nudges, build shared Synergy Streaks, and view synced real-time progress.',
      icon: Icons.people_alt_rounded,
      colorHex: 0xFF0D9488,
      features: [
        'Mutual hydration & screen break nudges',
        'Shared Synergy Streak system',
        'Real-time synced partner dashboard',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
    MiniAppModule(
      id: 'rewards-shop',
      title: 'Shop',
      subtitle: 'Perks, gear & vouchers',
      category: 'Rewards & Gear',
      description:
          'Explore the official catalog of Infinity PureFlow™ smart bottles, HydroMax+ electrolyte drops, synergy streak freeze shields, discount vouchers, and UI themes.',
      icon: Icons.storefront_rounded,
      colorHex: 0xFF2563EB,
      features: [
        'Official UV-C smart bottles & drops',
        'Instant discount promo codes',
        'Synergy streak freeze shields',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
    MiniAppModule(
      id: 'achievements',
      title: 'Achievements',
      subtitle: 'Milestones & badges',
      category: 'Rewards & Gear',
      description:
          'Track wellness badges, unlock streak achievements, and earn rewards points.',
      icon: Icons.emoji_events_rounded,
      colorHex: 0xFFF59E0B,
      features: [
        '6+ unique milestone badges',
        'Earn extra wellness points',
        'Synced mutual partner achievements',
      ],
      version: 'v1.0.0 (Phase 1)',
      isPinned: true,
    ),
  ].obs;

  List<MiniAppModule> get filteredMiniApps {
    if (selectedFilter.value == 'All') return miniApps;
    return miniApps.where((m) => m.category == selectedFilter.value).toList();
  }

  Map<String, List<MiniAppModule>> get groupedMiniApps {
    final map = <String, List<MiniAppModule>>{};
    for (final app in miniApps) {
      map.putIfAbsent(app.category, () => []).add(app);
    }
    return map;
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
    if (app.id == 'smart-hydration') {
      Get.toNamed(Routes.hydrationDetail);
    } else if (app.id == 'friend-synergy') {
      Get.toNamed(Routes.partnerDetail);
    } else if (app.id == 'rewards-shop') {
      Get.toNamed(Routes.rewardsShop);
    } else if (app.id == 'achievements') {
      Get.toNamed(Routes.achievements);
    } else if (app.id == 'medical-news') {
      Get.find<ShellController>().selectTab(1);
      if (Get.isRegistered<FeedController>()) {
        Get.find<FeedController>().selectTab(SocialTab.feed);
      }
    } else {
      Get.snackbar(
        'Opening ${app.title}',
        'Launching module sandbox (${app.version})...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
