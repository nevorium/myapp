import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:myapp/models/prayer_times.dart';
import 'dart:developer' as developer;

/// # Prayer Time Service
/// Handles fetching of prayer times based on the user's location.
///
/// ## Responsibilities:
/// - Request and retrieve the user's current geographical location.
/// - Convert latitude/longitude into a city and country name.
/// - Make an API call to an external service (aladhan.com) to get prayer times.
/// - Parse the JSON response into a `PrayerTimes` model.
/// - Handle potential errors gracefully (e.g., location permission denied, network issues).
class PrayerTimeService {
  final Location _location = Location();
  static const String _apiAuthority = 'api.aladhan.com';

  /// ## Get Prayer Times
  /// The main method to orchestrate the process of getting the user's location
  /// and fetching the prayer times from the API.
  ///
  /// - **Returns**: A `Future<PrayerTimes?>` which completes with the prayer times
  ///   data, or `null` if any step in the process fails.
  Future<PrayerTimes?> getPrayerTimes() async {
    try {
      // 1. Get user's current location
      final LocationData? locationData = await _getLocation();
      if (locationData == null || locationData.latitude == null || locationData.longitude == null) {
        developer.log('Failed to get location data.', name: 'PrayerTimeService');
        return null;
      }

      // 2. Convert location to city and country
      final placemark = await _getPlacemark(locationData.latitude!, locationData.longitude!);
      if (placemark == null || placemark.locality == null || placemark.country == null) {
        developer.log('Failed to convert location to placemark.', name: 'PrayerTimeService');
        return null;
      }

      // 3. Fetch prayer times from the API
      final uri = Uri.https(_apiAuthority, '/v1/timingsByCity', {
        'city': placemark.locality!,
        'country': placemark.country!,
        'method': '2', // Calculation method: ISNA
      });
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data['data']);
      } else {
        developer.log('Failed to load prayer times: ${response.statusCode}', name: 'PrayerTimeService');
        return null;
      }
    } catch (e, s) {
      developer.log('Error in getPrayerTimes', name: 'PrayerTimeService', error: e, stackTrace: s);
      return null;
    }
  }

  /// ## Get Location
  /// Private helper to handle location permission and retrieval.
  Future<LocationData?> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        developer.log('Location service is disabled.', name: 'PrayerTimeService');
        return null;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        developer.log('Location permission denied.', name: 'PrayerTimeService');
        return null;
      }
    }
    
    return await _location.getLocation();
  }

  /// ## Get Placemark
  /// Private helper to convert coordinates to a placemark (city, country).
  Future<geocoding.Placemark?> _getPlacemark(double latitude, double longitude) async {
    try {
      final List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      developer.log('Error getting placemark: $e', name: 'PrayerTimeService');
      return null;
    }
  }
}
