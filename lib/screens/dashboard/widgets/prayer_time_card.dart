import 'package:flutter/material.dart';
import 'package:myapp/models/prayer_times.dart';
import 'package:myapp/services/prayer_time_service.dart';

class PrayerTimeCard extends StatefulWidget {
  const PrayerTimeCard({super.key});

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  Future<PrayerTimes>? _prayerTimesFuture;

  @override
  void initState() {
    super.initState();
    _prayerTimesFuture = _prayerTimeService.getPrayerTimes('1301', DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<PrayerTimes>(
          future: _prayerTimesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading prayer times'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No prayer times found'));
            }

            final prayerTimes = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Sholat',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildPrayerTimeRow('Subuh', prayerTimes.fajr),
                _buildPrayerTimeRow('Dzuhur', prayerTimes.dhuhr),
                _buildPrayerTimeRow('Ashar', prayerTimes.asr),
                _buildPrayerTimeRow('Maghrib', prayerTimes.maghrib),
                _buildPrayerTimeRow('Isya', prayerTimes.isha),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(time),
        ],
      ),
    );
  }
}
