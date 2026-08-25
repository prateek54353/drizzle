# Drizzle Weather App

A modern, minimal weather application built with Flutter. Drizzle provides accurate weather information with a clean, user-friendly interface.

![Flutter](https://img.shields.io/badge/Flutter-3.13.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.13.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- **Current Weather**: Real-time weather data including temperature, feels-like temperature, humidity, wind speed, UV index, and visibility
- **Hourly Forecast**: 24-hour weather forecast with precipitation probability
- **7-Day Forecast**: Extended forecast with high/low temperatures and weather conditions
- **Location Services**: Automatic location detection with permission handling
- **City Search**: Search for cities worldwide with Open-Meteo geocoding
- **Recent Locations**: Quick access to previously searched locations
- **Offline Support**: Cached weather data available without internet connection
- **Theme Options**: Light, dark, and system theme support
- **Unit Conversion**: Switch between Celsius/Fahrenheit and various wind speed units
- **Pull-to-Refresh**: Easy weather data refresh with pull gesture
- **Sunrise/Sunset**: Daily sun times with daylight duration

## Screens

### Home Screen
- Current location display with search and settings buttons
- Large temperature display with weather icon
- Weather condition description
- Detail cards for humidity, wind, UV index, and visibility
- Horizontally scrollable hourly forecast
- 7-day forecast with temperature ranges
- Sunrise and sunset information

### Search Screen
- Debounced city search with Open-Meteo geocoding
- Recent locations history
- City results with country and region information

### Settings Screen
- Temperature unit selection (Celsius/Fahrenheit)
- Wind speed unit selection (km/h, mph, m/s, knots)
- Theme selection (System/Light/Dark)
- Location preference toggle
- About section with app information

## Installation

### Prerequisites
- Flutter SDK 3.13.0 or higher
- Dart SDK 3.13.0 or higher
- Android Studio / Xcode (for mobile development)
- Android device/emulator or iOS device/simulator

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd drizzle
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Architecture

Drizzle follows a clean, modular architecture with separation of concerns:

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration and routing
├── core/
│   ├── constants/           # App constants (weather conditions)
│   ├── theme/               # App theming (light/dark themes)
│   └── utils/               # Utility functions (unit conversions)
├── models/                  # Data models
│   ├── location.dart        # Location model
│   ├── weather.dart         # Weather model
│   └── forecast.dart        # Forecast models (hourly/daily)
├── services/                # Business logic and API calls
│   ├── weather_service.dart # Open-Meteo API integration
│   ├── geocoding_service.dart # City search API
│   ├── location_service.dart # Device location handling
│   └── storage_service.dart # Local storage management
├── providers/               # State management
│   └── weather_provider.dart # Weather state and settings
├── screens/                 # UI screens
│   ├── home_screen.dart     # Main weather dashboard
│   ├── search_screen.dart   # City search interface
│   └── settings_screen.dart # Settings interface
└── widgets/                 # Reusable UI components
    ├── location_header.dart # Location display header
    ├── current_weather.dart  # Current weather display
    ├── weather_details.dart  # Weather detail cards
    ├── hourly_forecast.dart # Hourly forecast widget
    ├── daily_forecast.dart  # Daily forecast widget
    └── sunrise_sunset.dart  # Sunrise/sunset display
```

## Dependencies

- **flutter**: Flutter SDK
- **http**: HTTP client for API calls
- **geolocator**: Location services
- **shared_preferences**: Local storage
- **provider**: State management

See [pubspec.yaml](pubspec.yaml) for complete dependency list.

## API

Drizzle uses the **Open-Meteo API** for weather data:
- No API key required
- Free and open-source
- Comprehensive weather data
- Global coverage

## Testing

Run the test suite:

```bash
flutter test
```

The project includes tests for:
- Model serialization and parsing
- Unit conversion functions
- Service behavior
- State management

## Code Quality

Run static analysis:

```bash
flutter analyze
```

## Building

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Publishing a release

Push a tag such as `v1.0.1` to publish a GitHub release. The release workflow
builds signed Android APKs for each ABI and an unsigned iOS IPA independently,
then attaches every successful artifact even when the other platform fails.

Before the first Android release, add these GitHub Actions secrets:

- `ANDROID_KEYSTORE_BASE64` — base64-encoded upload keystore
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

The Android artifacts are suitable for IzzyOnDroid after the corresponding tag
has been reviewed and the attached APK for the target ABI is selected.

## Configuration

### Platform Permissions

**Android** ([`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)):
- Internet access
- Fine location permission
- Coarse location permission

**iOS** ([`ios/Runner/Info.plist`](ios/Runner/Info.plist)):
- Location when in use permission description
- Location always and when in use permission description

## Features Details

### Weather Data
- Current temperature and apparent temperature
- Weather condition with emoji icons
- Precipitation and probability
- Humidity percentage
- Wind speed and direction
- UV index
- Visibility in kilometers
- Sunrise and sunset times
- Daylight duration

### Unit Conversions
- Temperature: Celsius ↔ Fahrenheit
- Wind speed: km/h ↔ mph ↔ m/s ↔ knots
- Distance: meters ↔ kilometers

### Storage
- User preferences (temperature unit, wind speed unit, theme)
- Selected location
- Recent locations (up to 5)
- Cached weather data (1-hour validity)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Open-Meteo** for providing free weather data
- **Flutter** team for the amazing framework
- Weather icons powered by Unicode emojis

## Author

Built with ❤️ using Flutter

---

**Note**: This is a demonstration project. For production use, consider adding additional features like weather alerts, radar maps, and more detailed forecasts.
