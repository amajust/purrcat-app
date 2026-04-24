# PurrCat App 🐱

A Flutter mobile application for cat lovers community.

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter (Dart SDK ^3.11.5) |
| **State Management** | Provider (^6.1.2) |
| **Navigation** | GoRouter (^14.1.4) |
| **HTTP Client** | Dio (^5.4.3), HTTP (^1.2.1) |
| **Local Storage** | Shared Preferences (^2.2.3) |
| **Internationalization** | Intl (^0.19.0) |
| **UI Icons** | Cupertino Icons (^1.0.8) |
| **Material Design** | Uses Material 3 design system |
| **Theme** | Orange color scheme (seed: Colors.orange) |

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── auth_provider.dart    # Authentication state management
└── utils/
    └── routes.dart           # GoRouter navigation config
```

## Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ Windows
- ✅ macOS

## Getting Started

1. **Install Flutter SDK** (v3.11.5+)
   ```bash
   flutter --version
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for platform**
   ```bash
   flutter build apk          # Android
   flutter build ios          # iOS
   flutter build web          # Web
   ```

## Development

- **Linting**: Uses `flutter_lints` package
- **Analysis**: Configured in `analysis_options.yaml`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Dio Package](https://pub.dev/packages/dio)
