import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/murojaah_record.dart';
import 'package:myapp/screens/settings/settings_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// # Home Screen
/// This is the main screen of the application after a user logs in.
///
/// ## Features:
/// - Displays a welcome message and a logout button.
/// - Shows an interactive calendar to track daily murojaah progress.
/// - Allows users to mark their murojaah as complete for a selected day.
/// - Provides a text field to add notes for the selected day.
/// - Saves the progress and notes to Firestore.
/// - Shows a daily motivational quote.
///
/// ## State Management:
/// - Uses a `StatefulWidget` to manage the calendar's state, the daily checklist's state, and the quote data.
/// - Uses a `StreamProvider` for real-time `MurojaahRecord` updates.
/// - Uses a `FutureBuilder` to handle the asynchronous fetching of the quote.
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

  // Data Stream & Future
  Stream<Map<DateTime, MurojaahRecord>>? _murojaahStream;
  Future<Map<String, dynamic>?>? _quoteFuture;


  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    // Correctly get the User object from the Provider.
    _currentUser = Provider.of<User>(context, listen: false);
    _noteController = TextEditingController();
    _selectedDay = _focusedDay;

    // Initialize the data streams and futures.
    _murojaahStream = _firestoreService.getMurojaahRecords(_currentUser.uid);
    _quoteFuture = _firestoreService.getRandomQuote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Triggered when a day is selected on the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  /// Saves or updates the MurojaahRecord for the `_selectedDay`.
  Future<void> _saveMurojaahRecord() async {
    if (_selectedDay == null) return;

    final recordToSave = MurojaahRecord(
      date: _selectedDay!,
      completed: _selectedRecord?.completed ?? true, // Default to true on save
      note: _noteController.text.trim(),
      timestamp: Timestamp.now(),
    );

    try {
      await _firestoreService.updateMurojaahRecord(
          _currentUser.uid, recordToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Pengaturan',
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<Map<DateTime, MurojaahRecord>>(
        stream: _murojaahStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final records = snapshot.data ?? {};
          return _buildContent(records);
        },
      ),
    );
  }

  /// Builds the main content of the screen including the calendar and checklist.
  Widget _buildContent(Map<DateTime, MurojaahRecord> records) {
    // Update the local state for the selected day's record
    final normalizedSelectedDay = _selectedDay != null
        ? DateTime.utc(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : null;
    _selectedRecord = records[normalizedSelectedDay];
    _noteController.text = _selectedRecord?.note ?? '';


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendar(records),
          const SizedBox(height: 24),
          _buildDailyChecklist(),
          const SizedBox(height: 24),
          _buildMotivationQuote(), // Add the quote widget here
        ],
      ),
    );
  }

  /// Builds the interactive calendar widget.
  Widget _buildCalendar(Map<DateTime, MurojaahRecord> records) {
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
          // Event loader to mark days with completed murojaah
          eventLoader: (day) {
            final normalizedDay = DateTime.utc(day.year, day.month, day.day);
            if (records[normalizedDay]?.completed == true) {
              return [records[normalizedDay]!]; // Return a list with the record
            }
            return [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    width: 7.0,
                    height: 7.0,
                  ),
                );
              }
              return null;
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

  /// Builds the checklist and note section for the selected day.
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
                        // Create a new record if it doesn't exist
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

  /// Builds the motivation quote widget.
  Widget _buildMotivationQuote() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _quoteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Don't show an error, just an empty container if quote fails.
          return const SizedBox.shrink();
        }

        final quote = snapshot.data!;
        final text = quote['text'] as String?;
        final source = quote['source'] as String?;

        if (text == null) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Motivasi Hari Ini',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '"$text"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                if (source != null && source.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '- $source',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
