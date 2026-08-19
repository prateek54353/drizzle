import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/weather_service.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

enum WeatherState {
  initial,
  loading,
  loaded,
  error,
  offline,
}

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  final GeocodingService _geocodingService;
  final LocationService _locationService;
  final StorageService _storageService;

  WeatherState _state = WeatherState.initial;
  Weather? _currentWeather;
  List<HourlyForecast> _hourlyForecast = [];
  List<DailyForecast> _dailyForecast = [];
  Location? _currentLocation;
  String? _errorMessage;
  bool _isCached = false;

  WeatherProvider({
    WeatherService? weatherService,
    GeocodingService? geocodingService,
    LocationService? locationService,
    StorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _geocodingService = geocodingService ?? GeocodingService(),
        _locationService = locationService ?? LocationService(),
        _storageService = storageService ?? StorageService();

  WeatherState get state => _state;
  Weather? get currentWeather => _currentWeather;
  List<HourlyForecast> get hourlyForecast => _hourlyForecast;
  List<DailyForecast> get dailyForecast => _dailyForecast;
  Location? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  bool get isCached => _isCached;

  // Settings
  String _temperatureUnit = 'celsius';
  String _windSpeedUnit = 'kmh';
  String _themeMode = 'system';
  bool _useCurrentLocation = true;

  String get temperatureUnit => _temperatureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  String get themeMode => _themeMode;
  bool get useCurrentLocation => _useCurrentLocation;

  Future<void> loadSettings() async {
    _temperatureUnit = await _storageService.getTemperatureUnit();
    _windSpeedUnit = await _storageService.getWindSpeedUnit();
    _themeMode = await _storageService.getThemeMode();
    _useCurrentLocation = await _storageService.getUseCurrentLocation();
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await _storageService.setTemperatureUnit(unit);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(String unit) async {
    _windSpeedUnit = unit;
    await _storageService.setWindSpeedUnit(unit);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _storageService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setUseCurrentLocation(bool use) async {
    _useCurrentLocation = use;
    await _storageService.setUseCurrentLocation(use);
    notifyListeners();
  }

  // Temperature conversion
  double getTemperature(double celsius) {
    if (_temperatureUnit == 'fahrenheit') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String getTemperatureUnitSymbol() {
    return _temperatureUnit == 'fahrenheit' ? '°F' : '°C';
  }

  // Wind speed conversion
  double getWindSpeed(double kmh) {
    switch (_windSpeedUnit) {
      case 'mph':
        return kmh * 0.621371;
      case 'ms':
        return kmh / 3.6;
      case 'kn':
        return kmh * 0.539957;
      default:
        return kmh;
    }
  }

  String getWindSpeedUnitSymbol() {
    switch (_windSpeedUnit) {
      case 'mph':
        return 'mph';
      case 'ms':
        return 'm/s';
      case 'kn':
        return 'kn';
      default:
        return 'km/h';
    }
  }

  // Initialize
  Future<void> initialize() async {
    await loadSettings();
    
    // Try to load cached data first
    final cachedData = await _storageService.getCachedWeatherData();
    final cacheValid = await _storageService.isCacheValid();
    
    if (cachedData != null && cacheValid) {
      _loadFromCache(cachedData);
    }
    
    // Try to load saved location
    final savedLocation = await _storageService.getSelectedLocation();
    if (savedLocation != null) {
      _currentLocation = savedLocation;
      await loadWeatherForLocation(savedLocation);
    } else if (_useCurrentLocation) {
      await loadWeatherForCurrentLocation();
    }
  }

  void _loadFromCache(Map<String, dynamic> cachedData) {
    try {
      _currentWeather = cachedData['current'] as Weather;
      _hourlyForecast = List<HourlyForecast>.from(cachedData['hourly'] as List);
      _dailyForecast = List<DailyForecast>.from(cachedData['daily'] as List);
      _isCached = true;
      _state = WeatherState.offline;
      notifyListeners();
    } catch (e) {
      // If cache is invalid, clear it
      _storageService.clearCache();
    }
  }

  Future<void> loadWeatherForCurrentLocation() async {
    _state = WeatherState.loading;
    _errorMessage = null;
    _isCached = false;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      final location = await _locationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      
      if (location != null) {
        _currentLocation = location;
        await _storageService.saveSelectedLocation(location);
        await _storageService.saveRecentLocation(location);
        await loadWeatherForLocation(location);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = WeatherState.error;
      notifyListeners();
    }
  }

  Future<void> loadWeatherForLocation(Location location) async {
    _state = WeatherState.loading;
    _errorMessage = null;
    _isCached = false;
    _currentLocation = location;
    notifyListeners();

    try {
      final data = await _weatherService.getCompleteWeatherData(
        location.latitude,
        location.longitude,
      );

      _currentWeather = data['current'] as Weather;
      _hourlyForecast = data['hourly'] as List<HourlyForecast>;
      _dailyForecast = data['daily'] as List<DailyForecast>;
      
      // Cache the data
      await _storageService.cacheWeatherData({
        'current': _currentWeather,
        'hourly': _hourlyForecast,
        'daily': _dailyForecast,
      });
      
      // Save as recent location
      await _storageService.saveRecentLocation(location);
      
      _state = WeatherState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      
      // Try to load from cache if network fails
      final cachedData = await _storageService.getCachedWeatherData();
      if (cachedData != null) {
        _loadFromCache(cachedData);
      } else {
        _state = WeatherState.error;
      }
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentLocation != null) {
      await loadWeatherForLocation(_currentLocation!);
    } else if (_useCurrentLocation) {
      await loadWeatherForCurrentLocation();
    }
  }

  Future<List<Location>> searchCity(String query) async {
    try {
      final results = await _geocodingService.searchCities(query);
      return results;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WeatherState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> selectLocation(Location location) async {
    await _storageService.saveSelectedLocation(location);
    await _storageService.saveRecentLocation(location);
    await loadWeatherForLocation(location);
  }

  Future<List<Location>> getRecentLocations() async {
    return await _storageService.getRecentLocations();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
