import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final SupabaseService _supabaseService = SupabaseService.to;
  StreamSubscription<AuthState>? _authSubscription;

  // Reactive state
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isAuthenticated = false.obs;
  final RxString userName = 'Alex Morgan'.obs;
  final RxString userEmail = 'alex.morgan@infinitywellness.io'.obs;
  final RxString avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuthState();
  }

  void _initAuthState() {
    if (!_supabaseService.isInitialized) {
      return;
    }

    // Check current session
    final currentSession = _supabaseService.client.auth.currentSession;
    if (currentSession?.user != null) {
      _updateUserState(currentSession!.user);
    }

    // Subscribe to auth state changes
    _authSubscription = _supabaseService.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        debugPrint('🔔 Supabase Auth Event: $event');

        if (session?.user != null) {
          _updateUserState(session!.user);
          if (Get.currentRoute == Routes.login) {
            Get.offAllNamed(Routes.shell);
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _clearUserState();
          if (Get.currentRoute != Routes.login && Get.currentRoute.isNotEmpty) {
            Get.offAllNamed(Routes.login);
          }
        }
      },
      onError: (error) {
        debugPrint('❌ Supabase Auth Subscription Error: $error');
      },
    );
  }

  void _updateUserState(User user) {
    currentUser.value = user;
    isAuthenticated.value = true;
    userEmail.value = user.email ?? '';

    // Extract metadata from Google OAuth
    final metadata = user.userMetadata;
    final fullName = metadata?['full_name'] ?? metadata?['name'] ?? user.email?.split('@').first ?? 'Alex Morgan';
    final picture = metadata?['avatar_url'] ?? metadata?['picture'] ?? '';

    userName.value = fullName.toString();
    avatarUrl.value = picture.toString();
  }

  void _clearUserState() {
    currentUser.value = null;
    isAuthenticated.value = false;
    userName.value = '';
    userEmail.value = '';
    avatarUrl.value = '';
  }

  /// Initiates Google OAuth Sign-In via Supabase
  Future<bool> signInWithGoogle() async {
    if (!_supabaseService.isInitialized) {
      throw const AuthException(
        'Supabase is not configured yet. Please provide valid Supabase credentials in assets/config/supabase_config.local.json.',
      );
    }

    try {
      final redirectUrl = _supabaseService.config.redirectUrl;
      final response = await _supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl.isNotEmpty ? redirectUrl : null,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      return response;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    _clearUserState();
    if (Get.currentRoute != Routes.login) {
      Get.offAllNamed(Routes.login);
    }

    try {
      if (_supabaseService.isInitialized) {
        await _supabaseService.client.auth.signOut(scope: SignOutScope.local);
      }
    } catch (e) {
      debugPrint('⚠️ Sign out warning: $e');
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
