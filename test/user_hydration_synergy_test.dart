import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/repositories/hydration_repository.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/app/features/auth/controller/auth_controller.dart';
import 'package:infinity_wellness/app/features/partner/controller/partner_detail_controller.dart';
import 'package:infinity_wellness/app/features/profile/controller/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('UserProfileModel & Smart Water Goal Calculation', () {
    test('computes recommended water goal accurately for sedentary, moderate, and athletic', () {
      // 68kg * 35 = 2380
      // Sedentary (0 bonus) -> 2380 -> 2400 ml
      final sedentaryGoal = UserProfileModel.computeRecommendedGoal(
        weightKg: 68.0,
        activityLevel: 'Sedentary (Low)',
      );
      expect(sedentaryGoal, equals(2400));

      // Moderate (+300 bonus) -> 2680 -> 2700 ml
      final moderateGoal = UserProfileModel.computeRecommendedGoal(
        weightKg: 68.0,
        activityLevel: 'Moderate Active',
      );
      expect(moderateGoal, equals(2700));

      // Athletic (+600 bonus + 250 hot weather) -> 3230 -> 3250 ml
      final athleticGoal = UserProfileModel.computeRecommendedGoal(
        weightKg: 68.0,
        activityLevel: 'Very Active (Athletic)',
        isHotWeather: true,
      );
      expect(athleticGoal, equals(3250));
    });

    test('serializes and deserializes UserProfileModel to/from JSON', () {
      const profile = UserProfileModel(
        id: 'usr-123',
        email: 'alex@infinitywellness.io',
        displayName: 'Alex Morgan',
        weightKg: 70.0,
        heightCm: 180.0,
        activityLevel: 'Moderate Active',
        dailyWaterGoalMl: 2750,
        wellnessPointsBalance: 250,
        inviteCode: 'INF789',
      );

      final json = profile.toJson();
      expect(json['id'], equals('usr-123'));
      expect(json['email'], equals('alex@infinitywellness.io'));
      expect(json['invite_code'], equals('INF789'));

      final restored = UserProfileModel.fromJson(json);
      expect(restored.id, equals(profile.id));
      expect(restored.dailyWaterGoalMl, equals(2750));
      expect(restored.inviteCode, equals('INF789'));
    });
  });

  group('HydrationRepository Intake Logging & Aggregation', () {
    test('logs water intake and aggregates daily total', () async {
      final repository = HydrationRepositoryImpl();
      const testUserId = 'test-user-uuid';

      final log1 = await repository.logWaterIntake(
        userId: testUserId,
        amountMl: 500,
        beverageType: 'Pure Water',
      );
      expect(log1.amountMl, equals(500));

      final log2 = await repository.logWaterIntake(
        userId: testUserId,
        amountMl: 350,
        beverageType: 'Electrolytes',
      );
      expect(log2.amountMl, equals(350));

      final todayLogs = await repository.getTodayLogs(testUserId);
      expect(todayLogs.length, equals(2));

      final total = await repository.getTodayTotalMl(testUserId);
      expect(total, equals(850));

      // Delete a log
      await repository.deleteLog(logId: log1.id, userId: testUserId);
      final remaining = await repository.getTodayLogs(testUserId);
      expect(remaining.length, equals(1));
    });

    test('strictly isolates hydration logs per individual user', () async {
      final repository = HydrationRepositoryImpl();
      const userA = 'user-a-111';
      const userB = 'user-b-222';

      await repository.logWaterIntake(userId: userA, amountMl: 500);
      await repository.logWaterIntake(userId: userB, amountMl: 750);

      final logsA = await repository.getTodayLogs(userA);
      final logsB = await repository.getTodayLogs(userB);

      expect(logsA.length, equals(1));
      expect(logsA.first.amountMl, equals(500));
      expect(logsA.first.userId, equals(userA));

      expect(logsB.length, equals(1));
      expect(logsB.first.amountMl, equals(750));
      expect(logsB.first.userId, equals(userB));

      expect(await repository.getTodayTotalMl(userA), equals(500));
      expect(await repository.getTodayTotalMl(userB), equals(750));
      expect(await repository.getTodayTotalMl(''), equals(0));
    });

    test('restarts hydration logs cleanly for every day', () async {
      final repository = HydrationRepositoryImpl();
      const user = 'daily-test-user';
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Log intake for yesterday
      await repository.logWaterIntake(
        userId: user,
        amountMl: 1200,
        loggedAt: yesterday,
      );

      // Today should start at 0
      expect(await repository.getTodayTotalMl(user), equals(0));
      expect((await repository.getTodayLogs(user)).length, equals(0));

      // Yesterday should show 1200 ml
      expect(await repository.getTotalMlForDate(user, yesterday), equals(1200));

      // Log intake for today
      await repository.logWaterIntake(
        userId: user,
        amountMl: 600,
        loggedAt: now,
      );

      // Today should show 600 ml and yesterday still 1200 ml
      expect(await repository.getTodayTotalMl(user), equals(600));
      expect(await repository.getTotalMlForDate(user, yesterday), equals(1200));
    });
  });

  group('SynergyRepository 1-on-1 Partner Pairing & Mutual Nudges', () {
    test('connects partner with invite code and ensures strictly 1-on-1', () async {
      final userRepo = UserRepositoryImpl();
      await userRepo.upsertProfile(const UserProfileModel(
        id: 'partner-jamie-uuid',
        email: 'jamie.lee@infinitywellness.io',
        displayName: 'Jamie Lee',
        inviteCode: 'JAMIE1',
        isOnboarded: true,
      ));

      final repository = SynergyRepositoryImpl(userRepository: userRepo);
      const currentUserId = 'alex-user-uuid';

      final pair = await repository.connectPartnerWithCode(
        currentUserId: currentUserId,
        inviteCode: 'JAMIE1',
      );

      expect(pair.isActive, isTrue);
      expect(pair.partnerProfile?.displayName, contains('Jamie Lee'));
      expect(pair.streakCount, greaterThanOrEqualTo(1));

      // Sending mutual nudge
      final nudge = await repository.sendNudge(
        senderId: currentUserId,
        receiverId: pair.partnerProfile!.id,
        nudgeType: SynergyNudgeType.hydrate,
        message: '💧 Time to drink water, partner!',
      );

      expect(nudge.nudgeType, equals(SynergyNudgeType.hydrate));
      expect(nudge.message, contains('Time to drink water'));

      final recentNudges = await repository.getRecentNudges(currentUserId);
      expect(recentNudges.any((n) => n.id == nudge.id), isTrue);
    });

    test('prevents self-pairing with own invite code', () async {
      final userRepo = UserRepositoryImpl();
      await userRepo.upsertProfile(const UserProfileModel(
        id: 'partner-jamie-uuid',
        email: 'jamie.lee@infinitywellness.io',
        displayName: 'Jamie Lee',
        inviteCode: 'JAMIE1',
        isOnboarded: true,
      ));

      final repository = SynergyRepositoryImpl(userRepository: userRepo);
      expect(
        () => repository.connectPartnerWithCode(
          currentUserId: 'partner-jamie-uuid',
          inviteCode: 'JAMIE1',
        ),
        throwsException,
      );
    });

    test('pairs successfully with lowercase invite code and queries partner intake', () async {
      final userRepo = UserRepositoryImpl();
      await userRepo.upsertProfile(const UserProfileModel(
        id: 'partner-bob-uuid',
        email: 'bob@infinitywellness.io',
        displayName: 'Bob Taylor',
        inviteCode: 'BOB123',
        isOnboarded: true,
      ));

      final hydrationRepo = HydrationRepositoryImpl();
      await hydrationRepo.logWaterIntake(userId: 'partner-bob-uuid', amountMl: 750);

      final repository = SynergyRepositoryImpl(
        userRepository: userRepo,
        hydrationRepository: hydrationRepo,
      );

      final pair = await repository.connectPartnerWithCode(
        currentUserId: 'alice-user-uuid',
        inviteCode: 'bob123', // lowercase input
      );

      expect(pair.partnerProfile?.displayName, equals('Bob Taylor'));
      expect(pair.partnerTodayIntakeMl, equals(750));
      expect(await repository.getPartnerTodayIntake('partner-bob-uuid'), equals(750));
    });
  });

  group('ProfileController & PartnerDetailController Reactive States', () {
    test('ProfileController updates health metrics and calculates daily goal', () async {
      Get.put<UserRepository>(UserRepositoryImpl());
      Get.put<SynergyRepository>(SynergyRepositoryImpl());
      final controller = Get.put(ProfileController());

      expect(controller.weightKg.value, equals(68.0));
      expect(controller.calculatedDailyGoalMl, equals(2680));

      controller.updateWeight(75.0);
      expect(controller.weightKg.value, equals(75.0));
      expect(controller.calculatedDailyGoalMl, equals(2925));
    });

    test('PartnerDetailController sends nudges and updates reminder timeline', () async {
      Get.put<SynergyRepository>(SynergyRepositoryImpl());
      final controller = Get.put(PartnerDetailController());

      final initialRemindersCount = controller.reminderLogs.length;
      await controller.sendNudge(
        type: SynergyNudgeType.screenBreak,
        customMessage: '👀 Time for a 5-minute break!',
      );

      expect(controller.reminderLogs.length, equals(initialRemindersCount + 1));
      expect(controller.reminderLogs.first.message, contains('5-minute break'));
    });

    test('AuthController manages reactive loading and configuration states', () {
      final supabaseService = SupabaseService();
      Get.put<SupabaseService>(supabaseService);
      Get.put<AuthService>(AuthService());
      final authController = Get.put(AuthController());

      expect(authController.isLoading.value, isFalse);
      expect(authController.isConnecting.value, isFalse);
      expect(authController.errorMessage.value, isEmpty);
    });
  });
}
