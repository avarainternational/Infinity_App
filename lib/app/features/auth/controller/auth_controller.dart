import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';

class AuthController extends BaseController {
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxString errorMessage = ''.obs;
  final RxBool isConnecting = false.obs;

  bool get isSupabaseConfigured => _supabaseService.config.isConfigured;

  /// Initiates Google OAuth Sign-In via Supabase
  Future<void> signInWithGoogle() async {
    if (isLoading.value || isConnecting.value) return;

    errorMessage.value = '';
    isLoading.value = true;
    isConnecting.value = true;

    try {
      if (!isSupabaseConfigured) {
        _showSnackbar(
          'Setup Required',
          'Supabase credentials not configured in assets/config/supabase_config.local.json.',
        );
        return;
      }

      await _authService.signInWithGoogle();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      _showSnackbar('Sign-In Notice', errorMessage.value);
    } finally {
      isLoading.value = false;
      isConnecting.value = false;
    }
  }

  void _showSnackbar(String title, String message) {
    if (Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
