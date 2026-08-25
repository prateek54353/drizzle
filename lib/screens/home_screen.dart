import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/location_header.dart';
import '../widgets/current_weather.dart';
import '../widgets/weather_details.dart';
import '../widgets/hourly_forecast.dart' show HourlyForecastWidget;
import '../widgets/daily_forecast.dart' show DailyForecastWidget;
import '../widgets/sunrise_sunset.dart';
import '../models/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedLocationIndex = 0;
  List<Location> _favoriteLocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
      _loadFavoriteLocations();
    });
  }

  Future<void> _loadFavoriteLocations() async {
    final provider = context.read<WeatherProvider>();
    final favorites = await provider.getFavoriteLocations();
    if (mounted) {
      setState(() {
        _favoriteLocations = favorites;
      });
    }
  }

  Future<void> _refresh() async {
    await context.read<WeatherProvider>().refresh();
    await _loadFavoriteLocations();
  }

  Future<void> _switchLocation(Location location) async {
    await context.read<WeatherProvider>().selectLocation(location);
    await _loadFavoriteLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case WeatherState.initial:
            case WeatherState.loading:
              return const _LoadingState();
            case WeatherState.loaded:
            case WeatherState.offline:
              return _LoadedContent(
                provider: provider,
                onRefresh: _refresh,
                onSwitchLocation: _switchLocation,
                favoriteLocations: _favoriteLocations,
                selectedLocationIndex: _selectedLocationIndex,
                onLocationIndexChanged: (index) {
                  setState(() {
                    _selectedLocationIndex = index;
                  });
                },
              );
            case WeatherState.error:
              return _ErrorState(
                errorMessage: provider.errorMessage ?? 'An error occurred',
                onRetry: _refresh,
              );
          }
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final WeatherProvider provider;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Location) onSwitchLocation;
  final List<Location> favoriteLocations;
  final int selectedLocationIndex;
  final Function(int) onLocationIndexChanged;

  const _LoadedContent({
    required this.provider,
    required this.onRefresh,
    required this.onSwitchLocation,
    required this.favoriteLocations,
    required this.selectedLocationIndex,
    required this.onLocationIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weather = provider.currentWeather;
    final location = provider.currentLocation;

    if (weather == null || location == null) {
      return const _LoadingState();
    }

    return SafeArea(
    child: RefreshIndicator(
    onRefresh: onRefresh,
    child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                LocationHeader(
                  location: location,
                  onSearchPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                  onSettingsPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  onLocationsPressed: () {
                    Navigator.pushNamed(context, '/locations');
                  },
                ),
                if (favoriteLocations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _LocationSelector(
                    locations: favoriteLocations,
                    selectedIndex: selectedLocationIndex,
                    onLocationSelected: (index) async {
                      onLocationIndexChanged(index);
                      await onSwitchLocation(favoriteLocations[index]);
                    },
                  ),
                ],
                const SizedBox(height: 24),
                CurrentWeather(
                  weather: weather,
                  temperatureUnit: provider.temperatureUnit,
                ),
                const SizedBox(height: 24),
                WeatherDetails(
                  weather: weather,
                  windSpeedUnit: provider.windSpeedUnit,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hourly Forecast',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                HourlyForecastWidget(
                  forecasts: provider.hourlyForecast,
                  temperatureUnit: provider.temperatureUnit,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '7-Day Forecast',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DailyForecastWidget(
                  forecasts: provider.dailyForecast,
                  temperatureUnit: provider.temperatureUnit,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sunrise & Sunset',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SunriseSunset(weather: weather),
                const SizedBox(height: 24),
                if (provider.isCached)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing cached data - no internet connection',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              icon: const Icon(Icons.search),
              label: const Text('Search for a city'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final List<Location> locations;
  final int selectedIndex;
  final Function(int) onLocationSelected;

  const _LocationSelector({
    required this.locations,
    required this.selectedIndex,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isSelected = index == selectedIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(location.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onLocationSelected(index);
                }
              },
              avatar: location.tag != null
                  ? Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          location.tag![0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
