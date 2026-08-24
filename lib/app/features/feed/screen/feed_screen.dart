import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';

class FeedScreen extends BaseView<FeedController> {
  const FeedScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.ambientGradientColors,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
        children: [
          // 1. Top Header: Title, Icon & Subtitle
          _buildTopHeader(context),
          const SizedBox(height: 16),

          // 2. Segmented Toggle: Challenges vs Wellness Feed vs Leaderboard
          _buildSegmentedTabToggle(),
          const SizedBox(height: 16),

          // 3. Content based on active tab
          Obx(() {
            switch (controller.activeTab.value) {
              case SocialTab.challenges:
                return _buildChallengesList(context);
              case SocialTab.feed:
                return _buildFeedList(context);
              case SocialTab.leaderboard:
                return _buildLeaderboardView(context);
            }
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header: Title, Icon & Subtitle
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.mintSoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.groups_rounded,
                    size: 28,
                    color: AppColors.primaryVibrant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Social & Feed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Community challenges, verified insights & leaderboard',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSubtitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Segmented Tab Toggle (Challenges -> Feed -> Leaderboard)
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedTabToggle() {
    return Obx(() {
      final active = controller.activeTab.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cyanToggleBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 1. Challenges Tab (First)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(SocialTab.challenges),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == SocialTab.challenges
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active == SocialTab.challenges
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Challenges',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active == SocialTab.challenges
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: active == SocialTab.challenges
                            ? AppColors.textDark
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Feed Tab (Second)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(SocialTab.feed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == SocialTab.feed
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active == SocialTab.feed
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Feed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active == SocialTab.feed
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: active == SocialTab.feed
                            ? AppColors.textDark
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Leaderboard Tab (Third)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(SocialTab.leaderboard),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == SocialTab.leaderboard
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active == SocialTab.leaderboard
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active == SocialTab.leaderboard
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: active == SocialTab.leaderboard
                                ? AppColors.textDark
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Feed List: Categories + Feed Cards
  // ---------------------------------------------------------------------------
  Widget _buildFeedList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryFilters(),
        const SizedBox(height: 16),
        Obx(() {
          final items = controller.filteredItems;
          return Column(
            children:
                items.map((item) => _buildFeedItemCard(context, item)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(
        () => Row(
          children: controller.categories.map((category) {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cyanActiveChip
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 1.4)
                        : Border.all(color: AppColors.iceBlueBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.textDark
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeedItemCard(BuildContext context, FeedItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: item.imageAsset != null
                ? Image.asset(
                    item.imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackNewsGraphic(item),
                  )
                : _buildFallbackNewsGraphic(item),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackNewsGraphic(FeedItem item) {
    return Stack(
      children: [
        // 1. Ambient Background Glowing Circles
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.bannerGradient,
            ),
          ),
        ),
        Positioned(
          left: -25,
          top: -25,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          right: -5,
          bottom: -5,
          child: Icon(
            item.bannerIcon,
            size: 130,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),

        // 2. Smooth Dark Scrim
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.30, 0.65, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.04),
                  Colors.black.withValues(alpha: 0.22),
                  Colors.black.withValues(alpha: 0.68),
                  Colors.black.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
        ),

        // 3. Title
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Text(
            item.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.28,
              letterSpacing: -0.25,
              shadows: [
                Shadow(
                  color: Color(0xDD000000),
                  offset: Offset(0, 1.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Challenges List
  // ---------------------------------------------------------------------------
  Widget _buildChallengesList(BuildContext context) {
    return Obx(() {
      return Column(
        children: controller.challenges.map((challenge) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: challenge.bannerGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: challenge.bannerGradient.first
                          .withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // 1. Ambient Background Glowing Circles
                      Positioned(
                        left: -25,
                        top: -25,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -15,
                        top: 15,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),

                      // 2. Large Thematic Watermark Graphic
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          challenge.bannerIcon,
                          size: 135,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),

                      // 3. Smooth Dark Scrim for High-Contrast Visible Text
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.30, 0.70, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.20),
                                Colors.black.withValues(alpha: 0.65),
                                Colors.black.withValues(alpha: 0.90),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 4. Foreground Content
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Row: Category pill & Points Reward
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    challenge.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.60),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.streakOrange,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '+${challenge.rewardPoints} pts',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Bottom Row: Title, Progress / Action
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  challenge.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.25,
                                    letterSpacing: -0.2,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xDD000000),
                                        offset: Offset(0, 1.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Progress or Join Button
                                if (challenge.isJoined) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: challenge.progress,
                                            minHeight: 6,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.25),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(
                                              AppColors.cyanActiveChip,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${(challenge.progress * 100).toInt()}% • ${challenge.daysLeft}d left',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  InkWell(
                                    onTap: () =>
                                        controller.joinChallenge(challenge),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.94),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Join Challenge',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDarkBlue,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 13,
                                            color: AppColors.primaryDarkBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Leaderboard View: Top 3 Podiums + Filter + Ranked List
  // ---------------------------------------------------------------------------
  Widget _buildLeaderboardView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Timeframe Filter Chips
        _buildLeaderboardFilters(),
        const SizedBox(height: 16),

        // 2. Top 3 Podium
        _buildPodiumView(),
        const SizedBox(height: 20),

        // 3. Ranked List
        _buildRankingList(),
      ],
    );
  }

  Widget _buildLeaderboardFilters() {
    return Obx(() {
      final currentFilter = controller.leaderboardFilter.value;

      return Row(
        children: controller.leaderboardFilters.map((filter) {
          final isSelected = currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.selectLeaderboardFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.cyanActiveChip : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 1.4)
                      : Border.all(color: AppColors.iceBlueBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color:
                        isSelected ? AppColors.textDark : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPodiumView() {
    final topUsers = controller.leaderboardUsers.take(3).toList();
    if (topUsers.length < 3) return const SizedBox.shrink();

    final rank1 = topUsers[0];
    final rank2 = topUsers[1];
    final rank3 = topUsers[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place (Silver)
        Expanded(
          child: _buildPodiumCard(
            user: rank2,
            height: 165,
            crownColor: const Color(0xFF9E9E9E),
            medalEmoji: '🥈',
            podiumColor: const Color(0xFFF1F5F9),
            borderColor: const Color(0xFFCBD5E1),
          ),
        ),
        const SizedBox(width: 8),

        // 1st Place (Gold - Elevated)
        Expanded(
          child: _buildPodiumCard(
            user: rank1,
            height: 190,
            crownColor: const Color(0xFFFFB300),
            medalEmoji: '👑',
            podiumColor: const Color(0xFFFEF3C7),
            borderColor: const Color(0xFFFCD34D),
            isFirst: true,
          ),
        ),
        const SizedBox(width: 8),

        // 3rd Place (Bronze)
        Expanded(
          child: _buildPodiumCard(
            user: rank3,
            height: 155,
            crownColor: const Color(0xFFCD7F32),
            medalEmoji: '🥉',
            podiumColor: const Color(0xFFFFF1EE),
            borderColor: const Color(0xFFFFCCBC),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumCard({
    required LeaderboardUser user,
    required double height,
    required Color crownColor,
    required String medalEmoji,
    required Color podiumColor,
    required Color borderColor,
    bool isFirst = false,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isFirst ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
            color: isFirst
                ? const Color(0xFFFFB300).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isFirst ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                medalEmoji,
                style: TextStyle(fontSize: isFirst ? 20 : 16),
              ),
              const SizedBox(height: 2),
              Container(
                width: isFirst ? 42 : 36,
                height: isFirst ? 42 : 36,
                decoration: BoxDecoration(
                  color: podiumColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    user.avatarEmoji,
                    style: TextStyle(fontSize: isFirst ? 20 : 16),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isFirst ? 12.5 : 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.streakOrangeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 11,
                      color: AppColors.streakOrange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${user.streakDays}d',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.streakOrangeDeep,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.points} pts',
                style: TextStyle(
                  fontSize: isFirst ? 12 : 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    final remainingUsers = controller.leaderboardUsers.skip(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rankings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ...remainingUsers.map((user) {
          final isUser = user.isCurrentUser;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFF0FDF4) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUser
                      ? AppColors.primaryVibrant
                      : AppColors.iceBlueBorder,
                  width: isUser ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppColors.primaryVibrant.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank Number
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#${user.rank}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isUser
                            ? AppColors.primaryVibrant
                            : AppColors.textSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Avatar Emoji
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.mintSoft
                          : AppColors.cyanPillBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.avatarEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // User Name + Badge Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isUser
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.textDark,
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryVibrant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (user.badgeTitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.badgeTitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtitle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Stats: Flame + Points
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.points} pts',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 12,
                            color: AppColors.streakOrange,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${user.streakDays}d streak',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.streakOrangeDeep,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
