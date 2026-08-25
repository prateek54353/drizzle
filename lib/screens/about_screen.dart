import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final Uri _releasesUri = Uri.parse(
    'https://github.com/prateek54353/drizzle/releases',
  );
  static final Uri _repositoryUri = Uri.parse(
    'https://github.com/prateek54353/drizzle',
  );

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 88,
                      height: 88,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Drizzle',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.1',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Prateek',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A simple, privacy-friendly weather app built with free and open weather data.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => _open(context, _releasesUri),
                    icon: const Icon(Icons.system_update_outlined),
                    label: const Text('Check for updates'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'More Info & Support',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _InfoAction(
            icon: Icons.new_releases_outlined,
            title: 'Release notes',
            subtitle: 'See what changed in each version',
            onTap: () => _open(context, _releasesUri),
          ),
          _InfoAction(
            icon: Icons.code,
            title: 'GitHub',
            subtitle: 'View source code or report an issue',
            onTap: () => _open(context, _repositoryUri),
          ),
          const SizedBox(height: 32),
          Text(
            'Made with ♥',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InfoAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: onTap,
    );
  }
}
