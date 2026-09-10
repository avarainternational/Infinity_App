import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/repositories/feed_repository.dart';
import 'package:infinity_wellness/app/data/repositories/hydration_repository.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/notification_service.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    required int intakeMl,
    required int goalMl,
    this.avatarEmoji,
    String themeKey = 'love',
    List<PartnerDayRecord>? pastDays,
    List<PartnerReminderLog>? reminders,
    List<PartnerWaterLog>? waterLogs,
  })  : intakeMl = intakeMl.obs,
        goalMl = goalMl.obs,
        themeKey = themeKey.obs,
        pastDays = (pastDays ?? []).obs,
        reminders = (reminders ?? []).obs,
        waterLogs = (waterLogs ?? []).obs;

  final String id;
  final String name;
  final RxInt intakeMl;
  final RxInt goalMl;
  final String? avatarEmoji;
  final RxString themeKey;
  final RxList<PartnerDayRecord> pastDays;
  final RxList<PartnerReminderLog> reminders;
  final RxList<PartnerWaterLog> waterLogs;

  double get progress => (goalMl.value > 0) ? (intakeMl.value / goalMl.value).clamp(0.0, 1.0) : 0.0;
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
  final userName = 'Wellness User'.obs;
  final userFullName = 'Wellness User'.obs;
  final userAge = 22.obs;
  final userGender = 'prefer_not_to_say'.obs;
  final avatarUrl = ''.obs;

  String get greetingText {
    final hour = DateTime.now().hour;
    final name = userName.value.isNotEmpty ? userName.value.split(' ').first : 'there';
    if (hour < 12) {
      return 'Good morning, $name 👋';
    } else if (hour < 17) {
      return 'Good afternoon, $name 👋';
    } else {
      return 'Good evening, $name 👋';
    }
  }

  String get formattedCurrentDate {
    final now = selectedDate.value;
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  // Notifications
  final notificationCount = 0.obs;

  // Calendar strip state
  final selectedDate = DateTime.now().obs;
  final ScrollController calendarScrollController = ScrollController();

  // Hydration Daily Snapshot (Real data loaded from Supabase)
  final currentWaterMl = 0.obs;
  final dailyGoalMl = 2600.obs;
  final sipAmountMl = 250.obs;
  final userThemeKey = 'energetic'.obs;

  PartnerThemeOption get userTheme =>
      PartnerThemes.getByKey(userThemeKey.value);

  // Active Streaks
  final personalStreakDays = 0.obs;
  final synergyStreakDays = 0.obs;
  final partnerName = ''.obs;

  // 1-on-1 Partner Synergy List (Populated dynamically from Supabase)
  final partners = <SynergyPartner>[].obs;

  // Ecosystem Points
  final wellnessPoints = 500.obs;

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
      subtitle: 'Build healthy hydration habits together with your 1-on-1 partner.',
      ctaText: 'Synergy Partner',
      icon: Icons.local_fire_department_rounded,
      gradientColors: [Color(0xFFFF6D00), Color(0xFFE64A19)],
      tagBgColor: Color(0xFFFFECE0),
      tagTextColor: Color(0xFFE65100),
      actionType: 'nudge_partner',
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

  // Live Feed Posts from Supabase
  final homeFeedPosts = <FeedItem>[].obs;
  final isLoadingFeed = false.obs;
  final savedPostIds = <String>{}.obs;

  // Likes state (tracked by post ID without text 'likes')
  final likedPostIds = <String>{}.obs;
  final postLikesCount = <String, int>{}.obs;

  bool isLiked(String id) => likedPostIds.contains(id);

  int getLikes(FeedItem item) => postLikesCount[item.id] ?? item.likesCount;

  Future<void> toggleLike(FeedItem item) async {
    final wasLiked = isLiked(item.id);
    final current = getLikes(item);
    final newLiked = !wasLiked;

    if (newLiked) {
      likedPostIds.add(item.id);
      postLikesCount[item.id] = current + 1;
    } else {
      likedPostIds.remove(item.id);
      postLikesCount[item.id] = (current - 1).clamp(0, 999999);
    }

    await _feedRepository.toggleLikePost(
      postId: item.id,
      isLiking: newLiked,
      currentLikes: current,
    );
  }

  bool isSaved(String id) => savedPostIds.contains(id);

  FeedRepository get _feedRepository =>
      Get.isRegistered<FeedRepository>() ? Get.find<FeedRepository>() : FeedRepositoryImpl();

  HydrationRepository get _hydrationRepository =>
      Get.isRegistered<HydrationRepository>() ? Get.find<HydrationRepository>() : HydrationRepositoryImpl();

  SynergyRepository get _synergyRepository =>
      Get.isRegistered<SynergyRepository>() ? Get.find<SynergyRepository>() : SynergyRepositoryImpl();

  UserRepository get _userRepository =>
      Get.isRegistered<UserRepository>() ? Get.find<UserRepository>() : UserRepositoryImpl();

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthService>()) {
      final auth = AuthService.to;
      if (auth.userName.value.isNotEmpty) {
        userName.value = auth.userName.value;
      }
      if (auth.avatarUrl.value.isNotEmpty) {
        avatarUrl.value = auth.avatarUrl.value;
      }
      ever(auth.userProfile, (profile) {
        if (profile != null) {
          userName.value = profile.displayName;
          avatarUrl.value = profile.avatarUrl;
          dailyGoalMl.value = profile.dailyWaterGoalMl;
          wellnessPoints.value = profile.wellnessPointsBalance;
        }
      });
      ever(auth.currentUser, (_) => _loadHomeData());
    }

    _loadHomeData();
    _loadHomeFeedPosts();
    _loadSavedPosts();
  }

  Future<void> refreshHomeFeed() async {
    isLoadingFeed.value = true;
    try {
      final posts = await _feedRepository.fetchFeedPosts();
      homeFeedPosts.assignAll(posts);
      await _loadSavedPosts();
    } catch (e) {
      debugPrint('⚠️ Error refreshing home feed: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> _loadHomeFeedPosts() async {
    isLoadingFeed.value = true;
    try {
      final posts = await _feedRepository.fetchFeedPosts();
      homeFeedPosts.assignAll(posts);
    } catch (e) {
      debugPrint('⚠️ Error loading home feed posts: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> _loadSavedPosts() async {
    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';
    if (userId.isNotEmpty) {
      try {
        final ids = await _feedRepository.getSavedPostIds(userId);
        savedPostIds.assignAll(ids);
      } catch (e) {
        debugPrint('⚠️ Error loading saved posts: $e');
      }
    }
  }

  Future<void> toggleSave(FeedItem item) async {
    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';
    final wasSaved = savedPostIds.contains(item.id);

    if (wasSaved) {
      savedPostIds.remove(item.id);
      if (Get.context != null) {
        Get.snackbar(
          'Post Removed',
          'Post removed from your saved bookmarks.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      savedPostIds.add(item.id);
      if (Get.context != null) {
        Get.snackbar(
          'Saved to Bookmarks! 🔖',
          'Post saved to your personal library.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }

    if (userId.isNotEmpty) {
      await _feedRepository.toggleSavePost(
        userId: userId,
        postId: item.id,
        title: item.title,
        category: item.category,
        authorName: item.authorName,
      );
    }
  }

  void sharePost(FeedItem item) {
    Clipboard.setData(ClipboardData(
      text: '${item.title}\n\n${item.caption}\n\nShared from Infinity Wellness App',
    ));
    if (Get.context != null) {
      Get.snackbar(
        'Link Copied! 🔗',
        'Post content and share link copied to clipboard.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  RealtimeChannel? _partnerChannel;

  void updateActivePartner(SynergyPartner newPartner) {
    partnerName.value = newPartner.name;
    synergyStreakDays.value = 1;
    partners.assignAll([newPartner]);
    _subscribeToPartnerUpdates(newPartner.id);
  }

  void clearPartner() {
    partners.clear();
    partnerName.value = '';
    synergyStreakDays.value = 0;
    _partnerChannel?.unsubscribe();
    _partnerChannel = null;
  }

  void _subscribeToPartnerUpdates(String partnerId) {
    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';
    if (userId.isEmpty || partnerId.isEmpty) return;

    _partnerChannel?.unsubscribe();
    _partnerChannel = _synergyRepository.subscribeToPartnerUpdates(
      currentUserId: userId,
      partnerId: partnerId,
      onPartnerWaterLogged: (intakeMl) {
        if (partners.isNotEmpty && partners.first.id == partnerId) {
          partners.first.intakeMl.value = intakeMl;
          partners.refresh();
        }
      },
      onNudgeReceived: (nudge) {
        notificationCount.value += 1;
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.to.showInstantNotification(
            title: '💧 Synergy Nudge from ${partnerName.value}!',
            body: nudge.message ?? '${partnerName.value} nudged you to hydrate!',
          );
        }
        Get.snackbar(
          'Partner Nudge! 💧',
          nudge.message ?? '${partnerName.value} nudged you to hydrate!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0284C7),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  Future<void> _loadHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      sipAmountMl.value = prefs.getInt('pref_user_sip_amount_ml') ?? 250;
      final cachedGoal = prefs.getInt('pref_user_daily_water_goal_ml');
      if (cachedGoal != null && cachedGoal > 0) {
        dailyGoalMl.value = cachedGoal;
      }
    } catch (_) {}

    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';

    try {
      if (userId.isNotEmpty) {
        final profile = await _userRepository.getUserProfile(userId);
        if (profile != null) {
          userName.value = profile.displayName;
          userFullName.value = profile.displayName;
          dailyGoalMl.value = profile.dailyWaterGoalMl;
          wellnessPoints.value = profile.wellnessPointsBalance;
          personalStreakDays.value = profile.currentStreak;
        }

        final dateIntake = await _hydrationRepository.getTotalMlForDate(userId, selectedDate.value);
        currentWaterMl.value = dateIntake;

        final activePair = await _synergyRepository.getActivePair(userId);
        if (activePair != null && activePair.partnerProfile != null) {
          final p = activePair.partnerProfile!;
          synergyStreakDays.value = activePair.streakCount;
          partnerName.value = p.displayName;

          final partnerIntake = await _synergyRepository.getPartnerTodayIntake(p.id);

          final realPartner = SynergyPartner(
            id: p.id,
            name: p.displayName,
            intakeMl: partnerIntake,
            goalMl: p.dailyWaterGoalMl > 0 ? p.dailyWaterGoalMl : 2600,
            themeKey: activePair.themeKey,
          );
          partners.assignAll([realPartner]);
          _subscribeToPartnerUpdates(p.id);
        } else {
          partners.clear();
          partnerName.value = '';
          synergyStreakDays.value = 0;
          _partnerChannel?.unsubscribe();
          _partnerChannel = null;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading home data from repositories: $e');
    }
  }

  Future<void> _loadDateHydration(DateTime date) async {
    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';
    if (userId.isEmpty) {
      currentWaterMl.value = 0;
      return;
    }

    try {
      final total = await _hydrationRepository.getTotalMlForDate(userId, date);
      currentWaterMl.value = total;
    } catch (e) {
      debugPrint('⚠️ Error loading date hydration: $e');
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
    _loadDateHydration(selectedDate.value);
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
      case 'nudge_partner':
        if (partners.isNotEmpty) {
          notifyPartner(partners.first);
        } else {
          Get.toNamed(Routes.partnerDetail);
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
    _partnerChannel?.unsubscribe();
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
    final prevWater = currentWaterMl.value;
    currentWaterMl.value += amountMl;

    // Calculate earned points: +10 pts (or +20 for >= 500ml), +100 bonus pts if goal is reached!
    final earnedPts = (amountMl >= 500) ? 20 : 10;
    final reachedGoal = (currentWaterMl.value >= dailyGoalMl.value) && (prevWater < dailyGoalMl.value);
    final totalAwarded = reachedGoal ? (earnedPts + 100) : earnedPts;

    wellnessPoints.value += totalAwarded;

    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';
    _hydrationRepository.logWaterIntake(
      userId: userId,
      amountMl: amountMl,
      beverageType: 'Pure Water',
    );

    if (userId.isNotEmpty) {
      _userRepository.addWellnessPoints(userId, totalAwarded);
      if (auth?.userProfile.value != null) {
        auth!.userProfile.value = auth.userProfile.value!.copyWith(
          wellnessPointsBalance: auth.userProfile.value!.wellnessPointsBalance + totalAwarded,
        );
      }
    }

    if (reachedGoal) {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.showInstantNotification(
          title: 'Daily Goal Reached! 🏆',
          body: 'Congratulations! You achieved your daily hydration target of ${dailyGoalMl.value} ml! +100 bonus points.',
        );
      }
    }

    if (Get.context != null) {
      if (reachedGoal) {
        Get.snackbar(
          'Daily Goal Reached! 🏆',
          '+$amountMl ml logged (+$earnedPts pts) + 100 Bonus Points! Total: ${wellnessPoints.value} pts',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0284C7),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 28),
        );
      } else {
        Get.snackbar(
          'Water Logged! 💧',
          '+$amountMl ml added! +$earnedPts Wellness Points (Total: ${wellnessPoints.value} pts)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.water_drop_rounded, color: Color(0xFF38BDF8), size: 24),
        );
      }
    }
  }

  void notifyPartner(SynergyPartner partner) {
    final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;
    final userId = auth?.currentUser.value?.id ?? '';

    if (userId.isNotEmpty) {
      _synergyRepository.sendNudge(
        senderId: userId,
        receiverId: partner.id,
        nudgeType: SynergyNudgeType.hydrate,
        message: 'Hydration reminder from your partner 💧',
      );
    }

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
