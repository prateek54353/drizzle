import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _selectedLocationKey = 'selected_location';
  static const String _recentLocationsKey = 'recent_locations';
  static const String _cachedWeatherKey = 'cached_weather';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _themeModeKey = 'theme_mode';
  static const String _useCurrentLocationKey = 'use_current_location';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Location storage
  Future<void> saveSelectedLocation(Location location) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedLocationKey, json.encode(location.toJson()));
  }

  Future<Location?> getSelectedLocation() async {
    final prefs = await _prefs;
    final locationJson = prefs.getString(_selectedLocationKey);
    if (locationJson == null) return null;
    
    try {
      return Location.fromJson(jsonDecode(locationJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSelectedLocation() async {
    final prefs = await _prefs;
    await prefs.remove(_selectedLocationKey);
  }

  // Recent locations
  Future<void> saveRecentLocation(Location location) async {
    final prefs = await _prefs;
    final recentJson = prefs.getStringList(_recentLocationsKey) ?? [];
    
    // Remove if already exists
    recentJson.removeWhere((jsonString) {
      try {
        final loc = Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
        return loc == location;
      } catch (e) {
        return false;
      }
    });
    
    // Add to front
    recentJson.insert(0, jsonEncode(location.toJson()));
    
    // Keep only last 5
    if (recentJson.length > 5) {
      recentJson.removeRange(5, recentJson.length);
    }
    
    await prefs.setStringList(_recentLocationsKey, recentJson);
  }

  Future<List<Location>> getRecentLocations() async {
    final prefs = await _prefs;
    final recentJson = prefs.getStringList(_recentLocationsKey) ?? [];
    
    final locations = <Location>[];
    for (final jsonString in recentJson) {
      try {
        locations.add(Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>));
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    return locations;
  }

  // Weather cache
  Future<void> cacheWeatherData(Map<String, dynamic> weatherData) async {
    final prefs = await _prefs;
    
    // Convert weather objects to serializable format
    final serializableData = {
      'current': (weatherData['current'] as Weather).toJson(),
      'hourly': (weatherData['hourly'] as List<HourlyForecast>)
          .map((forecast) => forecast.toJson())
          .toList(),
      'daily': (weatherData['daily'] as List<DailyForecast>)
          .map((forecast) => forecast.toJson())
          .toList(),
    };
    
    await prefs.setString(_cachedWeatherKey, jsonEncode(serializableData));
    await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    final prefs = await _prefs;
    final weatherJson = prefs.getString(_cachedWeatherKey);
    if (weatherJson == null) return null;
    
    try {
      final data = jsonDecode(weatherJson) as Map<String, dynamic>;
      
      return {
        'current': Weather.fromCacheJson(data['current'] as Map<String, dynamic>),
        'hourly': (data['hourly'] as List)
            .map((json) => HourlyForecast.fromCacheJson(json as Map<String, dynamic>))
            .toList(),
        'daily': (data['daily'] as List)
            .map((json) => DailyForecast.fromCacheJson(json as Map<String, dynamic>))
            .toList(),
      };
    } catch (e) {
      return null;
    }
  }

  Future<DateTime?> getCacheTimestamp() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 1)}) async {
    final timestamp = await getCacheTimestamp();
    if (timestamp == null) return false;
    
    final age = DateTime.now().difference(timestamp);
    return age < maxAge;
  }

  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(_cachedWeatherKey);
    await prefs.remove(_cacheTimestampKey);
  }

  // Settings
  Future<void> setTemperatureUnit(String unit) async {
    final prefs = await _prefs;
    await prefs.setString(_temperatureUnitKey, unit);
  }

  Future<String> getTemperatureUnit() async {
    final prefs = await _prefs;
    return prefs.getString(_temperatureUnitKey) ?? 'celsius';
  }

  Future<void> setWindSpeedUnit(String unit) async {
    final prefs = await _prefs;
    await prefs.setString(_windSpeedUnitKey, unit);
  }

  Future<String> getWindSpeedUnit() async {
    final prefs = await _prefs;
    return prefs.getString(_windSpeedUnitKey) ?? 'kmh';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> setUseCurrentLocation(bool use) async {
    final prefs = await _prefs;
    await prefs.setBool(_useCurrentLocationKey, use);
  }

  Future<bool> getUseCurrentLocation() async {
    final prefs = await _prefs;
    return prefs.getBool(_useCurrentLocationKey) ?? true;
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
