import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/mini_app_store/controller/mini_app_store_controller.dart';

class MiniAppStoreScreen extends BaseView<MiniAppStoreController> {
  const MiniAppStoreScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
        children: [
          // 1. Top Header: Title, Icon & Subtitle
          _buildTopHeader(context),
          const SizedBox(height: 24),

          // 2. Vertical Category Sections (Icon + Caption Below)
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
                    Icons.grid_view_rounded,
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
                      'Mini-App Store',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Directory of dedicated wellness modules',
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
  // Vertical Category Section
  // ---------------------------------------------------------------------------
  Widget _buildCategorySection(
    BuildContext context,
    String categoryName,
    List<MiniAppModule> apps,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title Header
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primaryVibrant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // App Icons with Captions Below (No white container card)
          Wrap(
            spacing: 18,
            runSpacing: 18,
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
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Squircle
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.iceBlueBgSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.iceBlueBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: moduleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Icon(
                      app.icon,
                      color: moduleColor,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Caption Text Below Icon
            Text(
              app.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


