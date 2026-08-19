import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/location.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Location> _searchResults = [];
  List<Location> _recentLocations = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _loadRecentLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentLocations() async {
    final provider = context.read<WeatherProvider>();
    final recent = await provider.getRecentLocations();
    if (mounted) {
      setState(() {
        _recentLocations = recent;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      setState(() {
        _isSearching = true;
      });

      try {
        final provider = context.read<WeatherProvider>();
        final results = await provider.searchCity(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _selectLocation(Location location) async {
    final provider = context.read<WeatherProvider>();
    await provider.selectLocation(location);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return _buildRecentLocations();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No cities found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return _LocationTile(
          location: location,
          onTap: () => _selectLocation(location),
        );
      },
    );
  }

  Widget _buildRecentLocations() {
    if (_recentLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Locations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              final location = _recentLocations[index];
              return _LocationTile(
                location: location,
                onTap: () => _selectLocation(location),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const _LocationTile({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(location.name),
      subtitle: Text(location.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}


