import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/notification_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerDetailController extends BaseController {
  late SynergyPartner partner;

  SynergyRepository get _synergyRepository =>
      Get.isRegistered<SynergyRepository>() ? Get.find<SynergyRepository>() : SynergyRepositoryImpl();

  AuthService? get _authService =>
      Get.isRegistered<AuthService>() ? AuthService.to : null;

  UserRepository get _userRepository =>
      Get.isRegistered<UserRepository>() ? Get.find<UserRepository>() : UserRepositoryImpl();

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

    _ensureUserInviteCode();

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

  Future<void> _ensureUserInviteCode() async {
    final currentUserId = _authService?.currentUser.value?.id ??
        (Get.isRegistered<SupabaseService>() ? SupabaseService.to.client.auth.currentUser?.id : null) ??
        '';
    if (userInviteCode.value.isEmpty && currentUserId.isNotEmpty) {
      try {
        final profile = await _userRepository.getUserProfile(currentUserId);
        if (profile != null && profile.inviteCode.isNotEmpty) {
          userInviteCode.value = profile.inviteCode;
        }
      } catch (e) {
        debugPrint('⚠️ Error retrieving user invite code: $e');
      }
    }
  }

  Future<void> _initLivePartnerSync() async {
    final currentUserId = _authService?.currentUser.value?.id ??
        (Get.isRegistered<SupabaseService>() ? SupabaseService.to.client.auth.currentUser?.id : null) ??
        '';
    if (currentUserId.isNotEmpty) {
      try {
        final pair = await _synergyRepository.getActivePair(currentUserId);
        if (pair != null && pair.partnerProfile != null) {
          final p = pair.partnerProfile!;
          hasActivePartner.value = true;
          partnerId.value = p.id;
          partnerName.value = p.displayName;
          partnerEmail.value = p.email;
          partnerGoalMl.value = p.dailyWaterGoalMl > 0 ? p.dailyWaterGoalMl : 2600;
          streakCount.value = pair.streakCount;
          selectedThemeKey.value = pair.themeKey;

          final partnerIntake = await _synergyRepository.getPartnerTodayIntake(p.id);
          partnerIntakeMl.value = partnerIntake;
          isLiveSynced.value = true;

          partner = SynergyPartner(
            id: p.id,
            name: p.displayName,
            intakeMl: partnerIntake,
            goalMl: partnerGoalMl.value,
            themeKey: pair.themeKey,
          );

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().updateActivePartner(partner);
          }

          // Fetch partner logs, past days, and recent nudges
          await _loadPartnerSubData(p.id, partnerGoalMl.value);

          // Subscribe to live Realtime updates
          _realtimeChannel?.unsubscribe();
          _realtimeChannel = _synergyRepository.subscribeToPartnerUpdates(
            currentUserId: currentUserId,
            partnerId: p.id,
            onPartnerWaterLogged: (intakeMl) async {
              partnerIntakeMl.value = intakeMl;
              partner.intakeMl.value = intakeMl;

              // Refresh today water logs
              final logs = await _synergyRepository.getPartnerTodayWaterLogs(p.id);
              waterLogs.assignAll(logs);

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

              if (Get.isRegistered<NotificationService>()) {
                NotificationService.to.showInstantNotification(
                  title: '💧 Synergy Nudge: ${nudge.nudgeType.defaultTitle}',
                  body: nudge.message ?? '${partnerName.value} sent you a reminder!',
                );
              }

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
        } else {
          hasActivePartner.value = false;
        }
      } catch (e) {
        debugPrint('⚠️ Error initializing live partner sync: $e');
      }
    }
  }

  Future<void> _loadPartnerSubData(String pId, int goalMl) async {
    try {
      final logs = await _synergyRepository.getPartnerTodayWaterLogs(pId);
      waterLogs.assignAll(logs);

      final days = await _synergyRepository.getPartnerPastDays(pId, goalMl);
      pastDays.assignAll(days);

      final nudges = await _synergyRepository.getRecentNudges(pId);
      if (nudges.isNotEmpty) {
        final logsList = nudges.map((nudge) {
          final now = nudge.createdAt;
          final timeFormatted =
              '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
          return PartnerReminderLog(
            id: nudge.id,
            timeStr: 'Today, $timeFormatted',
            message: nudge.message ?? 'Hydration nudge from ${partnerName.value} 💧',
            icon: nudge.nudgeType == SynergyNudgeType.screenBreak
                ? Icons.notifications_active_rounded
                : Icons.water_drop_rounded,
          );
        }).toList();
        reminderLogs.assignAll(logsList);
      }
    } catch (e) {
      debugPrint('⚠️ Error loading partner sub data: $e');
    }
  }

  void _loadPartnerData(SynergyPartner p) {
    partnerId.value = p.id;
    partnerName.value = p.name;
    partnerIntakeMl.value = p.intakeMl.value;
    partnerGoalMl.value = p.goalMl.value > 0 ? p.goalMl.value : 2600;
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

    final currentUserId = _authService?.currentUser.value?.id ??
        (Get.isRegistered<SupabaseService>() ? SupabaseService.to.client.auth.currentUser?.id : null) ??
        '';
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
    final currentUserId = _authService?.currentUser.value?.id ??
        (Get.isRegistered<SupabaseService>() ? SupabaseService.to.client.auth.currentUser?.id : null) ??
        '';
    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      final pair = await _synergyRepository.connectPartnerWithCode(
        currentUserId: currentUserId,
        inviteCode: code,
      );

      if (pair.partnerProfile != null) {
        final p = pair.partnerProfile!;
        hasActivePartner.value = true;
        partnerId.value = p.id;
        partnerName.value = p.displayName;
        partnerEmail.value = p.email;
        partnerGoalMl.value = p.dailyWaterGoalMl > 0 ? p.dailyWaterGoalMl : 2600;
        partnerIntakeMl.value = pair.partnerTodayIntakeMl;
        streakCount.value = pair.streakCount;
        selectedThemeKey.value = pair.themeKey;
        isLiveSynced.value = true;

        partner = SynergyPartner(
          id: p.id,
          name: p.displayName,
          intakeMl: pair.partnerTodayIntakeMl,
          goalMl: partnerGoalMl.value,
          themeKey: pair.themeKey,
        );

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().updateActivePartner(partner);
        }

        await _loadPartnerSubData(p.id, partnerGoalMl.value);
      }

      inviteInputController.clear();

      if (Get.isDialogOpen == true) {
        Get.back(); // Dismiss modal dialog if one was opened
      }

      Get.snackbar(
        'Partner Connected! 🎉',
        'You are now connected with ${partnerName.value} for 1-on-1 Synergy!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: currentTheme.accentColor.withValues(alpha: 0.92),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      _initLivePartnerSync();
    } catch (e) {
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

  Future<void> disconnectPartner() async {
    final currentUserId = _authService?.currentUser.value?.id ??
        (Get.isRegistered<SupabaseService>() ? SupabaseService.to.client.auth.currentUser?.id : null) ??
        '';
    try {
      final pair = await _synergyRepository.getActivePair(currentUserId);
      if (pair != null) {
        await _synergyRepository.disconnectPartner(pairId: pair.id);
      }
      hasActivePartner.value = false;
      partnerId.value = '';
      partnerName.value = '';
      partnerIntakeMl.value = 0;
      isLiveSynced.value = false;
      waterLogs.clear();
      pastDays.clear();
      reminderLogs.clear();
      _realtimeChannel?.unsubscribe();

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().clearPartner();
      }

      Get.snackbar(
        'Partner Disconnected',
        '1-on-1 synergy partnership has been disconnected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('⚠️ Error disconnecting partner: $e');
    }
  }

  @override
  void onClose() {
    inviteInputController.dispose();
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }
}

