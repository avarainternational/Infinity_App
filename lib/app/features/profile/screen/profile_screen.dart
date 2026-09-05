import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/profile/controller/profile_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class ProfileScreen extends BaseView<ProfileController> {
  const ProfileScreen({super.key});

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

            // 2. User Account Card
            _buildUserAccountCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 3. Achievements & Badges Card
            _buildAchievementsCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 4. Health Metrics & Smart Goal Calculator Card
            _buildHealthMetricsCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 5. 1-on-1 Synergy Partner Card
            _buildPartnerCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 6. Preferences & Settings Card
            _buildSettingsCard(context),
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
                    Icons.person_rounded,
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
                      'My Profile',
                      style: WalletTextStyles.heading2,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Health metrics & ecosystem account',
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
  // User Account Card
  // ---------------------------------------------------------------------------
  Widget _buildUserAccountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1.0),
        boxShadow: WalletShadows.level1,
      ),
      child: Row(
        children: [
          Obx(() {
            final avatar = controller.avatarUrl.value;
            if (avatar.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(WalletRadius.lg),
                child: Image.network(
                  avatar,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitialsAvatar(),
                ),
              );
            }
            return _buildInitialsAvatar();
          }),
          const SizedBox(width: WalletSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: WalletTextStyles.heading3,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: WalletTextStyles.bodyMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: WalletColors.primaryLight,
                        borderRadius: BorderRadius.circular(WalletRadius.xs),
                        border: Border.all(color: WalletColors.primaryBorder, width: 0.8),
                      ),
                      child: Obx(
                        () => Text(
                          controller.memberTier.value,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: WalletColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: WalletColors.shopBg,
                          borderRadius: BorderRadius.circular(WalletRadius.xs),
                          border: Border.all(color: WalletColors.shopBorder, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_rounded,
                              size: 12,
                              color: WalletColors.shopIcon,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Code: ${controller.inviteCode.value}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: WalletColors.shopText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Achievements Showcase Card
  // ---------------------------------------------------------------------------
  Widget _buildAchievementsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.achievements),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WalletColors.surface,
          borderRadius: BorderRadius.circular(WalletRadius.xl),
          border: Border.all(color: WalletColors.border, width: 1.0),
          boxShadow: WalletShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Header Row with Icon, Title, Counter, and "View all"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: WalletColors.warningBg,
                          borderRadius: BorderRadius.circular(WalletRadius.xs),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: WalletColors.warning,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: WalletSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Achievements',
                          style: WalletTextStyles.heading3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: WalletSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: WalletColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                    border: Border.all(color: WalletColors.border, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: WalletColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WalletSpacing.md),

            // Middle: Three Displayed Achievements
            Obx(() {
              final displayed = controller.achievements.take(3).toList();

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: displayed.map((achievement) {
                  return _buildDisplayedAchievementIcon(context, achievement);
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayedAchievementIcon(
    BuildContext context,
    ProfileAchievement achievement,
  ) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? achievement.color.withValues(alpha: 0.12)
            : WalletColors.surfaceMuted,
        borderRadius: BorderRadius.circular(WalletRadius.lg),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withValues(alpha: 0.35)
              : WalletColors.border,
          width: 1.2,
        ),
        boxShadow: WalletShadows.level1,
      ),
      child: Center(
        child: Icon(
          achievement.icon,
          color: achievement.isUnlocked ? achievement.color : WalletColors.textLight,
          size: 28,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Health Metrics Card
  // ---------------------------------------------------------------------------
  Widget _buildHealthMetricsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1.0),
        boxShadow: WalletShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: WalletColors.primaryLight,
                        borderRadius: BorderRadius.circular(WalletRadius.xs),
                      ),
                      child: const Icon(
                        Icons.monitor_weight_rounded,
                        color: WalletColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: WalletSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Health Metrics',
                        style: WalletTextStyles.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: WalletSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WalletColors.shopBg,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
                  border: Border.all(color: WalletColors.shopBorder, width: 0.8),
                ),
                child: const Text(
                  'Smart Goal Engine',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: WalletColors.shopText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),

          // Metrics Row (Weight / Height)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WalletColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(WalletRadius.lg),
                    border: Border.all(color: WalletColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight',
                        style: WalletTextStyles.label,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.weightKg.value.toInt()} kg',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: WalletColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: WalletSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: WalletColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(WalletRadius.lg),
                    border: Border.all(color: WalletColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Height',
                        style: WalletTextStyles.label,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.heightCm.value.toInt()} cm',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: WalletColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.sm),

          // Activity Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: WalletColors.surfaceMuted,
              borderRadius: BorderRadius.circular(WalletRadius.lg),
              border: Border.all(color: WalletColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WalletColors.textSecondary,
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: WalletColors.primaryLight,
                      borderRadius: BorderRadius.circular(WalletRadius.xs),
                      border: Border.all(color: WalletColors.primaryBorder, width: 0.8),
                    ),
                    child: Text(
                      controller.activityLevel.value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: WalletColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WalletSpacing.md),

          // Calculated Goal Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [WalletColors.primary, Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(WalletRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: WalletColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: WalletSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculated Daily Water Goal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          '${controller.calculatedDailyGoalMl} ml / day',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1-on-1 Synergy Partner Card
  // ---------------------------------------------------------------------------
  Widget _buildPartnerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1.0),
        boxShadow: WalletShadows.level1,
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: WalletColors.primaryLight,
                      borderRadius: BorderRadius.circular(WalletRadius.xs),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: WalletColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: WalletSpacing.sm),
                  const Text(
                    '1-on-1 Synergy Partner',
                    style: WalletTextStyles.heading3,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WalletColors.primaryLight,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
                  border: Border.all(color: WalletColors.primaryBorder, width: 0.8),
                ),
                child: const Text(
                  '1-on-1 Only',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: WalletColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WalletColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(color: WalletColors.border, width: 1.2),
                ),
                child: const Center(
                  child: Text(
                    'JL',
                    style: TextStyle(
                      color: WalletColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: WalletSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.partnerName.value,
                        style: WalletTextStyles.heading4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.partnerStatus.value,
                        style: WalletTextStyles.bodyMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.streakOrangeBg,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.streakOrange, size: 16),
                    const SizedBox(width: 3),
                    Obx(
                      () => Text(
                        '${controller.synergyStreakDays.value}d',
                        style: const TextStyle(
                          color: AppColors.streakOrangeDeep,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Partner Nudge',
                      'Hydration reminder sent to Jamie!',
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: WalletColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(WalletRadius.md),
                      border: Border.all(color: WalletColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'notify partner',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: WalletSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Partner Dashboard',
                      'Viewing Jamie\'s synced wellness stats',
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: WalletColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(WalletRadius.md),
                      border: Border.all(color: WalletColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'view details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Settings & Preferences Card
  // ---------------------------------------------------------------------------
  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1.0),
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
                  color: WalletColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: WalletColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: WalletSpacing.sm),
              const Text(
                'Settings & Preferences',
                style: WalletTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydration Push Reminders',
                        style: WalletTextStyles.heading4,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Timely alerts during your active hours',
                        style: WalletTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.hydrationRemindersEnabled.value,
                    activeTrackColor: WalletColors.primary,
                    onChanged: (val) => controller.hydrationRemindersEnabled.value = val,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: WalletColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1-on-1 Partner Nudges',
                        style: WalletTextStyles.heading4,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Allow Jamie to send hydration alerts',
                        style: WalletTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.partnerNudgesEnabled.value,
                    activeTrackColor: WalletColors.primary,
                    onChanged: (val) => controller.partnerNudgesEnabled.value = val,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: WalletColors.divider),
          const SizedBox(height: WalletSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: WalletColors.error,
                side: const BorderSide(color: WalletColors.errorBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              onPressed: () => _confirmSignOut(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Obx(() {
      final name = controller.userName.value.trim();
      final initials = name.isNotEmpty
          ? name
              .split(' ')
              .take(2)
              .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
              .join()
          : 'IW';

      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: WalletColors.surfaceMuted,
          borderRadius: BorderRadius.circular(WalletRadius.lg),
          border: Border.all(color: WalletColors.border, width: 1.2),
        ),
        child: Center(
          child: Text(
            initials.isNotEmpty ? initials : 'IW',
            style: const TextStyle(
              color: WalletColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    });
  }

  void _confirmSignOut(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WalletRadius.xl)),
        title: const Text(
          'Sign Out',
          style: WalletTextStyles.heading2,
        ),
        content: const Text(
          'Are you sure you want to sign out of Infinity Wellness?',
          style: WalletTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w700, color: WalletColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WalletColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WalletRadius.md),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
