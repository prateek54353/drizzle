import 'package:flutter/material.dart';
import '../models/weather.dart';

class SunriseSunset extends StatelessWidget {
  final Weather weather;

  const SunriseSunset({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SunInfo(
              icon: Icons.wb_sunny,
              label: 'Sunrise',
              time: _formatTime(weather.sunrise),
            ),
            Container(
              height: 40,
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            _SunInfo(
              icon: Icons.nights_stay,
              label: 'Sunset',
              time: _formatTime(weather.sunset),
            ),
            Container(
              height: 40,
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            _SunInfo(
              icon: Icons.schedule,
              label: 'Daylight',
              time: weather.daylightDuration,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}

class _SunInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _SunInfo({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
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
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
