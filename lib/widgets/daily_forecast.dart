import 'package:flutter/material.dart';
import '../models/forecast.dart';
import '../core/constants/weather_conditions.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final String temperatureUnit;

  const DailyForecastWidget({
    super.key,
    required this.forecasts,
    required this.temperatureUnit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: forecasts.length,
      itemBuilder: (context, index) {
        final forecast = forecasts[index];
        final tempUnit = temperatureUnit == 'fahrenheit' ? '°F' : '°C';
        final lowTemp = temperatureUnit == 'fahrenheit' 
            ? (forecast.lowTemperature * 9 / 5) + 32 
            : forecast.lowTemperature;
        final highTemp = temperatureUnit == 'fahrenheit' 
            ? (forecast.highTemperature * 9 / 5) + 32 
            : forecast.highTemperature;

        return _DailyItem(
          day: forecast.dayName,
          icon: forecast.condition.icon,
          condition: forecast.condition.displayName,
          lowTemperature: '${lowTemp.round()}$tempUnit',
          highTemperature: '${highTemp.round()}$tempUnit',
          rainProbability: forecast.precipitationProbability,
        );
      },
    );
  }
}

class _DailyItem extends StatelessWidget {
  final String day;
  final String icon;
  final String condition;
  final String lowTemperature;
  final String highTemperature;
  final int rainProbability;

  const _DailyItem({
    required this.day,
    required this.icon,
    required this.condition,
    required this.lowTemperature,
    required this.highTemperature,
    required this.rainProbability,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              condition,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          if (rainProbability > 0) ...[
            Icon(
              Icons.water_drop,
              size: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 40,
              child: Text(
                '$rainProbability%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                    ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            lowTemperature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.7, // Placeholder for temperature range
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            highTemperature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
