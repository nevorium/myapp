import 'package:flutter/material.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;


/// # Settings Screen
/// Allows the user to configure application settings, specifically for notifications.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _areNotificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  // Keys for SharedPreferences
  static const String _enabledKey = 'notifications_enabled';
  static const String _hourKey = 'notification_hour';
  static const String _minuteKey = 'notification_minute';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the saved notification settings from SharedPreferences.
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _areNotificationsEnabled = prefs.getBool(_enabledKey) ?? false;
        final hour = prefs.getInt(_hourKey) ?? 8;
        final minute = prefs.getInt(_minuteKey) ?? 0;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    } catch (e) {
      developer.log('Error loading settings: $e', name: 'SettingsScreen');
    }
  }

  /// Saves the current notification settings to SharedPreferences.
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, _areNotificationsEnabled);
      await prefs.setInt(_hourKey, _selectedTime.hour);
      await prefs.setInt(_minuteKey, _selectedTime.minute);
    } catch (e) {
      developer.log('Error saving settings: $e', name: 'SettingsScreen');
    }
  }

  /// Handles changes to the notification enabled/disabled switch.
  void _onEnabledChanged(bool value) {
    setState(() {
      _areNotificationsEnabled = value;
    });
    _saveSettings();
    _updateNotificationSchedule();
  }
  
  /// Schedules or cancels the daily notification based on the current settings.
  void _updateNotificationSchedule() {
    if (_areNotificationsEnabled) {
      _notificationService.scheduleDailyReminder(
        id: 0,
        title: 'Jangan Lupa Murojaah!',
        body: 'Ayo semangat menjaga hafalan Al-Qur\'an hari ini.',
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    } else {
      _notificationService.cancelNotifications(0);
    }
  }

  /// Shows the time picker dialog to select a reminder time.
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _saveSettings();
      _updateNotificationSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Notifikasi'),
          SwitchListTile(
            title: const Text('Pengingat Harian'),
            subtitle: const Text('Kirim notifikasi setiap hari untuk mengingatkan murojaah.'),
            value: _areNotificationsEnabled,
            onChanged: _onEnabledChanged,
            // FIX: Replaced deprecated `activeColor` with `activeTrackColor`
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          ListTile(
            title: const Text('Waktu Pengingat'),
            subtitle: Text('Notifikasi akan dikirim setiap pukul ${_selectedTime.format(context)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _areNotificationsEnabled ? _selectTime : null,
            enabled: _areNotificationsEnabled,
          ),
        ],
      ),
    );
  }

  /// Helper widget to build section titles.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
