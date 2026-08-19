import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,precipitation_probability,weather_code,wind_speed_10m,wind_direction_10m,uv_index,visibility',
      'hourly': 'temperature_2m,weather_code,precipitation_probability',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await _client.get(url).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout');
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final data = await getWeatherData(lat, lon);
    return Weather.fromJson(data);
  }

  Future<List<HourlyForecast>> getHourlyForecast(double lat, double lon) async {
    final data = await getWeatherData(lat, lon);
    final hourly = <HourlyForecast>[];
    
    final hourlyData = data['hourly'] as Map<String, dynamic>;
    final times = hourlyData['time'] as List;
    
    for (int i = 0; i < times.length; i++) {
      hourly.add(HourlyForecast.fromJson(data, i));
    }
    
    return hourly;
  }

  Future<List<DailyForecast>> getDailyForecast(double lat, double lon) async {
    final data = await getWeatherData(lat, lon);
    final daily = <DailyForecast>[];
    
    final dailyData = data['daily'] as Map<String, dynamic>;
    final times = dailyData['time'] as List;
    
    for (int i = 0; i < times.length; i++) {
      daily.add(DailyForecast.fromJson(data, i));
    }
    
    return daily;
  }

  Future<Map<String, dynamic>> getCompleteWeatherData(double lat, double lon) async {
    final data = await getWeatherData(lat, lon);
    
    return {
      'current': Weather.fromJson(data),
      'hourly': List.generate(
        (data['hourly']['time'] as List).length,
        (i) => HourlyForecast.fromJson(data, i),
      ),
      'daily': List.generate(
        (data['daily']['time'] as List).length,
        (i) => DailyForecast.fromJson(data, i),
      ),
    };
  }

  void dispose() {
    _client.close();
  }
}
