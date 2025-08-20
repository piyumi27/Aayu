# Changelog

All notable changes to the Aayu project will be documented in this file.

## [2025-01-20] - Complete Authentication Flow with Password Recovery

### Added
- **Splash Screen**
  - Animated splash screen with logo display (no text titles)
  - Apple-style rotating gradient background with smooth color transitions
  - Multi-layer gradient animation with #1E90FF (dodger blue) blending through sky blue, powder blue, and white
  - Radial gradient overlay for added depth effect
  - Fade and scale animations for smooth logo entry
  - Auto-navigation to language selection after 3 seconds
  - Logo container with gradient background and layered shadows
  - Fallback icon display if logo image is not found

- **Language Selection Screen**
  - Language selection interface with three options: Sinhala, English, Tamil
  - Logo-only display without text titles (since logo contains "Ayu" text)
  - Radio button style selection with visual feedback using #1E90FF color scheme
  - Language preference persistence using SharedPreferences
  - Dynamic button text based on selected language
  - Consistent color theme throughout with #1E90FF

- **Onboarding Carousel**
  - Three-slide carousel introducing app's core features
  - Full-width Lottie animations for visual engagement:
    - "Track Growth" slide: Rocket Launch animation
    - "Record Vaccines" slide: Medical/vaccine animation  
    - "Learn Nutrition" slide: Healthy vs Junk Food animation
  - Multi-language support (English, Sinhala, Tamil) based on selected language
  - Slide content: "Track Growth", "Record Vaccines", "Learn Nutrition"
  - Navigation dots with active/inactive states
  - Skip button on top-right for quick bypass
  - Get Started button on final slide
  - Smooth page transitions and animations
  - Fallback icons when Lottie animations fail to load

- **Navigation Updates**
  - Set splash screen as initial route
  - Added redirect logic to check language selection and onboarding status
  - Automatic redirect to splash if language not selected
  - Automatic redirect to onboarding if not completed
  - Navigation flow: Splash → Language Selection → Onboarding → Home

- **Firebase Phone Authentication**
  - Login Screen with phone number field (password removed for phone auth)
  - Registration Screen with full name and phone number fields
  - Real-time password strength meter with visual feedback (weak/medium/strong)
  - OTP Verification Screen with 6-digit code input
  - Forgot Password Screen with secure password reset flow
  - Multi-language support for all authentication screens (English, Sinhala, Tamil)
  - Firebase Auth service with comprehensive phone verification
  - Auto-verification support for instant login when possible
  - Manual OTP entry with 60-second resend countdown
  - User profile storage in Firestore
  - Error handling with localized messages
  - Loading states during authentication process
  - Privacy policy compliance text
  - Navigation between login, registration, OTP, and password recovery screens

- **Navigation Flow Updates**
  - Complete flow: Splash → Language Selection → Onboarding → Login → OTP → Home
  - Authentication guard on main app routes
  - Automatic redirects based on user state (language, onboarding, authentication)
  - Firebase initialization in main.dart
  - Persistent user session management with SharedPreferences and Firebase Auth

- **UI Styling & Design System**
  - Consistent design system with specified colors:
    - Primary Blue: #1E90FF (updated for better accessibility)
    - Secondary Light Gray: #F1F1F1
    - Supporting Gray: #6C757D  
    - Accent Green: #32CD32 (for success states)
    - Accent Green: #28A745 (for strong passwords)
  - 16dp consistent padding and margins throughout
  - 4dp border radius for input fields, 2dp for buttons
  - 1dp outline borders for form fields
  - Sans-serif typography: 16sp body text, 18sp bold for buttons
  - Form field styling with focus states and comprehensive error handling
  - Success and error message containers with appropriate color coding
  - Loading states with consistent spinner styling

- **Dependencies**
  - Added Lottie package (^3.1.3) for animated illustrations

### Fixed
- Replaced deprecated `withOpacity` method with `withValues(alpha:)` throughout the codebase
- Updated all color opacity references to use the new Flutter API

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

## [2025-08-18] - Core App Implementation

### Added
- **Data Models**
  - Child model with complete profile information
  - Growth record model for tracking weight/height/head circumference
  - Vaccine model for vaccine definitions
  - Vaccine record model for tracking administered vaccines

- **Services**
  - Database service with SQLite integration
  - Full CRUD operations for children, growth records, and vaccines
  - Pre-populated vaccine schedule based on Sri Lankan immunization program
  - Automatic database initialization with default vaccines

- **State Management**
  - ChildProvider for managing app state
  - Methods for calculating child age in months
  - Vaccine tracking (upcoming, overdue, given)
  - Child selection and data loading

- **Enhanced Screens**
  - **Home Screen**: 
    - Child profile display with age calculation
    - Quick stats for latest growth measurements
    - Overdue and upcoming vaccine alerts
    - Quick action cards for common tasks
    - Child selector for multiple children
  
  - **Growth Screen**:
    - Current measurements display
    - Growth charts with fl_chart integration
    - Growth history list
    - Add growth record bottom sheet
    - Support for weight, height, and head circumference tracking
  
  - **Vaccines Screen**:
    - Three-tab layout (Schedule, Given, Upcoming)
    - Color-coded vaccine status (given, overdue, pending)
    - Grouped vaccine schedule by age
    - Add vaccine record functionality
    - Support for location, doctor, batch number tracking

  - **Add Child Screen**:
    - Complete child registration form
    - Date picker for birth date
    - Optional fields for birth measurements and blood type

### Features
- Offline-first data storage with SQLite
- Age-appropriate vaccine recommendations
- Visual growth tracking with charts
- Multi-child support with easy switching
- Comprehensive vaccine history tracking