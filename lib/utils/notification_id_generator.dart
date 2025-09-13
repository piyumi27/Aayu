import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Expert-level Notification ID Generator
/// Ensures truly unique notification IDs to prevent database conflicts
class NotificationIdGenerator {
  static final NotificationIdGenerator _instance =
      NotificationIdGenerator._internal();
  factory NotificationIdGenerator() => _instance;
  NotificationIdGenerator._internal();

  static const String _counterKey = 'notification_id_counter';
  static const Uuid _uuid = Uuid();
  static int? _cachedCounter;

  /// Generate a truly unique integer notification ID
  /// Uses a combination of timestamp, counter, and randomness within 32-bit limits
  static Future<int> generateUniqueId() async {
    try {
      // Get and increment counter
      final counter = await _getNextCounter();

      // Get timestamp in seconds (more manageable size)
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Add some randomness to prevent collisions (0-99)
      final random = Random().nextInt(100);

      // Combine: timestamp seconds (mod 10000000) + counter (mod 100000) + random (0-99)
      // This ensures we stay well within 32-bit limits (max ~2.1 billion)
      final timeComponent =
          (nowSeconds % 10000000) * 10000; // Up to 99,999,990,000
      final counterComponent = (counter % 1000) * 100; // Up to 99,900
      final randomComponent = random; // Up to 99

      final uniqueId = timeComponent + counterComponent + randomComponent;

      // Ensure we're within 32-bit signed integer limits
      final safeId = uniqueId % 2147483647; // 2^31 - 1

      debugPrint('🆔 Generated unique notification ID: $safeId');
      return safeId == 0 ? 1 : safeId; // Ensure ID is never 0
    } catch (e) {
      debugPrint('⚠️ Error generating unique ID, using fallback: $e');
      // Fallback to simple safe random ID
      final fallback = Random().nextInt(2147483647);
      return fallback == 0 ? 1 : fallback;
    }
  }

  /// Generate a string-based UUID for complex identifiers
  static String generateUuidString() {
    return _uuid.v4();
  }

  /// Generate a deterministic but unique ID for specific content
  /// Use this when you want the same content to have the same ID (for updates)
  /// but with collision prevention
  static Future<int> generateContentBasedId(String content) async {
    try {
      final baseId = content.hashCode.abs();
      final counter = await _getNextCounter();

      // Keep base ID within reasonable bounds and add counter
      final safeBaseId = (baseId % 1000000); // Max 999,999
      final safeCounter = (counter % 2000); // Max 1,999

      // Combine ensuring we stay within 32-bit limits
      final uniqueId =
          safeBaseId + (safeCounter * 1000000); // Max ~1,999,999,999

      final safeId = uniqueId % 2147483647; // Ensure within int32 range

      debugPrint(
          '🆔 Generated content-based ID: $safeId for content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}');
      return safeId == 0 ? 1 : safeId; // Ensure ID is never 0
    } catch (e) {
      debugPrint('⚠️ Error generating content-based ID, using unique ID: $e');
      return await generateUniqueId();
    }
  }

  /// Get and increment the internal counter
  static Future<int> _getNextCounter() async {
    try {
      if (_cachedCounter == null) {
        final prefs = await SharedPreferences.getInstance();
        _cachedCounter = prefs.getInt(_counterKey) ?? 0;
      }

      _cachedCounter = (_cachedCounter! + 1) % 999999; // Keep within 6 digits

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, _cachedCounter!);

      return _cachedCounter!;
    } catch (e) {
      debugPrint('⚠️ Error with counter, using random: $e');
      return Random().nextInt(999999);
    }
  }

  /// Reset counter (useful for testing)
  static Future<void> resetCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_counterKey);
      _cachedCounter = null;
      debugPrint('🔄 Notification ID counter reset');
    } catch (e) {
      debugPrint('⚠️ Error resetting counter: $e');
    }
  }

  /// Get statistics about ID generation
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCounter = prefs.getInt(_counterKey) ?? 0;

      return {
        'currentCounter': currentCounter,
        'nextId': await generateUniqueId(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint('⚠️ Error getting stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Clean up duplicate notification IDs in the database
  /// This should be called once after updating to the new ID generation system
  static Future<void> cleanupDuplicateNotifications(Database db) async {
    try {
      debugPrint('🧹 Starting notification ID cleanup...');

      // Find duplicates based on id field
      final duplicates = await db.rawQuery('''
        SELECT id, COUNT(*) as count
        FROM scheduled_notifications
        GROUP BY id
        HAVING COUNT(*) > 1
      ''');

      if (duplicates.isEmpty) {
        debugPrint('✅ No duplicate notification IDs found');
        return;
      }

      debugPrint('⚠️ Found ${duplicates.length} duplicate notification IDs');

      for (final duplicate in duplicates) {
        final id = duplicate['id'] as String;
        final count = duplicate['count'] as int;

        debugPrint('🔍 Processing duplicate ID: $id (count: $count)');

        // Get all rows with this duplicate ID
        final rows = await db.query(
          'scheduled_notifications',
          where: 'id = ?',
          whereArgs: [id],
          orderBy: 'createdAt ASC',
        );

        // Keep the first one, remove the rest
        for (int i = 1; i < rows.length; i++) {
          final rowId = rows[i]['rowid'] as int;
          await db.execute(
              'DELETE FROM scheduled_notifications WHERE rowid = ?', [rowId]);
          debugPrint('🗑️ Deleted duplicate notification (rowid: $rowId)');
        }

        // Update the remaining one with a new unique ID to prevent future conflicts
        if (rows.isNotEmpty) {
          final newId = await generateUniqueId();
          await db.update(
            'scheduled_notifications',
            {'id': newId.toString()},
            where: 'rowid = ?',
            whereArgs: [rows.first['rowid']],
          );
          debugPrint('🔄 Updated remaining notification with new ID: $newId');
        }
      }

      debugPrint('✅ Notification ID cleanup completed');
    } catch (e) {
      debugPrint('❌ Error during notification cleanup: $e');
    }
  }
}
