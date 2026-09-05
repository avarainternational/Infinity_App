import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';

class SplashBannerController extends BaseController {
  final countdown = 5.obs;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        _timer?.cancel();
        skip();
      }
    });
  }

  void skip() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _timer?.cancel();

    try {
      final supabase = Get.isRegistered<SupabaseService>() ? SupabaseService.to : null;
      final auth = Get.isRegistered<AuthService>() ? AuthService.to : null;

      final bool hasSession = (supabase?.isInitialized == true &&
              supabase?.client.auth.currentSession?.user != null) ||
          (auth?.isAuthenticated.value == true);

      if (hasSession) {
        Get.offAllNamed(Routes.shell);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('⚠️ Navigation error on splash skip: $e');
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
