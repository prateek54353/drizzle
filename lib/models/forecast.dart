import '../core/constants/weather_conditions.dart';

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final WeatherCondition condition;
  final int precipitationProbability;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.precipitationProbability,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json, int index) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    
    return HourlyForecast(
      time: DateTime.parse(hourly['time'][index] as String),
      temperature: (hourly['temperature_2m'][index] as num).toDouble(),
      condition: WeatherConditionExtension.fromCode(hourly['weather_code'][index] as int),
      precipitationProbability: (hourly['precipitation_probability']?[index] as int?) ?? 0,
    );
  }

  bool get isCurrentHour {
    final now = DateTime.now();
    return time.year == now.year &&
           time.month == now.month &&
           time.day == now.day &&
           time.hour == now.hour;
  }

  String get conditionDisplayName => condition.displayName;
  String get conditionIcon => condition.icon;

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'condition': condition.index,
      'precipitationProbability': precipitationProbability,
    };
  }

  factory HourlyForecast.fromCacheJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: json['temperature'] as double,
      condition: WeatherCondition.values[json['condition'] as int],
      precipitationProbability: json['precipitationProbability'] as int,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final WeatherCondition condition;
  final double lowTemperature;
  final double highTemperature;
  final int precipitationProbability;

  DailyForecast({
    required this.date,
    required this.condition,
    required this.lowTemperature,
    required this.highTemperature,
    required this.precipitationProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    final daily = json['daily'] as Map<String, dynamic>;
    
    return DailyForecast(
      date: DateTime.parse(daily['time'][index] as String),
      condition: WeatherConditionExtension.fromCode(daily['weather_code'][index] as int),
      lowTemperature: (daily['temperature_2m_min'][index] as num).toDouble(),
      highTemperature: (daily['temperature_2m_max'][index] as num).toDouble(),
      precipitationProbability: daily['precipitation_probability_max'][index] as int? ?? 0,
    );
  }

  String get dayName {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String get conditionDisplayName => condition.displayName;
  String get conditionIcon => condition.icon;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'condition': condition.index,
      'lowTemperature': lowTemperature,
      'highTemperature': highTemperature,
      'precipitationProbability': precipitationProbability,
    };
  }

  factory DailyForecast.fromCacheJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date'] as String),
      condition: WeatherCondition.values[json['condition'] as int],
      lowTemperature: json['lowTemperature'] as double,
      highTemperature: json['highTemperature'] as double,
      precipitationProbability: json['precipitationProbability'] as int,
    );
  }
}
