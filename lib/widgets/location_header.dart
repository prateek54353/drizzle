import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationHeader extends StatelessWidget {
  final Location location;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLocationsPressed;

  const LocationHeader({
    super.key,
    required this.location,
    this.onSearchPressed,
    this.onSettingsPressed,
    this.onLocationsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location.displayName,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onLocationsPressed != null)
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: onLocationsPressed,
              tooltip: 'Saved Locations',
            ),
          if (onSearchPressed != null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: onSearchPressed,
              tooltip: 'Search',
            ),
          if (onSettingsPressed != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: onSettingsPressed,
              tooltip: 'Settings',
            ),
        ],
      ),
    );
  }
}
