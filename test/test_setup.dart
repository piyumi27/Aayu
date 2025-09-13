import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

/// Test setup utilities for Firebase and database initialization
class TestSetup {
  static bool _isInitialized = false;

  /// Initialize all test dependencies
  static Future<void> initialize() async {
    if (_isInitialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    await _initializeFirebase();
    await _initializeDatabase();
    _initializeMethodChannels();

    _isInitialized = true;
  }

  /// Initialize Firebase for testing
  static Future<void> _initializeFirebase() async {
    setupFirebaseCoreMocks();

    await Firebase.initializeApp();
  }

  /// Initialize SQLite database for testing
  static Future<void> _initializeDatabase() async {
    // Initialize sqflite for ffi
    sqfliteFfiInit();

    // Set the database factory for testing
    databaseFactory = databaseFactoryFfi;
  }

  /// Initialize method channels for testing
  static void _initializeMethodChannels() {
    // Mock shared preferences
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // Empty preferences
      }
      return null;
    });

    // Mock flutter_secure_storage
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
        .setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null;
        case 'write':
          return null;
        case 'delete':
          return null;
        case 'deleteAll':
          return null;
        case 'readAll':
          return <String, String>{};
        default:
          return null;
      }
    });

    // Mock path_provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'getTemporaryDirectory':
          return '/tmp';
        case 'getApplicationDocumentsDirectory':
          return '/tmp';
        case 'getApplicationSupportDirectory':
          return '/tmp';
        default:
          return null;
      }
    });

    // Mock local notifications
    const MethodChannel('dexterous.com/flutter/local_notifications')
        .setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return true;
        case 'show':
          return null;
        case 'schedule':
          return null;
        case 'cancel':
          return null;
        case 'cancelAll':
          return null;
        case 'pendingNotificationRequests':
          return <Map<String, dynamic>>[];
        case 'getActiveNotifications':
          return <Map<String, dynamic>>[];
        default:
          return null;
      }
    });

    // Mock timezone
    const MethodChannel('plugins.flutter.io/timezone')
        .setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'getTimeZoneName':
          return 'UTC';
        case 'getLocation':
          return 'UTC';
        default:
          return null;
      }
    });

    // Mock workmanager
    const MethodChannel('be.tramckrijte.workmanager/foreground_channel_work_manager')
        .setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return null;
        case 'registerOneOffTask':
          return null;
        case 'registerPeriodicTask':
          return null;
        case 'cancelByUniqueName':
          return null;
        case 'cancelAll':
          return null;
        default:
          return null;
      }
    });
  }

  /// Setup Firebase Core mocks
  static void setupFirebaseCoreMocks([String? projectId]) {
    // Firebase mocking is handled through method channels
    // No additional setup needed for basic testing
  }

  /// Clean up after tests
  static Future<void> cleanup() async {
    // Close any open databases
    await databaseFactory.deleteDatabase(':memory:');
  }
}

// Firebase mocking is handled through method channels above
// No additional mock classes needed for basic testing

/// Test utilities for creating mock data
class TestData {
  /// Create a test database instance
  static Future<Database> createTestDatabase({String? name}) async {
    final dbName = name ?? ':memory:';
    return await openDatabase(
      dbName,
      version: 1,
      onCreate: (db, version) async {
        // Create test tables as needed
        await db.execute('''
          CREATE TABLE children (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            birth_date TEXT NOT NULL,
            gender TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE notifications (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            category TEXT NOT NULL,
            priority TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            child_id TEXT,
            FOREIGN KEY (child_id) REFERENCES children (id)
          )
        ''');
      },
    );
  }

  /// Create mock child data
  static Map<String, dynamic> createMockChild({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
  }) {
    final now = DateTime.now();
    return {
      'id': id ?? 'test-child-${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test Child',
      'birth_date': (birthDate ?? now.subtract(const Duration(days: 90))).toIso8601String(),
      'gender': gender ?? 'male',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// Create mock notification data
  static Map<String, dynamic> createMockNotification({
    String? id,
    String? title,
    String? body,
    String? category,
    String? priority,
    DateTime? timestamp,
    bool isRead = false,
    String? childId,
  }) {
    return {
      'id': id ?? 'test-notification-${DateTime.now().millisecondsSinceEpoch}',
      'title': title ?? 'Test Notification',
      'body': body ?? 'This is a test notification',
      'category': category ?? 'test',
      'priority': priority ?? 'medium',
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'child_id': childId,
    };
  }
}

/// Test group helper for common test setup
void testGroupWithSetup(String description, dynamic Function() body) {
  group(description, () {
    setUpAll(() async {
      await TestSetup.initialize();
    });

    tearDownAll(() async {
      await TestSetup.cleanup();
    });

    body();
  });
}

/// Widget test helper with setup
void testWidgetsWithSetup(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    await TestSetup.initialize();
    await callback(tester);
  });
}