import 'package:flutter/material.dart';

/// Validation utilities for phone numbers and email addresses
class ValidationUtils {
  // Sri Lanka phone validation
  static const String sriLankaCountryCode = '+94';
  static const String sriLankaFlag = '🇱🇰';

  /// Validates Sri Lankan local phone number (9 digits starting with 7)
  static bool validateSriLankaLocal(String local) {
    return RegExp(r'^7\d{8}$').hasMatch(local);
  }

  /// Builds E.164 format from Sri Lankan local number
  static String buildE164SriLanka(String local) {
    return '+94$local';
  }

  /// Extracts local part from Sri Lankan E.164 number
  static String extractSriLankaLocal(String e164) {
    if (e164.startsWith('+94') && e164.length == 12) {
      return e164.substring(3);
    }
    return e164;
  }

  /// Normalizes Sri Lankan phone input (removes leading 0 if present)
  static String normalizeSriLankaInput(String input) {
    // Remove any non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 0, remove it (common Sri Lankan format: 077XXXXXXX)
    if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      return digitsOnly.substring(1);
    }

    return digitsOnly;
  }

  /// Formats Sri Lankan number for display: +94 7X XXX XXXX
  static String formatSriLankaDisplay(String local) {
    if (local.length == 9 && local.startsWith('7')) {
      return '+94 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5)}';
    }
    return '+94 $local';
  }

  // Gmail validation
  static const String gmailSuffix = '@gmail.com';

  /// Validates Gmail local part (before @gmail.com)
  static bool validateGmailLocalPart(String localPart) {
    // Gmail local part rules: start with alphanumeric, then allowed chars
    return RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._%+-]{0,63}$').hasMatch(localPart);
  }

  /// Constructs Gmail address from local part
  static String buildGmailAddress(String localPart) {
    return '${localPart.toLowerCase()}$gmailSuffix';
  }

  /// Extracts local part from Gmail address
  static String extractGmailLocalPart(String email) {
    if (email.toLowerCase().endsWith(gmailSuffix)) {
      return email.substring(0, email.length - gmailSuffix.length);
    }
    return email;
  }

  /// Validates password strength
  static PasswordStrength getPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  /// Phone number input error messages
  static String getPhoneErrorMessage(String input, String language) {
    final normalized = normalizeSriLankaInput(input);

    if (normalized.isEmpty) {
      switch (language) {
        case 'si':
          return 'දුරකථන අංකය ඇතුළත් කරන්න';
        case 'ta':
          return 'தொலைபேசி எண்ணை உள்ளிடவும்';
        default:
          return 'Enter phone number';
      }
    }

    if (normalized.length != 9) {
      switch (language) {
        case 'si':
          return '9 ඉලක්කම් ඇතුළත් කරන්න';
        case 'ta':
          return '9 இலக்கங்களை உள்ளிடவும்';
        default:
          return 'Enter 9 digits';
      }
    }

    if (!normalized.startsWith('7')) {
      switch (language) {
        case 'si':
          return '7 සමඟ ආරම්භ වන අංකයක් ඇතුළත් කරන්න';
        case 'ta':
          return '7 ஆல் தொடங்கும் எண்ணை உள்ளிடவும்';
        default:
          return 'Number must start with 7';
      }
    }

    return '';
  }

  /// Gmail local part error messages
  static String getGmailErrorMessage(String localPart, String language) {
    if (localPart.isEmpty) {
      switch (language) {
        case 'si':
          return 'ඊමේල් ඇතුළත් කරන්න';
        case 'ta':
          return 'மின்னஞ்சலை உள்ளிடவும்';
        default:
          return 'Enter email';
      }
    }

    if (!validateGmailLocalPart(localPart)) {
      switch (language) {
        case 'si':
          return 'වලංගු ඊමේල් ඇතුළත් කරන්න (උදා: amalka.r)';
        case 'ta':
          return 'சரியான மின்னஞ்சலை உள்ளிடவும் (உதா: amalka.r)';
        default:
          return 'Use letters, numbers, dots, underscores, plus or hyphens. Example: amalka.r';
      }
    }

    return '';
  }
}

/// Password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong;

  String getDisplayText(String language) {
    switch (this) {
      case PasswordStrength.weak:
        switch (language) {
          case 'si':
            return 'දුර්වල';
          case 'ta':
            return 'பலவீனமான';
          default:
            return 'Weak';
        }
      case PasswordStrength.medium:
        switch (language) {
          case 'si':
            return 'මධ්‍යම';
          case 'ta':
            return 'நடுத்தர';
          default:
            return 'Medium';
        }
      case PasswordStrength.strong:
        switch (language) {
          case 'si':
            return 'ශක්තිමත්';
          case 'ta':
            return 'வலுவான';
          default:
            return 'Strong';
        }
    }
  }

  Color getColor() {
    switch (this) {
      case PasswordStrength.weak:
        return const Color(0xFFEF4444); // Red
      case PasswordStrength.medium:
        return const Color(0xFFF59E0B); // Orange
      case PasswordStrength.strong:
        return const Color(0xFF10B981); // Green
    }
  }
}
