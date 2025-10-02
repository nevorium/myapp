import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/murojaah_record.dart';
import 'package:myapp/models/progress_summary.dart';
import 'package:myapp/screens/dashboard/widgets/daily_tracking_card.dart';
import 'package:myapp/screens/dashboard/widgets/prayer_time_card.dart';
import 'package:myapp/screens/settings/settings_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// # Dashboard Screen
/// This screen displays the user's overall progress, including the interactive
/// calendar (heatmap), streak counter, and other statistics.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Services
  late final FirestoreService _firestoreService;
  late final User _currentUser;

  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  // Data Streams & Futures
  Stream<Map<DateTime, MurojaahRecord>>? _murojaahStream;
  Future<ProgressSummary>? _progressFuture;
  Future<DateTime?>? _userCreationDateFuture;

  @override
  void initState() {
    super.initState();
    // Initialize services and current user from Provider.
    _firestoreService = FirestoreService();
    _currentUser = Provider.of<User>(context, listen: false);

    // Initialize data streams and futures required for the dashboard.
    _murojaahStream = _firestoreService.getMurojaahRecords(_currentUser.uid);
    _userCreationDateFuture = _firestoreService.getUserCreationDate(_currentUser.uid);
    _progressFuture = _firestoreService.getProgressSummary(_currentUser.uid);
  }

  /// Refreshes the progress summary data.
  void _refreshProgress() {
    setState(() {
      _progressFuture = _firestoreService.getProgressSummary(_currentUser.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Progres'),
        actions: [
          // Refresh button to update the progress summary manually.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProgress,
            tooltip: 'Perbarui Progres',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            tooltip: 'Pengaturan',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<DateTime?>(
        future: _userCreationDateFuture,
        builder: (context, dateSnapshot) {
          if (dateSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // **FIX:** Normalize the user creation date to UTC to ensure accurate comparisons.
          DateTime? userCreationDateUtc;
          if (dateSnapshot.hasData && dateSnapshot.data != null) {
            final localDate = dateSnapshot.data!;
            userCreationDateUtc = DateTime.utc(localDate.year, localDate.month, localDate.day);
          }

          return StreamBuilder<Map<DateTime, MurojaahRecord>>(
            stream: _murojaahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final records = snapshot.data ?? {};
              // Pass the normalized UTC date to the build method.
              return _buildDashboardContent(records, userCreationDateUtc);
            },
          );
        },
      ),
    );
  }

  /// Builds the main content of the dashboard.
  Widget _buildDashboardContent(Map<DateTime, MurojaahRecord> records, DateTime? userCreationDate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DailyTrackingCard(),
          const SizedBox(height: 24),
          const PrayerTimeCard(),
          const SizedBox(height: 24),
          _buildProgressSummary(),
          const SizedBox(height: 16),
          _buildCalendar(records, userCreationDate),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the progress summary widget (Streak & Weekly Rate).
  Widget _buildProgressSummary() {
    return FutureBuilder<ProgressSummary>(
      future: _progressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink(); // Don't show if there's an error.
        }

        final summary = snapshot.data!;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem('🔥', '${summary.currentStreak} Hari', 'Beruntun'),
                _buildProgressItem('📊', '${summary.weeklyCompletionRate.toStringAsFixed(0)}%', 'Minggu Ini'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Builds the interactive calendar heatmap.
  Widget _buildCalendar(Map<DateTime, MurojaahRecord> records, DateTime? userCreationDate) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<MurojaahRecord>(
          firstDay: userCreationDate ?? DateTime.utc(2020, 1, 1),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => false, 
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime.utc(day.year, day.month, day.day);
              final record = records[normalizedDay];
              final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

              BoxDecoration? decoration;
              if (record?.isCompleted == true) {
                decoration = BoxDecoration(color: Colors.green.withOpacity(0.7), shape: BoxShape.circle);
              } 
              // **FIXED LOGIC**: Now compares UTC with UTC.
              else if (userCreationDate != null &&
                         normalizedDay.isBefore(today) &&
                         !normalizedDay.isBefore(userCreationDate) && // Simplified and more robust check
                         !records.containsKey(normalizedDay)) {
                decoration = BoxDecoration(color: Colors.grey.withOpacity(0.5), shape: BoxShape.circle);
              }

              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: decoration,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle().copyWith(color: day.weekday > 6 ? Colors.red.shade400 : null),
                  ),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
               return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: Center(child: Text('${day.day}')),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red.shade600),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
