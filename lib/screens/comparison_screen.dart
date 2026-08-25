import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/location.dart';
import '../models/weather.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Comparison'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          final locationData = provider.allLocationWeatherData;
          
          if (locationData.isEmpty) {
            return const Center(
              child: Text('No locations to compare'),
            );
          }

          final locations = locationData.values.map((data) => data['location'] as Location).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemperatureComparison(context, locations, provider),
                const SizedBox(height: 24),
                _buildConditionComparison(context, locations, provider),
                const SizedBox(height: 24),
                _buildDetailsComparison(context, locations, provider),
                const SizedBox(height: 24),
                _buildForecastComparison(context, locations, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemperatureComparison(BuildContext context, List<Location> locations, WeatherProvider provider) {
    final tempUnit = provider.temperatureUnit == 'fahrenheit' ? '°F' : '°C';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...locations.map((location) {
              final weatherData = provider.getWeatherDataForLocation(location);
              final weather = weatherData?['current'] as Weather?;
              
              if (weather == null) return const SizedBox.shrink();
              
              final temp = tempUnit == '°F' 
                  ? (weather.temperature * 9 / 5) + 32 
                  : weather.temperature;
              final feelsLike = tempUnit == '°F' 
                  ? (weather.apparentTemperature * 9 / 5) + 32 
                  : weather.apparentTemperature;
              
              return _ComparisonRow(
                label: location.displayName,
                value: '${temp.round()}$tempUnit',
                subtitle: 'Feels like ${feelsLike.round()}$tempUnit',
                icon: weather.conditionIcon,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionComparison(BuildContext context, List<Location> locations, WeatherProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...locations.map((location) {
              final weatherData = provider.getWeatherDataForLocation(location);
              final weather = weatherData?['current'] as Weather?;
              
              if (weather == null) return const SizedBox.shrink();
              
              return _ComparisonRow(
                label: location.displayName,
                value: weather.conditionDisplayName,
                icon: weather.conditionIcon,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsComparison(BuildContext context, List<Location> locations, WeatherProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Humidity', locations, provider, (weather) => '${weather.humidity}%'),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Wind', locations, provider, (weather) {
              final windSpeed = provider.getWindSpeed(weather.windSpeed);
              final windUnit = provider.getWindSpeedUnitSymbol();
              return '${windSpeed.toStringAsFixed(1)} $windUnit ${weather.windDirectionText}';
            }),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'UV Index', locations, provider, (weather) => weather.uvIndex.toStringAsFixed(1)),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Visibility', locations, provider, (weather) {
              final visibility = weather.visibility / 1000;
              return '${visibility.toStringAsFixed(1)} km';
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    List<Location> locations,
    WeatherProvider provider,
    String Function(Weather) getValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ...locations.map((location) {
          final weatherData = provider.getWeatherDataForLocation(location);
          final weather = weatherData?['current'] as Weather?;
          
          if (weather == null) return const SizedBox.shrink();
          
          return _ComparisonRow(
            label: location.displayName,
            value: getValue(weather),
          );
        }),
      ],
    );
  }

  Widget _buildForecastComparison(BuildContext context, List<Location> locations, WeatherProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tomorrow\'s Forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...locations.map((location) {
              final weatherData = provider.getWeatherDataForLocation(location);
              final dailyForecasts = weatherData?['daily'] as List?;
              
              if (dailyForecasts == null || dailyForecasts.isEmpty) return const SizedBox.shrink();
              
              final tomorrow = dailyForecasts.length > 1 ? dailyForecasts[1] : dailyForecasts[0];
              final tempUnit = provider.temperatureUnit == 'fahrenheit' ? '°F' : '°C';
              final lowTemp = tempUnit == '°F' 
                  ? (tomorrow.lowTemperature * 9 / 5) + 32 
                  : tomorrow.lowTemperature;
              final highTemp = tempUnit == '°F' 
                  ? (tomorrow.highTemperature * 9 / 5) + 32 
                  : tomorrow.highTemperature;
              
              return _ComparisonRow(
                label: location.displayName,
                value: '${lowTemp.round()}$tempUnit - ${highTemp.round()}$tempUnit',
                subtitle: tomorrow.conditionDisplayName,
                icon: tomorrow.conditionIcon,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final String? icon;

  const _ComparisonRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(
              icon!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
