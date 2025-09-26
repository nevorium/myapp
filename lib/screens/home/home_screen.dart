import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/murojaah_record.dart';
import 'package:myapp/models/progress_summary.dart';
import 'package:myapp/screens/settings/settings_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// # Home Screen
/// This is the main screen of the application after a user logs in.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services
  late final FirestoreService _firestoreService;
  late final User _currentUser;

  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Daily Checklist State
  late final TextEditingController _noteController;
  MurojaahRecord? _selectedRecord;

  // Data Streams & Futures
  Stream<Map<DateTime, MurojaahRecord>>? _murojaahStream;
  Future<ProgressSummary>? _progressFuture;
  Future<DateTime?>? _userCreationDateFuture;


  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _currentUser = Provider.of<User>(context, listen: false);
    _noteController = TextEditingController();
    _selectedDay = _focusedDay;

    // Initialize data streams and futures.
    _murojaahStream = _firestoreService.getMurojaahRecords(_currentUser.uid);
    _progressFuture = _firestoreService.getProgressSummary(_currentUser.uid);
    _userCreationDateFuture = _firestoreService.getUserCreationDate(_currentUser.uid);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  Future<void> _saveMurojaahRecord() async {
    if (_selectedDay == null) return;

    final recordToSave = MurojaahRecord(
      date: _selectedDay!,
      completed: _selectedRecord?.completed ?? true,
      note: _noteController.text.trim(),
      timestamp: Timestamp.now(),
    );

    try {
      await _firestoreService.updateMurojaahRecord(_currentUser.uid, recordToSave);
      // Refresh the progress summary after saving
      setState(() {
        _progressFuture = _firestoreService.getProgressSummary(_currentUser.uid);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Murojaah Tracker'),
        actions: [
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

          final userCreationDate = dateSnapshot.data;

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
              return _buildContent(records, userCreationDate);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(Map<DateTime, MurojaahRecord> records, DateTime? userCreationDate) {
    final normalizedSelectedDay = _selectedDay != null ? DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day) : null;
    _selectedRecord = records[normalizedSelectedDay];
    _noteController.text = _selectedRecord?.note ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSummary(),
          const SizedBox(height: 16),
          _buildCalendar(records, userCreationDate),
          const SizedBox(height: 24),
          _buildDailyChecklist(),
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
          return const SizedBox.shrink();
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

  Widget _buildCalendar(Map<DateTime, MurojaahRecord> records, DateTime? userCreationDate) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<MurojaahRecord>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
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
              if (record?.completed == true) {
                // Completed day - Green circle
                decoration = BoxDecoration(color: Colors.green.withOpacity(0.5), shape: BoxShape.circle);
              } else if (userCreationDate != null &&
                         normalizedDay.isBefore(today) &&
                         normalizedDay.isAfter(userCreationDate.subtract(const Duration(days: 1))) &&
                         !records.containsKey(normalizedDay)) {
                // Missed day - Red circle
                decoration = BoxDecoration(color: Colors.red.withOpacity(0.4), shape: BoxShape.circle);
              }

              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: decoration,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle().copyWith(color: Colors.black),
                  ),
                ),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
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

  Widget _buildDailyChecklist() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedDay != null
              ? 'Catatan untuk ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDay!)}'
              : 'Pilih tanggal untuk melihat catatan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Sudah murojaah hari ini'),
                    value: _selectedRecord?.completed ?? false,
                    onChanged: (bool? value) {
                      if (value == null) return;
                      setState(() {
                        _selectedRecord = _selectedRecord?.copyWith(completed: value) ??
                            MurojaahRecord(
                              date: _selectedDay!,
                              completed: value,
                              timestamp: Timestamp.now(),
                              note: '',
                            );
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    // FIX: Reverted to `activeColor` for older package versions
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Tambah catatan (opsional)',
                      hintText: 'e.g. Surat Al-Baqarah, Ayat 1-50',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveMurojaahRecord,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Simpan Catatan'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
