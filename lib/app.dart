import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/comparison_screen.dart';

class DrizzleApp extends StatelessWidget {
  const DrizzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider()..loadSettings(),
      child: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Drizzle',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppTheme.getThemeMode(provider.themeMode),
            home: const HomeScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/search':
                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SearchScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  );
                case '/settings':
                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  );
                case '/locations':
                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LocationsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  );
                case '/compare':
                  return MaterialPageRoute(
                    builder: (context) => const ComparisonScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
