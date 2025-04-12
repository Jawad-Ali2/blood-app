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

  const DonorCard({required this.donor, required this.userLocation});

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
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  List<Donor> donors = [];
  final MapController _mapController = MapController();
  final _dioClient = GetIt.instance.get<DioClient>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLocationAndData();
  }

  Future<void> loadLocationAndData() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      userLocation = LatLng(position.latitude, position.longitude);

      // Fetch donors from API
      final response =
          await _dioClient.dio.get("/user/donors/nearby", queryParameters: {
        "lat": userLocation!.latitude,
        "lng": userLocation!.longitude,
        "radius": "10" // 10km radius
      });

      List apiDonors = response.data['data'] ?? [];

      // Convert API donors to Donor model objects
      donors = apiDonors.map((donor) {
        // Parse coordinates string "lat,lng" to LatLng object
        List<String> coords = donor['coordinates'].split(',');
        double lat = double.parse(coords[0]);
        double lng = double.parse(coords[1]);

        return Donor(
            name: donor['username'] ?? 'Unknown',
            bloodGroup: donor['bloodGroup'] ?? 'Unknown',
            location: LatLng(lat, lng),
            contact: donor['phone'] ?? 'N/A');
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _goToUserLocation() {
    if (userLocation != null) {
      _mapController.move(userLocation!, 13.0);
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
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
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
                  ...donors.map(
                    (donor) => Marker(
                      point: donor.location,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.bloodtype,
                        size: 32,
                        color: _getBloodGroupColor(donor.bloodGroup),
                      ),
                    ),
                  ),
                ],
              ),
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
