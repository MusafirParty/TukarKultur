import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _locationTimer;
  bool _isRunning = false;
  String? _currentUserId;

  // Location settings
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Only update if moved 10 meters
  );

  // Start location updates
  Future<bool> startLocationUpdates(String userId) async {
    if (_isRunning) return true;

    _currentUserId = userId;

    // Check and request permissions
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) return false;

    _isRunning = true;
    return true;
  }

  // Stop location updates
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isRunning = false;
    _currentUserId = null;
  }

  // Check if location service is running
  bool get isRunning => _isRunning;

  // Request location permissions
  Future<bool> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return false;
      }

      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Get current position once
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }
}