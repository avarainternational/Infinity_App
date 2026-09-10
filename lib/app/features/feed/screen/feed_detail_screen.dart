import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/core/utils/image_url_helper.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_detail_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class FeedDetailScreen extends BaseView<FeedDetailController> {
  const FeedDetailScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      backgroundColor: WalletColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar / Top Sliver
                  _buildSliverAppBar(context, item),

                  // Article Content Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Category & Read Time Tag Row
                          _buildCategoryRow(item),
                          const SizedBox(height: 12),

                          // 2. Full Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: WalletColors.textPrimary,
                              height: 1.35,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. Author Row
                          _buildAuthorCard(item),
                          const SizedBox(height: 20),

                          // 4. Caption / Lead-In Card (if present)
                          if (item.caption.isNotEmpty && item.caption != item.title)
                            _buildLeadInCard(item),

                          // 5. Myth vs Fact Callout (if applicable)
                          if (item.type == FeedItemType.mythVsFact ||
                              item.mythText != null ||
                              item.factText != null)
                            _buildMythVsFactCallout(item),

                          // 6. Main Body Content
                          _buildBodyContent(),
                          const SizedBox(height: 24),

                          // 7. Evidence & Medical Literacy Disclaimer Card
                          _buildDisclaimerCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Action Bar (Like, Save, Share)
            _buildBottomActionBar(context, item),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver App Bar with Hero Image / Gradient & Navigation Buttons
  // ---------------------------------------------------------------------------
  Widget _buildSliverAppBar(BuildContext context, FeedItem item) {
    final normalizedUrl = ImageUrlHelper.normalize(item.imageUrl);
    final hasNetworkImage = normalizedUrl != null && normalizedUrl.startsWith('http');

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      backgroundColor: WalletColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        // Save Bookmark Icon
        Obx(() {
          final saved = controller.isSaved.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.toggleSave(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: saved ? const Color(0xFF38BDF8) : Colors.white,
                  size: 20,
                ),
              ),
            ),
          );
        }),

        // Share Icon
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: () => controller.sharePost(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Graphic (Network or Asset or Fallback Gradient)
            if (hasNetworkImage)
              Image.network(
                normalizedUrl,
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
                        ? Image.asset(item.imageAsset!, fit: BoxFit.cover)
                        : _buildFallbackGradient(item),
              )
            else if (item.imageAsset != null && item.imageAsset!.isNotEmpty)
              Image.asset(item.imageAsset!, fit: BoxFit.cover)
            else
              _buildFallbackGradient(item),

            // Gradient scrim for top and bottom visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top-right promo price tag (if available)
            if (item.priceTag != null)
              Positioned(
                top: 50,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: WalletColors.error,
                    borderRadius: BorderRadius.circular(WalletRadius.xs),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    item.priceTag!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Bottom overlay tag (e.g. BEIJING-GUANGZHOU or WWW.JJEXPRESS.NET)
            if (item.badgeOverlayText != null)
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(WalletRadius.xs),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item.badgeOverlayText!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackGradient(FeedItem item) {
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
          size: 72,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category Pill & Read Time
  // ---------------------------------------------------------------------------
  Widget _buildCategoryRow(FeedItem item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: WalletColors.primaryLight,
            borderRadius: BorderRadius.circular(WalletRadius.pill),
            border: Border.all(color: WalletColors.primaryBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 13,
                color: WalletColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                item.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: WalletColors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: WalletColors.surfaceMuted,
            borderRadius: BorderRadius.circular(WalletRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: WalletColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.readTimeMinutes} min read',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: WalletColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Author Card
  // ---------------------------------------------------------------------------
  Widget _buildAuthorCard(FeedItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.lg),
        border: Border.all(color: WalletColors.border),
        boxShadow: WalletShadows.level1,
      ),
      child: Row(
        children: [
          // Author Initials Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WalletColors.primaryLight,
              border: Border.all(color: WalletColors.primaryBorder, width: 1.2),
            ),
            child: Center(
              child: Text(
                item.authorAvatarText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: WalletColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Author details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.authorName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: WalletColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.authorRole,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: WalletColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Published Time
          Text(
            item.timeAgo,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: WalletColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lead-in Quote / Summary Card
  // ---------------------------------------------------------------------------
  Widget _buildLeadInCard(FeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WalletColors.shopBg,
        borderRadius: BorderRadius.circular(WalletRadius.md),
        border: Border.all(color: WalletColors.shopBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: WalletColors.shopIcon,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.caption,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: WalletColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Myth vs Fact Callout Card
  // ---------------------------------------------------------------------------
  Widget _buildMythVsFactCallout(FeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.lg),
        border: Border.all(color: WalletColors.border),
        boxShadow: WalletShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: WalletColors.errorBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: WalletColors.error,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'COMMON MYTH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: WalletColors.error,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.mythText ?? 'Drinking huge amounts of water is an instant cure for skin conditions.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: WalletColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Divider(height: 24, color: WalletColors.border),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: WalletColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: WalletColors.success,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CLINICAL EVIDENCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: WalletColors.success,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.factText ?? 'Optimal hydration supports barrier function and cellular turnover, but dermatological conditions require multifaceted targeted interventions.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WalletColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main Body Content
  // ---------------------------------------------------------------------------
  Widget _buildBodyContent() {
    final bodyText = controller.getDisplayContent();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border),
        boxShadow: WalletShadows.level1,
      ),
      child: Text(
        bodyText,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: WalletColors.textPrimary,
          height: 1.65,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Disclaimer Card
  // ---------------------------------------------------------------------------
  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WalletColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WalletRadius.md),
        border: Border.all(color: WalletColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: WalletColors.textMuted,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Digital Health Literacy Notice: All content is curated for youth health literacy and habit formation. It does not replace individualized clinical diagnosis or medical care.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: WalletColors.textMuted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sticky Bottom Action Bar (Like, Save, Share)
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar(BuildContext context, FeedItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        border: const Border(
          top: BorderSide(color: WalletColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Like Button
          Obx(() {
            final isLiked = controller.isLiked.value;
            final count = controller.likesCount.value;

            return InkWell(
              onTap: () => controller.toggleLike(),
              borderRadius: BorderRadius.circular(WalletRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isLiked ? const Color(0xFFFEF2F2) : WalletColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(
                    color: isLiked ? const Color(0xFFFECACA) : WalletColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 20,
                      color: isLiked ? const Color(0xFFEF4444) : WalletColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLiked ? const Color(0xFFEF4444) : WalletColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 10),

          // 2. Save to Bookmarks Button
          Obx(() {
            final isSaved = controller.isSaved.value;

            return InkWell(
              onTap: () => controller.toggleSave(),
              borderRadius: BorderRadius.circular(WalletRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSaved ? WalletColors.primaryLight : WalletColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(
                    color: isSaved ? WalletColors.primaryBorder : WalletColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      size: 20,
                      color: isSaved ? WalletColors.primary : WalletColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSaved ? 'Saved' : 'Save',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSaved ? WalletColors.primary : WalletColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 10),

          // 3. Share Button (Primary Button)
          Expanded(
            child: FilledButton.icon(
              onPressed: () => controller.sharePost(),
              icon: const Icon(Icons.share_rounded, size: 17),
              label: const Text(
                'Share Post',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: WalletColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
