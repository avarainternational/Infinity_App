import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';

// -----------------------------------------------------------------------------
// Improved Design Color Palette Constants
// -----------------------------------------------------------------------------
class HomeThemeColors {
  HomeThemeColors._();

  static const Color background = Color(0xFFE0F2FE);
  static const Color backgroundTop = Color(0xFFD4EDFC);
  static const Color backgroundMiddle = Color(0xFFE5F3FD);
  static const Color backgroundBottom = Color(0xFFF1F8FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD6E6F7);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color tealAccent = Color(0xFF14BBA6);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF697386);
  static const Color softAccentBg = Color(0xFFE6F7F5);
  static const Color softBlueBg = Color(0xFFEBF3FF);
  static const Color softGrayButton = Color(0xFFF1F5F9);
}

class HomeScreen extends BaseView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HomeThemeColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HomeThemeColors.backgroundTop,
            HomeThemeColors.backgroundMiddle,
            HomeThemeColors.backgroundBottom,
          ],
          stops: [0.0, 0.40, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshHomeFeed,
          color: HomeThemeColors.primaryBlue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              // 1. Top Header: Greeting, User Avatar, Date, Bell
              _buildTopHeader(context),
              const SizedBox(height: 14),

              // 2. Standalone Date Selector Card
              _buildDateSelectorCard(context),
              const SizedBox(height: 18),

              // 3. "Today's overview" Section Header
              const Text(
                "Today's overview",
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: HomeThemeColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // 4. Separated Card: Hydration with Curve Indicator
              _buildHydrationCard(context),
              const SizedBox(height: 14),

              // 5. Separated Card: Friend Synergy
              _buildFriendSynergyCard(context),
              const SizedBox(height: 20),

              // 6. "Wellness for you" Section Header & Banner Carousel
              _buildWellnessForYouSection(context),
              const SizedBox(height: 20),

              // 7. Quick Mini-Apps Card
              _buildQuickMiniAppsCard(context),
              const SizedBox(height: 20),

              // 8. News & Community Feed Section
              _buildNewsAndChallengesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Top Header: Cleaner Header (Good evening, Hlyan 👋 / Date / Bell)
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                // Squircle User Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: HomeThemeColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: controller.avatarUrl.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.network(
                              controller.avatarUrl.value,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 26,
                                color: HomeThemeColors.primaryBlue,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 26,
                            color: HomeThemeColors.primaryBlue,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Greeting & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.greetingText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HomeThemeColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.formattedCurrentDate,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: HomeThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Circular Notification Bell Button
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Notifications',
                'You have ${controller.notificationCount.value} unread health updates & partner nudges',
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: HomeThemeColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: HomeThemeColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 21,
                      color: HomeThemeColors.textPrimary,
                    ),
                  ),
                  if (controller.notificationCount.value > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: HomeThemeColors.surface, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        child: Center(
                          child: Text(
                            controller.notificationCount.value > 9
                                ? '9+'
                                : '${controller.notificationCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 2. Standalone Date Selector Card
  // ---------------------------------------------------------------------------
  Widget _buildDateSelectorCard(BuildContext context) {
    final dates = controller.dateList;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HomeThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeThemeColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: Obx(() {
                final selected = controller.selectedDate.value;
                return ListView.separated(
                  controller: controller.calendarScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: dates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final isSelected = date.year == selected.year &&
                        date.month == selected.month &&
                        date.day == selected.day;
                    final weekdayStr = controller.getWeekdayShort(date.weekday).toUpperCase();

                    return GestureDetector(
                      onTap: () => controller.selectDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? HomeThemeColors.softBlueBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: HomeThemeColors.primaryBlue, width: 1.2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? HomeThemeColors.primaryBlue
                                    : HomeThemeColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              weekdayStr,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? HomeThemeColors.primaryBlue
                                    : HomeThemeColors.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 6),
          // Calendar Picker Button
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) {
                controller.selectDate(picked);
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: HomeThemeColors.softGrayButton,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HomeThemeColors.border),
              ),
              child: const Center(
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: HomeThemeColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Separated Card: Hydration (With Curve Progress Bar Gauge)
  // ---------------------------------------------------------------------------
  Widget _buildHydrationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HomeThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeThemeColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() {
        final current = controller.currentWaterMl.value;
        final goal = controller.dailyGoalMl.value;
        final progress = controller.hydrationProgress;
        final percent = controller.hydrationPercentage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Circular Water Droplet Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hydration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeThemeColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: HomeThemeColors.softBlueBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: HomeThemeColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Semicircle Speedometer Curve Progress Bar Indicator (Kept as requested)
            Center(
              child: HydrationGauge(
                progress: progress,
                percent: percent,
                gradientColors: controller.userTheme.gradient,
              ),
            ),
            const SizedBox(height: 8),

            // Intake / Goal Display
            Center(
              child: Text(
                '${_formatNumber(current)} / ${_formatNumber(goal)} ml',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: HomeThemeColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // View Details Button (Full Width Clean Gray Button)
            GestureDetector(
              onTap: controller.viewHydrationDetails,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: HomeThemeColors.softGrayButton,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HomeThemeColors.border,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: HomeThemeColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: HomeThemeColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Separated Card: Friend Synergy
  // ---------------------------------------------------------------------------
  Widget _buildFriendSynergyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HomeThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeThemeColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title, Subtitle + Soft Teal People Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friend Synergy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Stay motivated together',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: HomeThemeColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: HomeThemeColors.softAccentBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.groups_rounded,
                    color: HomeThemeColors.tealAccent,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Partner Status Row
          Obx(() {
            if (controller.partners.isEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'No partner connected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HomeThemeColors.textPrimary,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeThemeColors.tealAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Get.toNamed(Routes.partnerDetail),
                    child: const Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                ...controller.partners.map((partner) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildPartnerGaugeItem(context, partner),
                    ),
                  );
                }),
                // Add partner '+' button
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.partnerDetail),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: HomeThemeColors.softGrayButton,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HomeThemeColors.border),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: HomeThemeColors.tealAccent,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Partner Gauge Item
  // ---------------------------------------------------------------------------
  Widget _buildPartnerGaugeItem(BuildContext context, SynergyPartner partner) {
    return Obx(() {
      final theme = partner.theme;
      return Column(
        children: [
          Text(
            partner.name,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: HomeThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          MiniHydrationGauge(
            progress: partner.progress,
            percent: partner.percentage,
            gradientColors: theme.gradient,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => controller.notifyPartner(partner),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: HomeThemeColors.softGrayButton,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HomeThemeColors.border),
                  ),
                  child: const Text(
                    'notify',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.tealAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => controller.viewPartner(partner),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: HomeThemeColors.softGrayButton,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HomeThemeColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'view',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: HomeThemeColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.edit_rounded, size: 10, color: HomeThemeColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 6. "Wellness for you" Section Header & Carousel
  // ---------------------------------------------------------------------------
  Widget _buildWellnessForYouSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wellness for you',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: HomeThemeColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _buildDrinkWaterStickerBanner(context),
      ],
    );
  }

  Widget _buildDrinkWaterStickerBanner(BuildContext context) {
    return Obx(() {
      final banners = controller.banners;
      final activeIndex = controller.currentBannerIndex.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 128,
            child: PageView.builder(
              controller: controller.bannerPageController,
              itemCount: banners.length,
              onPageChanged: (index) => controller.currentBannerIndex.value = index,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final banner = banners[index];
                return _buildBannerCard(context, banner);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Animated indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isSelected = index == activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isSelected ? 18 : 5,
                decoration: BoxDecoration(
                  color: isSelected
                      ? HomeThemeColors.primaryBlue
                      : HomeThemeColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildBannerCard(BuildContext context, HomeBannerItem banner) {
    return GestureDetector(
      onTap: () => controller.onBannerTap(banner),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: banner.gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: banner.gradientColors.last.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: banner.tagBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              banner.tag,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: banner.tagTextColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            banner.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            banner.subtitle,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              banner.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.ctaText,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: banner.gradientColors.first,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 11,
                                color: banner.gradientColors.first,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Quick Mini-Apps Card
  // ---------------------------------------------------------------------------
  Widget _buildQuickMiniAppsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeThemeColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: HomeThemeColors.softBlueBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: HomeThemeColors.primaryBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick miniapps',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => controller.openMiniAppsTab(),
                child: const Row(
                  children: [
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: HomeThemeColors.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: HomeThemeColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickMiniAppItem(
                title: 'News',
                icon: Icons.article_rounded,
                color: const Color(0xFF2563EB),
                onTap: () => controller.openMiniApp('medical-news'),
              ),
              _buildQuickMiniAppItem(
                title: 'Hydration',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF0284C7),
                onTap: () => controller.openMiniApp('smart-hydration'),
              ),
              _buildQuickMiniAppItem(
                title: 'Synergy',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF0D9488),
                onTap: () => controller.openMiniApp('friend-synergy'),
              ),
              _buildQuickMiniAppItem(
                title: 'More',
                icon: Icons.grid_view_rounded,
                color: HomeThemeColors.primaryBlue,
                onTap: () => controller.openMiniAppsTab(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMiniAppItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? HomeThemeColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: itemColor.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: itemColor,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: HomeThemeColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. News & Community Feed Section
  // ---------------------------------------------------------------------------
  Widget _buildNewsAndChallengesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: HomeThemeColors.softBlueBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.article_rounded,
                    color: HomeThemeColors.primaryBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'News & Community Feed',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: HomeThemeColors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.find<ShellController>().selectTab(1);
              },
              child: const Row(
                children: [
                  Text(
                    'View All Feed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: HomeThemeColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingFeed.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: CircularProgressIndicator(color: HomeThemeColors.primaryBlue),
              ),
            );
          }

          final posts = controller.homeFeedPosts;
          if (posts.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: HomeThemeColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HomeThemeColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.feed_outlined, size: 36, color: HomeThemeColors.textSecondary),
                  const SizedBox(height: 8),
                  const Text(
                    'No News Posts Yet',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add rows to feed_posts in Supabase or pull down to refresh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomeThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => controller.refreshHomeFeed(),
                    icon: const Icon(Icons.refresh_rounded, size: 15),
                    label: const Text('Refresh', style: TextStyle(fontSize: 12.5)),
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeThemeColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: posts.map((item) => _buildHomeFeedCard(context, item)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildHomeFeedCard(BuildContext context, FeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: HomeThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeThemeColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author & Tag Header Row
          _buildHomePostAuthorHeader(context, item),

          // 2. Caption / Post Body Text (Top of Graphic - Facebook Style)
          if (item.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
              child: Text(
                item.caption,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: HomeThemeColors.textPrimary,
                  height: 1.4,
                  letterSpacing: -0.1,
                ),
              ),
            ),

          // 3. 16:9 Visual Graphic Banner
          _buildHomePostBannerGraphic(context, item),

          // 4. Action Row (Timestamp, Save, Share)
          _buildHomePostActionRow(context, item),
        ],
      ),
    );
  }

  Widget _buildHomePostAuthorHeader(BuildContext context, FeedItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
      child: Row(
        children: [
          // Author Avatar Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HomeThemeColors.softBlueBg,
              border: Border.all(color: HomeThemeColors.border, width: 1.2),
            ),
            child: Center(
              child: Text(
                item.authorAvatarText,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: HomeThemeColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Author Name & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.authorName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: HomeThemeColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: HomeThemeColors.primaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: HomeThemeColors.softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.badgeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: HomeThemeColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3-Dots Action Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: HomeThemeColors.textSecondary, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'save') {
                controller.toggleSave(item);
              } else if (val == 'share') {
                controller.sharePost(item);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(
                      controller.isSaved(item.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 17,
                      color: HomeThemeColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    Text(controller.isSaved(item.id) ? 'Remove Bookmark' : 'Save Bookmark'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 17, color: HomeThemeColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Share Post'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomePostBannerGraphic(BuildContext context, FeedItem item) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: HomeThemeColors.softGrayButton,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: HomeThemeColors.primaryBlue,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildHomeFallbackBanner(item),
            )
          else if (item.imageAsset != null && item.imageAsset!.isNotEmpty)
            Image.asset(
              item.imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildHomeFallbackBanner(item),
            )
          else
            _buildHomeFallbackBanner(item),

          if (item.priceTag != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

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
                child: Text(
                  item.badgeOverlayText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeFallbackBanner(FeedItem item) {
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
          size: 56,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildHomePostActionRow(BuildContext context, FeedItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Row(
        children: [
          Text(
            item.timeAgo,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: HomeThemeColors.textSecondary,
            ),
          ),
          const Spacer(),

          Obx(() {
            final isSaved = controller.isSaved(item.id);
            return _buildHomeActionButton(
              icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              label: 'Save',
              iconColor: isSaved ? HomeThemeColors.primaryBlue : HomeThemeColors.textSecondary,
              textColor: isSaved ? HomeThemeColors.primaryBlue : HomeThemeColors.textSecondary,
              onTap: () => controller.toggleSave(item),
            );
          }),
          const SizedBox(width: 14),

          _buildHomeActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            iconColor: HomeThemeColors.textSecondary,
            textColor: HomeThemeColors.textSecondary,
            onTap: () => controller.sharePost(item),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeActionButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
        decoration: BoxDecoration(
          color: HomeThemeColors.softGrayButton,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HomeThemeColors.border, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// -----------------------------------------------------------------------------
// Semicircle Hydration Gauges (Full & Mini)
// -----------------------------------------------------------------------------
class HydrationGauge extends StatelessWidget {
  const HydrationGauge({
    super.key,
    required this.progress,
    required this.percent,
    this.gradientColors,
  });

  final double progress;
  final int percent;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: 200,
          height: 110,
          child: CustomPaint(
            painter: _SemicircleGaugePainter(
              progress: animatedProgress,
              strokeWidth: 12.0,
              gradientColors: gradientColors,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: HomeThemeColors.primaryBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MiniHydrationGauge extends StatelessWidget {
  const MiniHydrationGauge({
    super.key,
    required this.progress,
    required this.percent,
    this.gradientColors,
  });

  final double progress;
  final int percent;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 52,
      child: CustomPaint(
        painter: _SemicircleGaugePainter(
          progress: progress,
          strokeWidth: 7.0,
          gradientColors: gradientColors,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  color: (gradientColors != null && gradientColors!.isNotEmpty)
                      ? gradientColors!.first
                      : HomeThemeColors.tealAccent,
                  size: 12,
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: HomeThemeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SemicircleGaugePainter extends CustomPainter {
  const _SemicircleGaugePainter({
    required this.progress,
    this.strokeWidth = 12.0,
    this.gradientColors,
  });

  final double progress;
  final double strokeWidth;
  final List<Color>? gradientColors;

  _SemicircleGaugePainter copyWith({
    double? progress,
    double? strokeWidth,
    List<Color>? gradientColors,
  }) {
    return _SemicircleGaugePainter(
      progress: progress ?? this.progress,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full background semicircle
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    if (progress > 0) {
      final activeColors = (gradientColors != null && gradientColors!.length >= 2)
          ? gradientColors!
          : const [Color(0xFF38BDF8), Color(0xFF2563EB)];

      final gradient = SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: activeColors,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(rect, math.pi, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemicircleGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors;
  }
}
