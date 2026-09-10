import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/feed/screen/feed_screen.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/home/screen/home_screen.dart';
import 'package:infinity_wellness/app/features/mini_app_store/screen/mini_app_store_screen.dart';
import 'package:infinity_wellness/app/features/profile/screen/profile_screen.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:infinity_wellness/app/features/wallet/screen/wallet_screen.dart';
import 'package:infinity_wellness/app/widget/floating_water_droplet.dart';

class ShellScreen extends BaseView<ShellController> {
  const ShellScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.currentIndex.value;

      return Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: activeIndex,
            children: const [
              WalletScreen(), // 0: Wallet
              FeedScreen(), // 1: Social (Challenges + Feed)
              HomeScreen(), // 2: Home
              MiniAppStoreScreen(), // 3: Mini Apps
              ProfileScreen(), // 4: Profile
            ],
          ),
        ),
        bottomNavigationBar: _buildLiquidGlassNavBar(context, activeIndex),
      );
    });
  }

  Widget _buildLiquidGlassNavBar(BuildContext context, int activeIndex) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final navItems = const [
      _NavItemData(
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
      ),
      _NavItemData(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        label: 'Social',
      ),
      _NavItemData(
        icon: Icons.water_drop_outlined,
        selectedIcon: Icons.water_drop_rounded,
        label: 'Home',
      ),
      _NavItemData(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: 'Mini Apps',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    const topRadius = Radius.circular(28);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: topRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            8,
            8,
            8,
            bottomPadding > 0 ? bottomPadding + 6 : 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: topRadius),
            border: Border(
              top: BorderSide(
                color: AppColors.borderLight.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = activeIndex == index;

              // Center Action Button (Index 2: Blue Highlighted Water Droplet & Home Tab)
              if (index == 2) {
                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final home = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
                        final sip = home?.sipAmountMl.value ?? 250;
                        return FloatingWaterDroplet(
                          isSelected: isSelected,
                          isHighlighted: true,
                          amountMl: sip,
                          showTooltip: false,
                          width: 54,
                          height: 64,
                          onTap: () => controller.selectTab(2),
                        );
                      }),
                      const SizedBox(height: 2),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSubtitle,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectTab(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selected highlight pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 16 : 8,
                            vertical: isSelected ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.navPillSelected
                                    .withValues(alpha: 0.9)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            size: 26,
                            color: isSelected
                                ? Colors.black
                                : AppColors.textSubtitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.black
                                : AppColors.textSubtitle,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
