import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationDataResult {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final bool isMockFallback;
  final String? errorMessage;

  LocationDataResult({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
    this.isMockFallback = false,
    this.errorMessage,
  });

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(5)}°, ${longitude.toStringAsFixed(5)}°';

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_meters': accuracyMeters,
        'timestamp': timestamp.toIso8601String(),
        'is_mock_fallback': isMockFallback,
      };
}

class LocationHelper {
  // Default mock coordinates (Connaught Place, New Delhi field location)
  static final LocationDataResult _fallbackLocation = LocationDataResult(
    latitude: 28.6139,
    longitude: 77.2090,
    accuracyMeters: 5.0,
    timestamp: DateTime.now(),
    isMockFallback: true,
    errorMessage: 'Simulated field location (GPS hardware fallback)',
  );

  static Future<LocationDataResult> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        return _fallbackLocation;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Using fallback.');
        return _fallbackLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied. Using fallback.');
          return _fallbackLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied. Using fallback.');
        return _fallbackLocation;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LocationDataResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        timestamp: DateTime.now(),
        isMockFallback: false,
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e. Returning mock location.');
      return LocationDataResult(
        latitude: 28.6139 + (0.001 * (DateTime.now().second % 5)),
        longitude: 77.2090 + (0.001 * (DateTime.now().minute % 5)),
        accuracyMeters: 6.2,
        timestamp: DateTime.now(),
        isMockFallback: true,
        errorMessage: e.toString(),
      );
    }
  }
}
