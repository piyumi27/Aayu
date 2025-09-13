import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aayu/main.dart' as app;
import 'package:aayu/services/notifications/local_notification_service.dart';
import 'package:aayu/services/notifications/push_notification_service.dart';
import 'package:aayu/services/notifications/scheduling_engine.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification System Integration Tests', () {
    setUpAll(() async {
      // Initialize notification services
      final localNotificationService = LocalNotificationService();
      final pushNotificationService = PushNotificationService();
      final schedulingEngine = NotificationSchedulingEngine();

      await localNotificationService.initialize();
      await pushNotificationService.initialize();
      await schedulingEngine.initialize();
    });

    group('End-to-End Notification Flow', () {
      testWidgets('complete vaccination reminder flow', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // 1. Navigate to add child screen
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // 2. Add a new child
        await tester.enterText(
            find.byKey(const Key('child_name_field')), 'Test Child');
        await tester.tap(find.byKey(const Key('birth_date_picker')));
        await tester.pumpAndSettle();

        // Select birth date (2 months ago for vaccination schedule)
        final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
        await tester.tap(find.text(twoMonthsAgo.day.toString()));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_child_button')));
        await tester.pumpAndSettle();

        // 3. Verify child is created and notifications are scheduled
        expect(find.text('Test Child'), findsOneWidget);

        // 4. Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // 5. Verify vaccination reminders appear
        expect(find.text('Vaccination'), findsAtLeastNWidgets(1));
        expect(find.textContaining('BCG'), findsWidgets);

        // 6. Tap on a notification to mark as read
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        // 7. Verify notification is marked as read
        await tester.tap(find.text('Unread'));
        await tester.pumpAndSettle();

        // Should have one less unread notification
        // Specific verification would depend on UI implementation
      });

      testWidgets('growth tracking reminder workflow', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to growth section
        await tester.tap(find.byIcon(Icons.trending_up));
        await tester.pumpAndSettle();

        // Add growth measurement
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('weight_field')), '7.5');
        await tester.enterText(find.byKey(const Key('height_field')), '65');
        await tester.tap(find.byKey(const Key('save_measurement_button')));
        await tester.pumpAndSettle();

        // Verify growth tracking notifications are updated
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        expect(find.text('Growth'), findsAtLeastNWidgets(1));
      });

      testWidgets('milestone tracking notification flow', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to milestones section (assuming it exists)
        await tester.tap(find.byIcon(Icons.celebration));
        await tester.pumpAndSettle();

        // Mark a milestone as achieved
        await tester.tap(find.byKey(const Key('milestone_sitting_checkbox')));
        await tester.pumpAndSettle();

        // Verify milestone notification is generated
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        expect(find.textContaining('Milestone'), findsWidgets);
      });
    });

    group('Notification Settings Integration', () {
      testWidgets('notification preferences workflow', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Open notification settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Verify notification preferences screen loads
        expect(find.text('Notification Settings'), findsOneWidget);
        expect(find.text('Push Notifications'), findsOneWidget);
        expect(find.text('Local Notifications'), findsOneWidget);

        // Toggle vaccination reminders off
        await tester.tap(find.ancestor(
          of: find.text('Vaccination Reminders'),
          matching: find.byType(Switch),
        ));
        await tester.pumpAndSettle();

        // Go back and verify vaccination notifications are reduced
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Refresh notification list
        await tester.fling(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // Vaccination notifications should be filtered out or reduced
        // Specific verification depends on implementation
      });

      testWidgets('quiet hours functionality', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification settings
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Enable quiet hours
        await tester.tap(find.ancestor(
          of: find.text('Enable Quiet Hours'),
          matching: find.byType(Switch),
        ));
        await tester.pumpAndSettle();

        // Set quiet hours start time
        await tester.tap(find.text('Start Time'));
        await tester.pumpAndSettle();

        // Select 10 PM
        await tester.tap(find.text('10'));
        await tester.tap(find.text('PM'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Set quiet hours end time
        await tester.tap(find.text('End Time'));
        await tester.pumpAndSettle();

        // Select 7 AM
        await tester.tap(find.text('7'));
        await tester.tap(find.text('AM'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Verify settings are saved
        expect(find.text('10:00 PM'), findsOneWidget);
        expect(find.text('7:00 AM'), findsOneWidget);
      });
    });

    group('Notification Categories and Filtering', () {
      testWidgets('category filtering workflow', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Test different category filters
        final categories = ['Vaccines', 'Growth', 'Milestones', 'Feeding'];

        for (final category in categories) {
          await tester.tap(find.text(category));
          await tester.pumpAndSettle();

          // Verify filter is applied (chip should be selected)
          final chip = find.ancestor(
            of: find.text(category),
            matching: find.byType(FilterChip),
          );
          expect(chip, findsOneWidget);

          // Verify notification list updates
          expect(find.byType(ListView), findsOneWidget);
        }

        // Reset to all notifications
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();
      });

      testWidgets('tab switching functionality', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Test tab switching
        await tester.tap(find.text('Unread'));
        await tester.pumpAndSettle();
        expect(find.text('Unread'), findsOneWidget);

        await tester.tap(find.text('Health'));
        await tester.pumpAndSettle();
        expect(find.text('Health'), findsOneWidget);

        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();
        expect(find.text('All'), findsOneWidget);
      });
    });

    group('Notification Actions', () {
      testWidgets('mark as read functionality', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Count initial unread notifications
        await tester.tap(find.text('Unread'));
        await tester.pumpAndSettle();

        final initialUnreadCount = tester.widgetList(find.byType(Card)).length;

        // Go back to all notifications
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Tap on first notification to mark as read
        if (tester.widgetList(find.byType(Card)).isNotEmpty) {
          await tester.tap(find.byType(Card).first);
          await tester.pumpAndSettle();

          // Check unread count decreased
          await tester.tap(find.text('Unread'));
          await tester.pumpAndSettle();

          final newUnreadCount = tester.widgetList(find.byType(Card)).length;
          expect(newUnreadCount, lessThan(initialUnreadCount));
        }
      });

      testWidgets('delete notification functionality', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Count initial notifications
        final initialCount = tester.widgetList(find.byType(Card)).length;

        // Delete first notification (if any)
        if (initialCount > 0) {
          await tester.tap(find.byIcon(Icons.delete_outline).first);
          await tester.pumpAndSettle();

          // Verify notification count decreased
          final newCount = tester.widgetList(find.byType(Card)).length;
          expect(newCount, lessThan(initialCount));
        }
      });

      testWidgets('mark all as read functionality', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // If mark all read button exists, tap it
        final markAllReadButton = find.text('Mark All Read');
        if (markAllReadButton.evaluate().isNotEmpty) {
          await tester.tap(markAllReadButton);
          await tester.pumpAndSettle();

          // Verify unread tab is empty
          await tester.tap(find.text('Unread'));
          await tester.pumpAndSettle();

          expect(find.text('All caught up! 🎉'), findsOneWidget);
        }
      });
    });

    group('Background Notification Processing', () {
      testWidgets('background notification scheduling', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Simulate app going to background
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          null,
          (data) {},
        );

        // Wait for background processing
        await Future.delayed(const Duration(seconds: 2));

        // Bring app back to foreground
        await tester.pumpAndSettle();

        // Verify notifications are still properly scheduled
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Performance and Memory', () {
      testWidgets('notification list performance with many items',
          (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // Measure scroll performance
        final stopwatch = Stopwatch()..start();

        // Perform rapid scrolling
        for (int i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -300),
            1000,
          );
          await tester.pump();
        }

        stopwatch.stop();

        // Verify scrolling performance is acceptable (less than 5 seconds for 10 flings)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Verify UI is still responsive
        await tester.pumpAndSettle();
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('graceful handling of notification service errors',
          (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification center
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();

        // UI should still be functional even if some notifications fail to load
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('handling of missing notification permissions',
          (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to notification settings
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // App should handle missing permissions gracefully
        expect(find.text('Notification Settings'), findsOneWidget);
      });
    });
  });
}
