import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/core/utils/image_url_helper.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class FeedScreen extends BaseView<FeedController> {
  const FeedScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      color: WalletColors.background,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshFeed,
          color: WalletColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              // 1. Top Header: Title, Icon & Subtitle
              _buildTopHeader(context),
              const SizedBox(height: WalletSpacing.lg),

              // 2. Segmented Toggle: Challenges vs Wellness Feed vs Leaderboard
              _buildSegmentedTabToggle(),
              const SizedBox(height: WalletSpacing.lg),

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
        ),
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
              // Social Icon Container with custom Shadcn blue styling
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WalletColors.surface,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(
                    color: WalletColors.primaryBorder,
                    width: 1.2,
                  ),
                  boxShadow: WalletShadows.level1,
                ),
                child: const Center(
                  child: Icon(
                    Icons.groups_rounded,
                    size: 26,
                    color: WalletColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: WalletSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Social & Feed',
                      style: WalletTextStyles.heading2,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verified medical insights, challenges & leaderboards',
                      style: WalletTextStyles.bodyMuted,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: WalletSpacing.sm),
        // Circular Refresh Button
        Obx(() {
          return GestureDetector(
            onTap: controller.isLoadingFeed.value ? null : () => controller.refreshFeed(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WalletColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: WalletColors.border,
                  width: 1,
                ),
                boxShadow: WalletShadows.level1,
              ),
              child: Center(
                child: controller.isLoadingFeed.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: WalletColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: WalletColors.primary,
                      ),
              ),
            ),
          );
        }),
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
        padding: const EdgeInsets.all(WalletSpacing.xs),
        decoration: BoxDecoration(
          color: WalletColors.tabBg,
          borderRadius: BorderRadius.circular(WalletRadius.lg),
          border: Border.all(color: WalletColors.border, width: 1),
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
                        ? WalletColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                    border: active == SocialTab.challenges
                        ? Border.all(color: WalletColors.border.withValues(alpha: 0.8), width: 1)
                        : null,
                    boxShadow: active == SocialTab.challenges ? WalletShadows.level1 : null,
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
                            ? WalletColors.textPrimary
                            : WalletColors.textMuted,
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
                        ? WalletColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                    border: active == SocialTab.feed
                        ? Border.all(color: WalletColors.border.withValues(alpha: 0.8), width: 1)
                        : null,
                    boxShadow: active == SocialTab.feed ? WalletShadows.level1 : null,
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
                            ? WalletColors.textPrimary
                            : WalletColors.textMuted,
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
                        ? WalletColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                    border: active == SocialTab.leaderboard
                        ? Border.all(color: WalletColors.border.withValues(alpha: 0.8), width: 1)
                        : null,
                    boxShadow: active == SocialTab.leaderboard ? WalletShadows.level1 : null,
                  ),
                  child: Center(
                    child: Text(
                      'Rankings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active == SocialTab.leaderboard
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: active == SocialTab.leaderboard
                            ? WalletColors.textPrimary
                            : WalletColors.textMuted,
                      ),
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
        const SizedBox(height: WalletSpacing.lg),
        Obx(() {
          if (controller.isLoadingFeed.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: WalletColors.primary),
              ),
            );
          }

          final items = controller.filteredItems;
          if (items.isEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: WalletColors.surface,
                borderRadius: BorderRadius.circular(WalletRadius.xl),
                border: Border.all(color: WalletColors.border, width: 1),
                boxShadow: WalletShadows.level1,
              ),
              child: Column(
                children: [
                  const Icon(Icons.feed_outlined, size: 48, color: WalletColors.textLight),
                  const SizedBox(height: 12),
                  const Text(
                    'No News Posts Yet',
                    style: WalletTextStyles.heading3,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add rows to the feed_posts table in Supabase to see real-time posts appear here.',
                    textAlign: TextAlign.center,
                    style: WalletTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => controller.refreshFeed(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh Feed'),
                    style: FilledButton.styleFrom(
                      backgroundColor: WalletColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(WalletRadius.md),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: items.map((item) => _buildFeedItemCard(context, item)).toList(),
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
              padding: const EdgeInsets.only(right: WalletSpacing.sm),
              child: GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? WalletColors.primaryLight : WalletColors.surface,
                    borderRadius: BorderRadius.circular(WalletRadius.pill),
                    border: Border.all(
                      color: isSelected ? WalletColors.primary : WalletColors.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: isSelected ? WalletShadows.level1 : null,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? WalletColors.primary : WalletColors.textMuted,
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
    return Container(
      margin: const EdgeInsets.only(bottom: WalletSpacing.lg),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1.0),
        boxShadow: WalletShadows.level1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.feedDetail, arguments: item),
          splashColor: WalletColors.primary.withValues(alpha: 0.08),
          highlightColor: WalletColors.primary.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Author & Tag Header Row
              _buildPostAuthorHeader(context, item),

              // 2. Caption / Post Body Text (Top of Graphic - Facebook Style)
              if (item.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: Text(
                    item.caption,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: WalletColors.textPrimary,
                      height: 1.4,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),

              // 3. 16:9 Visual Graphic Banner
              _buildPostBannerGraphic(context, item),

              // 4. Action Row (Timestamp, Save, Share)
              _buildPostActionRow(context, item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostAuthorHeader(BuildContext context, FeedItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
      child: Row(
        children: [
          // Author Avatar Circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WalletColors.surfaceMuted,
              border: Border.all(color: WalletColors.border, width: 1.2),
            ),
            child: Center(
              child: Text(
                item.authorAvatarText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: WalletColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Author Name
          Text(
            item.authorName,
            style: WalletTextStyles.heading3,
          ),
          const SizedBox(width: 8),

          // Promoted By / Tag Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: WalletColors.primaryLight,
              borderRadius: BorderRadius.circular(WalletRadius.xs),
              border: Border.all(color: WalletColors.primaryBorder, width: 0.8),
            ),
            child: Text(
              item.badgeText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: WalletColors.primary,
              ),
            ),
          ),

          const Spacer(),

          // Bell Icon
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: WalletColors.textLight,
              size: 20,
            ),
            onPressed: () {
              Get.snackbar(
                'Notifications',
                'Subscribed to updates from ${item.authorName}',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
          ),

          // 3-Dots Vert Options
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
            icon: const Icon(
              Icons.more_vert_rounded,
              color: WalletColors.textLight,
              size: 20,
            ),
            onPressed: () => _showPostOptionsMenu(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildPostBannerGraphic(BuildContext context, FeedItem item) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Visual (Network or Asset or Gradient Fallback)
          if (ImageUrlHelper.normalize(item.imageUrl) != null &&
              ImageUrlHelper.normalize(item.imageUrl)!.startsWith('http'))
            Image.network(
              ImageUrlHelper.normalize(item.imageUrl)!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFFF1F5F9),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  item.imageAsset != null
                      ? Image.asset(item.imageAsset!, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildFallbackGradientGraphic(item))
                      : _buildFallbackGradientGraphic(item),
            )
          else if (item.imageAsset != null)
            Image.asset(
              item.imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackGradientGraphic(item),
            )
          else
            _buildFallbackGradientGraphic(item),

          // Top Right Price / Promo Tag if available
          if (item.priceTag != null)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WalletColors.error,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  item.priceTag!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Bottom Overlay Badge (e.g. BEIJING-GUANGZHOU or WWW.JJEXPRESS.NET)
          if (item.badgeOverlayText != null)
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.badgeOverlayText!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                    if (item.id == 'feed-2')
                      const Text(
                        '📞 09 772 82 3000',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackGradientGraphic(FeedItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.bannerGradient,
        ),
      ),
      child: Center(
        child: Icon(
          item.bannerIcon,
          size: 64,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildPostActionRow(BuildContext context, FeedItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          // Time Ago
          Text(
            item.timeAgo,
            style: WalletTextStyles.label,
          ),
          const Spacer(),

          // Like Action Button (Symbol only + count, NO text "likes")
          Obx(() {
            final isLiked = controller.isLiked(item.id);
            final count = controller.getLikes(item);
            return _buildActionButton(
              icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: '$count',
              iconColor: isLiked ? const Color(0xFFEF4444) : WalletColors.textMuted,
              textColor: isLiked ? const Color(0xFFEF4444) : WalletColors.textMuted,
              onTap: () => controller.toggleLike(item),
            );
          }),
          const SizedBox(width: WalletSpacing.md),

          // Save Action Button (Saves to Bookmarks / Supabase)
          Obx(() {
            final isSaved = controller.isSaved(item.id);
            return _buildActionButton(
              icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              label: 'Save',
              iconColor: isSaved ? WalletColors.primary : WalletColors.textMuted,
              textColor: isSaved ? WalletColors.primary : WalletColors.textMuted,
              onTap: () => controller.toggleSave(item),
            );
          }),
          const SizedBox(width: WalletSpacing.md),

          // Share Action Button
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            iconColor: WalletColors.textMuted,
            textColor: WalletColors.textMuted,
            onTap: () => controller.sharePost(item),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: WalletColors.surfaceMuted,
          borderRadius: BorderRadius.circular(WalletRadius.md),
          border: Border.all(color: WalletColors.border, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptionsMenu(BuildContext context, FeedItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: WalletColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(WalletRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline_rounded, color: WalletColors.primary),
              title: Text(
                controller.isSaved(item.id) ? 'Remove from Saved' : 'Save Post to Bookmarks',
                style: WalletTextStyles.heading4,
              ),
              onTap: () {
                Get.back();
                controller.toggleSave(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: WalletColors.primary),
              title: const Text('Share Post Link', style: WalletTextStyles.heading4),
              onTap: () {
                Get.back();
                controller.sharePost(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hide_source_rounded, color: WalletColors.textMuted),
              title: const Text('Hide posts like this', style: WalletTextStyles.bodyMuted),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
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
            padding: const EdgeInsets.only(bottom: WalletSpacing.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: challenge.bannerGradient,
                  ),
                  borderRadius: BorderRadius.circular(WalletRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: challenge.bannerGradient.first.withValues(alpha: 0.35),
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
                  borderRadius: BorderRadius.circular(WalletRadius.xl),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(WalletRadius.xs),
                                  ),
                                  child: Text(
                                    challenge.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: WalletColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    borderRadius: BorderRadius.circular(WalletRadius.xs),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: WalletColors.warning,
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
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: challenge.progress,
                                            minHeight: 6,
                                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                                            valueColor: const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF67E8F9),
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
                                    onTap: () => controller.joinChallenge(challenge),
                                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.94),
                                        borderRadius: BorderRadius.circular(WalletRadius.sm),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Join Challenge',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: WalletColors.primaryDark,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 13,
                                            color: WalletColors.primaryDark,
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
        const SizedBox(height: WalletSpacing.lg),

        // 2. Top 3 Podium
        _buildPodiumView(),
        const SizedBox(height: WalletSpacing.lg),

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
            padding: const EdgeInsets.only(right: WalletSpacing.sm),
            child: GestureDetector(
              onTap: () => controller.selectLeaderboardFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? WalletColors.primaryLight : WalletColors.surface,
                  borderRadius: BorderRadius.circular(WalletRadius.pill),
                  border: Border.all(
                    color: isSelected ? WalletColors.primary : WalletColors.border,
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected ? WalletShadows.level1 : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? WalletColors.primary : WalletColors.textMuted,
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
    return Obx(() {
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
              height: 168,
              medalIcon: Icons.military_tech_rounded,
              medalColor: const Color(0xFF64748B),
              podiumColor: WalletColors.surfaceMuted,
              borderColor: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: WalletSpacing.sm),

          // 1st Place (Gold - Elevated)
          Expanded(
            child: _buildPodiumCard(
              user: rank1,
              height: 194,
              medalIcon: Icons.workspace_premium_rounded,
              medalColor: const Color(0xFFD97706),
              podiumColor: WalletColors.warningBg,
              borderColor: const Color(0xFFFCD34D),
              isFirst: true,
            ),
          ),
          const SizedBox(width: WalletSpacing.sm),

          // 3rd Place (Bronze)
          Expanded(
            child: _buildPodiumCard(
              user: rank3,
              height: 158,
              medalIcon: Icons.shield_rounded,
              medalColor: const Color(0xFFB45309),
              podiumColor: const Color(0xFFFFF1EE),
              borderColor: const Color(0xFFFFCCBC),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPodiumCard({
    required LeaderboardUser user,
    required double height,
    required IconData medalIcon,
    required Color medalColor,
    required Color podiumColor,
    required Color borderColor,
    bool isFirst = false,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: borderColor, width: isFirst ? 1.8 : 1.2),
        boxShadow: isFirst ? WalletShadows.level2 : WalletShadows.level1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: podiumColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  medalIcon,
                  size: isFirst ? 22 : 18,
                  color: medalColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: isFirst ? 44 : 38,
                height: isFirst ? 44 : 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: user.avatarGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: isFirst ? 14 : 12,
                      fontWeight: FontWeight.w900,
                      color: WalletColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isFirst ? 12.5 : 11.5,
                  fontWeight: FontWeight.w800,
                  color: WalletColors.textPrimary,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.streakOrangeBg,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
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
                  color: WalletColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    return Obx(() {
      final remainingUsers = controller.leaderboardUsers.skip(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rankings',
            style: WalletTextStyles.heading3,
          ),
          const SizedBox(height: WalletSpacing.sm),
          ...remainingUsers.map((user) {
            final isUser = user.isCurrentUser;

            return Padding(
              padding: const EdgeInsets.only(bottom: WalletSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? WalletColors.shopBg : WalletColors.surface,
                  borderRadius: BorderRadius.circular(WalletRadius.lg),
                  border: Border.all(
                    color: isUser ? WalletColors.primary : WalletColors.border,
                    width: isUser ? 1.4 : 1.0,
                  ),
                  boxShadow: isUser ? WalletShadows.level2 : WalletShadows.level1,
                ),
                child: Row(
                  children: [
                    // Rank Number
                    SizedBox(
                      width: 28,
                      child: Text(
                        '#${user.rank}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isUser ? WalletColors.primary : WalletColors.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Avatar Circle with Initials & Gradient
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: user.avatarGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUser ? WalletColors.primary : WalletColors.border,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isUser ? WalletColors.primary : WalletColors.textPrimary,
                          ),
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
                              Flexible(
                                child: Text(
                                  user.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isUser ? WalletColors.primary : WalletColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: WalletColors.primary,
                                    borderRadius: BorderRadius.circular(WalletRadius.xs),
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
                            Row(
                              children: [
                                Icon(
                                  user.icon,
                                  size: 12,
                                  color: user.iconColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  user.badgeTitle!,
                                  style: WalletTextStyles.label,
                                ),
                              ],
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
                            color: WalletColors.primary,
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
    });
  }
}
