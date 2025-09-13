import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aayu/providers/child_provider.dart';

/// Helper functions for creating test widgets with proper setup
class TestHelpers {
  /// Create a MaterialApp with routing for widget tests
  static Widget createTestAppWithRouting({
    required Widget child,
    String initialLocation = '/',
    List<GoRoute>? additionalRoutes,
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: const Center(child: Text('Notification Center')),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Center(child: Text('Settings Screen')),
          ),
        ),
        GoRoute(
          path: '/notification-preferences',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Notification Preferences')),
            body: const Center(child: Text('Notification Preferences')),
          ),
        ),
        ...?additionalRoutes,
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: MaterialApp.router(
        title: 'Test App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0086FF)),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }

  /// Create a simple MaterialApp wrapper for widget tests
  static Widget createSimpleTestApp({
    required Widget child,
    ThemeData? theme,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: MaterialApp(
        title: 'Test App',
        theme: theme ??
            ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF0086FF)),
              useMaterial3: true,
            ),
        home: Scaffold(body: child),
      ),
    );
  }

  /// Create a test widget with scaffold wrapper
  static Widget createTestWidgetWithScaffold({
    required Widget child,
    String? title,
    PreferredSizeWidget? appBar,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: appBar ?? (title != null ? AppBar(title: Text(title)) : null),
        body: child,
      ),
    );
  }

  /// Pump a widget with proper setup and binding initialization
  static Future<void> pumpWidgetWithSetup(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
    bool settleTimeout = true,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(widget);
    if (settleTimeout) {
      await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
    } else {
      await tester.pump(duration ?? Duration.zero);
    }
  }

  /// Find widget by text with timeout
  static Future<Finder> findTextWithTimeout(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      final finder = find.text(text);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }
    throw Exception('Text "$text" not found within timeout');
  }

  /// Find widget by type with timeout
  static Future<Finder> findWidgetWithTimeout<T extends Widget>(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      final finder = find.byType(T);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }
    throw Exception('Widget of type $T not found within timeout');
  }

  /// Simulate screen size changes for responsive testing
  static Future<void> setScreenSize(
    WidgetTester tester,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pump();
  }

  /// Common screen sizes for testing
  static const Size pixelPhone = Size(411, 731); // Pixel 3
  static const Size pixel6Phone = Size(411, 915); // Pixel 6
  static const Size tablet = Size(800, 1200); // Tablet
  static const Size desktop = Size(1200, 800); // Desktop
}

/// Test data helpers for creating mock objects
class TestData {
  /// Create mock child data for testing
  static Map<String, dynamic> mockChild({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
  }) {
    final now = DateTime.now();
    return {
      'id': id ?? 'test-child-${now.millisecondsSinceEpoch}',
      'name': name ?? 'Test Child',
      'birth_date': (birthDate ?? now.subtract(const Duration(days: 90)))
          .toIso8601String(),
      'gender': gender ?? 'male',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// Create mock notification data for testing
  static Map<String, dynamic> mockNotification({
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

  /// Create a list of mock notifications
  static List<Map<String, dynamic>> mockNotificationList({
    int count = 3,
    bool includeUnread = true,
  }) {
    final notifications = <Map<String, dynamic>>[];
    final categories = ['vaccination', 'growth', 'milestone', 'feeding'];
    final priorities = ['low', 'medium', 'high', 'critical'];

    for (int i = 0; i < count; i++) {
      notifications.add(mockNotification(
        id: 'notification-$i',
        title: 'Test Notification ${i + 1}',
        body: 'This is test notification number ${i + 1}',
        category: categories[i % categories.length],
        priority: priorities[i % priorities.length],
        timestamp: DateTime.now().subtract(Duration(hours: i)),
        isRead: includeUnread ? i % 2 == 0 : true, // Alternate read/unread
        childId: 'child-${i % 2}', // Alternate children
      ));
    }

    return notifications;
  }
}
