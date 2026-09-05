import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/repositories/hydration_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/hydration/model/hydration_models.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';

class HydrationDetailController extends BaseController {
  // Repositories & Services
  HydrationRepository get _hydrationRepository =>
      Get.isRegistered<HydrationRepository>() ? Get.find<HydrationRepository>() : HydrationRepositoryImpl();

  UserRepository get _userRepository =>
      Get.isRegistered<UserRepository>() ? Get.find<UserRepository>() : UserRepositoryImpl();

  AuthService? get _authService =>
      Get.isRegistered<AuthService>() ? AuthService.to : null;

  // Sync with HomeController if available
  HomeController? get _homeController =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  // Hydration Daily Metrics (Real data from Supabase)
  final currentWaterMl = 0.obs;
  final dailyGoalMl = 2600.obs;
  final selectedThemeKey = 'energetic'.obs;

  // Selected Beverage Type
  final selectedBeverage = BeverageTypes.pureWater.obs;

  // Streaks & Stats
  final personalStreakDays = 0.obs;
  final weeklyAdherencePercent = 0.obs;
  final averageDailyMl = 0.obs;

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

  // 7-Day History Records (Populated dynamically)
  final weeklyHistory = <DayIntakeRecord>[].obs;

  // Today's Intake Timeline (Populated dynamically from Supabase)
  final intakeLogs = <PersonalIntakeLog>[].obs;

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

    _loadHydrationData();
  }

  Future<void> _loadHydrationData() async {
    final userId = _authService?.currentUser.value?.id ?? '';
    if (userId.isNotEmpty) {
      try {
        final profile = await _userRepository.getUserProfile(userId);
        if (profile != null) {
          userWeightKg.value = profile.weightKg;
          userHeightCm.value = profile.heightCm;
          dailyGoalMl.value = profile.dailyWaterGoalMl;
        }

        final logs = await _hydrationRepository.getTodayLogs(userId);
        if (logs.isNotEmpty) {
          intakeLogs.assignAll(logs.map((l) {
            final now = l.loggedAt.toLocal();
            final timeFormatted =
                '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
            return PersonalIntakeLog(
              id: l.id,
              timeStr: timeFormatted,
              amountMl: l.amountMl,
              beverageType: l.beverageType,
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF00A3FF),
            );
          }).toList());
        } else {
          intakeLogs.clear();
        }

        final total = await _hydrationRepository.getTodayTotalMl(userId);
        currentWaterMl.value = total;
        _homeController?.currentWaterMl.value = total;

        // Load weekly history from repository strictly for the individual user
        final historyData = await _hydrationRepository.getWeeklyHistory(userId);
        final now = DateTime.now();
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        final historyList = <DayIntakeRecord>[];
        for (int i = 6; i >= 0; i--) {
          final dayDate = now.subtract(Duration(days: i));
          final key = DateTime(dayDate.year, dayDate.month, dayDate.day);
          final dayName = i == 0 ? 'Today' : (i == 1 ? 'Yesterday' : weekdays[dayDate.weekday - 1]);
          final dateStr = '${months[dayDate.month - 1]} ${dayDate.day}';
          final intake = historyData[key] ?? (i == 0 ? total : 0);
          historyList.add(DayIntakeRecord(
            dayLabel: dayName,
            dateStr: dateStr,
            intakeMl: intake,
            goalMl: dailyGoalMl.value,
            isReached: intake >= dailyGoalMl.value && intake > 0,
          ));
        }
        weeklyHistory.assignAll(historyList);
        if (dailyGoalMl.value > 0) {
          weeklyAdherencePercent.value = ((total / dailyGoalMl.value) * 100).clamp(0, 100).toInt();
        }
      } catch (e) {
        debugPrint('⚠️ Error loading hydration data: $e');
      }
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
    final prevWater = currentWaterMl.value;
    currentWaterMl.value += effectiveAmount;
    _homeController?.currentWaterMl.value = currentWaterMl.value;

    final earnedPts = (amountMl >= 500) ? 20 : 10;
    final reachedGoal = (currentWaterMl.value >= dailyGoalMl.value) && (prevWater < dailyGoalMl.value);
    final totalAwarded = reachedGoal ? (earnedPts + 100) : earnedPts;

    if (_homeController != null) {
      _homeController!.wellnessPoints.value += totalAwarded;
    }

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

    // Persist to Supabase
    final userId = _authService?.currentUser.value?.id ?? '';
    _hydrationRepository.logWaterIntake(
      userId: userId,
      amountMl: effectiveAmount,
      beverageType: selectedBeverage.value.name,
    );

    if (userId.isNotEmpty) {
      _userRepository.addWellnessPoints(userId, totalAwarded);
      if (_authService?.userProfile.value != null) {
        _authService!.userProfile.value = _authService!.userProfile.value!.copyWith(
          wellnessPointsBalance: _authService!.userProfile.value!.wellnessPointsBalance + totalAwarded,
        );
      }
    }

    if (reachedGoal) {
      Get.snackbar(
        'Daily Goal Reached! 🏆',
        '+$amountMl ml logged (+$earnedPts pts) + 100 Bonus Points! Today: ${currentWaterMl.value} / ${dailyGoalMl.value} ml',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF0284C7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
        icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 28),
      );
    } else {
      Get.snackbar(
        'Intake Logged! 💧',
        '+$amountMl ml recorded (+$earnedPts pts). Today: ${currentWaterMl.value} / ${dailyGoalMl.value} ml',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
        icon: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
      );
    }
  }

  void deleteLog(PersonalIntakeLog log) {
    intakeLogs.remove(log);
    currentWaterMl.value = (currentWaterMl.value - log.amountMl).clamp(0, 100000);
    _homeController?.currentWaterMl.value = currentWaterMl.value;

    final userId = _authService?.currentUser.value?.id ?? '';
    _hydrationRepository.deleteLog(logId: log.id, userId: userId);

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

    final userId = _authService?.currentUser.value?.id ?? '';
    if (userId.isNotEmpty) {
      _userRepository.updateHealthMetrics(
        userId: userId,
        weightKg: userWeightKg.value,
        heightCm: userHeightCm.value,
        activityLevel: activityLevel.value,
        dailyWaterGoalMl: newGoal,
      );
    }

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
