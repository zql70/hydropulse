# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HydroPulse (水动力) is a Flutter-based intelligent water intake tracking app with Material 3 design.

## Environment

- Flutter SDK: >=3.38.0
- Dart SDK: ^3.8.0
- Android Studio 2025+, JDK 21, Android SDK 36

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Build APK
flutter build apk
```

## Architecture

**State Management**: Provider pattern with 4 ChangeNotifier providers

- `SettingsProvider` - User profile, daily goals, reminder settings
- `HydrationProvider` - Core water intake tracking logic
- `AchievementProvider` - Badge/challenge system
- `NotificationProvider` - Local notification scheduling

**Initialization Order** (in `main.dart`):
1. SettingsProvider.init() loads user profile
2. HydrationProvider.init() with daily goal from settings
3. NotificationProvider.init() schedules reminders if enabled

**Screens** (4 main pages):
- `DashboardPage` - Main intake tracking view
- `StatisticsPage` - Historical data and charts
- `AchievementPage` - Badges and challenges
- `ProfilePage` - User settings

**Data Layer**:
- Models in `lib/models/`: `DrinkRecord`, `UserProfile`, `Badge`, `Challenge`
- Persistence via `shared_preferences`

**Charts**: Uses `fl_chart` library for visualizations (hourly/weekly bar charts, pie charts)

## Key Dependencies

- `provider` - State management
- `fl_chart` - Data visualization
- `flutter_local_notifications` + `timezone` - Reminder system
- `shared_preferences` - Local storage
- `google_fonts` - Typography
- `image_picker` - Avatar selection
