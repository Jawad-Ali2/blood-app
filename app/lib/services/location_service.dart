import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LocationResult> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) {
      return LocationResult(
        isSuccess: false,
        errorMessage: 'Location permissions are denied',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final coordinates = "${position.latitude},${position.longitude}";

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        return LocationResult(
          isSuccess: true,
          city: city,
          coordinates: coordinates,
        );
      } else {
        return LocationResult(
          isSuccess: false,
          errorMessage: 'Could not determine your city',
        );
      }
    } catch (e) {
      return LocationResult(
        isSuccess: false,
        errorMessage: 'Error getting location: $e',
      );
    }
  }

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }
}

class LocationResult {
  final bool isSuccess;
  final String? city;
  final String? coordinates;
  final String? errorMessage;

  LocationResult({
    required this.isSuccess,
    this.city,
    this.coordinates,
    this.errorMessage,
  });
}
