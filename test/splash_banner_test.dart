import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/features/splash/controller/splash_banner_controller.dart';
import 'package:infinity_wellness/app/features/splash/screen/splash_banner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  group('SplashBannerScreen Widget Tests', () {
    testWidgets('renders splash banner screen with skip button and countdown',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = Get.put(SplashBannerController());

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: Routes.splash,
          getPages: [
            GetPage(
              name: Routes.splash,
              page: () => const SplashBannerScreen(),
            ),
            GetPage(
              name: Routes.login,
              page: () => const Scaffold(body: Text('Login Screen Test')),
            ),
          ],
        ),
      );
      await tester.pump();

      // Verify Skip button exists with countdown
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('${controller.countdown.value}s'), findsOneWidget);

      // Verify tapping Skip triggers navigation
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Test'), findsOneWidget);
    });

    testWidgets('auto-skips after countdown expires', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(SplashBannerController());

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: Routes.splash,
          getPages: [
            GetPage(
              name: Routes.splash,
              page: () => const SplashBannerScreen(),
            ),
            GetPage(
              name: Routes.login,
              page: () => const Scaffold(body: Text('Login Screen Test')),
            ),
          ],
        ),
      );
      await tester.pump();

      // Advance clock by 6 seconds for 5s countdown
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Test'), findsOneWidget);
    });
  });
}
