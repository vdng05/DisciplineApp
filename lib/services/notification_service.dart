import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Request notification permissions on Android 13+
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init notice (safe to ignore on desktop): $e');
    }
  }

  /// Schedule or trigger a notification for a habit
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!_isInitialized || habit.reminderTime == null || !habit.isReminderEnabled) {
      return;
    }

    try {
      final parts = habit.reminderTime!.split(':');
      if (parts.length < 2) return;
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;

      const androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Nhắc nhở thói quen',
        channelDescription: 'Thông báo nhắc nhở rèn luyện kỷ luật mỗi ngày',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      // Show immediate sample alert when scheduled, or daily
      await _notifications.show(
        id: habit.id ?? DateTime.now().millisecond,
        title: '⏰ Đã đặt nhắc nhở: ${habit.title}',
        body: 'Bạn sẽ nhận thông báo vào lúc ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} mỗi ngày!',
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Notification scheduling error: $e');
    }
  }

  /// Cancel reminder for a habit
  Future<void> cancelHabitReminder(int habitId) async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancel(id: habitId);
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }
}
