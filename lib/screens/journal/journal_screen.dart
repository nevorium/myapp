import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/quran_surahs.dart';
import 'package:myapp/models/murojaah_record.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';

/// # Journal Screen
/// This screen is dedicated to the user's daily input.
/// It contains detailed checklists for murojaah, tilawah, ziyadah,
/// custom habits, and a separate section for notes.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // Services & User
  late final FirestoreService _firestoreService;
  late final User _currentUser;

  // State Management
  MurojaahRecord? _todayRecord;
  final DateTime _selectedDay = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _newHabitController = TextEditingController();

  // UI State
  String? _selectedMurojaahJuz;
  String? _selectedTilawahSurah;
  bool _ziyadahChecked = false;
  Map<String, bool> _customHabitsState = {};

  // Data Streams
  Stream<List<String>>? _customHabitsStream;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _currentUser = Provider.of<User>(context, listen: false);
    _loadTodayRecord();
    _customHabitsStream = _firestoreService.getCustomHabits(_currentUser.uid);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _newHabitController.dispose();
    super.dispose();
  }

  /// ## Load Today's Record
  /// Fetches the record for the current day from Firestore and updates the UI state.
  Future<void> _loadTodayRecord() async {
    final stream = _firestoreService.getMurojaahRecords(_currentUser.uid);
    final records = await stream.first;
    final todayNormalized = DateTime.utc(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (mounted) {
      setState(() {
        _todayRecord = records[todayNormalized];
        _noteController.text = _todayRecord?.note ?? '';
        _selectedMurojaahJuz = _todayRecord?.murojaahJuz;
        _selectedTilawahSurah = _todayRecord?.tilawahSurah;
        _ziyadahChecked = _todayRecord?.ziyadah ?? false;
        _customHabitsState = Map<String, bool>.from(_todayRecord?.customHabits ?? {});
      });
    }
  }

  /// ## Save Journal
  /// Compiles the current state into a MurojaahRecord and saves it to Firestore.
  Future<void> _saveJournal() async {
    final recordToSave = MurojaahRecord(
      date: _selectedDay,
      timestamp: Timestamp.now(),
      murojaahJuz: _selectedMurojaahJuz,
      tilawahSurah: _selectedTilawahSurah,
      ziyadah: _ziyadahChecked,
      customHabits: _customHabitsState,
      note: _noteController.text.trim(),
    );

    try {
      await _firestoreService.updateMurojaahRecord(_currentUser.uid, recordToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jurnal berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jurnal: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  /// ## Add New Habit Dialog
  /// Shows a dialog to the user to enter a new custom habit.
  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Habit Baru'),
          content: TextField(
            controller: _newHabitController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Contoh: Sholat Dhuha'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final newHabit = _newHabitController.text.trim();
                if (newHabit.isNotEmpty) {
                  await _firestoreService.addCustomHabit(_currentUser.uid, newHabit);
                  _newHabitController.clear();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jurnal ${DateFormat.yMMMEd('id_ID').format(_selectedDay)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveJournal,
            tooltip: 'Simpan Jurnal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivityCard(),
            const SizedBox(height: 16),
            _buildCustomHabitsCard(),
            const SizedBox(height: 16),
            _buildNotesCard(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveJournal,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Simpan Jurnal'),
            )
          ],
        ),
      ),
    );
  }

  /// Card for primary activities: Murojaah, Tilawah, Ziyadah.
  Widget _buildActivityCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktivitas Utama', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            // --- Murojaah Section ---
            _buildMurojaahSection(),
            const SizedBox(height: 16),
            // --- Tilawah Section ---
            _buildTilawahSection(),
            const SizedBox(height: 16),
            // --- Ziyadah Section ---
            CheckboxListTile(
              title: const Text('Ziyadah (Tambah Hafalan Baru)'),
              value: _ziyadahChecked,
              onChanged: (val) => setState(() => _ziyadahChecked = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Murojaah selection widget.
  Widget _buildMurojaahSection() {
    final options = ['1/4 juz', '1/2 juz', '1 juz', '2 juz', '3 juz'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Murojaah hari ini:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((juz) {
            return ChoiceChip(
              label: Text(juz),
              selected: _selectedMurojaahJuz == juz,
              onSelected: (selected) {
                setState(() {
                  _selectedMurojaahJuz = selected ? juz : null;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Tilawah selection widget (dropdown with all surahs).
  Widget _buildTilawahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tilawah hari ini:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTilawahSurah,
          hint: const Text('Pilih Surah'),
          isExpanded: true,
          items: quranSurahs.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTilawahSurah = newValue;
            });
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  /// Card for dynamic custom habits.
  Widget _buildCustomHabitsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<String>>(
          stream: _customHabitsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                 children: [
                  const Text('Belum ada habit kustom. Tambahkan satu!'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Habit Baru'),
                    onPressed: _showAddHabitDialog,
                  ),
                ],
              );
            }

            final habits = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Habit Harian', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _showAddHabitDialog,
                      tooltip: 'Tambah Habit Baru',
                    ),
                  ],
                ),
                const Divider(height: 24),
                ...habits.map((habit) {
                  return CheckboxListTile(
                    title: Text(habit),
                    value: _customHabitsState[habit] ?? false,
                    onChanged: (val) {
                      setState(() {
                        _customHabitsState[habit] = val ?? false;
                      });
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _firestoreService.deleteCustomHabit(_currentUser.uid, habit),
                      tooltip: 'Hapus Habit',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Card for the text note input.
  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catatan Tambahan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Tulis catatan di sini...',
                hintText: 'Contoh: Mengulang hafalan terasa lebih lancar hari ini.',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
