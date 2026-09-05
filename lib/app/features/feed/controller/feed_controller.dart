import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/repositories/feed_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';

enum FeedItemType { medicalNews, mythVsFact, announcement, promo }

class FeedItem {
  const FeedItem({
    required this.id,
    required this.authorName,
    this.authorAvatarText = 'IW',
    this.badgeText = 'Promoted By',
    required this.title,
    required this.caption,
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
    this.timeAgo = '21 min(s) ago',
    this.imageAsset,
    this.imageUrl,
    this.priceTag,
    this.badgeOverlayText,
    this.externalUrl,
    this.keyTakeaways = const [],
    this.mythText,
    this.factText,
    this.likesCount = 24,
    this.sharesCount = 12,
  });

  final String id;
  final String authorName;
  final String authorAvatarText;
  final String badgeText;
  final String title;
  final String caption;
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
  final String timeAgo;
  final String? imageAsset;
  final String? imageUrl;
  final String? priceTag;
  final String? badgeOverlayText;
  final String? externalUrl;
  final List<String> keyTakeaways;
  final String? mythText;
  final String? factText;
  final int likesCount;
  final int sharesCount;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    FeedItemType parseType(String? val) {
      switch (val) {
        case 'medicalNews':
          return FeedItemType.medicalNews;
        case 'mythVsFact':
          return FeedItemType.mythVsFact;
        case 'promo':
          return FeedItemType.promo;
        default:
          return FeedItemType.announcement;
      }
    }

    String formatTimeAgo(dynamic timestamp) {
      if (timestamp == null) return 'Just now';
      try {
        final dt = DateTime.parse(timestamp.toString()).toLocal();
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes} min(s) ago';
        if (diff.inHours < 24) return '${diff.inHours} hour(s) ago';
        if (diff.inDays < 7) return '${diff.inDays} day(s) ago';
        return '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        return 'Recently';
      }
    }

    return FeedItem(
      id: json['id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Infinity Wellness',
      authorAvatarText: json['author_avatar_text']?.toString() ??
          (json['author_name'] != null && json['author_name'].toString().isNotEmpty
              ? json['author_name'].toString().substring(0, 1).toUpperCase()
              : 'IW'),
      badgeText: json['badge_text']?.toString() ?? 'Promoted By',
      title: json['title']?.toString() ?? '',
      caption: json['caption']?.toString() ?? (json['summary']?.toString() ?? ''),
      summary: json['summary']?.toString() ?? '',
      fullContent: json['full_content']?.toString() ?? '',
      type: parseType(json['post_type']?.toString()),
      category: json['category']?.toString() ?? 'General',
      authorRole: json['author_role']?.toString() ?? 'Verified Publisher',
      readTimeMinutes: (json['read_time_minutes'] as num?)?.toInt() ?? 3,
      bannerGradient: const [Color(0xFF0099FF), Color(0xFF0055D4)],
      bannerIcon: Icons.article_rounded,
      bannerTag: json['badge_text']?.toString() ?? 'NEWS',
      publishedTime: formatTimeAgo(json['published_at'] ?? json['created_at']),
      timeAgo: formatTimeAgo(json['published_at'] ?? json['created_at']),
      imageUrl: json['image_url']?.toString(),
      priceTag: json['price_tag']?.toString(),
      badgeOverlayText: json['badge_overlay_text']?.toString(),
      externalUrl: json['external_url']?.toString(),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
    );
  }
}

enum SocialTab { challenges, feed, leaderboard }

class LeaderboardUser {
  const LeaderboardUser({
    required this.rank,
    required this.name,
    this.initials = 'IW',
    required this.points,
    required this.streakDays,
    required this.hydrationPercent,
    this.isCurrentUser = false,
    this.badgeTitle,
    this.icon = Icons.workspace_premium_rounded,
    this.iconColor = const Color(0xFF0284C7),
    this.avatarGradient = const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
  });

  final int rank;
  final String name;
  final String initials;
  final int points;
  final int streakDays;
  final int hydrationPercent;
  final bool isCurrentUser;
  final String? badgeTitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> avatarGradient;
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
  FeedController({
    FeedRepository? feedRepository,
    UserRepository? userRepository,
  })  : _feedRepository = feedRepository ?? (Get.isRegistered<FeedRepository>() ? Get.find<FeedRepository>() : FeedRepositoryImpl()),
        _userRepository = userRepository ?? (Get.isRegistered<UserRepository>() ? Get.find<UserRepository>() : UserRepositoryImpl());

  final FeedRepository _feedRepository;
  final UserRepository _userRepository;
  AuthService? get _authService => Get.isRegistered<AuthService>() ? AuthService.to : null;

  final activeTab = SocialTab.feed.obs;
  final selectedCategory = 'All'.obs;
  final categories = const ['All', 'Saved', 'Medical News', 'Myth vs. Fact', 'Promotions'];

  // Leaderboard filters & data
  final leaderboardFilter = 'Weekly'.obs;
  final leaderboardFilters = const ['Weekly', 'Monthly', 'All-Time'];

  void selectLeaderboardFilter(String filter) {
    leaderboardFilter.value = filter;
  }

  // Saved state
  final savedPostIds = <String>{}.obs;

  // Live Supabase Leaderboard Users
  final liveLeaderboardUsers = <LeaderboardUser>[
    const LeaderboardUser(
      rank: 1,
      name: 'Dr. Maya Lin',
      initials: 'ML',
      points: 2850,
      streakDays: 45,
      hydrationPercent: 98,
      badgeTitle: 'Hydration Deity',
      icon: Icons.workspace_premium_rounded,
      iconColor: Color(0xFFF59E0B),
      avatarGradient: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    ),
    const LeaderboardUser(
      rank: 2,
      name: 'Alex & Elena',
      initials: 'AE',
      points: 2420,
      streakDays: 38,
      hydrationPercent: 95,
      badgeTitle: 'Synergy Master',
      icon: Icons.military_tech_rounded,
      iconColor: Color(0xFF94A3B8),
      avatarGradient: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
    ),
    const LeaderboardUser(
      rank: 3,
      name: 'Kai Rivera',
      initials: 'KR',
      points: 2190,
      streakDays: 31,
      hydrationPercent: 92,
      badgeTitle: 'Streak Champion',
      icon: Icons.shield_rounded,
      iconColor: Color(0xFFD97706),
      avatarGradient: [Color(0xFFFFF1EE), Color(0xFFFFEDD5)],
    ),
    const LeaderboardUser(
      rank: 4,
      name: 'You (Infinity User)',
      initials: 'YOU',
      points: 1840,
      streakDays: 24,
      hydrationPercent: 90,
      isCurrentUser: true,
      badgeTitle: 'Flame Keeper',
      icon: Icons.star_rounded,
      iconColor: Color(0xFF0284C7),
      avatarGradient: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    ),
    const LeaderboardUser(
      rank: 5,
      name: 'Sarah Chen',
      initials: 'SC',
      points: 1720,
      streakDays: 21,
      hydrationPercent: 88,
      badgeTitle: 'Vitality Pro',
      icon: Icons.diamond_outlined,
      iconColor: Color(0xFF0284C7),
      avatarGradient: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    ),
  ].obs;

  List<LeaderboardUser> get leaderboardUsers => liveLeaderboardUsers;

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
  ].obs;

  static const defaultFeedItems = <FeedItem>[
    FeedItem(
      id: 'feed-1',
      authorName: 'M Travel',
      authorAvatarText: 'MT',
      badgeText: 'Promoted By',
      title: 'Beijing-Guangzhou Wellness Travel Expedition',
      caption: '✨ မဟာဗုဒ္ဓ၏ မြင့်မြတ်လှသော စွယ်တော်မြတ်ကို ဖူးမြော်ကြည်ညိုရင် တရုတ်ပြည်ရဲ့ သမိုင်းဝင် အထင်ကရ နေရာများသို့ လေ့လာရေးခရီးစဉ်...',
      summary: 'Explore China historical heritage and wellness mineral hot spring destinations.',
      fullContent: 'Experience transformative wellness travel with guided hydration schedules and mineral spring immersion across historical cultural heritage sites.',
      type: FeedItemType.promo,
      category: 'Promotions',
      authorRole: 'Verified Travel Partner',
      readTimeMinutes: 2,
      bannerGradient: [Color(0xFFE65100), Color(0xFFF57C00)],
      bannerIcon: Icons.flight_takeoff_rounded,
      bannerTag: 'SPECIAL TOUR',
      publishedTime: '21 min(s) ago',
      timeAgo: '21 min(s) ago',
      priceTag: '\$1350',
      badgeOverlayText: 'BEIJING-GUANGZHOU',
      imageAsset: AppImages.news1,
      likesCount: 56,
      sharesCount: 18,
    ),
    FeedItem(
      id: 'feed-2',
      authorName: 'JJ EXPRESS',
      authorAvatarText: 'JJ',
      badgeText: 'Promoted By',
      title: 'Luxury Highway VIP Travel & Mineral Refreshment',
      caption: 'နောက်ထပ် ပြေးဆွဲမည့် ခရီးစဉ်အသစ်က ဘာဖြစ်မလဲ? VIP Coach များတွင် Infinity Pure Water အခမဲ့ ဖြန့်ဝေပေးသွားပါမည်။',
      summary: 'VIP premium express travel with built-in hydration packs across all major routes.',
      fullContent: 'Enjoy comfortable air-conditioned journeys with onboard hydration monitors and pure water bottles provided on every seat.',
      type: FeedItemType.promo,
      category: 'Promotions',
      authorRole: 'Official Transport Partner',
      readTimeMinutes: 2,
      bannerGradient: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
      bannerIcon: Icons.directions_bus_rounded,
      bannerTag: 'VIP EXPRESS',
      publishedTime: '24 min(s) ago',
      timeAgo: '24 min(s) ago',
      badgeOverlayText: 'WWW.JJEXPRESS.NET',
      imageAsset: AppImages.news2,
      likesCount: 89,
      sharesCount: 34,
    ),
    FeedItem(
      id: 'feed-3',
      authorName: 'Infinity Health Desk',
      authorAvatarText: 'IH',
      badgeText: 'Curated Evidence',
      title: 'Can Drinking 3L of Water Cure Acne? The Clinical Reality',
      caption: '💧 ရေများများသောက်ခြင်းက ဝက်ခြံကို တကယ်ပျောက်စေသလား? ဆေးပညာရှင်များ၏ ဓမ္မဓိဋ္ဌာန်ကျသော သုတေသနရှင်းလင်းချက်။',
      summary: 'Dermatological studies show that optimal hydration maintains skin elasticity but is not a standalone acne cure.',
      fullContent: 'Clinical dermatological evidence clarifies that acne is mediated by sebum and bacteria. Hydration supports skin barrier function and toxin elimination.',
      type: FeedItemType.mythVsFact,
      category: 'Myth vs. Fact',
      authorRole: 'Verified by Dr. Maya Lin & Med Student Cohort',
      readTimeMinutes: 3,
      bannerGradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      bannerIcon: Icons.water_drop_rounded,
      bannerTag: 'MYTH BUSTER',
      publishedTime: '1 hour ago',
      timeAgo: '1 hour ago',
      badgeOverlayText: 'EVIDENCE-BASED LITERACY',
      imageAsset: AppImages.news3,
      likesCount: 142,
      sharesCount: 45,
    ),
    FeedItem(
      id: 'feed-4',
      authorName: 'Dr. Sarah Lin (MD)',
      authorAvatarText: 'SL',
      badgeText: 'Verified MD',
      title: 'Optimal Cellular Hydration: Electrolytes vs Plain Water',
      caption: '⚡ အားကစားပြုလုပ်ချိန် သို့မဟုတ် ရာသီဥတုပူပြင်းချိန်တွင် ဆဲလ်အတွင်း ရေဓာတ်ပြည့်ဝစေရန် Electrolyte များ၏ အရေးပါပုံ။',
      summary: 'Sweating depletes sodium and potassium. Discover when to integrate electrolyte formulas during intense physical workouts.',
      fullContent: 'For workouts exceeding 45 minutes, hypotonic electrolyte solutions replenish cellular sodium faster than plain water, preventing cramps and muscle fatigue.',
      type: FeedItemType.medicalNews,
      category: 'Medical News',
      authorRole: 'Sports Medicine Resident',
      readTimeMinutes: 4,
      bannerGradient: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      bannerIcon: Icons.bolt_rounded,
      bannerTag: 'SPORTS SCIENCE',
      publishedTime: '3 hours ago',
      timeAgo: '3 hours ago',
      badgeOverlayText: 'CELLULAR HYDRATION',
      imageAsset: AppImages.news4,
      likesCount: 215,
      sharesCount: 67,
    ),
  ];

  late final RxList<FeedItem> liveFeedItems = <FeedItem>[...defaultFeedItems].obs;
  List<FeedItem> get feedItems => liveFeedItems;
  final isLoadingFeed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLiveFeedPosts();
    _loadUserFeedInteractions();
    _loadLeaderboard();
  }

  Future<void> refreshFeed() async {
    isLoadingFeed.value = true;
    try {
      final livePosts = await _feedRepository.fetchFeedPosts();
      if (livePosts.isNotEmpty) {
        liveFeedItems.assignAll(livePosts);
      }
      await _loadUserFeedInteractions();
      await _loadLeaderboard();
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> _loadLiveFeedPosts() async {
    isLoadingFeed.value = true;
    try {
      final livePosts = await _feedRepository.fetchFeedPosts();
      if (livePosts.isNotEmpty) {
        liveFeedItems.assignAll(livePosts);
      }
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> _loadUserFeedInteractions() async {
    final userId = _authService?.currentUser.value?.id ?? '';
    if (userId.isNotEmpty) {
      final savedIds = await _feedRepository.getSavedPostIds(userId);
      savedPostIds.assignAll(savedIds);
    }
  }

  Future<void> _loadLeaderboard() async {
    final userId = _authService?.currentUser.value?.id ?? '';
    try {
      final users = await _userRepository.getLeaderboardUsers(currentUserId: userId);
      if (users.isNotEmpty) {
        liveLeaderboardUsers.assignAll(users);
      }
    } catch (e) {
      debugPrint('⚠️ Error loading leaderboard in FeedController: $e');
    }
  }

  Future<void> refreshLeaderboard() => _loadLeaderboard();

  List<FeedItem> get filteredItems {
    if (selectedCategory.value == 'All') {
      return feedItems;
    }
    if (selectedCategory.value == 'Saved') {
      return feedItems.where((i) => savedPostIds.contains(i.id)).toList();
    }
    if (selectedCategory.value == 'Medical News') {
      return feedItems.where((i) => i.type == FeedItemType.medicalNews).toList();
    }
    if (selectedCategory.value == 'Myth vs. Fact') {
      return feedItems.where((i) => i.type == FeedItemType.mythVsFact).toList();
    }
    if (selectedCategory.value == 'Promotions') {
      return feedItems.where((i) => i.type == FeedItemType.promo).toList();
    }
    return feedItems;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void selectTab(SocialTab tab) {
    activeTab.value = tab;
    if (tab == SocialTab.leaderboard) {
      _loadLeaderboard();
    }
  }

  bool isSaved(String id) => savedPostIds.contains(id);

  Future<void> toggleSave(FeedItem item) async {
    final userId = _authService?.currentUser.value?.id ?? '';
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

  // Expand / collapse state
  final expandedItemIds = <String>{}.obs;
  bool isExpanded(String id) => expandedItemIds.contains(id);
  void toggleExpand(String id) {
    if (expandedItemIds.contains(id)) {
      expandedItemIds.remove(id);
    } else {
      expandedItemIds.add(id);
    }
  }

  // Bookmarks / Save aliases
  bool isBookmarked(String id) => isSaved(id);
  void toggleBookmark(String id) {
    final item = feedItems.firstWhereOrNull((i) => i.id == id);
    if (item != null) {
      toggleSave(item);
    } else {
      if (savedPostIds.contains(id)) {
        savedPostIds.remove(id);
      } else {
        savedPostIds.add(id);
      }
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
