import 'package:geolocator/geolocator.dart';
import 'geocoding_service.dart';
import '../models/location.dart';

class LocationService {
  final GeocodingService _geocodingService;

  LocationService({GeocodingService? geocodingService})
      : _geocodingService = geocodingService ?? GeocodingService();

  Future<bool> hasPermission() async {
    return await Geolocator.checkPermission() == LocationPermission.always ||
           await Geolocator.checkPermission() == LocationPermission.whileInUse;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition() async {
    final hasPermission = await this.hasPermission();
    
    if (!hasPermission) {
      final permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Location?> reverseGeocode(double lat, double lon) async {
    // Try to find the nearest city using approximate coordinates
    try {
      final results = await _geocodingService.searchNearbyCities(lat, lon);
      if (results.isNotEmpty) {
        return results.first;
      }
      // Fallback: create a location with coordinates
      return Location(
        name: 'Current Location',
        country: 'Unknown',
        latitude: lat,
        longitude: lon,
      );
    } catch (e) {
      // Fallback: create a location with coordinates
      return Location(
        name: 'Current Location',
        country: 'Unknown',
        latitude: lat,
        longitude: lon,
      );
    }
  }
}
