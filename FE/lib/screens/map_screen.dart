import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider instead
import 'dart:async';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  // Remove this line: final AuthService _authService = AuthService();
  
  // Current user location
  LatLng? _currentLocation;
  
  // Initial location (San Francisco)
  static const LatLng _initialCenter = LatLng(37.7749, -122.4194);
  
  // Markers for nearby users
  Set<Marker> _markers = {};
  
  // Timer for fetching nearby users
  Timer? _nearbyUsersTimer;

  @override
  void initState() {
    super.initState();
    _checkAuthAndInitialize();
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    _nearbyUsersTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndInitialize() async {
    // Get AuthProvider instance
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in using AuthProvider
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      print('❌ User not logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to use location features')),
      );
      return;
    }
    
    _initializeLocationServices();
  }

Future<void> _initializeLocationServices() async {
  // Get AuthProvider instance
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // ADD THESE DEBUG PRINTS
  print('🔍 Auth debug:');
  print('🔍 isLoggedIn: ${authProvider.isLoggedIn}');
  print('🔍 currentUser: ${authProvider.currentUser}');
  print('🔍 currentUser.id: ${authProvider.currentUser?.id}');
  print('🔍 currentUser.username: ${authProvider.currentUser?.username}');
  
  // Get the actual logged-in user ID from AuthProvider
  final userId = authProvider.currentUser?.id;
  
  if (userId == null) {
    print('❌ No user ID available');
    return;
  }
  
    print('🔑 User ID type: ${userId.runtimeType}');
    print('🔑 User ID value: "$userId"');
    print('🔑 User ID length: ${userId.length}');
  
    
    final success = await _locationService.startLocationUpdates(userId);
    if (success) {
      print('✅ Location services started for user: $userId');
      
      // Get initial position
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Move camera to current location
        _moveToCurrentLocation();
      }
      
      // Start updating location and fetching nearby users every 5 seconds
      _startLocationUpdates(userId);
    } else {
      print('❌ Failed to start location services');
      _showLocationPermissionDialog();
    }
  }

  void _startLocationUpdates(String userId) {
    _nearbyUsersTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _updateLocationAndFetchNearby(userId);
    });
  }

  Future<void> _updateLocationAndFetchNearby(String userId) async {
    try {
      // Get current position
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;

      // Update current location
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Update location on backend and get nearby users
      final nearbyUsers = await _apiService.updateLocationAndGetNearby(
        userId,
        position.latitude,
        position.longitude,
      );
      
      // Get current user info from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserName = authProvider.currentUser?.username ?? 'You';
      
      setState(() {
        _markers.clear();
        
        // Add current user marker (blue)
        _markers.add(
          Marker(
            markerId: MarkerId('current_user'),
            position: _currentLocation!,
            infoWindow: InfoWindow(
              title: 'You ($currentUserName)',
              snippet: 'Your current location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
        
        // Add nearby users markers (red)
        for (var user in nearbyUsers) {
          final lat = user['latitude'] as double?;
          final lng = user['longitude'] as double?;
          
          if (lat != null && lng != null) {
            _markers.add(
              Marker(
                markerId: MarkerId(user['id'].toString()),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: user['username'] ?? 'Unknown User',
                  snippet: '${user['distance_km']?.toStringAsFixed(2) ?? '0'} km away',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () => _onUserMarkerTapped(user),
              ),
            );
          }
        }
      });
      
      print('📍 Updated location and found ${nearbyUsers.length} nearby users');
    } catch (e) {
      print('Error updating location and fetching nearby users: $e');
    }
  }
  void _onUserMarkerTapped(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user['profile_picture_url'] != null 
                ? NetworkImage(user['profile_picture_url']) 
                : null,
              child: user['profile_picture_url'] == null 
                ? Icon(Icons.person, size: 30) 
                : null,
            ),
            SizedBox(height: 12),
            Text(
              user['username'] ?? 'Unknown User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user['full_name'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text('${user['distance_km']?.toStringAsFixed(2) ?? '0'} km away'),
            if (user['city'] != null) 
              Text('📍 ${user['city']}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to user profile
                    print('Navigate to profile: ${user['id']}');
                  },
                  icon: Icon(Icons.person),
                  label: Text('View Profile'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to chat
                    print('Start chat with: ${user['id']}');
                  },
                  icon: Icon(Icons.chat),
                  label: Text('Chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _moveToCurrentLocation() {
    if (_currentLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text('This app needs location permission to show nearby users on the map.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeLocationServices();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLocation != null) {
      _moveToCurrentLocation();
    }
  }

  void _goToCurrentLocation() {
    _moveToCurrentLocation();
  }

  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _locationService.isRunning ? Icons.location_on : Icons.location_off,
              color: _locationService.isRunning ? Colors.green : Colors.red,
            ),
            onPressed: () {
              if (_locationService.isRunning) {
                _locationService.stopLocationUpdates();
                _nearbyUsersTimer?.cancel();
              } else {
                _initializeLocationServices();
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                SizedBox(width: 12),
                _buildFilterChip('Nearby'),
                SizedBox(width: 12),
                _buildFilterChip('Active'),
              ],
            ),
          ),

          // Google Map Area
          Expanded(
            child: Container(
              child: ClipRRect(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation ?? _initialCenter,
                        zoom: 12.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),

                    Positioned(
                      left: 16,
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search location',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    // Zoom controls
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _zoomIn,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.add, color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 2),
                          GestureDetector(
                            onTap: _zoomOut,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.remove, color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _goToCurrentLocation,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.my_location, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF2F0E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            CupertinoIcons.chevron_down,
            color: Colors.black,
            size: 20,
          ),
        ],
      ),
    );
  }
}