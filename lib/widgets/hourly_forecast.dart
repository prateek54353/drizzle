import 'package:flutter/material.dart';
import '../models/forecast.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final String temperatureUnit;

  const HourlyForecastWidget({
    super.key,
    required this.forecasts,
    required this.temperatureUnit,
  });

  @override
  Widget build(BuildContext context) {
    // Show next 24 hours
    final hourlyForecasts = forecasts.take(24).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hourlyForecasts.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecasts[index];
          final isCurrentHour = forecast.isCurrentHour;
          final tempUnit = temperatureUnit == 'fahrenheit' ? '°F' : '°C';
          final temp = temperatureUnit == 'fahrenheit' 
              ? (forecast.temperature * 9 / 5) + 32 
              : forecast.temperature;

          return _HourlyItem(
            time: forecast.time,
            icon: forecast.conditionIcon,
            temperature: '${temp.round()}$tempUnit',
            rainProbability: forecast.precipitationProbability,
            isCurrentHour: isCurrentHour,
          );
        },
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final DateTime time;
  final String icon;
  final String temperature;
  final int rainProbability;
  final bool isCurrentHour;

  const _HourlyItem({
    required this.time,
    required this.icon,
    required this.temperature,
    required this.rainProbability,
    required this.isCurrentHour,
  });

  @override
  Widget build(BuildContext context) {
    final hour = time.hour;
    final displayTime = hour == 0 ? '12 AM' : hour < 12 ? '$hour AM' : hour == 12 ? '12 PM' : '${hour - 12} PM';

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isCurrentHour
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isCurrentHour ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            temperature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (rainProbability > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 2),
                Text(
                  '$rainProbability%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
