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

  static Future<LocationDataResult> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        return LocationDataResult(
          latitude: 28.6139,
          longitude: 77.2090,
          accuracyMeters: 5.0,
          timestamp: DateTime.now(),
          isMockFallback: true,
          errorMessage: null, // Web uses fallback without blocking error
        );
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return LocationDataResult(
          latitude: 0.0,
          longitude: 0.0,
          accuracyMeters: 0.0,
          timestamp: DateTime.now(),
          isMockFallback: true,
          errorMessage: 'Location services are disabled. Please enable GPS in device settings.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          return LocationDataResult(
            latitude: 0.0,
            longitude: 0.0,
            accuracyMeters: 0.0,
            timestamp: DateTime.now(),
            isMockFallback: true,
            errorMessage: 'Location permission denied. Please allow location access to submit.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied.');
        return LocationDataResult(
          latitude: 0.0,
          longitude: 0.0,
          accuracyMeters: 0.0,
          timestamp: DateTime.now(),
          isMockFallback: true,
          errorMessage: 'Location permission permanently denied. Please enable it in Settings.',
        );
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
      debugPrint('Error getting GPS location: $e');
      return LocationDataResult(
        latitude: 0.0,
        longitude: 0.0,
        accuracyMeters: 0.0,
        timestamp: DateTime.now(),
        isMockFallback: true,
        errorMessage: 'Failed to capture location: ${e.toString()}',
      );
    }
  }
}
