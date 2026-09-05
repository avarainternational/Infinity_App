import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';

class OnboardingSetupController extends BaseController {
  OnboardingSetupController({
    UserRepository? userRepository,
    SynergyRepository? synergyRepository,
  })  : _userRepository = userRepository ?? UserRepositoryImpl(),
        _synergyRepository = synergyRepository ?? SynergyRepositoryImpl();

  final UserRepository _userRepository;
  final SynergyRepository _synergyRepository;

  AuthService get _authService => AuthService.to;

  // Controllers & Form State
  late final TextEditingController nameController;
  final partnerCodeController = TextEditingController();

  final selectedGender = 'Prefer not to say'.obs;
  final genderOptions = const [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final age = 22.obs;
  final weightKg = 68.0.obs;
  final heightCm = 175.0.obs;

  final selectedActivity = 'Moderate Active (+300 ml)'.obs;
  final activityOptions = const [
    'Sedentary (Base)',
    'Light Active (+150 ml)',
    'Moderate Active (+300 ml)',
    'Very Active / Athletic (+600 ml)',
  ];

  final isSaving = false.obs;

  int get calculatedGoalMl => UserProfileModel.computeRecommendedGoal(
        weightKg: weightKg.value,
        activityLevel: selectedActivity.value,
      );

  @override
  void onInit() {
    super.onInit();
    final currentName = _authService.userName.value.isNotEmpty
        ? _authService.userName.value
        : 'Wellness Champion';
    nameController = TextEditingController(text: currentName);

    // If profile has existing metrics, initialize them
    final existing = _authService.userProfile.value;
    if (existing != null) {
      if (existing.displayName.isNotEmpty) nameController.text = existing.displayName;
      if (existing.gender.isNotEmpty) selectedGender.value = existing.gender;
      if (existing.age > 0) age.value = existing.age;
      if (existing.weightKg > 0) weightKg.value = existing.weightKg;
      if (existing.heightCm > 0) heightCm.value = existing.heightCm;
      if (existing.activityLevel.isNotEmpty) {
        final match = activityOptions.firstWhereOrNull((a) => a.contains(existing.activityLevel.split(' ').first));
        if (match != null) selectedActivity.value = match;
      }
    }
  }

  Future<void> completeOnboarding() async {
    final user = _authService.currentUser.value;
    final userId = user?.id ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User session not found. Please log in again.');
      Get.offAllNamed(Routes.login);
      return;
    }

    final trimmedName = nameController.text.trim().isEmpty
        ? (_authService.userName.value.isNotEmpty ? _authService.userName.value : 'Infinity Member')
        : nameController.text.trim();

    isSaving.value = true;

    try {
      final existing = _authService.userProfile.value;
      final inviteCode = (existing?.inviteCode.isNotEmpty == true)
          ? existing!.inviteCode
          : UserProfileModel.generateInviteCode(trimmedName);

      final updatedProfile = UserProfileModel(
        id: userId,
        email: user?.email ?? '',
        displayName: trimmedName,
        avatarUrl: _authService.avatarUrl.value,
        gender: selectedGender.value,
        age: age.value,
        weightKg: weightKg.value,
        heightCm: heightCm.value,
        activityLevel: selectedActivity.value,
        dailyWaterGoalMl: calculatedGoalMl,
        wellnessPointsBalance: existing?.wellnessPointsBalance ?? 500,
        inviteCode: inviteCode,
        currentStreak: existing?.currentStreak ?? 0,
        isOnboarded: true,
        updatedAt: DateTime.now(),
      );

      // Save to Supabase
      final saved = await _userRepository.upsertProfile(updatedProfile);
      _authService.userProfile.value = saved;
      _authService.userName.value = saved.displayName;

      // Optional partner pairing
      final partnerCode = partnerCodeController.text.trim();
      if (partnerCode.isNotEmpty) {
        try {
          await _synergyRepository.connectPartnerWithCode(
            currentUserId: userId,
            inviteCode: partnerCode,
          );
        } catch (e) {
          debugPrint('⚠️ Optional partner pairing notice: $e');
        }
      }

      Get.offAllNamed(Routes.shell);
      Get.snackbar(
        'Welcome to Infinity Wellness! 💧',
        'Your profile has been calibrated with a $calculatedGoalMl ml daily hydration target.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF00A3FF).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('❌ Error completing onboarding: $e');
      Get.snackbar(
        'Setup Error',
        'Could not save your preferences. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    partnerCodeController.dispose();
    super.onClose();
  }
}
