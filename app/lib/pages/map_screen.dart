import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:get_it/get_it.dart';

import '../models/donor.dart';
import '../services/location_service.dart';

class DonorCard extends StatelessWidget {
  final Donor donor;
  final LatLng userLocation;

  const DonorCard({super.key, required this.donor, required this.userLocation});

  @override
  Widget build(BuildContext context) {
    final distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          donor.location.latitude,
          donor.location.longitude,
        ) /
        1000; // in km

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () {
          // Do something when tapped
        },
        title: Text(
          donor.bloodGroup,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${donor.name} • ${distance.toStringAsFixed(1)} km away"),
            SizedBox(height: 4),
            Text("Contact: ${donor.contact}"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Open call or message
          },
          child: Text("Contact"),
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  List<Donor> donors = [];
  final MapController _mapController = MapController();
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(13.0);
  final _dioClient = GetIt.instance.get<DioClient>();
  bool isLoading = true;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    loadLocationAndData();
  }

  @override
  void dispose() {
    // Clean up resources here if needed
    super.dispose();
  }

  Future<void> loadLocationAndData() async {
    try {
      // Use the static method that returns Position directly
      Position position = await LocationService.getCurrentPosition();

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      // Fetch donors from API
      final response =
          await _dioClient.dio.get("/user/donors/nearby", queryParameters: {
        "lat": userLocation!.latitude,
        "lng": userLocation!.longitude,
        "radius": "100" // 10km radius
      });

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      List apiDonors = response.data['data'] ?? [];

      // Convert API donors to Donor model objects
      donors = apiDonors.map((donor) {
        List<String> coords = donor['coordinates'].split(',');
        double lat = double.parse(coords[0]);
        double lng = double.parse(coords[1]);

        return Donor(
            name: donor['username'] ?? 'Unknown',
            bloodGroup: donor['bloodGroup'] ?? 'Unknown',
            location: LatLng(lat, lng),
            contact: donor['phone'] ?? 'N/A');
      }).toList();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _goToUserLocation() {
    if (userLocation != null && _mapInitialized) {
      try {
        _mapController.move(userLocation!, 13.0);
      } catch (e) {
        print("Error moving map: $e");
      }
    }
  }

  void _onMapCreated(MapController controller) {
    // Map is now initialized
    _mapInitialized = true;

    // Now it's safe to move the map to user location
    if (userLocation != null) {
      _goToUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null || isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onMapReady: () {
                _onMapCreated(_mapController);
              },
              initialCenter: userLocation!,
              initialZoom: 13.0,
              // maxZoom: 18.0,
              onPositionChanged: (pos, hasGesture) {
                double newZoom = pos.zoom;
                if ((newZoom - _zoomNotifier.value).abs() >= 0.2) {
                  _zoomNotifier.value = newZoom;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              ValueListenableBuilder<double>(
                  valueListenable: _zoomNotifier,
                  builder: (context, zoom, _) {
                    return MarkerLayer(
                      markers: [
                        // User marker
                        Marker(
                          point: userLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.person_pin_circle_rounded,
                              size: 35, color: Colors.teal[400]),
                        ),
                        // Donor markers
                        ...donors.map((donor) {

                          double scale = (zoom - 10).clamp(0.0, 1.0);
                          double fontSize = 10 + (scale * 2);
                          double markerSize = 28 + (scale * 10);

                          return Marker(
                            point: donor.location,
                            width: markerSize,
                            height: markerSize,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _getBloodGroupColor(donor.bloodGroup)
                                      .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Text(
                                  donor.bloodGroup,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.my_location, color: Colors.black),
                onPressed: _goToUserLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine marker color based on blood group
  Color _getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'A+':
      case 'A-':
        return Colors.red;
      case 'B+':
      case 'B-':
        return Colors.blue;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      case 'O+':
      case 'O-':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
