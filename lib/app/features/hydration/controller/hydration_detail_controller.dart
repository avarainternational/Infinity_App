import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/hydration/model/hydration_models.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';

class HydrationDetailController extends BaseController {
  // Sync with HomeController if available
  HomeController? get _homeController =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  // Hydration Daily Metrics
  final currentWaterMl = 2100.obs;
  final dailyGoalMl = 2600.obs;
  final selectedThemeKey = 'energetic'.obs;

  // Selected Beverage Type
  final selectedBeverage = BeverageTypes.pureWater.obs;

  // Streaks & Stats
  final personalStreakDays = 7.obs;
  final weeklyAdherencePercent = 96.obs;
  final averageDailyMl = 2540.obs;

  // Smart Goal Calculator inputs
  final userWeightKg = 68.0.obs;
  final userHeightCm = 175.0.obs;
  final activityLevel = 'Moderate (+300 ml)'.obs;
  final isHotWeather = false.obs;

  // Reminder Settings
  final isRemindersEnabled = true.obs;
  final reminderIntervalMins = 90.obs;
  final reminderStartHour = '08:00 AM'.obs;
  final reminderEndHour = '10:00 PM'.obs;

  // 7-Day History Records
  final weeklyHistory = <DayIntakeRecord>[
    const DayIntakeRecord(
      dayLabel: 'Mon',
      dateStr: 'Aug 17',
      intakeMl: 2600,
      goalMl: 2600,
      isReached: true,
    ),
    const DayIntakeRecord(
      dayLabel: 'Tue',
      dateStr: 'Aug 18',
      intakeMl: 2750,
      goalMl: 2600,
      isReached: true,
    ),
    const DayIntakeRecord(
      dayLabel: 'Wed',
      dateStr: 'Aug 19',
      intakeMl: 2600,
      goalMl: 2600,
      isReached: true,
    ),
    const DayIntakeRecord(
      dayLabel: 'Thu',
      dateStr: 'Aug 20',
      intakeMl: 2800,
      goalMl: 2600,
      isReached: true,
    ),
    const DayIntakeRecord(
      dayLabel: 'Fri',
      dateStr: 'Aug 21',
      intakeMl: 2650,
      goalMl: 2600,
      isReached: true,
    ),
    const DayIntakeRecord(
      dayLabel: 'Sat',
      dateStr: 'Aug 22',
      intakeMl: 2100,
      goalMl: 2600,
      isReached: false,
    ),
  ].obs;

  // Today's Intake Timeline
  final intakeLogs = <PersonalIntakeLog>[
    const PersonalIntakeLog(
      id: 'log-1',
      timeStr: '4:45 PM',
      amountMl: 350,
      beverageType: 'Electrolytes',
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFF10B981),
    ),
    const PersonalIntakeLog(
      id: 'log-2',
      timeStr: '2:15 PM',
      amountMl: 500,
      beverageType: 'Pure Water',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF00A3FF),
    ),
    const PersonalIntakeLog(
      id: 'log-3',
      timeStr: '11:30 AM',
      amountMl: 450,
      beverageType: 'Mineral Water',
      icon: Icons.local_drink_rounded,
      iconColor: Color(0xFF06B6D4),
    ),
    const PersonalIntakeLog(
      id: 'log-4',
      timeStr: '8:30 AM',
      amountMl: 500,
      beverageType: 'Herbal Tea',
      icon: Icons.emoji_food_beverage_rounded,
      iconColor: Color(0xFF8B5CF6),
    ),
    const PersonalIntakeLog(
      id: 'log-5',
      timeStr: '7:15 AM',
      amountMl: 300,
      beverageType: 'Pure Water',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF00A3FF),
    ),
  ].obs;

  double get progress => (dailyGoalMl.value > 0)
      ? (currentWaterMl.value / dailyGoalMl.value).clamp(0.0, 1.0)
      : 0.0;
  int get percentage => (progress * 100).toInt();

  PartnerThemeOption get currentTheme =>
      PartnerThemes.getByKey(selectedThemeKey.value);

  int get calculatedRecommendedGoal {
    // Standard formula: Weight (kg) * 35 ml + activity boost + weather boost
    int base = (userWeightKg.value * 35).round();
    if (activityLevel.value.contains('+300')) {
      base += 300;
    } else if (activityLevel.value.contains('+600')) {
      base += 600;
    }
    if (isHotWeather.value) {
      base += 250;
    }
    // Round to nearest 50 ml
    return ((base + 25) ~/ 50) * 50;
  }

  @override
  void onInit() {
    super.onInit();
    final home = _homeController;
    if (home != null) {
      currentWaterMl.value = home.currentWaterMl.value;
      dailyGoalMl.value = home.dailyGoalMl.value;
      selectedThemeKey.value = home.userThemeKey.value;
      personalStreakDays.value = home.personalStreakDays.value;
    }
  }

  void setTheme(String themeKey) {
    selectedThemeKey.value = themeKey;
    _homeController?.userThemeKey.value = themeKey;
    final theme = PartnerThemes.getByKey(themeKey);

    Get.snackbar(
      'Theme Updated ✨',
      'Personal hydration theme set to ${theme.name}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: theme.accentColor.withValues(alpha: 0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  void logIntake(int amountMl) {
    final effectiveAmount =
        (amountMl * selectedBeverage.value.hydrationFactor).round();
    currentWaterMl.value += effectiveAmount;
    _homeController?.currentWaterMl.value = currentWaterMl.value;

    final now = DateTime.now();
    final timeFormatted =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final newLog = PersonalIntakeLog(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      timeStr: timeFormatted,
      amountMl: amountMl,
      beverageType: selectedBeverage.value.name,
      icon: selectedBeverage.value.icon,
      iconColor: selectedBeverage.value.color,
    );

    intakeLogs.insert(0, newLog);

    Get.snackbar(
      'Intake Logged! 💧',
      '+$amountMl ml (${selectedBeverage.value.name}) recorded. Today: ${currentWaterMl.value} / ${dailyGoalMl.value} ml',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  void deleteLog(PersonalIntakeLog log) {
    intakeLogs.remove(log);
    currentWaterMl.value = (currentWaterMl.value - log.amountMl).clamp(0, 100000);
    _homeController?.currentWaterMl.value = currentWaterMl.value;

    Get.snackbar(
      'Log Removed',
      '-${log.amountMl} ml removed from today\'s total.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void applyCalculatedGoal() {
    final newGoal = calculatedRecommendedGoal;
    dailyGoalMl.value = newGoal;
    _homeController?.dailyGoalMl.value = newGoal;

    Get.snackbar(
      'Daily Goal Updated 🎯',
      'Recommended daily goal set to $newGoal ml based on your health metrics.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  void toggleReminders(bool value) {
    isRemindersEnabled.value = value;
    Get.snackbar(
      value ? 'Reminders Activated 🔔' : 'Reminders Paused 🔕',
      value
          ? 'Automated alerts set for every ${reminderIntervalMins.value} mins ($reminderStartHour - $reminderEndHour).'
          : 'Hydration push reminders paused.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
