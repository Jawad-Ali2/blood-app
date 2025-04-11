import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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

// class MapScreen extends StatefulWidget {
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   LatLng? userLocation;
//   List<Donor> donors = [];
//   final MapController _mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//     loadLocationAndData();
//   }
//
//   Future<void> loadLocationAndData() async {
//     try {
//       Position position = await LocationService.getCurrentLocation();
//       userLocation = LatLng(position.latitude, position.longitude);
//
//       // Simulated API data
//       donors = [
//         Donor(
//             name: 'Ali',
//             bloodGroup: 'O+',
//             location: LatLng(33.6844, 73.0479),
//             contact: '0300-1234567'),
//         Donor(
//             name: 'Sara',
//             bloodGroup: 'A-',
//             location: LatLng(33.6900, 73.0500),
//             contact: '0312-4567890'),
//         Donor(
//             name: 'Usman',
//             bloodGroup: 'B+',
//             location: LatLng(33.6980, 73.0400),
//             contact: '0345-9876543'),
//       ];
//
//       // Sort by distance
//       donors.sort((a, b) {
//         final distA = Geolocator.distanceBetween(
//           userLocation!.latitude,
//           userLocation!.longitude,
//           a.location.latitude,
//           a.location.longitude,
//         );
//         final distB = Geolocator.distanceBetween(
//           userLocation!.latitude,
//           userLocation!.longitude,
//           b.location.latitude,
//           b.location.longitude,
//         );
//         return distA.compareTo(distB);
//       });
//
//       setState(() {});
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//
//   void _goToUserLocation() {
//     if (mounted && userLocation != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _mapController.move(userLocation!, 13.0);
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (userLocation == null) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Nearby Donors"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.my_location),
//             onPressed: _goToUserLocation,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           SizedBox(
//               height: 300,
//               child: FlutterMap(
//                 // 31.309428, 74.204854
//                 // 31.308658, 74.204339
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         "https://tile.openstreetmap.org/{z}/{x}/{y}{r}.png",
//                     subdomains: ['a', 'b', 'c'],
//                   ),
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: userLocation!,
//                         width: 80,
//                         height: 80,
//                         child:
//                             Icon(Icons.person_pin, size: 40, color: Colors.red),
//                       ),
//                       ...donors.map(
//                         (d) => Marker(
//                           point: d.location,
//                           width: 80,
//                           height: 80,
//                           child: Icon(Icons.bloodtype,
//                               size: 32, color: Colors.blue),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               )),
//           Expanded(
//             child: ListView.builder(
//               itemCount: donors.length,
//               itemBuilder: (_, index) => DonorCard(
//                 donor: donors[index],
//                 userLocation: userLocation!,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  List<Donor> donors = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadLocationAndData();
  }

  Future<void> loadLocationAndData() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      userLocation = LatLng(position.latitude, position.longitude);

      donors = [
        Donor(
            name: 'Ali',
            bloodGroup: 'O+',
            location: LatLng(33.6844, 73.0479),
            contact: '0300-1234567'),
        Donor(
            name: 'Sara',
            bloodGroup: 'A-',
            location: LatLng(33.6900, 73.0500),
            contact: '0312-4567890'),
        Donor(
            name: 'Usman',
            bloodGroup: 'B+',
            location: LatLng(33.6980, 73.0400),
            contact: '0345-9876543'),
      ];

      setState(() {});
    } catch (e) {;
      print("Error: $e");
    }
  }

  void _goToUserLocation() {
    if (userLocation != null) {
      _mapController.move(userLocation!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.person_pin_circle_rounded, size: 35, color: Colors.teal[400]),
                  ),
                  ...donors.map(
                    (d) => Marker(
                      point: d.location,
                      width: 40,
                      height: 40,
                      child:
                          Icon(Icons.bloodtype, size: 32, color: Colors.blue),
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
}
