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
          Icon(
            Icons.location_on,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
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
              icon: Icon(
                Icons.bookmark_border,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: onLocationsPressed,
              tooltip: 'Saved Locations',
            ),
          if (onSearchPressed != null)
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: onSearchPressed,
              tooltip: 'Search',
            ),
          if (onSettingsPressed != null)
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: onSettingsPressed,
              tooltip: 'Settings',
            ),
        ],
      ),
    );
  }
}
