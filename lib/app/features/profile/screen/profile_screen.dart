import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_builder_studio/app/constant/resources/app_colors.dart';
import 'package:the_builder_studio/app/core/base/base_view.dart';
import 'package:the_builder_studio/app/features/profile/controller/profile_controller.dart';
import 'package:the_builder_studio/app/widget/app_header.dart';
import 'package:the_builder_studio/app/widget/section_card.dart';

class ProfileScreen extends BaseView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const AppHeader(
          title: 'My Profile',
          subtitle: 'Health metrics & ecosystem account',
        ),
        const SizedBox(height: 18),

        // 1. User Account Card
        _buildUserAccountCard(context),
        const SizedBox(height: 16),

        // 2. Health Metrics & Smart Goal Calculator Card
        _buildHealthMetricsCard(context),
        const SizedBox(height: 16),

        // 3. 1-on-1 Synergy Partner Card
        _buildPartnerCard(context),
        const SizedBox(height: 16),

        // 4. Preferences & Settings Card
        _buildSettingsCard(context),
      ],
    );
  }

  Widget _buildUserAccountCard(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'AM',
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Obx(
                    () => Text(
                      controller.memberTier.value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsCard(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.monitor_weight_outlined,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Health Metrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Smart Goal Engine',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.weightKg.value.toInt()} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.heightCm.value.toInt()} cm',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity Level
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Level',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                  ],
                ),
                Obx(
                  () => Text(
                    controller.activityLevel.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dynamic Goal Result Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculated Daily Water Goal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          '${controller.calculatedDailyGoalMl} ml / day',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
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

  Widget _buildPartnerCard(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_alt_rounded,
                      color: AppColors.violet, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '1-on-1 Synergy Partner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '1-on-1 Only',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'JL',
                    style: TextStyle(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.partnerName.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.partnerStatus.value,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: AppColors.violet, size: 16),
                    const SizedBox(width: 4),
                    Obx(
                      () => Text(
                        '${controller.synergyStreakDays.value}d',
                        style: const TextStyle(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings & Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Hydration Push Reminders',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Timely alerts during your active hours',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: controller.hydrationRemindersEnabled.value,
            activeTrackColor: AppColors.primary,
            onChanged: (val) =>
                controller.hydrationRemindersEnabled.value = val,
          ),
          const Divider(color: AppColors.border),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '1-on-1 Partner Nudges',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Allow Jamie to send hydration alerts',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: controller.partnerNudgesEnabled.value,
            activeTrackColor: AppColors.violet,
            onChanged: (val) => controller.partnerNudgesEnabled.value = val,
          ),
        ],
      ),
    );
  }
}
