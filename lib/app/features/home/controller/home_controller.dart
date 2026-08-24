import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';

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

class SynergyPartner {
  SynergyPartner({
    required this.id,
    required this.name,
    required this.intakeMl,
    required this.goalMl,
    this.avatarEmoji,
    String themeKey = 'love',
    List<PartnerDayRecord>? pastDays,
    List<PartnerReminderLog>? reminders,
    List<PartnerWaterLog>? waterLogs,
  })  : themeKey = themeKey.obs,
        pastDays = (pastDays ?? []).obs,
        reminders = (reminders ?? []).obs,
        waterLogs = (waterLogs ?? []).obs;

  final String id;
  final String name;
  final int intakeMl;
  final int goalMl;
  final String? avatarEmoji;
  final RxString themeKey;
  final RxList<PartnerDayRecord> pastDays;
  final RxList<PartnerReminderLog> reminders;
  final RxList<PartnerWaterLog> waterLogs;

  double get progress => (goalMl > 0) ? (intakeMl / goalMl).clamp(0.0, 1.0) : 0.0;
  int get percentage => (progress * 100).toInt();

  PartnerThemeOption get theme => PartnerThemes.getByKey(themeKey.value);
}

class HomeFeedCardItem {
  const HomeFeedCardItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.bannerGradient,
    required this.icon,
    this.imageAsset,
    this.readTime = '3 min read',
    this.isOrange = false,
  });

  final String id;
  final String tag;
  final String title;
  final String description;
  final String fullContent;
  final List<Color> bannerGradient;
  final IconData icon;
  final String? imageAsset;
  final String readTime;
  final bool isOrange;
}

class HomeBannerItem {
  const HomeBannerItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.icon,
    required this.gradientColors,
    required this.tagBgColor,
    required this.tagTextColor,
    this.actionType = 'info',
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String ctaText;
  final IconData icon;
  final List<Color> gradientColors;
  final Color tagBgColor;
  final Color tagTextColor;
  final String actionType;
}

class HomeController extends BaseController {
  // User Profile
  final userName = 'Hlyan Paing'.obs;
  final userFullName = 'Hlyan Paing Aung'.obs;
  final userAge = 21.obs;
  final userGender = 'male'.obs;
  final avatarUrl = ''.obs;

  // Notifications
  final notificationCount = 9.obs;

  // Calendar strip state
  final selectedDate = DateTime.now().obs;
  final ScrollController calendarScrollController = ScrollController();

  // Hydration Daily Snapshot (Defaults to 2100 / 2600 ml matching design)
  final currentWaterMl = 2100.obs;
  final dailyGoalMl = 2600.obs;
  final userThemeKey = 'energetic'.obs;

  PartnerThemeOption get userTheme =>
      PartnerThemes.getByKey(userThemeKey.value);

  // Active Streaks
  final personalStreakDays = 7.obs;
  final synergyStreakDays = 12.obs;
  final partnerName = 'Wifey'.obs;

  // Partner Synergy List (Matching Image 1)
  final partners = <SynergyPartner>[
    SynergyPartner(
      id: 'wifey',
      name: 'Wifey❤️',
      intakeMl: 2080,
      goalMl: 2600,
      themeKey: 'love',
      pastDays: [
        const PartnerDayRecord(
          dayLabel: 'Yesterday',
          dateStr: 'Aug 21',
          intakeMl: 2650,
          goalMl: 2600,
          isReached: true,
        ),
        const PartnerDayRecord(
          dayLabel: '2 Days Ago',
          dateStr: 'Aug 20',
          intakeMl: 2700,
          goalMl: 2600,
          isReached: true,
        ),
        const PartnerDayRecord(
          dayLabel: '3 Days Ago',
          dateStr: 'Aug 19',
          intakeMl: 2600,
          goalMl: 2600,
          isReached: true,
        ),
      ],
      reminders: [
        const PartnerReminderLog(
          id: 'rem-1',
          timeStr: 'Today, 2:15 PM',
          message: 'Afternoon hydration nudge sent 💧',
          icon: Icons.water_drop_rounded,
        ),
        const PartnerReminderLog(
          id: 'rem-2',
          timeStr: 'Today, 10:45 AM',
          message: 'Morning water kickstart reminder ☀️',
          icon: Icons.wb_sunny_rounded,
        ),
        const PartnerReminderLog(
          id: 'rem-3',
          timeStr: 'Yesterday, 4:30 PM',
          message: 'Screen break & glass of water reminder 🌊',
          icon: Icons.notifications_active_rounded,
        ),
      ],
      waterLogs: [
        const PartnerWaterLog(
          id: 'log-1',
          timeStr: '5:20 PM',
          amountMl: 300,
          label: 'Post-walk refresh',
        ),
        const PartnerWaterLog(
          id: 'log-2',
          timeStr: '2:10 PM',
          amountMl: 450,
          label: 'Afternoon intake',
        ),
        const PartnerWaterLog(
          id: 'log-3',
          timeStr: '11:30 AM',
          amountMl: 500,
          label: 'Lunch water',
        ),
        const PartnerWaterLog(
          id: 'log-4',
          timeStr: '8:15 AM',
          amountMl: 500,
          label: 'Morning water ritual',
        ),
      ],
    ),
    SynergyPartner(
      id: 'bob',
      name: 'Bob',
      intakeMl: 1950,
      goalMl: 2500,
      themeKey: 'energetic',
      pastDays: [
        const PartnerDayRecord(
          dayLabel: 'Yesterday',
          dateStr: 'Aug 21',
          intakeMl: 2550,
          goalMl: 2500,
          isReached: true,
        ),
        const PartnerDayRecord(
          dayLabel: '2 Days Ago',
          dateStr: 'Aug 20',
          intakeMl: 2500,
          goalMl: 2500,
          isReached: true,
        ),
        const PartnerDayRecord(
          dayLabel: '3 Days Ago',
          dateStr: 'Aug 19',
          intakeMl: 2300,
          goalMl: 2500,
          isReached: false,
        ),
      ],
      reminders: [
        const PartnerReminderLog(
          id: 'rem-b1',
          timeStr: 'Today, 1:00 PM',
          message: 'Gym hydration reminder sent ⚡',
          icon: Icons.fitness_center_rounded,
        ),
        const PartnerReminderLog(
          id: 'rem-b2',
          timeStr: 'Yesterday, 11:15 AM',
          message: 'Desk hydration reminder 💧',
          icon: Icons.water_drop_rounded,
        ),
      ],
      waterLogs: [
        const PartnerWaterLog(
          id: 'log-b1',
          timeStr: '3:45 PM',
          amountMl: 500,
          label: 'Workout water',
        ),
        const PartnerWaterLog(
          id: 'log-b2',
          timeStr: '12:30 PM',
          amountMl: 450,
          label: 'Lunch intake',
        ),
        const PartnerWaterLog(
          id: 'log-b3',
          timeStr: '9:00 AM',
          amountMl: 500,
          label: 'Morning start',
        ),
      ],
    ),
  ].obs;

  // Ecosystem Points
  final wellnessPoints = 450.obs;

  // Banner Carousel State (Habits, Hydration Tips & Wellness Ads)
  final bannerPageController = PageController();
  final currentBannerIndex = 0.obs;
  Timer? _bannerTimer;

  final banners = <HomeBannerItem>[
    const HomeBannerItem(
      id: 'morning-habit',
      tag: 'DAILY HABIT',
      title: 'Morning Water Ritual',
      subtitle: 'Drinking 500ml upon waking boosts metabolism & clears brain fog.',
      ctaText: 'Log 500ml',
      icon: Icons.water_drop_rounded,
      gradientColors: [Color(0xFF0099FF), Color(0xFF0055D4)],
      tagBgColor: Color(0xFFE0F2FE),
      tagTextColor: Color(0xFF0284C7),
      actionType: 'log_water_500',
    ),
    const HomeBannerItem(
      id: 'tumbler-ad',
      tag: 'SPONSORED AD',
      title: 'Infinity PureFlow™ Bottle',
      subtitle: 'Self-cleaning UV-C smart tumbler. 20% off with code PURE20.',
      ctaText: 'Shop 20% Off',
      icon: Icons.local_drink_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
      tagBgColor: Color(0xFFEDE9FE),
      tagTextColor: Color(0xFF6D28D9),
      actionType: 'shop_ad',
    ),
    const HomeBannerItem(
      id: 'synergy-habit',
      tag: 'HABIT STREAK',
      title: 'Synergy Flame Active',
      subtitle: '12-day streak with Wifey! Keep it burning with your daily goal.',
      ctaText: 'Nudge Partner',
      icon: Icons.local_fire_department_rounded,
      gradientColors: [Color(0xFFFF6D00), Color(0xFFE64A19)],
      tagBgColor: Color(0xFFFFECE0),
      tagTextColor: Color(0xFFE65100),
      actionType: 'nudge_wifey',
    ),
    const HomeBannerItem(
      id: 'electrolytes-ad',
      tag: 'WELLNESS AD',
      title: 'HydroMax+ Electrolytes',
      subtitle: 'Sugar-free rapid cellular hydration drops for peak energy.',
      ctaText: 'Explore',
      icon: Icons.bolt_rounded,
      gradientColors: [Color(0xFF0D9488), Color(0xFF047857)],
      tagBgColor: Color(0xFFCCFBF1),
      tagTextColor: Color(0xFF0F766E),
      actionType: 'shop_drops',
    ),
  ].obs;

  // Expand / Collapse state for home news items
  final expandedNewsIds = <String>{}.obs;

  bool isNewsExpanded(String id) => expandedNewsIds.contains(id);

  void toggleNewsExpand(String id) {
    if (expandedNewsIds.contains(id)) {
      expandedNewsIds.remove(id);
    } else {
      expandedNewsIds.add(id);
    }
  }

  // News and Challenges List
  final newsAndChallenges = <HomeFeedCardItem>[
    const HomeFeedCardItem(
      id: 'home-news-1',
      tag: 'MYTH BUSTER',
      title: 'Can Drinking 3L of Water Cure Acne? The Clinical Reality',
      description:
          'Dermatological studies show that while optimal hydration maintains skin elasticity, acne is driven by follicular biology and sebum.',
      fullContent:
          'While adequate hydration is vital for maintaining skin barrier integrity, sebum balance, and cellular turnover, clinical dermatological evidence clarifies that acne is primarily caused by follicular hyperkeratinization, excess sebum production, and Cutibacterium acnes colonization. Optimal daily hydration supports kidney filtration and skin resilience, but should be combined with evidence-based topical care.',
      bannerGradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      icon: Icons.water_drop_rounded,
      imageAsset: AppImages.news2,
      readTime: '3 min read',
      isOrange: false,
    ),
    const HomeFeedCardItem(
      id: 'home-news-2',
      tag: 'CHALLENGE',
      title: '7-Day Smart Hydration Sprint: +150 Points',
      description:
          'Hit your personalized daily water target for 7 consecutive days and earn 150 Wellness Points.',
      fullContent:
          'Build strong hydration habits with the community! Log your water intake consistently throughout the day. Reaching your daily calibrated goal for 7 consecutive days unlocks bonus ecosystem points, streak protection badges, and wellness rewards.',
      bannerGradient: [Color(0xFFFF7043), Color(0xFFFF5252)],
      icon: Icons.emoji_events_rounded,
      imageAsset: AppImages.news4,
      readTime: 'Active Challenge',
      isOrange: true,
    ),
    const HomeFeedCardItem(
      id: 'home-news-3',
      tag: 'CLINICAL INSIGHT',
      title: 'Optimal Electrolyte Balance During High-Intensity Training',
      description:
          'Understanding sodium and potassium sweat loss and the science of rapid cellular replenishment during workouts.',
      fullContent:
          'During intense physical exertion exceeding 45-60 minutes, sweating leads to substantial electrolyte loss. Replacing sodium, magnesium, and potassium prevents cellular hypohydration and muscle fatigue. Use hypotonic electrolyte solutions for rapid absorption during training sessions.',
      bannerGradient: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      icon: Icons.bolt_rounded,
      imageAsset: AppImages.news1,
      readTime: '4 min read',
      isOrange: false,
    ),
    const HomeFeedCardItem(
      id: 'home-news-4',
      tag: 'NEUROSCIENCE',
      title: 'Circadian Biology: Blue Light & Melatonin Suppression',
      description:
          'How night-time digital screens alter circadian rhythm and actionable digital hygiene tips for deeper sleep.',
      fullContent:
          'Retinal ganglion cells are particularly sensitive to 460-480nm blue light from smartphone and laptop screens. Evening exposure delays melatonin release by up to 45%. Implementing a 60-minute digital sunset before bed dramatically improves REM sleep architecture.',
      bannerGradient: [Color(0xFF134E5E), Color(0xFF71B280)],
      icon: Icons.bedtime_rounded,
      imageAsset: AppImages.news3,
      readTime: '5 min read',
      isOrange: false,
    ),
  ].obs;

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

  /// Generate a date strip from 14 days ago to 28 days in the future
  List<DateTime> get dateList {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 14));
    return List.generate(45, (index) => start.add(Duration(days: index)));
  }

  String getWeekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthService>()) {
      final auth = AuthService.to;
      if (auth.userName.value.isNotEmpty && auth.userName.value != 'Alex Morgan') {
        userName.value = auth.userName.value;
      }
      if (auth.avatarUrl.value.isNotEmpty) {
        avatarUrl.value = auth.avatarUrl.value;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToDate(selectedDate.value, animated: false);
    });
    // Fallback delayed trigger in case layout settles asynchronously
    Future.delayed(const Duration(milliseconds: 100), () {
      if (calendarScrollController.hasClients) {
        scrollToDate(selectedDate.value, animated: false);
      }
    });
    _startBannerAutoPlay();
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (bannerPageController.hasClients && banners.isNotEmpty) {
        final nextIndex = (currentBannerIndex.value + 1) % banners.length;
        bannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    scrollToDate(selectedDate.value, animated: true);
  }

  void scrollToDate(DateTime date, {bool animated = true}) {
    final list = dateList;
    final index = list.indexWhere(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
    if (index != -1 && calendarScrollController.hasClients) {
      final position = calendarScrollController.position;
      final viewportWidth = position.viewportDimension;
      const itemWidth = 48.0;
      const itemSpacing = 8.0;
      // Center of the target item from the start of the list
      final itemCenter = index * (itemWidth + itemSpacing) + (itemWidth / 2.0);
      final targetOffset = itemCenter - (viewportWidth / 2.0);
      final clampedOffset = targetOffset.clamp(
        0.0,
        position.maxScrollExtent,
      );
      if (animated) {
        calendarScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        calendarScrollController.jumpTo(clampedOffset);
      }
    }
  }

  void onBannerTap(HomeBannerItem banner) {
    switch (banner.actionType) {
      case 'log_water_500':
        logWater(500);
        break;
      case 'nudge_wifey':
        final wifey = partners.firstWhereOrNull((p) => p.id == 'wifey');
        if (wifey != null) {
          notifyPartner(wifey);
        } else {
          Get.snackbar(
            'Partner Synergy 🔥',
            'Nudge sent to your partner to keep the streak going!',
            snackPosition: SnackPosition.TOP,
          );
        }
        break;
      case 'shop_ad':
        Get.snackbar(
          'Infinity PureFlow™ Store 🏷️',
          'Promo code PURE20 applied for 20% off!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        break;
      case 'shop_drops':
        Get.snackbar(
          'HydroMax+ Electrolytes ⚡',
          'Learn more about cellular hydration science & mineral absorption.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        break;
      default:
        Get.snackbar(
          banner.title,
          banner.subtitle,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        break;
    }
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    calendarScrollController.dispose();
    super.onClose();
  }

  double get hydrationProgress {
    if (dailyGoalMl.value <= 0) return 0.0;
    return (currentWaterMl.value / dailyGoalMl.value).clamp(0.0, 1.0);
  }

  int get hydrationPercentage => (hydrationProgress * 100).toInt();

  void logWater(int amountMl) {
    currentWaterMl.value += amountMl;
    if (Get.context != null) {
      Get.snackbar(
        'Water Logged! 💧',
        '+$amountMl ml added. Total: ${currentWaterMl.value} / ${dailyGoalMl.value} ml',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void notifyPartner(SynergyPartner partner) {
    Get.snackbar(
      'Nudge Sent! 💧',
      'Hydration reminder sent to ${partner.name}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void viewPartner(SynergyPartner partner) {
    Get.toNamed(Routes.partnerDetail, arguments: partner);
  }

  void viewHydrationDetails() {
    Get.toNamed(Routes.hydrationDetail);
  }

  void addPartner() {
    Get.snackbar(
      'Add Partner',
      'Invite a partner via QR code or email for 1-on-1 synergy',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void openMiniApp(String id) {
    if (id == 'medical-news' || id == 'news') {
      Get.find<ShellController>().selectTab(1); // Social / Feed Tab
      if (Get.isRegistered<FeedController>()) {
        Get.find<FeedController>().selectTab(SocialTab.feed);
      }
    } else if (id == 'challenges') {
      Get.find<ShellController>().selectTab(1); // Social / Feed Tab
      if (Get.isRegistered<FeedController>()) {
        Get.find<FeedController>().selectTab(SocialTab.challenges);
      }
    } else if (id == 'smart-hydration' || id == 'hydration' || id == 'reminder') {
      Get.toNamed(Routes.hydrationDetail);
    } else if (id == 'friend-synergy' || id == 'synergy' || id == 'partner') {
      Get.toNamed(Routes.partnerDetail);
    } else if (id == 'rewards-shop' || id == 'rewards' || id == 'shop') {
      Get.toNamed(Routes.rewardsShop);
    } else if (id == 'achievements' || id == 'badges') {
      Get.toNamed(Routes.achievements);
    } else if (id == 'more' || id == 'mini-apps') {
      openMiniAppsTab();
    } else {
      openMiniAppsTab();
    }
  }

  void openMiniAppsTab() {
    Get.find<ShellController>().selectTab(3); // 3: Mini Apps Tab
  }
}
