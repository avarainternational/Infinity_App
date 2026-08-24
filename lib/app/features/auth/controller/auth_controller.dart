import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';

class AuthController extends BaseController {
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;

  final RxString errorMessage = ''.obs;

  bool get isSupabaseConfigured => _supabaseService.config.isConfigured;

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;

    errorMessage.value = '';
    isLoading.value = true;

    try {
      if (!isSupabaseConfigured) {
        _showConfigNotice();
        isLoading.value = false;
        return;
      }

      await _authService.signInWithGoogle();
      // Browser OAuth initiated; stream listener in AuthService handles successful redirect
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      Get.snackbar(
        'Sign-in Notice',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showConfigNotice() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Supabase Setup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To connect live Google OAuth:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '1. Add your Supabase URL & Anon Key to:\n   assets/config/supabase_config.local.json\n\n'
              '2. Enable Google Provider in Supabase Auth Dashboard.\n\n'
              'You can continue in Explorer Mode to test the app UI immediately.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              // Demo / Explorer sign-in
              _authService.userName.value = 'Alex Morgan';
              _authService.userEmail.value = 'alex.morgan@infinitywellness.io';
              _authService.isAuthenticated.value = true;
              Get.offAllNamed(Routes.shell);
            },
            child: const Text('Enter Explorer Mode'),
          ),
        ],
      ),
    );
  }
}
