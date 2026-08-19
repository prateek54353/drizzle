import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../core/constants/weather_conditions.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;
  final String temperatureUnit;

  const CurrentWeather({
    super.key,
    required this.weather,
    required this.temperatureUnit,
  });

  @override
  Widget build(BuildContext context) {
    final tempUnit = temperatureUnit == 'fahrenheit' ? '°F' : '°C';
    final temp = temperatureUnit == 'fahrenheit' 
        ? (weather.temperature * 9 / 5) + 32 
        : weather.temperature;
    final feelsLike = temperatureUnit == 'fahrenheit' 
        ? (weather.apparentTemperature * 9 / 5) + 32 
        : weather.apparentTemperature;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          children: [
            Text(
              weather.condition.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 8),
            Text(
              '${temp.round()}$tempUnit',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Feels like ${feelsLike.round()}$tempUnit',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              weather.condition.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
