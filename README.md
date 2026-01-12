# Posha

A Flutter recipe browsing app with search, categories, filters, and favorites functionality. Uses the [TheMealDB API](https://www.themealdb.com/api.php) for recipe data.

## Screenshots

_Add your app screenshots here_

## Folder Structure

```
lib/
├── constants/          # App-wide constants (colors, strings, text styles)
├── cubit/             # State management (BLoC/Cubit)
├── models/            # Data models
├── services/          # API and local storage services
├── utils/             # Utilities (router, theme, helpers)
└── views/             # UI screens and widgets
    ├── screens/       # Main app screens
    └── widgets/       # Reusable widgets

test/
├── cubit/             # Cubit unit tests (home, recipe detail)
├── models/            # Model unit tests (recipe model)
├── services/          # Service unit tests (API, local storage)
└── widgets/           # Widget tests (cards, buttons)
```

## Key Dependencies

- **State Management:** `flutter_bloc` (^9.1.1)
- **Routing:** `go_router` (^17.0.0)
- **Networking:** `http` (^1.6.0)
- **Local Storage:** `hive` (^2.2.3), `hive_flutter` (^1.1.0)
- **Dependency Injection:** `get_it` (^9.2.0)
- **UI/UX:** `skeletonizer` (^2.1.2), `cached_network_image` (^3.4.1), `google_fonts` (^6.3.2)
- **Video Player:** `youtube_player_flutter` (^9.1.3)

## Tested Environment

This app was developed and tested with:

- **Flutter:** 3.32.8
- **Dart:** 3.8.1
- **Gradle:** 8.9 (set in `android/gradle/wrapper/gradle-wrapper.properties`)
- **Android Gradle Plugin:** 8.7.3 (set in `android/settings.gradle.kts`)
- **Kotlin:** 2.1.0 (set in `android/settings.gradle.kts`)
- **Dart SDK:** `>=3.5.0 <4.0.0` (set in `pubspec.yaml`)

**Note:** To run this project on your machine, you may need to update these versions in the respective configuration files to match your Flutter SDK and Android build tools.
