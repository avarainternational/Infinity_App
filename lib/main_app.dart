import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/constant/resources/app_theme.dart';
import 'package:infinity_wellness/app/constant/routing/app_pages.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/binding/initial_binding.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      appBuilder: (context) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppString.appName,
          builder: (context, child) {
            return ShadToaster(
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child,
              ),
            );
          },
          theme: AppTheme.lightTheme,
          initialRoute: Routes.splash,
          initialBinding: InitialBinding(),
          getPages: AppPages.routes,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(
          primary: AppColors.primaryDarkBlue,
        ),
        radius: BorderRadius.circular(16),
      ),
    );
  }
}
