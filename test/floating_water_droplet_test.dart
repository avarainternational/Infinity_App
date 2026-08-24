import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/widget/floating_water_droplet.dart';
import 'package:infinity_wellness/app/widget/whole_screen_bubble_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('FloatingWaterDroplet Widget Tests', () {
    testWidgets('renders floating water droplet and hold tooltip when enabled', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingWaterDroplet(
                amountMl: 250,
                showTooltip: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify widget and tooltip exist
      expect(find.byType(FloatingWaterDroplet), findsOneWidget);
      expect(find.text('Hold 2s to log'), findsOneWidget);
    });

    testWidgets('triggers onTap callback on quick tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool tapped = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingWaterDroplet(
                amountMl: 250,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('water_droplet_button'))),
      );
      // Quick tap < 350ms
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('cancels water logging when released before 2 seconds', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int loggedAmount = 0;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingWaterDroplet(
                amountMl: 250,
                onWaterLogged: (amt) => loggedAmount += amt,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('water_droplet_button'))),
      );
      // Hold for 800ms (less than 2000ms)
      await tester.pump(const Duration(milliseconds: 800));
      await gesture.up();
      await tester.pumpAndSettle();

      // Must not have logged water
      expect(loggedAmount, equals(0));
    });

    testWidgets('shows whole screen bubble overlay when holding water log button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingWaterDroplet(
                amountMl: 250,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Before holding, no bubble overlay
      expect(find.byType(WholeScreenBubbleOverlayWidget), findsNothing);

      // Start holding
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('water_droplet_button'))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Overlay should now be active
      expect(find.byType(WholeScreenBubbleOverlayWidget), findsOneWidget);

      // Release hold
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('logs water after holding for full 2 seconds with filling animation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int loggedWater = 0;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingWaterDroplet(
                amountMl: 250,
                onWaterLogged: (amt) => loggedWater += amt,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('water_droplet_button'))),
      );
      // Process pointer down
      await tester.pump();

      // Hold for full 2.1 seconds (500 + 500 + 500 + 600 = 2100ms > 2000ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify water was logged
      expect(loggedWater, equals(250));

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 1000));
    });
  });
}
