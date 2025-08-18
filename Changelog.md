# Changelog

All notable changes to the Aayu project will be documented in this file.

## [2025-08-18] - Migration from Kotlin to Flutter

### Changed
- **Complete Technology Stack Migration**
  - Migrated from Kotlin/Jetpack Compose to Flutter/Dart
  - Replaced Gradle build system with Flutter's build system
  - Changed from single-activity Android architecture to Flutter's widget-based architecture

### Added
- **Flutter Project Structure**
  - Created `pubspec.yaml` with Flutter dependencies
  - Added Flutter-specific `.gitignore` configuration
  - Set up `analysis_options.yaml` for Dart linting
  - Created main Flutter entry point (`lib/main.dart`)
  
- **Core Screens**
  - Home Screen (`lib/screens/home_screen.dart`)
  - Growth Screen (`lib/screens/growth_screen.dart`)
  - Vaccines Screen (`lib/screens/vaccines_screen.dart`)
  - Learn Screen (`lib/screens/learn_screen.dart`)
  - Profile Screen (`lib/screens/profile_screen.dart`)
  
- **Navigation**
  - Implemented GoRouter for navigation
  - Created bottom navigation widget (`lib/widgets/bottom_navigation.dart`)
  - Set up navigation structure with shell route for persistent bottom nav
  
- **Dependencies**
  - Provider for state management
  - GoRouter for navigation
  - SQLite (sqflite) for local database
  - Firebase suite for backend sync
  - Google Fonts for Noto Serif Sinhala typography
  - Flutter Secure Storage for sensitive data

### Removed
- **Kotlin/Android Files**
  - All Java/Kotlin source files
  - Gradle build files and wrappers
  - Android-specific resource files
  - IntelliJ IDEA configuration files
  - Android manifest and XML layouts

### Updated
- **CLAUDE.md**
  - Updated all build commands from Gradle to Flutter CLI
  - Changed directory structure documentation to Flutter conventions
  - Updated testing guidelines for Flutter testing framework
  - Added mandatory Changelog.md update requirement
  - Modified technology stack details to reflect Flutter/Dart

### Configuration
- Set minimum iOS version to 12.0
- Set minimum Android API level to 21
- Configured Material 3 design system
- Set up localization support for English, Sinhala, and Tamil