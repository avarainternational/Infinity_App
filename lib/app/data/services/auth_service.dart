import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final SupabaseService _supabaseService = SupabaseService.to;
  StreamSubscription<AuthState>? _authSubscription;

  // Reactive state
  final Rxn<User> currentUser = Rxn<User>();
  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final RxBool isAuthenticated = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString avatarUrl = ''.obs;

  final UserRepository _userRepository = UserRepositoryImpl();

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
      if (currentSession!.isExpired) {
        debugPrint('🔄 Access token expired on startup, refreshing session...');
        _supabaseService.client.auth.refreshSession().then((res) {
          if (res.user != null) {
            _updateUserState(res.user!);
          }
        }).catchError((e) {
          debugPrint('⚠️ Token refresh failed on startup (network offline): $e');
        });
      } else {
        _updateUserState(currentSession.user);
      }
    }

    // Subscribe to auth state changes
    _authSubscription = _supabaseService.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        debugPrint('🔔 Supabase Auth Event: $event');

        if (session?.user != null) {
          _updateUserState(session!.user);
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

  Future<void> _updateUserState(User user) async {
    currentUser.value = user;
    isAuthenticated.value = true;
    userEmail.value = user.email ?? '';

    // Extract metadata from Google OAuth
    final metadata = user.userMetadata;
    final fullName = metadata?['full_name'] ??
        metadata?['name'] ??
        (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Infinity User');
    final picture = metadata?['avatar_url'] ?? metadata?['picture'] ?? '';

    userName.value = fullName.toString();
    avatarUrl.value = picture.toString();

    // Fetch or initialize profile from PostgreSQL via UserRepository
    try {
      var profile = await _userRepository.getUserProfile(user.id);
      if (profile == null) {
        final newProfile = UserProfileModel(
          id: user.id,
          email: user.email ?? '',
          displayName: userName.value.isNotEmpty ? userName.value : 'Wellness Champion',
          avatarUrl: avatarUrl.value,
          weightKg: 68.0,
          heightCm: 175.0,
          activityLevel: 'Moderate Active (+300 ml)',
          dailyWaterGoalMl: 2700,
          inviteCode: UserProfileModel.generateInviteCode(userName.value),
          wellnessPointsBalance: 500,
          isOnboarded: false,
        );
        profile = await _userRepository.upsertProfile(newProfile);
      }
      userProfile.value = profile;
      if (profile.displayName.isNotEmpty) {
        userName.value = profile.displayName;
      }
      if (profile.avatarUrl.isNotEmpty) {
        avatarUrl.value = profile.avatarUrl;
      }

      // Check and award daily login / check-in points (+50 pts)
      await _checkAndAwardDailyLoginReward(user.id);

      if (!profile.isOnboarded) {
        if (Get.currentRoute != Routes.onboarding) {
          Get.offAllNamed(Routes.onboarding);
        }
      } else {
        if (Get.currentRoute == Routes.login || Get.currentRoute == Routes.onboarding) {
          Get.offAllNamed(Routes.shell);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading/creating user profile: $e');
    }
  }

  Future<void> _checkAndAwardDailyLoginReward(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final key = 'last_daily_login_reward_$userId';
      final lastRewardDate = prefs.getString(key);

      if (lastRewardDate != todayStr) {
        await prefs.setString(key, todayStr);
        final updated = await _userRepository.addWellnessPoints(userId, 50);
        if (updated != null) {
          userProfile.value = updated;
          if (Get.context != null) {
            Get.snackbar(
              'Daily Check-In Reward! 🌟',
              '+50 Wellness Points awarded for checking in today!',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF0284C7),
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(16),
              borderRadius: 14,
              icon: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 28),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error awarding daily login points: $e');
    }
  }

  void _clearUserState() {
    currentUser.value = null;
    userProfile.value = null;
    isAuthenticated.value = false;
    userName.value = '';
    userEmail.value = '';
    avatarUrl.value = '';
  }

  /// Signs in with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_supabaseService.isInitialized) {
      throw const AuthException(
        'Supabase is not configured yet. Please provide valid Supabase credentials in assets/config/supabase_config.local.json.',
      );
    }

    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        await _updateUserState(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Email Sign-In Error: $e');
      rethrow;
    }
  }

  /// Signs up with Email, Password, and initial Health Metrics
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    double weightKg = 68.0,
    double heightCm = 175.0,
    String activityLevel = 'Moderate Active',
  }) async {
    if (!_supabaseService.isInitialized) {
      throw const AuthException(
        'Supabase is not configured yet. Please provide valid Supabase credentials in assets/config/supabase_config.local.json.',
      );
    }

    try {
      final trimmedName = displayName.trim().isEmpty ? email.split('@').first : displayName.trim();

      final response = await _supabaseService.client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': trimmedName,
          'name': trimmedName,
        },
      );

      final user = response.user;
      if (user != null) {
        final goal = UserProfileModel.computeRecommendedGoal(
          weightKg: weightKg,
          activityLevel: activityLevel,
        );

        // Update health metrics in PostgreSQL profile
        try {
          await _userRepository.updateHealthMetrics(
            userId: user.id,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: activityLevel,
            dailyWaterGoalMl: goal,
          );
        } catch (e) {
          debugPrint('⚠️ Error saving initial health metrics during sign up: $e');
        }

        await _updateUserState(user);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Email Sign-Up Error: $e');
      rethrow;
    }
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
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
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

    try {
      if (_supabaseService.isInitialized) {
        await _supabaseService.client.auth.signOut(scope: SignOutScope.local);
      }
    } catch (e) {
      debugPrint('⚠️ Sign out warning: $e');
    }

    if (Get.currentRoute != Routes.login) {
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
