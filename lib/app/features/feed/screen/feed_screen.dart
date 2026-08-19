import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_builder_studio/app/constant/resources/app_colors.dart';
import 'package:the_builder_studio/app/core/base/base_view.dart';
import 'package:the_builder_studio/app/features/feed/controller/feed_controller.dart';
import 'package:the_builder_studio/app/widget/app_header.dart';
import 'package:the_builder_studio/app/widget/section_card.dart';

class FeedScreen extends BaseView<FeedController> {
  const FeedScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const AppHeader(
          title: 'Wellness Feed',
          subtitle: 'Verified health insights & myth-busting',
        ),
        const SizedBox(height: 18),

        // Category Filter Chips
        _buildCategoryFilters(),
        const SizedBox(height: 18),

        // Feed Item List
        Obx(() {
          final items = controller.filteredItems;
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
      child: Obx(
        () => Row(
          children: controller.categories.map((category) {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => controller.selectCategory(category),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primarySoft,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag and Reading Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _getCategoryColor(item.type),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${item.readTimeMinutes} min read',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Summary
            Text(
              item.summary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            // If Myth vs Fact, display highlight breakdown
            if (item.type == FeedItemType.mythVsFact &&
                item.mythText != null &&
                item.factText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MYTH',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.mythText!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'FACT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.factText!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Footer: Verification badge
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 16, color: AppColors.violet),
                const SizedBox(width: 6),
                Text(
                  item.authorRole,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(FeedItemType type) {
    switch (type) {
      case FeedItemType.medicalNews:
        return AppColors.primary;
      case FeedItemType.mythVsFact:
        return AppColors.violet;
      case FeedItemType.announcement:
        return AppColors.primaryDark;
    }
  }
}
