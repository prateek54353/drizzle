import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _selectedLocationKey = 'selected_location';
  static const String _recentLocationsKey = 'recent_locations';
  static const String _favoriteLocationsKey = 'favorite_locations';
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

  // Favorite locations
  Future<void> saveFavoriteLocation(Location location) async {
    final prefs = await _prefs;
    final favoriteJson = prefs.getStringList(_favoriteLocationsKey) ?? [];

    // Check if already exists
    final existingIndex = favoriteJson.indexWhere((jsonString) {
      try {
        final loc = Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
        return loc == location;
      } catch (e) {
        return false;
      }
    });

    // If exists, update it with new data (including isFavorite = true)
    if (existingIndex != -1) {
      final updatedLocation = location.copyWith(isFavorite: true, order: existingIndex);
      favoriteJson[existingIndex] = jsonEncode(updatedLocation.toJson());
    } else {
      // Add as new favorite
      final newLocation = location.copyWith(isFavorite: true, order: favoriteJson.length);
      favoriteJson.add(jsonEncode(newLocation.toJson()));
    }

    await prefs.setStringList(_favoriteLocationsKey, favoriteJson);
  }

  Future<void> removeFavoriteLocation(Location location) async {
    final prefs = await _prefs;
    final favoriteJson = prefs.getStringList(_favoriteLocationsKey) ?? [];

    favoriteJson.removeWhere((jsonString) {
      try {
        final loc = Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
        return loc == location;
      } catch (e) {
        return false;
      }
    });

    // Reorder remaining locations
    final reorderedFavorites = <String>[];
    for (int i = 0; i < favoriteJson.length; i++) {
      try {
        final loc = Location.fromJson(jsonDecode(favoriteJson[i]) as Map<String, dynamic>);
        final updatedLoc = loc.copyWith(order: i);
        reorderedFavorites.add(jsonEncode(updatedLoc.toJson()));
      } catch (e) {
        // Skip invalid entries
      }
    }

    await prefs.setStringList(_favoriteLocationsKey, reorderedFavorites);
  }

  Future<List<Location>> getFavoriteLocations() async {
    final prefs = await _prefs;
    final favoriteJson = prefs.getStringList(_favoriteLocationsKey) ?? [];

    final locations = <Location>[];
    for (final jsonString in favoriteJson) {
      try {
        locations.add(Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>));
      } catch (e) {
        // Skip invalid entries
      }
    }

    // Sort by order
    locations.sort((a, b) => a.order.compareTo(b.order));
    return locations;
  }

  Future<void> reorderFavoriteLocations(List<Location> locations) async {
    final prefs = await _prefs;
    final reorderedJson = <String>[];

    for (int i = 0; i < locations.length; i++) {
      final updatedLocation = locations[i].copyWith(order: i);
      reorderedJson.add(jsonEncode(updatedLocation.toJson()));
    }

    await prefs.setStringList(_favoriteLocationsKey, reorderedJson);
  }

  Future<void> updateLocationMetadata(Location location) async {
    final prefs = await _prefs;
    final favoriteJson = prefs.getStringList(_favoriteLocationsKey) ?? [];

    final updatedJson = <String>[];
    bool found = false;

    for (final jsonString in favoriteJson) {
      try {
        final loc = Location.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
        if (loc == location) {
          updatedJson.add(jsonEncode(location.toJson()));
          found = true;
        } else {
          updatedJson.add(jsonString);
        }
      } catch (e) {
        // Skip invalid entries
      }
    }

    // If not found in favorites, it might be the selected location
    if (!found) {
      final selectedLocation = await getSelectedLocation();
      if (selectedLocation != null && selectedLocation == location) {
        await saveSelectedLocation(location);
      }
    } else {
      await prefs.setStringList(_favoriteLocationsKey, updatedJson);
    }
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
