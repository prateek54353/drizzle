import '../core/constants/weather_conditions.dart';

class Weather {
  final double temperature;
  final double apparentTemperature;
  final WeatherCondition condition;
  final double precipitation;
  final int precipitationProbability;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double uvIndex;
  final double visibility;
  final DateTime sunrise;
  final DateTime sunset;

  Weather({
    required this.temperature,
    required this.apparentTemperature,
    required this.condition,
    required this.precipitation,
    required this.precipitationProbability,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      condition: WeatherConditionExtension.fromCode(current['weather_code'] as int),
      precipitation: (current['precipitation'] as num).toDouble(),
      precipitationProbability: current['precipitation_probability'] as int? ?? 0,
      humidity: current['relative_humidity_2m'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: current['wind_direction_10m'] as int,
      uvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
      visibility: (current['visibility'] as num?)?.toDouble() ?? 10000.0,
      sunrise: DateTime.parse(daily['sunrise'][0] as String),
      sunset: DateTime.parse(daily['sunset'][0] as String),
    );
  }

  String get windDirectionText {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final normalizedDirection = windDirection % 360;
    final index = ((normalizedDirection + 22.5) / 45).round() % 8;
    return directions[index];
  }

  String get daylightDuration {
    final duration = sunset.difference(sunrise);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get conditionDisplayName => condition.displayName;
  String get conditionIcon => condition.icon;

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'condition': condition.index,
      'precipitation': precipitation,
      'precipitationProbability': precipitationProbability,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'uvIndex': uvIndex,
      'visibility': visibility,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
    };
  }

  factory Weather.fromCacheJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['temperature'] as double,
      apparentTemperature: json['apparentTemperature'] as double,
      condition: WeatherCondition.values[json['condition'] as int],
      precipitation: json['precipitation'] as double,
      precipitationProbability: json['precipitationProbability'] as int,
      humidity: json['humidity'] as int,
      windSpeed: json['windSpeed'] as double,
      windDirection: json['windDirection'] as int,
      uvIndex: json['uvIndex'] as double,
      visibility: json['visibility'] as double,
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
    );
  }
}
