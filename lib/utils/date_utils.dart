import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('h:mm a');

  /// Get relative time string (e.g., "2 minutes ago", "1 hour ago")
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Format date for display (e.g., "Jan 15, 2024")
  static String formatDisplayDate(DateTime dateTime) {
    return _displayDateFormat.format(dateTime);
  }

  /// Format time for display (e.g., "2:30 PM")
  static String formatDisplayTime(DateTime dateTime) {
    return _displayTimeFormat.format(dateTime);
  }

  /// Format date and time for display (e.g., "Jan 15, 2024 at 2:30 PM")
  static String formatDisplayDateTime(DateTime dateTime) {
    return '${formatDisplayDate(dateTime)} at ${formatDisplayTime(dateTime)}';
  }

  /// Format date for database storage (ISO 8601)
  static String formatForDatabase(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse date from database (ISO 8601)
  static DateTime parseFromDatabase(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Check if date is within the last week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return dateTime.isAfter(weekAgo) && dateTime.isBefore(now);
  }

  /// Get smart date string (Today, Yesterday, or formatted date)
  static String getSmartDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else if (isThisWeek(dateTime)) {
      return DateFormat('EEEE').format(dateTime); // Day name
    } else {
      return formatDisplayDate(dateTime);
    }
  }

  /// Calculate age in months from birth date
  static int calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    
    if (now.day < birthDate.day) {
      months--;
    }
    
    return months;
  }

  /// Calculate age in days from birth date
  static int calculateAgeInDays(DateTime birthDate) {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  /// Get start of day
  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day
  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  /// Check if DateTime is in the future
  static bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  /// Check if DateTime is in the past
  static bool isPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }
}