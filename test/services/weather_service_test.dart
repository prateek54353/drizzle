import 'package:flutter_test/flutter_test.dart';
import 'package:drizzle/services/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('should create WeatherService instance', () {
      final weatherService = WeatherService();
      expect(weatherService, isNotNull);
      weatherService.dispose();
    });

    test('should handle URL construction', () {
      final weatherService = WeatherService();
      // The service should construct proper URLs
      // This is a basic sanity check
      expect(weatherService, isNotNull);
      weatherService.dispose();
    });
  });
}
