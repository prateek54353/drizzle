import 'package:flutter_test/flutter_test.dart';
import 'package:drizzle/models/forecast.dart';
import 'package:drizzle/core/constants/weather_conditions.dart';

void main() {
  group('HourlyForecast', () {
    test('should create HourlyForecast from JSON', () {
      final json = {
        'hourly': {
          'time': ['2024-01-01T12:00:00'],
          'temperature_2m': [25.0],
          'weather_code': [1],
          'precipitation_probability': [20],
        },
      };

      final forecast = HourlyForecast.fromJson(json, 0);

      expect(forecast.time.year, 2024);
      expect(forecast.temperature, 25.0);
      expect(forecast.condition, WeatherCondition.mainlyClear);
      expect(forecast.precipitationProbability, 20);
    });

    test('should handle missing precipitation probability', () {
      final json = {
        'hourly': {
          'time': ['2024-01-01T12:00:00'],
          'temperature_2m': [25.0],
          'weather_code': [1],
          'precipitation_probability': [0],
        },
      };

      final forecast = HourlyForecast.fromJson(json, 0);

      expect(forecast.precipitationProbability, 0);
    });

    test('should identify current hour correctly', () {
      final now = DateTime.now();
      final json = {
        'hourly': {
          'time': [now.toIso8601String()],
          'temperature_2m': [25.0],
          'weather_code': [1],
          'precipitation_probability': [20],
        },
      };

      final forecast = HourlyForecast.fromJson(json, 0);

      expect(forecast.isCurrentHour, true);
    });
  });

  group('DailyForecast', () {
    test('should create DailyForecast from JSON', () {
      final json = {
        'daily': {
          'time': ['2024-01-01'],
          'weather_code': [1],
          'temperature_2m_min': [15.0],
          'temperature_2m_max': [25.0],
          'precipitation_probability_max': [30],
        },
      };

      final forecast = DailyForecast.fromJson(json, 0);

      expect(forecast.date.year, 2024);
      expect(forecast.lowTemperature, 15.0);
      expect(forecast.highTemperature, 25.0);
      expect(forecast.condition, WeatherCondition.mainlyClear);
      expect(forecast.precipitationProbability, 30);
    });

    test('should display Today for current date', () {
      final now = DateTime.now();
      final json = {
        'daily': {
          'time': [now.toIso8601String().split('T')[0]],
          'weather_code': [1],
          'temperature_2m_min': [15.0],
          'temperature_2m_max': [25.0],
          'precipitation_probability_max': [30],
        },
      };

      final forecast = DailyForecast.fromJson(json, 0);

      expect(forecast.dayName, 'Today');
    });

    test('should display Tomorrow for next day', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final json = {
        'daily': {
          'time': [tomorrow.toIso8601String().split('T')[0]],
          'weather_code': [1],
          'temperature_2m_min': [15.0],
          'temperature_2m_max': [25.0],
          'precipitation_probability_max': [30],
        },
      };

      final forecast = DailyForecast.fromJson(json, 0);

      expect(forecast.dayName, 'Tomorrow');
    });

    test('should display day name for other dates', () {
      final json = {
        'daily': {
          'time': ['2024-01-01'], // Monday
          'weather_code': [1],
          'temperature_2m_min': [15.0],
          'temperature_2m_max': [25.0],
          'precipitation_probability_max': [30],
        },
      };

      final forecast = DailyForecast.fromJson(json, 0);

      expect(forecast.dayName, 'Mon');
    });
  });
}
