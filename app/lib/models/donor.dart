import 'package:latlong2/latlong.dart';

class Donor {
  final String name;
  final String bloodGroup;
  final LatLng location;
  final String contact;

  Donor({
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.contact,
  });
}
