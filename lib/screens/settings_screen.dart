import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _Section(
                title: 'Units',
                children: [
                  _SettingTile(
                    title: 'Temperature',
                    subtitle: provider.temperatureUnit == 'celsius'
                        ? 'Celsius'
                        : 'Fahrenheit',
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: true,
                      segments: const [
                        ButtonSegment<String>(
                          value: 'celsius',
                          label: Text('°C'),
                        ),
                        ButtonSegment<String>(
                          value: 'fahrenheit',
                          label: Text('°F'),
                        ),
                      ],
                      selected: {provider.temperatureUnit},
                      onSelectionChanged: (selected) {
                        provider.setTemperatureUnit(selected.first);
                      },
                    ),
                  ),
                  _SettingTile(
                    title: 'Wind Speed',
                    subtitle: _getWindSpeedUnitName(provider.windSpeedUnit),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: true,
                      segments: const [
                        ButtonSegment<String>(
                          value: 'kmh',
                          label: Text('km/h'),
                        ),
                        ButtonSegment<String>(
                          value: 'mph',
                          label: Text('mph'),
                        ),
                        ButtonSegment<String>(
                          value: 'ms',
                          label: Text('m/s'),
                        ),
                        ButtonSegment<String>(
                          value: 'kn',
                          label: Text('kn'),
                        ),
                      ],
                      selected: {provider.windSpeedUnit},
                      onSelectionChanged: (selected) {
                        provider.setWindSpeedUnit(selected.first);
                      },
                    ),
                  ),
                ],
              ),

              _Section(
                title: 'Appearance',
                children: [
                  _SettingTile(
                    title: 'Theme',
                    subtitle: _getThemeModeName(provider.themeMode),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: true,
                      segments: const [
                        ButtonSegment<String>(
                          value: 'system',
                          label: Text('System'),
                        ),
                        ButtonSegment<String>(
                          value: 'light',
                          label: Text('Light'),
                        ),
                        ButtonSegment<String>(
                          value: 'dark',
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {provider.themeMode},
                      onSelectionChanged: (selected) {
                        provider.setThemeMode(selected.first);
                      },
                    ),
                  ),
                ],
              ),

              _Section(
                title: 'Location',
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SwitchListTile(
                      title: const Text('Use Current Location'),
                      subtitle: const Text(
                        'Automatically use device location on launch',
                      ),
                      value: provider.useCurrentLocation,
                      onChanged: provider.setUseCurrentLocation,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),

              _Section(
                title: 'About',
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: const Text('Drizzle'),
                      subtitle: const Text('Version 1.0.0'),
                      leading: const Icon(Icons.info_outline),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: const Text('Open-Meteo API'),
                      subtitle: const Text(
                        'Weather data provided by Open-Meteo',
                      ),
                      leading: const Icon(Icons.cloud_outlined),
                      onTap: () {
                        // Could open a browser to Open-Meteo.
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getWindSpeedUnitName(String unit) {
    switch (unit) {
      case 'kmh':
        return 'Kilometers per hour';
      case 'mph':
        return 'Miles per hour';
      case 'ms':
        return 'Meters per second';
      case 'kn':
        return 'Knots';
      default:
        return 'Unknown';
    }
  }

  String _getThemeModeName(String mode) {
    switch (mode) {
      case 'system':
        return 'System default';
      case 'light':
        return 'Light mode';
      case 'dark':
        return 'Dark mode';
      default:
        return 'Unknown';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Give the segmented control the entire available width.
            SizedBox(
              width: double.infinity,
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }
}