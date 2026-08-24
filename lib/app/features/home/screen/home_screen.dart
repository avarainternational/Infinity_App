import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';

class HomeScreen extends BaseView<HomeController> {
  const HomeScreen({super.key});

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
          // 1. Top Profile Greeting & Notification Notice
          _buildTopHeader(context),
          const SizedBox(height: 16),

          // 2. Main Card: Calendar + Hydration Meter (You & Partners)
          _buildMainHydrationCard(context),
          const SizedBox(height: 16),

          // 3. Middle Sticker Banner: Drink Water Illustration Card
          _buildDrinkWaterStickerBanner(context),
          const SizedBox(height: 16),

          // 4. Quick Mini-Apps Card
          _buildQuickMiniAppsCard(context),
          const SizedBox(height: 20),

          // 5. News and Challenges Section
          _buildNewsAndChallengesSection(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header: Greeting, Avatar, Age/Gender, Bell with Red 9+ Badge
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
                // Avatar (Circular with pale cyan/mint background & silhouette)
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.mintSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: controller.avatarUrl.value.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              controller.avatarUrl.value,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 34,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 34,
                            color: AppColors.textLight,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Greeting & User Profile info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Have a nice day!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.userName.value} -Age ${controller.userAge.value}/${controller.userGender.value}',
                        style: const TextStyle(
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
          const SizedBox(width: 8),
          // Notification Bell Notice with red badge on top-left
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Notifications',
                'You have ${controller.notificationCount.value} unread health updates & partner nudges',
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.redBadge,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          controller.notificationCount.value > 9
                              ? '9+'
                              : '${controller.notificationCount.value}',
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 9,
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
  // Main Card: Calendar + Hydration Meter (You & Partners)
  // ---------------------------------------------------------------------------
  Widget _buildMainHydrationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Scrollable Calendar Strip
          _buildHorizontalCalendar(context),
          const SizedBox(height: 16),

          // 2. Section Header: Droplet icon in cyan box + "Hydration Meter"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Hydration Meter',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. "You" Subsection
          const Text(
            'You',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Semicircle Speedometer Gauge (You)
          Obx(() {
            final current = controller.currentWaterMl.value;
            final goal = controller.dailyGoalMl.value;
            final progress = controller.hydrationProgress;
            final percent = controller.hydrationPercentage;

            return Column(
              children: [
                Center(
                  child: HydrationGauge(
                    progress: progress,
                    percent: percent,
                    gradientColors: controller.userTheme.gradient,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Total Intake',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSlate,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$current / $goal ml',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.viewHydrationDetails,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.cyanPillBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.cyanPillBorder,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'view details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSubtitle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.textSubtitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 14),

          // 4. "Partners" Subsection
          const Text(
            'Partners',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Partners List
          Obx(() {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  onTap: controller.addPartner,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cyanToggleBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryDarkBlue,
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
  // Partner Gauge Item (e.g. Wifey❤️ or Bob)
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
              color: AppColors.textDark,
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
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'notify',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => controller.viewPartner(partner),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'view',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.edit_rounded, size: 10, color: AppColors.textMuted),
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
  // Horizontal Calendar Strip
  // ---------------------------------------------------------------------------
  Widget _buildHorizontalCalendar(BuildContext context) {
    final dates = controller.dateList;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: Obx(() {
              final selected = controller.selectedDate.value;
              return ListView.separated(
                controller: controller.calendarScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = date.year == selected.year &&
                      date.month == selected.month &&
                      date.day == selected.day;
                  final weekdayStr = controller.getWeekdayShort(date.weekday);

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cyanActiveChip
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 1.4)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.textDark
                                  : AppColors.calendarDate,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            weekdayStr,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.textDark
                                  : AppColors.calendarWeekday,
                              letterSpacing: 0.2,
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
        const SizedBox(width: 8),
        // Calendar Picker Icon Button
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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.calendar_today_outlined,
                size: 22,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Wellness, Hydration Habits & Sponsored Ads Banner Carousel
  // ---------------------------------------------------------------------------
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
          // Sleek animated indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isSelected = index == activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isSelected ? 20 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textLight.withValues(alpha: 0.35),
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: banner.gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Ambient background decorative glow circles
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
              Positioned(
                right: 50,
                top: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Content Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Row(
                  children: [
                    // Left Text Block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: banner.tagBgColor,
                              borderRadius: BorderRadius.circular(8),
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
                          const SizedBox(height: 6),
                          // Title
                          Text(
                            banner.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Subtitle description
                          Text(
                            banner.subtitle,
                            style: TextStyle(
                              fontSize: 11,
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
                    // Right Visual Icon + CTA Button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
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
                              size: 22,
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
                            borderRadius: BorderRadius.circular(16),
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
  // Quick Mini-Apps Card
  // ---------------------------------------------------------------------------
  Widget _buildQuickMiniAppsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                      color: AppColors.cyanBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick miniapps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
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
                        color: AppColors.primaryVibrant,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primaryVibrant,
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
                color: const Color(0xFF6200EE),
                onTap: () => controller.openMiniApp('medical-news'),
              ),
              _buildQuickMiniAppItem(
                title: 'Hydration',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF00A3FF),
                onTap: () => controller.openMiniApp('smart-hydration'),
              ),
              _buildQuickMiniAppItem(
                title: 'Synergy',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF005C99),
                onTap: () => controller.openMiniApp('friend-synergy'),
              ),
              _buildQuickMiniAppItem(
                title: 'More',
                icon: Icons.grid_view_rounded,
                color: AppColors.primaryVibrant,
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
    final itemColor = color ?? AppColors.primary;
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: itemColor.withValues(alpha: 0.20),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: itemColor.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: itemColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // News and Challenges Section
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.article_rounded,
                    color: AppColors.primaryDarkBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'News & Challenges',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Navigate to Social / Feed Tab in Shell
                Get.find<ShellController>().selectTab(1);
              },
              child: const Row(
                children: [
                  Text(
                    'View All Feed',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryVibrant,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primaryVibrant,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          return Column(
            children: controller.newsAndChallenges.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                                  _buildHomeFallbackNewsGraphic(item),
                            )
                          : _buildHomeFallbackNewsGraphic(item),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildHomeFallbackNewsGraphic(HomeFeedCardItem item) {
    return Stack(
      children: [
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
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          right: -10,
          bottom: -5,
          child: Icon(
            item.icon,
            size: 120,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
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
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Text(
            item.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.28,
              letterSpacing: -0.2,
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
          width: 220,
          height: 120,
          child: CustomPaint(
            painter: _SemicircleGaugePainter(
              progress: animatedProgress,
              strokeWidth: 14.0,
              gradientColors: gradientColors,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
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
      width: 100,
      height: 60,
      child: CustomPaint(
        painter: _SemicircleGaugePainter(
          progress: progress,
          strokeWidth: 8.0,
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
                      : AppColors.primary,
                  size: 13,
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
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
    this.strokeWidth = 14.0,
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

    // Background track (soft water-tinted track)
    final bgPaint = Paint()
      ..color = AppColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full background semicircle (from pi to 2*pi)
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    if (progress > 0) {
      final activeColors = (gradientColors != null && gradientColors!.length >= 2)
          ? gradientColors!
          : AppColors.gaugeGradientColors;

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
