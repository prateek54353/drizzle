import 'package:flutter_test/flutter_test.dart';
import 'package:drizzle/models/weather.dart';
import 'package:drizzle/core/constants/weather_conditions.dart';

void main() {
  group('Weather', () {
    test('should create Weather from JSON', () {
      final json = {
        'current': {
          'temperature_2m': 25.5,
          'apparent_temperature': 27.0,
          'weather_code': 1,
          'precipitation': 0.0,
          'precipitation_probability': 10,
          'relative_humidity_2m': 65,
          'wind_speed_10m': 15.0,
          'wind_direction_10m': 180,
          'uv_index': 5.0,
          'visibility': 10000.0,
        },
        'daily': {
          'sunrise': ['2024-01-01T06:30:00'],
          'sunset': ['2024-01-01T18:30:00'],
        },
      };

      final weather = Weather.fromJson(json);

      expect(weather.temperature, 25.5);
      expect(weather.apparentTemperature, 27.0);
      expect(weather.condition, WeatherCondition.mainlyClear);
      expect(weather.precipitation, 0.0);
      expect(weather.precipitationProbability, 10);
      expect(weather.humidity, 65);
      expect(weather.windSpeed, 15.0);
      expect(weather.windDirection, 180);
      expect(weather.uvIndex, 5.0);
      expect(weather.visibility, 10000.0);
    });

    test('should handle missing optional fields', () {
      final json = {
        'current': {
          'temperature_2m': 20.0,
          'apparent_temperature': 22.0,
          'weather_code': 0,
          'precipitation': 0.0,
          'precipitation_probability': 0,
          'relative_humidity_2m': 70,
          'wind_speed_10m': 10.0,
          'wind_direction_10m': 90,
          'visibility': 10000.0,
        },
        'daily': {
          'sunrise': ['2024-01-01T06:30:00'],
          'sunset': ['2024-01-01T18:30:00'],
        },
      };

      final weather = Weather.fromJson(json);

      expect(weather.uvIndex, 0.0); // Default value
    });

    test('should convert wind direction to text', () {
      final json = {
        'current': {
          'temperature_2m': 20.0,
          'apparent_temperature': 22.0,
          'weather_code': 0,
          'precipitation': 0.0,
          'precipitation_probability': 0,
          'relative_humidity_2m': 70,
          'wind_speed_10m': 10.0,
          'wind_direction_10m': 350, // 350 degrees is North
          'visibility': 10000.0,
        },
        'daily': {
          'sunrise': ['2024-01-01T06:30:00'],
          'sunset': ['2024-01-01T18:30:00'],
        },
      };

      final weather = Weather.fromJson(json);
      expect(weather.windDirectionText, 'N');
    });

    test('should calculate daylight duration', () {
      final json = {
        'current': {
          'temperature_2m': 20.0,
          'apparent_temperature': 22.0,
          'weather_code': 0,
          'precipitation': 0.0,
          'precipitation_probability': 0,
          'relative_humidity_2m': 70,
          'wind_speed_10m': 10.0,
          'wind_direction_10m': 90,
          'visibility': 10000.0,
        },
        'daily': {
          'sunrise': ['2024-01-01T06:00:00'],
          'sunset': ['2024-01-01T18:00:00'],
        },
      };

      final weather = Weather.fromJson(json);
      expect(weather.daylightDuration, '12h 0m');
    });
  });
}
