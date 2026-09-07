import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_pages.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
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

  testWidgets('launches into Login screen, signs in, and verifies Super App navigation', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.login,
        getPages: AppPages.routes,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Google OAuth Login Screen elements exist on initial launch
    expect(find.text('Infinity Wellness'), findsOneWidget);
    expect(find.text('ချစ်ရသူတွေနဲ့'), findsOneWidget);
    expect(find.text('ဝေ မျှရင်းဂရုစိုက်လိုက်ပါ'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue in Demo Mode'), findsOneWidget);
    expect(find.text('By Infinity Water'), findsOneWidget);
    expect(find.text('ရေသန့်ထက်ပိုသောရေသန့်'), findsOneWidget);

    // Verify Google Sign In button is present and clickable
    final googleSignInButton = find.widgetWithText(ElevatedButton, 'Continue with Google');
    expect(googleSignInButton, findsOneWidget);

    // Enter the local prototype without depending on the owner's Supabase.
    await tester.tap(find.text('Continue in Demo Mode'));
    await tester.pumpAndSettle();

    // Verify 5 navigation tabs exist on home/shell launch
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Mini Apps'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Home snapshot elements
    expect(find.text('Hydration'), findsWidgets);
    expect(find.text('Friend Synergy'), findsWidgets);
    expect(find.text('Quick miniapps'), findsOneWidget);

    // Verify view details button in Hydration card
    expect(find.text('View details'), findsOneWidget);

    // Test central water droplet 2-second hold logging
    final dropletFinder = find.byKey(const Key('water_droplet_button'));
    expect(dropletFinder, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(dropletFinder));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.textContaining('250 /'), findsOneWidget);

    // Dismiss any snackbar
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Switch to Social tab
    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Social & Feed'), findsOneWidget);

    // Switch to Mini-Apps tab
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mini-App Store'), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Demo User'), findsOneWidget);

    // Scroll to Sign Out button
    await tester.ensureVisible(find.text('Sign Out'));
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out button to open confirmation dialog
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Are you sure you want to sign out of Infinity Wellness?'), findsOneWidget);

    // Trigger Sign Out
    await AuthService.to.signOut();
    await tester.pumpAndSettle();

    // Verify navigates back to Login Screen on Sign Out
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
