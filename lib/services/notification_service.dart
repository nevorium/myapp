import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

/// # Notification Service
/// Handles all local notification logic for the application.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ## Initialize
  /// Sets up the notification service.
  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _notificationsPlugin.initialize(settings);
      developer.log('Notification Service Initialized', name: 'NotificationService');
    } catch (e, s) {
      developer.log('Error initializing notification service', name: 'NotificationService', error: e, stackTrace: s);
    }
  }

  /// ## Request Permissions
  /// Requests notification permissions from the user.
  Future<void> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        // FIX: Corrected method name back to `requestNotificationsPermission`
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e, s) {
      developer.log('Error requesting permissions', name: 'NotificationService', error: e, stackTrace: s);
    }
  }

  /// ## Schedule Daily Reminder
  /// Schedules a notification to be shown daily at the specified time.
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await cancelNotifications(id);
      
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
      
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_murojaah_reminder_channel',
        'Murojaah Reminders',
        channelDescription: 'Channel for daily murojaah reminders.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
      developer.log('Scheduled daily reminder for $hour:$minute', name: 'NotificationService');
    } catch (e, s) {
      developer.log('Error scheduling daily reminder', name: 'NotificationService', error: e, stackTrace: s);
    }
  }
  
  /// Calculates the next instance of a specific time.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// ## Cancel Notifications
  /// Cancels a notification with a specific [id].
  Future<void> cancelNotifications(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      developer.log('Cancelled notification with id: $id', name: 'NotificationService');
    } catch(e, s) {
       developer.log('Error cancelling notification', name: 'NotificationService', error: e, stackTrace: s);
    }
  }
}
