import 'package:flutter_test/flutter_test.dart';
import 'package:drizzle/models/location.dart';

void main() {
  group('Location', () {
    test('should create Location from JSON', () {
      final json = {
        'name': 'New York',
        'admin1': 'New York',
        'country': 'United States',
        'latitude': 40.7128,
        'longitude': -74.0060,
      };

      final location = Location.fromJson(json);

      expect(location.name, 'New York');
      expect(location.region, 'New York');
      expect(location.country, 'United States');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
    });

    test('should create Location from JSON without region', () {
      final json = {
        'name': 'London',
        'country': 'United Kingdom',
        'latitude': 51.5074,
        'longitude': -0.1278,
      };

      final location = Location.fromJson(json);

      expect(location.name, 'London');
      expect(location.region, null);
      expect(location.country, 'United Kingdom');
    });

    test('should convert Location to JSON', () {
      final location = Location(
        name: 'Paris',
        region: 'Île-de-France',
        country: 'France',
        latitude: 48.8566,
        longitude: 2.3522,
      );

      final json = location.toJson();

      expect(json['name'], 'Paris');
      expect(json['region'], 'Île-de-France');
      expect(json['country'], 'France');
      expect(json['latitude'], 48.8566);
      expect(json['longitude'], 2.3522);
    });

    test('should display full name with region', () {
      final location = Location(
        name: 'Tokyo',
        region: 'Tokyo',
        country: 'Japan',
        latitude: 35.6762,
        longitude: 139.6503,
      );

      expect(location.displayName, 'Tokyo, Tokyo, Japan');
    });

    test('should display name without region when region is null', () {
      final location = Location(
        name: 'Berlin',
        country: 'Germany',
        latitude: 52.5200,
        longitude: 13.4050,
      );

      expect(location.displayName, 'Berlin, Germany');
    });

    test('should display name only when country is Unknown', () {
      final location = Location(
        name: 'Current Location',
        country: 'Unknown',
        latitude: 0.0,
        longitude: 0.0,
      );

      expect(location.displayName, 'Current Location');
    });

    test('should implement equality correctly', () {
      final location1 = Location(
        name: 'Sydney',
        region: 'New South Wales',
        country: 'Australia',
        latitude: -33.8688,
        longitude: 151.2093,
      );

      final location2 = Location(
        name: 'Sydney',
        region: 'New South Wales',
        country: 'Australia',
        latitude: -33.8688,
        longitude: 151.2093,
      );

      final location3 = Location(
        name: 'Melbourne',
        country: 'Australia',
        latitude: -37.8136,
        longitude: 144.9631,
      );

      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
    });
  });
}
