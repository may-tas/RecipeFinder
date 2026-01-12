# Posha

A Flutter recipe browsing app with search, categories, filters, and favorites functionality. Uses the [TheMealDB API](https://www.themealdb.com/api.php) for recipe data.


## Screenshots
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 34 40 AM" src="https://github.com/user-attachments/assets/0cf11a15-2624-4511-b7dc-4f1f822e9578" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 00 AM" src="https://github.com/user-attachments/assets/e4474d48-9bb5-4636-96d5-f000e99b0d40" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 34 46 AM" src="https://github.com/user-attachments/assets/acedd036-2284-4262-96ce-7164faa2a917" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 13 AM" src="https://github.com/user-attachments/assets/f0cc094c-74f3-4153-958f-f170634b735d" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 19 AM" src="https://github.com/user-attachments/assets/ab7546f5-19c8-478e-9e55-4d6126dbd84c" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 28 AM" src="https://github.com/user-attachments/assets/9f10eb2b-9c46-463d-9280-f307a68028d6" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 37 AM" src="https://github.com/user-attachments/assets/0cf85b46-008c-485f-a16b-a3eaf117af8e" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 42 AM" src="https://github.com/user-attachments/assets/4ad5ae89-b809-41e8-8425-29f7db7a5f62" />
<img width="275" height="648" alt="Screenshot 2026-01-12 at 8 35 51 AM" src="https://github.com/user-attachments/assets/cba61f2e-7ee1-4f66-bf73-cab5f13ff24e" />

## Recording
https://github.com/user-attachments/assets/64504619-35fc-456d-a5e7-06cdf2ced0a1

## Download APK
[APK](https://github.com/may-tas/RecipeFinder/blob/main/release-apk/app-release.apk)

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
