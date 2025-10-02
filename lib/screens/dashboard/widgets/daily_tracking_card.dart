import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/murojaah_record.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyTrackingCard extends StatefulWidget {
  const DailyTrackingCard({super.key});

  @override
  State<DailyTrackingCard> createState() => _DailyTrackingCardState();
}

class _DailyTrackingCardState extends State<DailyTrackingCard> {
  bool _isMurojaahCompleted = false;
  bool _isDhuhaCompleted = false;
  final TextEditingController _noteController = TextEditingController();

  void _saveRecord() {
    final user = Provider.of<User>(context, listen: false);
    final firestoreService = FirestoreService();

    final record = MurojaahRecord(
      date: DateTime.now(),
      timestamp: Timestamp.now(),
      customHabits: {
        'Murojaah': _isMurojaahCompleted,
        'Sholat Dhuha': _isDhuhaCompleted,
      },
      note: _noteController.text,
    );

    firestoreService.updateMurojaahRecord(user.uid, record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan Hari Ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Selesai Murojaah'),
              value: _isMurojaahCompleted,
              onChanged: (value) {
                setState(() {
                  _isMurojaahCompleted = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Selesai Sholat Dhuha'),
              value: _isDhuhaCompleted,
              onChanged: (value) {
                setState(() {
                  _isDhuhaCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan Murojaah',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveRecord,
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
