import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerDetailController extends BaseController {
  late SynergyPartner partner;

  SynergyRepository get _synergyRepository =>
      Get.isRegistered<SynergyRepository>() ? Get.find<SynergyRepository>() : SynergyRepositoryImpl();

  AuthService? get _authService =>
      Get.isRegistered<AuthService>() ? AuthService.to : null;

  RealtimeChannel? _realtimeChannel;

  final hasActivePartner = false.obs;
  final userInviteCode = ''.obs;
  final inviteInputController = TextEditingController();

  final partnerId = ''.obs;
  final partnerName = ''.obs;
  final partnerEmail = ''.obs;
  final partnerIntakeMl = 0.obs;
  final partnerGoalMl = 2600.obs;
  final selectedThemeKey = 'love'.obs;
  final isLiveSynced = false.obs;
  final streakCount = 0.obs;

  final pastDays = <PartnerDayRecord>[].obs;
  final reminderLogs = <PartnerReminderLog>[].obs;
  final waterLogs = <PartnerWaterLog>[].obs;

  double get progress => (partnerGoalMl.value > 0)
      ? (partnerIntakeMl.value / partnerGoalMl.value).clamp(0.0, 1.0)
      : 0.0;
  int get percentage => (progress * 100).toInt();

  PartnerThemeOption get currentTheme =>
      PartnerThemes.getByKey(selectedThemeKey.value);

  @override
  void onInit() {
    super.onInit();
    final auth = _authService;
    if (auth != null) {
      userInviteCode.value = auth.userProfile.value?.inviteCode ?? '';
      ever(auth.userProfile, (profile) {
        if (profile != null && profile.inviteCode.isNotEmpty) {
          userInviteCode.value = profile.inviteCode;
        }
      });
    }

    final args = Get.arguments;
    if (args is SynergyPartner) {
      partner = args;
      hasActivePartner.value = true;
      _loadPartnerData(partner);
    } else {
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      if (homeController != null && homeController.partners.isNotEmpty) {
        partner = homeController.partners.first;
        hasActivePartner.value = true;
        _loadPartnerData(partner);
      } else {
        partner = SynergyPartner(
          id: '',
          name: 'Partner',
          intakeMl: 0,
          goalMl: 2600,
        );
        hasActivePartner.value = false;
      }
    }

    _initLivePartnerSync();
  }

  Future<void> _initLivePartnerSync() async {
    final currentUserId = _authService?.currentUser.value?.id ?? '';
    if (currentUserId.isNotEmpty) {
      try {
        final pair = await _synergyRepository.getActivePair(currentUserId);
        if (pair != null && pair.partnerProfile != null) {
          final p = pair.partnerProfile!;
          hasActivePartner.value = true;
          partnerId.value = p.id;
          partnerName.value = p.displayName;
          partnerEmail.value = p.email;
          partnerGoalMl.value = p.dailyWaterGoalMl;
          streakCount.value = pair.streakCount;
          selectedThemeKey.value = pair.themeKey;

          final partnerIntake = await _synergyRepository.getPartnerTodayIntake(p.id);
          partnerIntakeMl.value = partnerIntake;
          isLiveSynced.value = true;

          // Subscribe to live Realtime updates
          _realtimeChannel?.unsubscribe();
          _realtimeChannel = _synergyRepository.subscribeToPartnerUpdates(
            currentUserId: currentUserId,
            partnerId: p.id,
            onPartnerWaterLogged: (intakeMl) {
              partnerIntakeMl.value = intakeMl;
              Get.snackbar(
                'Partner Hydrated! 💧',
                '${partnerName.value} just logged water intake! Total: $intakeMl / ${partnerGoalMl.value} ml',
                snackPosition: SnackPosition.TOP,
                backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            },
            onNudgeReceived: (nudge) {
              final now = nudge.createdAt;
              final timeFormatted =
                  '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

              final reminderLog = PartnerReminderLog(
                id: nudge.id,
                timeStr: 'Today, $timeFormatted',
                message: nudge.message ?? 'Hydration nudge from ${partnerName.value} 💧',
                icon: Icons.water_drop_rounded,
              );
              reminderLogs.insert(0, reminderLog);

              Get.snackbar(
                nudge.nudgeType.defaultTitle,
                nudge.message ?? '${partnerName.value} sent you a reminder!',
                snackPosition: SnackPosition.TOP,
                backgroundColor: currentTheme.accentColor.withValues(alpha: 0.95),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            },
          );
        }
      } catch (e) {
        debugPrint('⚠️ Error initializing live partner sync: $e');
      }
    }
  }

  void _loadPartnerData(SynergyPartner p) {
    partnerId.value = p.id;
    partnerName.value = p.name;
    partnerIntakeMl.value = p.intakeMl;
    partnerGoalMl.value = p.goalMl;
    selectedThemeKey.value = p.themeKey.value;
    pastDays.assignAll(p.pastDays);
    reminderLogs.assignAll(p.reminders);
    waterLogs.assignAll(p.waterLogs);
  }

  void setTheme(String themeKey) {
    selectedThemeKey.value = themeKey;
    partner.themeKey.value = themeKey;
    final theme = PartnerThemes.getByKey(themeKey);

    Get.snackbar(
      'Theme Updated ✨',
      'Progress bar color set to ${theme.name} (${theme.description})',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: theme.accentColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  Future<void> sendNudge({SynergyNudgeType type = SynergyNudgeType.hydrate, String? customMessage}) async {
    final now = DateTime.now();
    final timeFormatted =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final message = customMessage ?? 'Hydration reminder sent to ${partnerName.value} 💧';

    final newReminder = PartnerReminderLog(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      timeStr: 'Today, $timeFormatted',
      message: message,
      icon: type == SynergyNudgeType.screenBreak
          ? Icons.notifications_active_rounded
          : Icons.water_drop_rounded,
    );

    reminderLogs.insert(0, newReminder);
    partner.reminders.insert(0, newReminder);

    final currentUserId = _authService?.currentUser.value?.id ?? '';
    final targetPartnerId = partnerId.value.isNotEmpty ? partnerId.value : partner.id;

    if (currentUserId.isNotEmpty && targetPartnerId.isNotEmpty) {
      await _synergyRepository.sendNudge(
        senderId: currentUserId,
        receiverId: targetPartnerId,
        nudgeType: type,
        message: message,
      );
    }

    if (Get.context != null) {
      Get.snackbar(
        'Nudge Sent! 💧',
        'Reminder sent to ${partnerName.value} to drink water!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    }
  }

  Future<void> connectPartnerWithCode(String inviteCode) async {
    final currentUserId = _authService?.currentUser.value?.id ?? '';
    if (inviteCode.trim().isEmpty) return;

    try {
      final pair = await _synergyRepository.connectPartnerWithCode(
        currentUserId: currentUserId,
        inviteCode: inviteCode.trim(),
      );

      if (pair.partnerProfile != null) {
        partnerId.value = pair.partnerProfile!.id;
        partnerName.value = pair.partnerProfile!.displayName;
        partnerEmail.value = pair.partnerProfile!.email;
        partnerGoalMl.value = pair.partnerProfile!.dailyWaterGoalMl;
        partnerIntakeMl.value = pair.partnerTodayIntakeMl;
        streakCount.value = pair.streakCount;
        isLiveSynced.value = true;
      }

      if (Get.context != null) {
        Get.back(); // Dismiss dialog
        Get.snackbar(
          'Partner Connected! 🎉',
          'You are now connected with ${partnerName.value} for 1-on-1 Synergy!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      _initLivePartnerSync();
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'Connection Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }
}
