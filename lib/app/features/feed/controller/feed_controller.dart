import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

enum FeedItemType { medicalNews, mythVsFact, announcement }

class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.fullContent,
    required this.type,
    required this.category,
    required this.authorRole,
    required this.readTimeMinutes,
    required this.bannerGradient,
    required this.bannerIcon,
    required this.bannerTag,
    required this.publishedTime,
    this.imageAsset,
    this.keyTakeaways = const [],
    this.mythText,
    this.factText,
    this.helpfulCount = 0,
  });

  final String id;
  final String title;
  final String summary;
  final String fullContent;
  final FeedItemType type;
  final String category;
  final String authorRole;
  final int readTimeMinutes;
  final List<Color> bannerGradient;
  final IconData bannerIcon;
  final String bannerTag;
  final String publishedTime;
  final String? imageAsset;
  final List<String> keyTakeaways;
  final String? mythText;
  final String? factText;
  final int helpfulCount;
}

enum SocialTab { challenges, feed, leaderboard }

class LeaderboardUser {
  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.avatarEmoji,
    required this.points,
    required this.streakDays,
    required this.hydrationPercent,
    this.isCurrentUser = false,
    this.badgeTitle,
  });

  final int rank;
  final String name;
  final String avatarEmoji;
  final int points;
  final int streakDays;
  final int hydrationPercent;
  final bool isCurrentUser;
  final String? badgeTitle;
}

class CommunityChallenge {
  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.participantsCount,
    required this.rewardPoints,
    required this.daysLeft,
    required this.isJoined,
    required this.progress,
    required this.bannerGradient,
    required this.bannerIcon,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int participantsCount;
  final int rewardPoints;
  final int daysLeft;
  final bool isJoined;
  final double progress;
  final List<Color> bannerGradient;
  final IconData bannerIcon;
}

class FeedController extends BaseController {
  final activeTab = SocialTab.challenges.obs;
  final selectedCategory = 'All'.obs;
  final categories = const ['All', 'Medical News', 'Myth vs. Fact', 'Ecosystem'];

  // Leaderboard filters & data
  final leaderboardFilter = 'Weekly'.obs;
  final leaderboardFilters = const ['Weekly', 'Monthly', 'All-Time'];

  void selectLeaderboardFilter(String filter) {
    leaderboardFilter.value = filter;
  }

  final leaderboardUsers = const <LeaderboardUser>[
    LeaderboardUser(
      rank: 1,
      name: 'Dr. Maya Lin',
      avatarEmoji: '👩‍⚕️',
      points: 2850,
      streakDays: 45,
      hydrationPercent: 98,
      badgeTitle: 'Hydration Deity',
    ),
    LeaderboardUser(
      rank: 2,
      name: 'Alex & Elena',
      avatarEmoji: '⚡',
      points: 2420,
      streakDays: 38,
      hydrationPercent: 95,
      badgeTitle: 'Synergy Master',
    ),
    LeaderboardUser(
      rank: 3,
      name: 'Kai Rivera',
      avatarEmoji: '🏄‍♂️',
      points: 2190,
      streakDays: 31,
      hydrationPercent: 92,
      badgeTitle: 'Streak Champion',
    ),
    LeaderboardUser(
      rank: 4,
      name: 'You (Alex)',
      avatarEmoji: '🚀',
      points: 1840,
      streakDays: 24,
      hydrationPercent: 90,
      isCurrentUser: true,
      badgeTitle: 'Flame Keeper',
    ),
    LeaderboardUser(
      rank: 5,
      name: 'Sarah Chen',
      avatarEmoji: '🌸',
      points: 1720,
      streakDays: 21,
      hydrationPercent: 88,
      badgeTitle: 'Vitality Pro',
    ),
    LeaderboardUser(
      rank: 6,
      name: 'Marcus Brody',
      avatarEmoji: '🦁',
      points: 1560,
      streakDays: 19,
      hydrationPercent: 85,
      badgeTitle: 'Hydro Pioneer',
    ),
    LeaderboardUser(
      rank: 7,
      name: 'Chloe & Sam',
      avatarEmoji: '💖',
      points: 1410,
      streakDays: 16,
      hydrationPercent: 84,
      badgeTitle: 'Synergy Duo',
    ),
  ];

  // Expand / Collapse state for news cards
  final expandedItemIds = <String>{}.obs;

  // Helpful interactions
  final helpfulVotes = <String, int>{}.obs;
  final userVotedHelpful = <String, bool>{}.obs;
  final bookmarkedItemIds = <String>{}.obs;

  final challenges = <CommunityChallenge>[
    const CommunityChallenge(
      id: 'ch-1',
      title: '7-Day Smart Hydration Sprint',
      category: 'Vitality',
      description: 'Hit your personalized daily water goal for 7 consecutive days.',
      participantsCount: 342,
      rewardPoints: 150,
      daysLeft: 3,
      isJoined: true,
      progress: 0.71,
      bannerGradient: [Color(0xFF0099FF), Color(0xFF0055D4)],
      bannerIcon: Icons.water_drop_rounded,
    ),
    const CommunityChallenge(
      id: 'ch-2',
      title: '1-on-1 Synergy Streak Master',
      category: 'Mutual Accountability',
      description: 'Send daily nudges and complete mutual wellness targets with your partner.',
      participantsCount: 188,
      rewardPoints: 300,
      daysLeft: 12,
      isJoined: true,
      progress: 0.85,
      bannerGradient: [Color(0xFFFF6D00), Color(0xFFE64A19)],
      bannerIcon: Icons.local_fire_department_rounded,
    ),
    const CommunityChallenge(
      id: 'ch-3',
      title: 'Digital Screen-Break Habit',
      category: 'Mental Wellness',
      description: 'Take verified 5-minute hydration & stretch pauses every 90 minutes.',
      participantsCount: 520,
      rewardPoints: 100,
      daysLeft: 5,
      isJoined: false,
      progress: 0.0,
      bannerGradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      bannerIcon: Icons.self_improvement_rounded,
    ),
  ].obs;

  final feedItems = const <FeedItem>[
    FeedItem(
      id: 'feed-1',
      title: 'Can Drinking 3L of Water Cure Acne? The Clinical Reality',
      summary:
          'Dermatological studies show that while optimal hydration maintains skin elasticity and barrier function, it does not replace targeted acne care.',
      fullContent:
          'The belief that drinking excessive amounts of water will flush toxins and cure acne vulgaris is widespread on social media. While adequate hydration is vital for maintaining skin barrier integrity, sebum balance, and cellular turnover, clinical dermatological evidence clarifies that acne is primarily caused by follicular hyperkeratinization, excess sebum production mediated by androgens, and Cutibacterium acnes colonization.\n\nDrinking beyond your physiologic hydration baseline (approx. 2.5L to 3.0L for active adults) does not accelerate pore decongestion. Instead, a holistic regimen combining gentle non-comedogenic skincare, balanced nutrition, and consistent hydration yields the best clinical outcomes.',
      type: FeedItemType.mythVsFact,
      category: 'Dermatology & Hydration',
      authorRole: 'Verified by Dr. Maya Lin & Med Student Cohort',
      readTimeMinutes: 3,
      bannerGradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      bannerIcon: Icons.water_drop_rounded,
      bannerTag: 'MYTH BUSTER',
      publishedTime: '2 hours ago',
      imageAsset: AppImages.news2,
      keyTakeaways: [
        'Hydration improves skin barrier resilience but is not a standalone cure for acne.',
        'Over-hydration does not "wash away" subcutaneous follicular bacteria.',
        'Combine steady hydration (2.5L/day) with evidence-based topical treatments.',
      ],
      mythText: 'Drinking extreme amounts of water completely eliminates acne.',
      factText:
          'Hydration supports skin cell turnover and kidney filtration, but acne pathogenesis involves sebum, hormones, and follicular bacteria.',
      helpfulCount: 84,
    ),
    FeedItem(
      id: 'feed-2',
      title: 'Optimal Electrolyte Balance During High-Intensity Training',
      summary:
          'Understanding sodium, potassium, and magnesium loss during intense cardio and the science of rapid cellular replenishment.',
      fullContent:
          'When engaging in vigorous training lasting over 60 minutes or in warm environments, sweat output leads to significant loss of essential electrolytes—predominantly sodium, chloride, and potassium. Ingesting plain water in extreme volumes without electrolytes can paradoxically lead to exercise-associated hyponatremia (dilutional low blood sodium).\n\nFor optimal recovery and muscle contraction velocity, integrate hypotonic electrolyte formulas containing 300–500mg sodium per 500ml of fluid during workouts exceeding 45 minutes.',
      type: FeedItemType.medicalNews,
      category: 'Sports & Physiology',
      authorRole: 'Curated by Sports Medicine Resident',
      readTimeMinutes: 4,
      bannerGradient: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      bannerIcon: Icons.bolt_rounded,
      bannerTag: 'CLINICAL PHYSIOLOGY',
      publishedTime: '5 hours ago',
      imageAsset: AppImages.news1,
      keyTakeaways: [
        'Sweating depletes sodium fastest, which impairs neuromuscular signaling if unreplaced.',
        'Plain water is great for <45 min workouts; add electrolytes for high-intensity sessions.',
        'Magnesium and potassium co-factors prevent exercise-associated cramps.',
      ],
      helpfulCount: 112,
    ),
    FeedItem(
      id: 'feed-3',
      title: 'Circadian Biology: Debunking Blue Light & Sleep Architecture Myths',
      summary:
          'How evening screen exposure impacts melatonin suppression and evidence-based digital hygiene protocols for restorative deep sleep.',
      fullContent:
          'Specialized intrinsically photosensitive retinal ganglion cells (ipRGCs) are highly sensitive to blue-wavelength light (460–480 nm). Exposure to bright digital screens within 90 minutes of bedtime delays nocturnal melatonin release by up to 45%, shifting circadian phase and fragmenting REM cycles.\n\nWhile blue-light filtering glasses reduce retinal strain, dimming ambient room light and establishing a digital sunset 60 minutes before bedtime remain the most effective interventions for deep sleep recovery.',
      type: FeedItemType.medicalNews,
      category: 'Mental Health & Sleep',
      authorRole: 'Verified by Neuroscience Fellow',
      readTimeMinutes: 5,
      bannerGradient: [Color(0xFF134E5E), Color(0xFF71B280)],
      bannerIcon: Icons.bedtime_rounded,
      bannerTag: 'NEUROSCIENCE',
      publishedTime: '1 day ago',
      imageAsset: AppImages.news3,
      keyTakeaways: [
        'Blue wavelengths suppress pineal melatonin secretion more than other light spectrums.',
        'Blue-light glasses reduce fatigue but do not replace lowering total room lux.',
        'Establish a 45-60 min screen-free wind-down routine with hydration.',
      ],
      helpfulCount: 96,
    ),
    FeedItem(
      id: 'feed-4',
      title: 'Infinity Wellness Ecosystem Launch: Phase 1 Mini-Apps',
      summary:
          'Discover our 3 dedicated digital health modules: Medical News, Smart Hydration, and 1-on-1 Friend Synergy.',
      fullContent:
          'We are thrilled to roll out the official Phase 1 release of the Infinity Wellness Super App! Our mission is to bridge scientific health literacy with proactive, daily mutual accountability.\n\nExplore our core modules:\n• Medical News: Peer-reviewed health breakdowns & myth busting.\n• Smart Hydration: Personalized water intake algorithms calibrated to your biometric metrics.\n• Friend Synergy: Pure 1-on-1 mutual accountability with real-time nudges and shared synergy streaks.',
      type: FeedItemType.announcement,
      category: 'Ecosystem News',
      authorRole: 'Infinity Water Health Team',
      readTimeMinutes: 2,
      bannerGradient: [Color(0xFFFF8008), Color(0xFFFFC837)],
      bannerIcon: Icons.stars_rounded,
      bannerTag: 'OFFICIAL RELEASE',
      publishedTime: '2 days ago',
      imageAsset: AppImages.news4,
      keyTakeaways: [
        'All 3 mini-apps are fully integrated into your native Super App shell.',
        'Earn Wellness Points daily by hitting hydration targets and completing synergy goals.',
        'More clinical modules coming in Phase 2.',
      ],
      helpfulCount: 230,
    ),
    FeedItem(
      id: 'feed-5',
      title: 'The 2% Dehydration Paradox: How Subtle Water Deficits Impair Focus',
      summary:
          'Cognitive performance drops by up to 15% when total body water decreases by just 2%, mimicking mild sleep deprivation.',
      fullContent:
          'Neurocognitive trials demonstrate that even mild dehydration (1.5% to 2% loss of body mass via water) significantly decreases working memory, visual-spatial processing speed, and sustained attention span.\n\nBecause the brain is 75% water, mild cellular hypohydration alters neuronal volume and neurotransmitter synthesis. Keeping a calibrated water bottle nearby and drinking at regular intervals prevents the mid-afternoon cognitive slump.',
      type: FeedItemType.medicalNews,
      category: 'Cognitive Health',
      authorRole: 'Verified by Clinical Neurology Resident',
      readTimeMinutes: 3,
      bannerGradient: [Color(0xFF0072FF), Color(0xFF00C6FF)],
      bannerIcon: Icons.psychology_rounded,
      bannerTag: 'BRAIN & FOCUS',
      publishedTime: '3 days ago',
      keyTakeaways: [
        'Thirst sensation only activates after 1-2% dehydration has already occurred.',
        'Regular micro-sips maintain steady cerebral blood flow and focus.',
        'Pair water logging with work breaks for compound productivity gains.',
      ],
      helpfulCount: 145,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize helpful counts
    for (final item in feedItems) {
      helpfulVotes[item.id] = item.helpfulCount;
      userVotedHelpful[item.id] = false;
    }
  }

  List<FeedItem> get filteredItems {
    if (selectedCategory.value == 'All') {
      return feedItems;
    }
    if (selectedCategory.value == 'Medical News') {
      return feedItems.where((i) => i.type == FeedItemType.medicalNews).toList();
    }
    if (selectedCategory.value == 'Myth vs. Fact') {
      return feedItems.where((i) => i.type == FeedItemType.mythVsFact).toList();
    }
    if (selectedCategory.value == 'Ecosystem') {
      return feedItems.where((i) => i.type == FeedItemType.announcement).toList();
    }
    return feedItems;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void selectTab(SocialTab tab) {
    activeTab.value = tab;
  }

  bool isExpanded(String id) => expandedItemIds.contains(id);

  void toggleExpand(String id) {
    if (expandedItemIds.contains(id)) {
      expandedItemIds.remove(id);
    } else {
      expandedItemIds.add(id);
    }
  }

  void toggleBookmark(String id) {
    if (bookmarkedItemIds.contains(id)) {
      bookmarkedItemIds.remove(id);
      if (Get.context != null) {
        Get.snackbar(
          'Bookmark Removed',
          'Article removed from your saved insights.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      bookmarkedItemIds.add(id);
      if (Get.context != null) {
        Get.snackbar(
          'Article Saved! 🔖',
          'Article saved to your wellness library.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void toggleHelpful(String id) {
    final hasVoted = userVotedHelpful[id] ?? false;
    final currentCount = helpfulVotes[id] ?? 0;

    if (!hasVoted) {
      userVotedHelpful[id] = true;
      helpfulVotes[id] = currentCount + 1;
      if (Get.context != null) {
        Get.snackbar(
          'Thank you! 🙌',
          'Your vote helps us surface high-quality medical literacy insights.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      userVotedHelpful[id] = false;
      helpfulVotes[id] = currentCount > 0 ? currentCount - 1 : 0;
    }
  }

  int getHelpfulCount(String id) {
    return helpfulVotes[id] ?? 0;
  }

  bool isHelpfulVoted(String id) {
    return userVotedHelpful[id] ?? false;
  }

  bool isBookmarked(String id) {
    return bookmarkedItemIds.contains(id);
  }

  void joinChallenge(CommunityChallenge challenge) {
    if (Get.context != null) {
      Get.snackbar(
        'Challenge Joined! 🏆',
        'You are now enrolled in "${challenge.title}". Win +${challenge.rewardPoints} pts upon completion!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
