enum WeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}

extension WeatherConditionExtension on WeatherCondition {
  String get displayName {
    switch (this) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.mainlyClear:
        return 'Mainly Clear';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.overcast:
        return 'Overcast';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.drizzle:
        return 'Drizzle';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.unknown:
        return 'Unknown';
    }
  }

  String get icon {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.mainlyClear:
        return '🌤️';
      case WeatherCondition.partlyCloudy:
        return '⛅';
      case WeatherCondition.overcast:
        return '☁️';
      case WeatherCondition.fog:
        return '🌫️';
      case WeatherCondition.drizzle:
        return '🌦️';
      case WeatherCondition.rain:
        return '🌧️';
      case WeatherCondition.snow:
        return '❄️';
      case WeatherCondition.thunderstorm:
        return '⛈️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }

  static WeatherCondition fromCode(int code) {
    if (code == 0) return WeatherCondition.clear;
    if (code == 1) return WeatherCondition.mainlyClear;
    if (code == 2) return WeatherCondition.partlyCloudy;
    if (code == 3) return WeatherCondition.overcast;
    if (code >= 45 && code <= 48) return WeatherCondition.fog;
    if (code >= 51 && code <= 57) return WeatherCondition.drizzle;
    if (code >= 61 && code <= 67) return WeatherCondition.rain;
    if (code >= 71 && code <= 77) return WeatherCondition.snow;
    if (code >= 80 && code <= 82) return WeatherCondition.rain;
    if (code >= 85 && code <= 86) return WeatherCondition.snow;
    if (code >= 95 && code <= 99) return WeatherCondition.thunderstorm;
    return WeatherCondition.unknown;
  }
}
