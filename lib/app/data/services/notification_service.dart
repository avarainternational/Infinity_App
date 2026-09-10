import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _hydrationChannelId = 'infinity_hydration_channel';
  static const String _hydrationChannelName = 'Hydration & Synergy Alerts';
  static const String _hydrationChannelDesc =
      'Timely hydration reminders and partner synergy nudges';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _hydrationChannelId,
    _hydrationChannelName,
    description: _hydrationChannelDesc,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final RxBool isInitialized = false.obs;
  final RxBool areRemindersEnabled = true.obs;
  final RxInt reminderIntervalMins = 90.obs;

  static const String _prefKeyRemindersEnabled = 'pref_hydration_reminders_enabled';
  static const String _prefKeyReminderInterval = 'pref_hydration_reminder_interval';

  Future<NotificationService> init() async {
    try {
      // 1. Initialize Timezone database
      tz.initializeTimeZones();

      // 2. Load stored preferences
      final prefs = await SharedPreferences.getInstance();
      areRemindersEnabled.value = prefs.getBool(_prefKeyRemindersEnabled) ?? true;
      reminderIntervalMins.value = prefs.getInt(_prefKeyReminderInterval) ?? 90;

      // 3. Platform settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 4. Create Android Notification Channel
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      isInitialized.value = true;
      debugPrint('✅ NotificationService successfully initialized.');

      // 5. Schedule if reminders are enabled
      if (areRemindersEnabled.value) {
        await schedulePeriodicHydrationReminders(
          intervalMinutes: reminderIntervalMins.value,
        );
      }
    } catch (e) {
      debugPrint('⚠️ NotificationService initialization notice: $e');
    }

    return this;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped with payload: ${response.payload}');
  }

  /// Explicitly requests notification permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permissions: $e');
    }
    return true;
  }

  /// Displays an immediate high-priority local notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    int id = 1,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _hydrationChannelId,
        _hydrationChannelName,
        channelDescription: _hydrationChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      debugPrint('🔔 Instant notification sent: $title - $body');
    } catch (e) {
      debugPrint('⚠️ Error displaying instant notification: $e');
    }
  }

  /// Schedules daily waking-hour hydration reminders (8:00 AM - 10:00 PM)
  Future<void> schedulePeriodicHydrationReminders({
    int intervalMinutes = 90,
    int startHour = 8,
    int endHour = 22,
  }) async {
    try {
      // Cancel previous scheduled reminders (IDs 100-150)
      await cancelHydrationReminders();

      if (!areRemindersEnabled.value) return;

      reminderIntervalMins.value = intervalMinutes;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyReminderInterval, intervalMinutes);
      await prefs.setBool(_prefKeyRemindersEnabled, true);

      final now = DateTime.now();
      int scheduleId = 100;

      final messages = [
        'A sip of pure water keeps your mind sharp and body energized! 💧',
        'Hydration check! Grab your favorite glass and log your sip! 🌊',
        'Keep your synergy streak alive! Time for a refreshing water break. 🩵',
        'Stay refreshed! Your body works better when well-hydrated. ✨',
        'Take a short stretch and enjoy a cold glass of Infinity Water! 💧',
      ];

      for (int hour = startHour; hour < endHour; hour++) {
        for (int minute = 0; minute < 60; minute += intervalMinutes) {
          var scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
          final msgIndex = (scheduleId - 100) % messages.length;

          const androidDetails = AndroidNotificationDetails(
            _hydrationChannelId,
            _hydrationChannelName,
            channelDescription: _hydrationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

          const darwinDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

          const details = NotificationDetails(
            android: androidDetails,
            iOS: darwinDetails,
          );

          await _notificationsPlugin.zonedSchedule(
            id: scheduleId,
            title: 'Hydration Reminder 💧',
            body: messages[msgIndex],
            scheduledDate: tzScheduled,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'hydration_reminder_$scheduleId',
          );

          scheduleId++;
          if (scheduleId > 130) break;
        }
        if (scheduleId > 130) break;
      }

      debugPrint(
        '✅ Scheduled ${scheduleId - 100} daily hydration reminder slots every $intervalMinutes mins.',
      );
    } catch (e) {
      debugPrint('⚠️ Error scheduling periodic hydration reminders: $e');
    }
  }

  /// Cancels all scheduled hydration reminders
  Future<void> cancelHydrationReminders() async {
    try {
      for (int id = 100; id <= 150; id++) {
        await _notificationsPlugin.cancel(id: id);
      }
      debugPrint('🔕 Hydration reminders cancelled.');
    } catch (e) {
      debugPrint('⚠️ Error cancelling reminders: $e');
    }
  }

  /// Toggles reminders on or off and persists preference
  Future<void> setRemindersEnabled(bool enabled) async {
    areRemindersEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyRemindersEnabled, enabled);

    if (enabled) {
      await schedulePeriodicHydrationReminders(
        intervalMinutes: reminderIntervalMins.value,
      );
    } else {
      await cancelHydrationReminders();
    }
  }
}
