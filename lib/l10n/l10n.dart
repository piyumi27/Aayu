import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localization configuration for Aayu app
/// Supports English, Sinhala, and Tamil languages
class L10n {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('si', 'LK'), // Sinhala (Sri Lanka)
    Locale('ta', 'LK'), // Tamil (Sri Lanka)
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Get locale display name
  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get locale flag emoji
  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'si':
      case 'ta':
        return '🇱🇰';
      default:
        return '🌐';
    }
  }

  /// Check if locale is RTL
  static bool isRTL(Locale locale) {
    // Tamil and Sinhala are LTR languages
    return false;
  }

  /// Get default locale based on system
  static Locale getDefaultLocale(List<Locale> systemLocales) {
    for (final systemLocale in systemLocales) {
      for (final supportedLocale in supportedLocales) {
        if (systemLocale.languageCode == supportedLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return supportedLocales.first; // Default to English
  }
}

/// Extension to add localization methods to BuildContext
extension LocalizationContext on BuildContext {
  /// Get current locale
  Locale get locale => Localizations.localeOf(this);

  /// Check if current locale is Sinhala
  bool get isSinhala => locale.languageCode == 'si';

  /// Check if current locale is Tamil
  bool get isTamil => locale.languageCode == 'ta';

  /// Check if current locale is English
  bool get isEnglish => locale.languageCode == 'en';

  /// Get localized app name
  String get appName {
    switch (locale.languageCode) {
      case 'si':
      case 'ta':
        return 'ආයු';
      default:
        return 'Aayu';
    }
  }
}

/// Simple localization texts for immediate use
/// (Until generated localizations are set up)
class AppTexts {
  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'home': 'Home',
      'growth': 'Growth',
      'vaccines': 'Vaccines',
      'learn': 'Learn',
      'profile': 'Profile',
      'add_child': 'Add Child',
      'child_name': 'Child Name',
      'birth_date': 'Birth Date',
      'male': 'Male',
      'female': 'Female',
      'save': 'Save',
      'cancel': 'Cancel',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'vaccination_schedule': 'Vaccination Schedule',
      'medications_supplements': 'Medications & Supplements',
      'overdue': 'Overdue',
      'upcoming': 'Upcoming',
      'today': 'Today',
      'active': 'Active',
      'history': 'History',
      'stats': 'Stats',
      'take': 'Take',
      'skip': 'Skip',
      'add_medication': 'Add Medication',
      'side_effects_noted': 'Side Effects Noted (Optional)',
    },
    'si': {
      'home': 'මුල් පිටුව',
      'growth': 'වර්ධනය',
      'vaccines': 'එන්නත්',
      'learn': 'ඉගෙනගන්න',
      'profile': 'පැතිකඩ',
      'add_child': 'දරුවා එකතු කරන්න',
      'child_name': 'දරුවාගේ නම',
      'birth_date': 'උපන් දිනය',
      'male': 'පුරුෂ',
      'female': 'ස්ත්‍රී',
      'save': 'සුරකින්න',
      'cancel': 'අවලංගු කරන්න',
      'loading': 'පූරණය වෙමින්...',
      'error': 'දෝෂය',
      'success': 'සාර්ථකයි',
      'vaccination_schedule': 'එන්නත් කිරීමේ කාලසටහන',
      'medications_supplements': 'ඖෂධ සහ අතිරේක',
      'overdue': 'ප්‍රමාද වූ',
      'upcoming': 'ඉදිරි',
      'today': 'අද',
      'active': 'ක්‍රියාකාරී',
      'history': 'ඉතිහාසය',
      'stats': 'සංඛ්‍යාලේඛන',
      'take': 'ගන්න',
      'skip': 'මඟ හරින්න',
      'add_medication': 'ඖෂධය එකතු කරන්න',
      'side_effects_noted': 'පාර්ශ්ව ප්‍රතිඵල සටහන් (විකල්ප)',
    },
    'ta': {
      'home': 'முகப்பு',
      'growth': 'வளர்ச்சி',
      'vaccines': 'தடுப்பூசிகள்',
      'learn': 'கற்றுக்கொள்',
      'profile': 'சுயவிவரம்',
      'add_child': 'குழந்தையை சேர்',
      'child_name': 'குழந்தையின் பெயர்',
      'birth_date': 'பிறந்த தேதி',
      'male': 'ஆண்',
      'female': 'பெண்',
      'save': 'சேமி',
      'cancel': 'ரத்து செய்',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'vaccination_schedule': 'தடுப்பூசி அட்டவணை',
      'medications_supplements': 'மருந்துகள் & சப்ளிமெண்ட்ஸ்',
      'overdue': 'தாமதமான',
      'upcoming': 'வரவிருக்கும்',
      'today': 'இன்று',
      'active': 'செயலில்',
      'history': 'வரலாறு',
      'stats': 'புள்ளிவிவரங்கள்',
      'take': 'எடு',
      'skip': 'தவிர்',
      'add_medication': 'மருந்து சேர்',
      'side_effects_noted': 'பக்கவிளைவுகள் குறிப்பிட்டது (விருப்பம்)',
    },
  };

  /// Get localized text
  static String get(String key, String languageCode) {
    return _texts[languageCode]?[key] ?? _texts['en']?[key] ?? key;
  }

  /// Get localized text with context
  static String getText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    return get(key, locale.languageCode);
  }
}

/// Number and date formatting for Sri Lankan context
class SriLankanFormatters {
  /// Format numbers for Sri Lankan context
  static String formatNumber(double number, String languageCode) {
    // Use appropriate number formatting for each language
    switch (languageCode) {
      case 'si':
      case 'ta':
        // Use local number formatting if needed
        return number.toStringAsFixed(1);
      default:
        return number.toStringAsFixed(1);
    }
  }

  /// Format dates for Sri Lankan context
  static String formatDate(DateTime date, String languageCode) {
    switch (languageCode) {
      case 'si':
        return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      case 'ta':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      default:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  /// Get month names in local languages
  static List<String> getMonthNames(String languageCode) {
    switch (languageCode) {
      case 'si':
        return [
          'ජනවාරි', 'පෙබරවාරි', 'මාර්තු', 'අප්‍රේල්', 'මැයි', 'ජූනි',
          'ජූලි', 'අගෝස්තු', 'සැප්තැම්බර්', 'ඔක්තෝබර්', 'නොවැම්බර්', 'දෙසැම්බර්'
        ];
      case 'ta':
        return [
          'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்',
          'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்'
        ];
      default:
        return [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
    }
  }
}