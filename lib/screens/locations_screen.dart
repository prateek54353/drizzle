import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/location.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherForFavoriteLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            tooltip: 'Add Location',
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Location>>(
            future: provider.getFavoriteLocations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(
                  onAddLocation: () {
                    Navigator.pushNamed(context, '/search');
                  },
                );
              }

              final locations = snapshot.data!;
              return ReorderableListView.builder(
                itemCount: locations.length,
                onReorderItem: (oldIndex, newIndex) {
                  final item = locations.removeAt(oldIndex);
                  locations.insert(newIndex, item);
                  provider.reorderFavoriteLocations(locations);
                },
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final weatherData = provider.getWeatherDataForLocation(location);
                  
                  return _LocationCard(
                    key: ValueKey(location.name),
                    location: location,
                    weatherData: weatherData,
                    onTap: () async {
                      await provider.selectLocation(location);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    onFavoriteToggle: () async {
                      if (location.isFavorite) {
                        await provider.removeFavoriteLocation(location);
                      } else {
                        await provider.addFavoriteLocation(location);
                      }
                    },
                    onEdit: () {
                      _showEditDialog(context, location, provider);
                    },
                    onCompare: () {
                      _showCompareDialog(context, locations, provider);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Location location, WeatherProvider provider) {
    final nicknameController = TextEditingController(text: location.nickname ?? '');
    final tagController = TextEditingController(text: location.tag ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${location.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'e.g., Home, Work',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'e.g., Home, Work, Vacation',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedLocation = location.copyWith(
                nickname: nicknameController.text.isNotEmpty ? nicknameController.text : null,
                tag: tagController.text.isNotEmpty ? tagController.text : null,
              );
              await provider.updateLocationMetadata(updatedLocation);
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCompareDialog(BuildContext context, List<Location> locations, WeatherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _CompareDialog(
        locations: locations,
        provider: provider,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddLocation;

  const _EmptyState({required this.onAddLocation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved locations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite locations to quickly check their weather',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddLocation,
            icon: const Icon(Icons.add),
            label: const Text('Add Location'),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Location location;
  final Map<String, dynamic>? weatherData;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onEdit;
  final VoidCallback onCompare;

  const _LocationCard({
    super.key,
    required this.location,
    required this.weatherData,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onEdit,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    final weather = weatherData?['current'];
    final tempUnit = context.read<WeatherProvider>().temperatureUnit == 'fahrenheit' ? '°F' : '°C';
    
    String temperature = '--';
    String condition = 'Loading...';
    String icon = '❓';

    if (weather != null) {
      final temp = tempUnit == '°F' 
          ? (weather.temperature * 9 / 5) + 32 
          : weather.temperature;
      temperature = '${temp.round()}$tempUnit';
      condition = weather.conditionDisplayName;
      icon = weather.conditionIcon;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                location.displayName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (location.tag != null)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  location.tag!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.fullDisplayName),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(condition),
                const SizedBox(width: 8),
                Text(
                  temperature,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                location.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: location.isFavorite ? Colors.red : null,
              ),
              onPressed: onFavoriteToggle,
              tooltip: location.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CompareDialog extends StatefulWidget {
  final List<Location> locations;
  final WeatherProvider provider;

  const _CompareDialog({
    required this.locations,
    required this.provider,
  });

  @override
  State<_CompareDialog> createState() => _CompareDialogState();
}

class _CompareDialogState extends State<_CompareDialog> {
  final Set<Location> _selectedLocations = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compare Locations'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.locations.length,
          itemBuilder: (context, index) {
            final location = widget.locations[index];
            final isSelected = _selectedLocations.contains(location);
            
            return CheckboxListTile(
              title: Text(location.displayName),
              subtitle: Text(location.fullDisplayName),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedLocations.add(location);
                  } else {
                    _selectedLocations.remove(location);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedLocations.length >= 2
              ? () async {
                  await widget.provider.loadWeatherForComparison(_selectedLocations.toList());
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/compare');
                }
              : null,
          child: const Text('Compare'),
        ),
      ],
    );
  }
}
