import 'package:flutter/material.dart';
import 'package:myapp/models/prayer_times.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/prayer_time_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// # Settings Screen
/// Allows the user to enable or disable prayer time notifications.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  
  bool _areNotificationsEnabled = false;
  bool _isLoading = false;
  String _statusMessage = 'Aktifkan untuk menjadwalkan pengingat harian.';

  // Key for SharedPreferences
  static const String _enabledKey = 'prayer_notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the saved notification setting.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _areNotificationsEnabled = prefs.getBool(_enabledKey) ?? false;
      _statusMessage = _areNotificationsEnabled
          ? 'Pengingat waktu sholat sudah aktif.'
          : 'Aktifkan untuk menjadwalkan pengingat harian.';
    });
  }

  /// Saves the notification setting.
  Future<void> _saveSettings(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, isEnabled);
  }

  /// Handles changes to the notification switch.
  Future<void> _onEnabledChanged(bool value) async {
    setState(() {
      _areNotificationsEnabled = value;
      _isLoading = true;
    });

    if (_areNotificationsEnabled) {
      // --- Enable Notifications ---
      setState(() {
        _statusMessage = 'Mendapatkan lokasi dan jadwal sholat...';
      });
      
      // TODO: Replace with actual city ID from user's location
      const String cityId = '1301'; // Example: Jakarta
      final DateTime date = DateTime.now();
      final PrayerTimes? prayerTimes = await _prayerTimeService.getPrayerTimes(cityId, date);
      
      if (prayerTimes != null) {
        await _notificationService.schedulePrayerTimeNotifications(prayerTimes);
        setState(() {
          _statusMessage = 'Pengingat berhasil diaktifkan!';
          _isLoading = false;
        });
        _saveSettings(true);
      } else {
        setState(() {
          _statusMessage = 'Gagal mendapatkan data. Pastikan izin lokasi aktif.';
          _areNotificationsEnabled = false; // Toggle back on failure
          _isLoading = false;
        });
        _saveSettings(false);
      }
    } else {
      // --- Disable Notifications ---
      await _notificationService.cancelAllPrayerTimeNotifications();
      setState(() {
        _statusMessage = 'Semua pengingat telah dinonaktifkan.';
        _isLoading = false;
      });
      _saveSettings(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Pengingat Waktu Sholat'),
          SwitchListTile(
            title: const Text('Aktifkan Pengingat'),
            value: _areNotificationsEnabled,
            onChanged: _isLoading ? null : _onEnabledChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isLoading
                ? const Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 16),
                      Expanded(child: Text('Memproses...')),
                    ],
                  )
                : Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Saat diaktifkan, aplikasi akan meminta izin lokasi untuk mendapatkan jadwal sholat yang akurat dan menjadwalkan 5 notifikasi pengingat murojaah setiap hari.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
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
