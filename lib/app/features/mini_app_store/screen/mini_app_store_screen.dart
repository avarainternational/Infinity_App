import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/mini_app_store/controller/mini_app_store_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class MiniAppStoreScreen extends BaseView<MiniAppStoreController> {
  const MiniAppStoreScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      color: WalletColors.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            // 1. Top Header: Title, Icon & Subtitle
            _buildTopHeader(context),
            const SizedBox(height: WalletSpacing.lg),

            // 2. Vertical Category Sections
            Obx(() {
              final grouped = controller.groupedMiniApps;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.entries.map((entry) {
                  return _buildCategorySection(context, entry.key, entry.value);
                }).toList(),
              );
            }),
          ],
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
                    Icons.grid_view_rounded,
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
                      'Mini-App Store',
                      style: WalletTextStyles.heading2,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Directory of dedicated wellness modules',
                      style: WalletTextStyles.bodyMuted,
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
  // Vertical Category Section
  // ---------------------------------------------------------------------------
  Widget _buildCategorySection(
    BuildContext context,
    String categoryName,
    List<MiniAppModule> apps,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WalletSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title Header
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: WalletSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 3.5,
                  height: 14,
                  decoration: BoxDecoration(
                    color: WalletColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: WalletSpacing.sm),
                Text(
                  categoryName,
                  style: WalletTextStyles.heading3,
                ),
              ],
            ),
          ),

          // App Icons with Captions Below
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: apps
                .map((app) => _buildMiniAppGridItem(context, app))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Item: Icon + Caption Below
  // ---------------------------------------------------------------------------
  Widget _buildMiniAppGridItem(BuildContext context, MiniAppModule app) {
    final moduleColor = Color(app.colorHex);

    return GestureDetector(
      onTap: () => controller.launchModule(app),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Squircle (Exact match with Quick Mini-Apps)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: moduleColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: moduleColor.withValues(alpha: 0.18),
                  width: 1,
                ),
                boxShadow: WalletShadows.level1,
              ),
              child: Center(
                child: Icon(
                  app.icon,
                  color: moduleColor,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Caption Text Below Icon
            Text(
              app.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: WalletColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
