import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';

class PartnerDetailController extends BaseController {
  late SynergyPartner partner;

  final partnerName = ''.obs;
  final partnerIntakeMl = 0.obs;
  final partnerGoalMl = 0.obs;
  final selectedThemeKey = 'love'.obs;

  final pastDays = <PartnerDayRecord>[].obs;
  final reminderLogs = <PartnerReminderLog>[].obs;
  final waterLogs = <PartnerWaterLog>[].obs;

  double get progress => (partnerGoalMl.value > 0)
      ? (partnerIntakeMl.value / partnerGoalMl.value).clamp(0.0, 1.0)
      : 0.0;
  int get percentage => (progress * 100).toInt();

  PartnerThemeOption get currentTheme =>
      PartnerThemes.getByKey(selectedThemeKey.value);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SynergyPartner) {
      partner = args;
      _loadPartnerData(partner);
    } else {
      // Fallback default partner
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      if (homeController != null && homeController.partners.isNotEmpty) {
        partner = homeController.partners.first;
      } else {
        partner = SynergyPartner(
          id: 'wifey',
          name: 'Wifey❤️',
          intakeMl: 2080,
          goalMl: 2600,
        );
      }
      _loadPartnerData(partner);
    }
  }

  void _loadPartnerData(SynergyPartner p) {
    partnerName.value = p.name;
    partnerIntakeMl.value = p.intakeMl;
    partnerGoalMl.value = p.goalMl;
    selectedThemeKey.value = p.themeKey.value;
    pastDays.assignAll(p.pastDays);
    reminderLogs.assignAll(p.reminders);
    waterLogs.assignAll(p.waterLogs);
  }

  void setTheme(String themeKey) {
    selectedThemeKey.value = themeKey;
    partner.themeKey.value = themeKey;
    final theme = PartnerThemes.getByKey(themeKey);

    Get.snackbar(
      'Theme Updated ✨',
      'Progress bar color set to ${theme.name} (${theme.description})',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: theme.accentColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  void sendNudge() {
    final now = DateTime.now();
    final timeFormatted =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final newReminder = PartnerReminderLog(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      timeStr: 'Today, $timeFormatted',
      message: 'Hydration reminder sent to ${partnerName.value} 💧',
      icon: Icons.water_drop_rounded,
    );

    reminderLogs.insert(0, newReminder);
    partner.reminders.insert(0, newReminder);

    Get.snackbar(
      'Nudge Sent! 💧',
      'Reminder sent to ${partnerName.value} to drink water!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }
}
