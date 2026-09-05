import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_pages.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    Get.put<SupabaseService>(SupabaseService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('OnboardingSetupScreen renders all signup questions and dynamic goal preview', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Provide authenticated user profile needing onboarding
    AuthService.to.userName.value = 'Hlyan Paing';
    AuthService.to.userEmail.value = 'hlyan@infinitywellness.io';
    AuthService.to.isAuthenticated.value = true;
    AuthService.to.userProfile.value = const UserProfileModel(
      id: 'test-user-id-123',
      email: 'hlyan@infinitywellness.io',
      displayName: 'Hlyan Paing',
      isOnboarded: false,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.onboarding,
        getPages: AppPages.routes,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header & Sections
    expect(find.text('Welcome to Infinity Wellness'), findsOneWidget);
    expect(find.text('YOUR IDENTITY'), findsOneWidget);
    expect(find.text('HEALTH BIOMETRICS'), findsOneWidget);
    expect(find.text('CALIBRATED WATER GOAL'), findsOneWidget);
    expect(find.text('1-ON-1 FRIEND SYNERGY (OPTIONAL)'), findsOneWidget);

    // Verify Questions
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Body Weight'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('Daily Activity Level'), findsOneWidget);

    // Verify Gender Options
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Prefer not to say'), findsOneWidget);

    // Verify Dynamic Water Goal Calculation
    expect(find.text('ml / day'), findsOneWidget);

    // Verify Submit CTA Button
    expect(find.text('Launch Infinity Wellness'), findsOneWidget);

    // Tap Submit CTA
    await tester.tap(find.text('Launch Infinity Wellness'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
  });
}
