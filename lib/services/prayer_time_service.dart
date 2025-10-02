import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/prayer_times.dart';

class PrayerTimeService {
  final String _baseUrl = 'https://api.myquran.com/v1';

  Future<PrayerTimes> getPrayerTimes(String cityId, DateTime date) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sholat/jadwal/$cityId/${date.year}/${date.month}/${date.day}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimes.fromJson(data['data']['jadwal']);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
