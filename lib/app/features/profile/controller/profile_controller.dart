import 'package:get/get.dart';
import 'package:the_builder_studio/app/core/base/base_controller.dart';

class ProfileController extends BaseController {
  // User Account
  final userName = 'Alex Morgan'.obs;
  final userEmail = 'alex.morgan@infinitywellness.io'.obs;
  final memberTier = 'Infinity Wellness Explorer'.obs;

  // Health Metrics
  final weightKg = 68.0.obs;
  final heightCm = 175.0.obs;
  final activityLevel = 'Moderate Active'.obs;
  final activityOptions = const [
    'Sedentary (Low)',
    'Light Active',
    'Moderate Active',
    'Very Active (Athletic)',
  ];

  // 1-on-1 Synergy Partner
  final partnerName = 'Jamie Lee'.obs;
  final partnerEmail = 'jamie.lee@infinitywellness.io'.obs;
  final partnerStatus = 'Active & Synced'.obs;
  final synergyStreakDays = 12.obs;

  // Notification Preferences
  final hydrationRemindersEnabled = true.obs;
  final partnerNudgesEnabled = true.obs;

  // Smart Dynamic Water Goal Calculation
  int get calculatedDailyGoalMl {
    final baseMl = weightKg.value * 35;
    int activityBonus = 0;
    if (activityLevel.value.contains('Moderate')) {
      activityBonus = 300;
    } else if (activityLevel.value.contains('Very')) {
      activityBonus = 600;
    } else if (activityLevel.value.contains('Light')) {
      activityBonus = 150;
    }
    return (baseMl + activityBonus).round();
  }

  void updateWeight(double newWeight) {
    weightKg.value = newWeight;
  }

  void updateHeight(double newHeight) {
    heightCm.value = newHeight;
  }

  void setActivityLevel(String level) {
    activityLevel.value = level;
  }
}
