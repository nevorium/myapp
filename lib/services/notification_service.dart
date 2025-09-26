import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/models/prayer_times.dart';
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
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e, s) {
      developer.log('Error requesting permissions', name: 'NotificationService', error: e, stackTrace: s);
    }
  }

  /// ## Schedule Prayer Time Notifications
  /// Schedules 5 daily notifications based on the fetched prayer times.
  Future<void> schedulePrayerTimeNotifications(PrayerTimes prayerTimes) async {
    await cancelAllPrayerTimeNotifications(); // Clear old notifications first

    final prayerSchedule = {
      0: {'name': 'Subuh', 'time': prayerTimes.fajr},
      // FIX: Corrected typo from 'dhr' to 'dhuhr'
      1: {'name': 'Dzuhur', 'time': prayerTimes.dhuhr},
      2: {'name': 'Ashar', 'time': prayerTimes.asr},
      3: {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      4: {'name': 'Isya', 'time': prayerTimes.isha},
    };

    for (var entry in prayerSchedule.entries) {
      final id = entry.key;
      final name = entry.value['name'] as String;
      final timeString = entry.value['time'] as String;
      
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      await _scheduleDailyNotification(
        id: id,
        title: 'Waktunya Sholat $name',
        body: 'Jangan lupa murojaah setelah sholat ya!',
        hour: hour,
        minute: minute,
      );
    }
    developer.log('Scheduled all prayer time notifications.', name: 'NotificationService');
  }
  
  /// ## Cancel All Prayer Time Notifications
  /// Cancels all scheduled prayer time reminders.
  Future<void> cancelAllPrayerTimeNotifications() async {
    for (int i = 0; i < 5; i++) {
      try {
        await _notificationsPlugin.cancel(i);
      } catch(e,s) {
        developer.log('Error cancelling notification for id: $i', name: 'NotificationService', error: e, stackTrace: s);
      }
    }
    developer.log('Cancelled all prayer time notifications.', name: 'NotificationService');
  }

  /// Private helper to schedule a single daily notification.
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
      
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_time_channel',
        'Prayer Time Reminders',
        channelDescription: 'Channel for prayer time murojaah reminders.',
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
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
    } catch (e, s) {
      developer.log('Error scheduling notification for id: $id', name: 'NotificationService', error: e, stackTrace: s);
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
}
