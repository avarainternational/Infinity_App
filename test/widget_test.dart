import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/main_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final supabaseService = SupabaseService();
    await supabaseService.init();
    Get.put<SupabaseService>(supabaseService, permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('launches directly into Super App shell and verifies navigation', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify 5 navigation tabs exist on home/shell launch
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Mini Apps'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Home snapshot elements
    expect(find.text('Hydration Meter'), findsOneWidget);
    expect(find.text('Partners'), findsOneWidget);
    expect(find.text('Quick miniapps'), findsOneWidget);

    // Verify view details button in Hydration card
    expect(find.text('view details'), findsOneWidget);

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

    expect(find.text('2350 / 2600 ml'), findsOneWidget);

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
    expect(find.text('Alex Morgan'), findsOneWidget);

    // Scroll to Sign Out button
    await tester.ensureVisible(find.text('Sign Out'));
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out button
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Confirmation dialog
    expect(find.text('Are you sure you want to sign out of Infinity Wellness?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
    await tester.pumpAndSettle();

    // Verify navigates to Login Screen on Sign Out
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
