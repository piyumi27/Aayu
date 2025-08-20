# Changelog

All notable changes to the Aayu project will be documented in this file.

## [2025-08-20] - Comprehensive Home Dashboard Implementation

### Added
- **Complete Home Dashboard Redesign**
  - Responsive design optimized for 1080 × 1920 mobile screens
  - Full multilingual support (English, Sinhala, Tamil) with dynamic language switching
  - Professional dashboard layout with modern Material 3 design principles

- **Child Selector System**
  - Horizontal scrollable chips showing child avatars and names
  - FilterChip design with selected state indication using #0086FF color scheme
  - Dynamic switching between multiple children with visual feedback
  - Only displays when multiple children are registered

- **Hero Card Component**
  - 72dp circular child photo placeholder with gradient background
  - Child details column with name (18sp bold), age, and last measurement date (12sp gray)
  - Gradient background with #0086FF theme integration
  - Responsive layout maintaining specifications

- **Health Metrics Row**
  - Three 100 × 100dp metric chips for Weight, Height, and BMI
  - Color-coded status indicators: Green (normal), Orange (underweight), Red (overweight)
  - Automatic BMI calculation from latest measurements
  - Material icons with status-based color coding

- **Nutritional Status Banner**
  - Full-width banner displaying calculated nutritional status
  - Dynamic status detection: Normal | Underweight | Overweight
  - Color-coded indicators with appropriate icons (check_circle, warning, error)
  - Status text localized in selected language

- **Action Grid (2×2)**
  - Four 160dp square actio buttons with Material symbol icons
  - Add Measurement, Growth Charts, Vaccines, Learn functionality
  - Color-coded design: Blue (#0086FF), Green, Orange, Purple
  - Responsive tap interactions with proper navigation

- **Recent Activity Feed**
  - Displays last 5 measurement and vaccine records chronologically
  - Mixed content from growth records and vaccination history
  - Color-coded activity types with descriptive icons
  - Empty state handling with localized messaging

- **Enhanced Navigation**
  - Floating Action Button (FAB) bottom-right with '+' icon
  - FAB opens Add Measurement functionality
  - Consistent #0086FF color scheme throughout interface
  - Bottom navigation bar integration maintained

### Architecture
- **Multilingual Implementation**
  - Complete localization system with SharedPreferences integration
  - Dynamic font family switching for Sinhala (NotoSerifSinhala)
  - Consistent text styling across all dashboard components
  - Language-aware number formatting and units

- **Responsive Design**
  - Adaptive layout supporting various screen densities
  - Proper spacing and sizing using dp measurements
  - ScrollView implementation for content overflow handling
  - Material 3 design system compliance

- **Data Integration**
  - Real-time data binding with ChildProvider state management
  - Automatic BMI calculation and status determination
  - Recent activity aggregation from multiple data sources
  - Efficient list rendering with proper error handling

## [2025-08-20] - UI Enhancements and Performance Optimization

### Updated
- **Authentication Screen Design**
  - Removed duplicate headers from Login and Register screens (previously showing same title in AppBar and body)
  - Completely removed unnecessary AppBars from both authentication screens for cleaner, full-screen experience
  - Login screen: Added person outline icon with blue gradient circle background (#0086FF)
  - Register screen: Added person add icon with green gradient circle background (#32CD32)
  - Register screen: Added floating back button with shadow for navigation without AppBar
  - Improved visual hierarchy and reduced redundancy in authentication flow
  - Full-screen design provides more space for content and better mobile experience

- **Lottie Animation Performance**
  - Implemented precise per-animation loading tracking to show accurate loading states
  - Added dedicated AnimationControllers for each slide with proper lifecycle management
  - Individual loading indicators per slide - only show loading for animations that haven't loaded yet
  - Loading indicator automatically disappears when specific animation completes loading
  - Controlled animation playback - only animate current visible slide for better performance
  - Used user-requested Lottie URLs:
    - Slide 1: Rocket Launch animation (https://assets9.lottiefiles.com/packages/lf20_5tl1xxnz.json)
    - Slide 2: Medical/vaccine animation (https://assets3.lottiefiles.com/packages/lf20_tutvdkg0.json)
    - Slide 3: Healthy Food animation (https://assets5.lottiefiles.com/packages/lf20_ysas4vcp.json)
  - Enhanced error handling with fallback icons if animations fail to load
  - Fixed icon centering - both Lottie animations and fallback icons are now perfectly centered
  - Automatic animation restart when user navigates to each slide
  - Eliminated inaccurate global loading state in favor of precise individual tracking

### Architecture
- **Performance Optimizations**
  - TickerProviderStateMixin integration for smooth animation control
  - Memory-efficient animation controller management with proper disposal
  - Network request batching for concurrent Lottie preloading
  - Reduced UI blocking during animation loading through background processes

## [2025-08-20] - Unified Navigation Pattern

### Updated
- **Bottom Navigation Bar**
  - Updated with 5 items: Home 🏠, Growth 📈, Medicine 💉, Learn 📚, Profile 👤  
  - Set fixed height to 56dp as specified
  - Applied active tint color #0086FF with inactive color #666666
  - Enabled label visibility for all items
  - Implemented Noto Serif Sinhala typography for labels (font size 12sp)
  - Updated Medicine icon from vaccines to medical_services for better clarity

- **Navigation Visibility**
  - Configured bottom navigation to show only on main 5 screens
  - Hidden on authentication flow screens (splash, language, onboarding, login, register, OTP, forgot password)
  - ScaffoldWithNavBar widget automatically detects current route and shows/hides bottom navigation appropriately

- **Screen Configuration**  
  - All main screens (Home, Growth, Medicine, Learn, Profile) retain their existing AppBar configurations
  - Authentication flow screens maintain their AppBar-less design for seamless user experience
  - No changes needed to existing screen AppBars as they already follow the design specification

- **Navigation Transitions**
  - Implemented slide-right transitions for all main navigation screens  
  - Added SlideRightTransitionPage with 300ms duration and easeInOut curve
  - Applied consistent slide animation across Home, Growth, Vaccines, Learn, and Profile screens

### Architecture
- **Route Structure**
  - Maintained ShellRoute pattern for persistent bottom navigation on main screens
  - Routes outside ShellRoute (splash, auth flow) automatically exclude bottom navigation
  - Clean separation between authenticated and unauthenticated screen navigation patterns

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