import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherDetails extends StatelessWidget {
  final Weather weather;
  final String windSpeedUnit;

  const WeatherDetails({
    super.key,
    required this.weather,
    required this.windSpeedUnit,
  });

  String getWindSpeedUnitSymbol() {
    switch (windSpeedUnit) {
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

  double getWindSpeed(double kmh) {
    switch (windSpeedUnit) {
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

  @override
  Widget build(BuildContext context) {
    final windSpeed = getWindSpeed(weather.windSpeed);
    final windUnit = getWindSpeedUnitSymbol();
    final visibility = weather.visibility / 1000; // Convert to km

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _DetailCard(
              icon: Icons.water_drop,
              label: 'Humidity',
              value: '${weather.humidity}%',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DetailCard(
              icon: Icons.air,
              label: 'Wind',
              value: '${windSpeed.toStringAsFixed(1)} $windUnit',
              subtitle: weather.windDirectionText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DetailCard(
              icon: Icons.sunny,
              label: 'UV Index',
              value: weather.uvIndex.toStringAsFixed(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DetailCard(
              icon: Icons.visibility,
              label: 'Visibility',
              value: '${visibility.toStringAsFixed(1)} km',
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
