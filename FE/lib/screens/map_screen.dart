import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  // San Francisco coordinates
  static const LatLng _center = LatLng(37.7749, -122.4194);

  // Set of markers for locations
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('alcatraz'),
      position: LatLng(37.8267, -122.4233),
      infoWindow: InfoWindow(title: 'Alcatraz Island'),
    ),
    Marker(
      markerId: MarkerId('golden_gate'),
      position: LatLng(37.8199, -122.4783),
      infoWindow: InfoWindow(title: 'Golden Gate Bridge'),
    ),
    Marker(
      markerId: MarkerId('india_basin'),
      position: LatLng(37.7367, -122.3734),
      infoWindow: InfoWindow(title: 'India Basin Shoreline'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _goToCurrentLocation() {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_center, 14.0),
    );
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
                        target: _center,
                        zoom: 12.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false, // We'll use custom button
                      zoomControlsEnabled: false, // We'll use custom controls
                    ),

                    Positioned(
                      left: 16,
                      top: 16,
                      right: 16,
                      child: // Search Bar
                          Container(
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
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey.shade500),
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
                              child:
                                  Icon(Icons.my_location, color: Colors.black),
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
