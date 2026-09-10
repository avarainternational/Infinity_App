import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/services/notification_service.dart';
import 'package:infinity_wellness/app/features/hydration/controller/hydration_detail_controller.dart';
import 'package:infinity_wellness/app/features/profile/controller/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('Biometric Hydration Goal Calculation Tests', () {
    test('computes recommended goal correctly based on weight, height, age, gender, and activity', () {
      // Case 1: 70kg, 175cm, 22yo, Male, Moderate Active
      // Base: 70 * 35 = 2450
      // Height: (175 - 160)/10 = 1.5 -> round = 2 -> +100
      // Age: 22 (<=30) -> +100
      // Gender: Male -> +200
      // Activity: Moderate -> +300
      // Total: 2450 + 100 + 100 + 200 + 300 = 3150 ml
      final goal1 = UserProfileModel.computeRecommendedGoal(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 22,
        gender: 'Male',
        activityLevel: 'Moderate Active (+300 ml)',
      );
      expect(goal1, equals(3150));

      // Case 2: 55kg, 160cm, 25yo, Female, Light Active
      // Base: 55 * 35 = 1925
      // Height: 160cm -> 0 extra
      // Age: 25 -> +100
      // Gender: Female -> 0 extra
      // Activity: Light -> +150
      // Total: 1925 + 100 + 150 = 2175 -> round to nearest 50 = 2200 ml
      final goal2 = UserProfileModel.computeRecommendedGoal(
        weightKg: 55.0,
        heightCm: 160.0,
        age: 25,
        gender: 'Female',
        activityLevel: 'Light Active (+150 ml)',
      );
      expect(goal2, equals(2200));

      // Case 3: 85kg, 185cm, 28yo, Male, Athletic, Hot Weather
      // Base: 85 * 35 = 2975
      // Height: (185 - 160)/10 = 2.5 -> round = 3 -> +150
      // Age: 28 -> +100
      // Gender: Male -> +200
      // Activity: Athletic -> +600
      // Hot weather: +250
      // Total: 2975 + 150 + 100 + 200 + 600 + 250 = 4275 -> round to nearest 50 = 4300 ml
      final goal3 = UserProfileModel.computeRecommendedGoal(
        weightKg: 85.0,
        heightCm: 185.0,
        age: 28,
        gender: 'Male',
        activityLevel: 'Very Active / Athletic (+600 ml)',
        isHotWeather: true,
      );
      expect(goal3, equals(4300));
    });

    test('respects safe boundary clamps (1500 ml minimum, 5000 ml maximum)', () {
      // Extremely low weight clamp
      final minGoal = UserProfileModel.computeRecommendedGoal(
        weightKg: 30.0,
        heightCm: 140.0,
        age: 40,
        gender: 'Female',
        activityLevel: 'Sedentary',
      );
      expect(minGoal, equals(1500));

      // Extremely high weight clamp
      final maxGoal = UserProfileModel.computeRecommendedGoal(
        weightKg: 180.0,
        heightCm: 210.0,
        age: 25,
        gender: 'Male',
        activityLevel: 'Very Active / Athletic (+600 ml)',
        isHotWeather: true,
      );
      expect(maxGoal, equals(5000));
    });
  });

  group('Daily Water Goal Customization Tests', () {
    test('updates daily water goal and caches to SharedPreferences in HydrationDetailController', () async {
      SharedPreferences.setMockInitialValues({'pref_user_daily_water_goal_ml': 2600});

      final controller = HydrationDetailController();
      expect(controller.dailyGoalMl.value, equals(2600));

      // Change goal to 3200 ml
      await controller.updateDailyGoal(3200);
      expect(controller.dailyGoalMl.value, equals(3200));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_user_daily_water_goal_ml'), equals(3200));
    });

    test('updates daily water goal in ProfileController and clamps safely', () async {
      final profileController = ProfileController();

      await profileController.updateDailyGoal(3500);
      expect(profileController.customDailyGoalMl.value, equals(3500));

      // Test clamp under 1000
      await profileController.updateDailyGoal(500);
      expect(profileController.customDailyGoalMl.value, equals(1000));

      // Test clamp over 6000
      await profileController.updateDailyGoal(8000);
      expect(profileController.customDailyGoalMl.value, equals(6000));
    });
  });

  group('1 Sip Amount Customization Tests', () {
    test('defaults sip amount to 250 ml and allows customization', () async {
      final controller = HydrationDetailController();
      expect(controller.sipAmountMl.value, equals(250));

      // Change sip to 350 ml (tumbler)
      await controller.updateSipAmount(350);
      expect(controller.sipAmountMl.value, equals(350));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_user_sip_amount_ml'), equals(350));
    });

    test('ProfileController updates sip amount and syncs', () async {
      final profileController = ProfileController();
      expect(profileController.sipAmountMl.value, equals(250));

      await profileController.updateSipAmount(500);
      expect(profileController.sipAmountMl.value, equals(500));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_user_sip_amount_ml'), equals(500));
    });
  });

  group('Notification System Tests', () {
    test('initializes and manages hydration reminder settings', () async {
      SharedPreferences.setMockInitialValues({
        'pref_hydration_reminders_enabled': true,
        'pref_hydration_reminder_interval': 90,
      });

      final notif = NotificationService();
      await notif.init();

      expect(notif.areRemindersEnabled.value, isTrue);
      expect(notif.reminderIntervalMins.value, equals(90));

      // Toggle off
      await notif.setRemindersEnabled(false);
      expect(notif.areRemindersEnabled.value, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_hydration_reminders_enabled'), isFalse);

      // Toggle back on
      await notif.setRemindersEnabled(true);
      expect(notif.areRemindersEnabled.value, isTrue);
      expect(prefs.getBool('pref_hydration_reminders_enabled'), isTrue);
    });

    test('sends instant notification without throwing exception', () async {
      final notif = NotificationService();
      await notif.init();

      expect(
        () async => await notif.showInstantNotification(
          title: 'Test Title',
          body: 'Test Body',
        ),
        returnsNormally,
      );
    });
  });
}
