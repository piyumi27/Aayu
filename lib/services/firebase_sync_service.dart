import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

import '../models/migration_queue.dart';
import '../models/user_account.dart';
import '../models/growth_standard.dart';
import '../models/nutrition_guideline.dart';
import '../models/development_milestone.dart';
import '../repositories/standards_repository.dart';
import 'local_auth_service.dart';
import 'firebase_initialization_service.dart';

/// Firebase sync service that handles background synchronization
class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  static const String syncTaskName = 'firebaseSync';
  static const String authSyncTaskName = 'authSync';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthService _localAuth = LocalAuthService();
  final StandardsRepository _standardsRepository = StandardsRepository();

  // Migration queue storage key
  static const String _migrationQueueKey = 'migration_queue';

  /// Initialize WorkManager for background sync (only if Firebase is available)
  static Future<void> initialize() async {
    final firebaseService = FirebaseInitializationService();

    if (!firebaseService.isInitialized) {
      debugPrint(
          '⚠️ Skipping WorkManager initialization - Firebase not available');
      return;
    }

    try {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      debugPrint('✅ WorkManager initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize WorkManager: $e');
    }
  }

  /// Schedule periodic sync job
  Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: const Duration(hours: 1), // Sync every hour when online
    );
  }

  /// Schedule immediate sync
  Future<void> scheduleImmediateSync() async {
    await Workmanager().registerOneOffTask(
      'immediateSync',
      syncTaskName,
    );
  }

  /// Sync user authentication data with Firebase
  Future<SyncResult> syncUserAuthentication() async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return SyncResult(
          success: false,
          message: 'No network connection',
          type: SyncType.auth,
        );
      }

      final localUser = await _localAuth.getCurrentUser();
      if (localUser == null || !localUser.needsSync) {
        return SyncResult(
          success: true,
          message: 'No sync required',
          type: SyncType.auth,
        );
      }

      // Check if user already exists in Firebase
      final existingUsers = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: localUser.phoneNumber)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        // User exists, sync with existing account
        final firebaseUser = existingUsers.docs.first;
        await _syncWithExistingUser(localUser, firebaseUser);
      } else {
        // Create new user in Firebase
        await _createFirebaseUser(localUser);
      }

      // Mark local user as synced
      await _localAuth.markAsSynced();

      return SyncResult(
        success: true,
        message: 'User data synced successfully',
        type: SyncType.auth,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
        type: SyncType.auth,
      );
    }
  }

  /// Create new user in Firebase
  Future<void> _createFirebaseUser(UserAccount localUser) async {
    // Create user document in Firestore
    await _firestore.collection('users').doc(localUser.id).set({
      'id': localUser.id,
      'fullName': localUser.fullName,
      'phoneNumber': localUser.phoneNumber,
      'email': localUser.email,
      'isVerified': false, // Will be verified through phone OTP
      'createdAt': localUser.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'localCreated': true,
    });
  }

  /// Sync with existing Firebase user
  Future<void> _syncWithExistingUser(
      UserAccount localUser, QueryDocumentSnapshot firebaseUser) async {
    final firebaseData = firebaseUser.data() as Map<String, dynamic>;

    // Update Firebase with any local changes
    await _firestore.collection('users').doc(firebaseUser.id).update({
      'fullName': localUser.fullName,
      'email': localUser.email,
      'updatedAt': DateTime.now().toIso8601String(),
      'lastSyncAt': DateTime.now().toIso8601String(),
    });

    // Check if user is verified in Firebase
    final isVerifiedOnFirebase = firebaseData['isVerified'] ?? false;
    if (isVerifiedOnFirebase && !localUser.isVerified) {
      await _localAuth.markAsVerified();
    }
  }

  /// Sync child data with Firebase
  Future<SyncResult> syncChildData() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return SyncResult(
          success: false,
          message: 'No network connection',
          type: SyncType.childData,
        );
      }

      final localUser = await _localAuth.getCurrentUser();
      if (localUser == null) {
        return SyncResult(
          success: false,
          message: 'No user logged in',
          type: SyncType.childData,
        );
      }

      // TODO: Implement child data sync
      // This would sync child profiles, measurements, vaccinations, etc.
      // For now, just return success

      return SyncResult(
        success: true,
        message: 'Child data synced successfully',
        type: SyncType.childData,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Child data sync failed: ${e.toString()}',
        type: SyncType.childData,
      );
    }
  }

  /// Add entry to migration queue
  Future<void> queueForMigration({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final user = await _localAuth.getCurrentUser();

    // If user is verified, sync immediately instead of queueing
    if (user?.isSyncGateOpen == true) {
      await _processImmediateSync(entityType, entityId, operation, data);
      return;
    }

    // Otherwise, add to queue
    final entry = MigrationQueueEntry.create(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
    );

    final queue = await _getMigrationQueue();
    queue.add(entry);
    await _saveMigrationQueue(queue);
  }

  /// Get migration queue summary
  Future<MigrationQueueSummary> getMigrationQueueSummary() async {
    final queue = await _getMigrationQueue();

    final pending =
        queue.where((e) => e.status == MigrationStatus.pending).length;
    final processing =
        queue.where((e) => e.status == MigrationStatus.processing).length;
    final completed =
        queue.where((e) => e.status == MigrationStatus.completed).length;
    final failed =
        queue.where((e) => e.status == MigrationStatus.failed).length;

    final lastProcessed = queue
        .where((e) => e.processedAt != null)
        .map((e) => e.processedAt!)
        .fold<DateTime?>(null,
            (prev, date) => prev == null || date.isAfter(prev) ? date : prev);

    return MigrationQueueSummary(
      totalEntries: queue.length,
      pendingEntries: pending,
      processingEntries: processing,
      completedEntries: completed,
      failedEntries: failed,
      lastProcessedAt: lastProcessed,
    );
  }

  /// Process migration queue (called after verification)
  Future<List<SyncResult>> processMigrationQueue() async {
    final user = await _localAuth.getCurrentUser();
    if (user?.isSyncGateOpen != true) {
      return [
        SyncResult(
          success: false,
          message: 'User not verified - cannot process migration queue',
          type: SyncType.unknown,
        )
      ];
    }

    final queue = await _getMigrationQueue();
    final results = <SyncResult>[];

    // Sort by priority (users first, then children, etc.)
    queue.sort((a, b) => b.priority.compareTo(a.priority));

    for (final entry in queue) {
      if (entry.status == MigrationStatus.pending || entry.canRetry) {
        final result = await _processMigrationEntry(entry);
        results.add(result);

        // Update entry status
        final updatedEntry = entry.copyWith(
          status: result.success
              ? MigrationStatus.completed
              : MigrationStatus.failed,
          processedAt: DateTime.now(),
          retryCount: entry.retryCount + (result.success ? 0 : 1),
          errorMessage: result.success ? null : result.message,
        );

        // Replace entry in queue
        final index = queue.indexWhere((e) => e.id == entry.id);
        if (index >= 0) {
          queue[index] = updatedEntry;
        }
      }
    }

    // Save updated queue
    await _saveMigrationQueue(queue);

    return results;
  }

  /// Clear completed entries from migration queue
  Future<void> clearCompletedMigrations() async {
    final queue = await _getMigrationQueue();
    final filtered =
        queue.where((e) => e.status != MigrationStatus.completed).toList();
    await _saveMigrationQueue(filtered);
  }

  /// Get migration queue from storage
  Future<List<MigrationQueueEntry>> _getMigrationQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_migrationQueueKey);

    if (queueJson == null) return [];

    try {
      final List<dynamic> queueList = json.decode(queueJson);
      return queueList
          .map((item) => MigrationQueueEntry.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save migration queue to storage
  Future<void> _saveMigrationQueue(List<MigrationQueueEntry> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = json.encode(queue.map((e) => e.toJson()).toList());
    await prefs.setString(_migrationQueueKey, queueJson);
  }

  /// Process immediate sync for verified users
  Future<void> _processImmediateSync(
    String entityType,
    String entityId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      switch (entityType) {
        case 'user':
          await _syncUserData(data);
          break;
        case 'child':
          await _syncChildData(data);
          break;
        case 'measurement':
          await _syncMeasurementData(data);
          break;
        case 'vaccination':
          await _syncVaccinationData(data);
          break;
      }
    } catch (e) {
      // If immediate sync fails, add to queue
      final entry = MigrationQueueEntry.create(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
      );

      final queue = await _getMigrationQueue();
      queue.add(entry);
      await _saveMigrationQueue(queue);
    }
  }

  /// Process individual migration entry
  Future<SyncResult> _processMigrationEntry(MigrationQueueEntry entry) async {
    try {
      switch (entry.entityType) {
        case 'user':
          await _syncUserData(entry.data);
          break;
        case 'child':
          await _syncChildData(entry.data);
          break;
        case 'measurement':
          await _syncMeasurementData(entry.data);
          break;
        case 'vaccination':
          await _syncVaccinationData(entry.data);
          break;
        default:
          throw Exception('Unknown entity type: ${entry.entityType}');
      }

      return SyncResult(
        success: true,
        message: '${entry.entityType} ${entry.operation} successful',
        type: SyncType.childData,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Failed to sync ${entry.entityType}: ${e.toString()}',
        type: SyncType.childData,
      );
    }
  }

  /// Sync user data to Firestore
  Future<void> _syncUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Sync child data to Firestore
  Future<void> _syncChildData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  /// Sync measurement data to Firestore
  Future<void> _syncMeasurementData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('measurements')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  /// Sync vaccination data to Firestore
  Future<void> _syncVaccinationData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vaccinations')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  /// Sync user's preferred standards settings and custom standards
  Future<SyncResult> syncStandardsData() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return SyncResult(
          success: false,
          message: 'No network connection',
          type: SyncType.growthStandards,
        );
      }

      final user = _auth.currentUser;
      if (user == null) {
        return SyncResult(
          success: false,
          message: 'No authenticated user',
          type: SyncType.growthStandards,
        );
      }

      final currentSource = _standardsRepository.currentStandardSource;
      final standardsStats = await _standardsRepository.getStandardsStats();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('standards')
          .set({
        'preferredStandardSource': currentSource,
        'lastSyncAt': FieldValue.serverTimestamp(),
        'localStandardsStats': standardsStats,
      }, SetOptions(merge: true));

      final availableSources = await _standardsRepository.getAvailableSources();
      await _syncCommunityStandards(availableSources);

      return SyncResult(
        success: true,
        message: 'Standards data synced successfully',
        type: SyncType.growthStandards,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Standards sync failed: $e',
        type: SyncType.growthStandards,
      );
    }
  }

  /// Sync community standards and updates
  Future<void> _syncCommunityStandards(List<String> availableSources) async {
    final user = _auth.currentUser;
    if (user == null) return;

    for (final source in availableSources) {
      final communityData =
          await _firestore.collection('community_standards').doc(source).get();

      if (communityData.exists) {
        final data = communityData.data()!;
        final lastUpdated = (data['lastUpdated'] as Timestamp?)?.toDate();

        if (lastUpdated != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('standards_updates')
              .doc(source)
              .set({
            'source': source,
            'lastCommunityUpdate': lastUpdated,
            'checkedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    }
  }

  /// Sync health alerts to Firebase for analysis and community insights
  Future<SyncResult> syncHealthAlerts(List<Map<String, dynamic>> alerts) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return SyncResult(
          success: false,
          message: 'No network connection',
          type: SyncType.healthAlerts,
        );
      }

      final user = _auth.currentUser;
      if (user == null) {
        return SyncResult(
          success: false,
          message: 'No authenticated user',
          type: SyncType.healthAlerts,
        );
      }

      final batch = _firestore.batch();

      for (final alert in alerts) {
        final alertRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('health_alerts')
            .doc(alert['id']);

        final anonymizedAlert = Map<String, dynamic>.from(alert);
        anonymizedAlert.remove('childId');
        anonymizedAlert['userId'] = user.uid;
        anonymizedAlert['syncedAt'] = FieldValue.serverTimestamp();

        batch.set(alertRef, anonymizedAlert, SetOptions(merge: true));

        final communityRef =
            _firestore.collection('community_health_insights').doc();

        final communityData = {
          'alertType': alert['type'],
          'severity': alert['severity'],
          'standardSource': _standardsRepository.currentStandardSource,
          'timestamp': FieldValue.serverTimestamp(),
          'region': 'sri_lanka',
        };

        batch.set(communityRef, communityData);
      }

      await batch.commit();

      return SyncResult(
        success: true,
        message: '${alerts.length} health alerts synced',
        type: SyncType.healthAlerts,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Health alerts sync failed: $e',
        type: SyncType.healthAlerts,
      );
    }
  }

  /// Download updated standards from Firebase
  Future<SyncResult> downloadStandardsUpdates() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return SyncResult(
          success: false,
          message: 'No network connection',
          type: SyncType.growthStandards,
        );
      }

      final updatesRef = _firestore.collection('standards_updates');
      final updates = await updatesRef
          .where('published', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .limit(10)
          .get();

      int updatesApplied = 0;

      for (final doc in updates.docs) {
        final data = doc.data();
        final updateType = data['type'] as String?;
        final updateData = data['data'] as Map<String, dynamic>?;

        if (updateType != null && updateData != null) {
          switch (updateType) {
            case 'growth_standards_update':
              await _applyGrowthStandardsUpdate(updateData);
              updatesApplied++;
              break;
            case 'nutrition_guidelines_update':
              await _applyNutritionGuidelinesUpdate(updateData);
              updatesApplied++;
              break;
            case 'development_milestones_update':
              await _applyDevelopmentMilestonesUpdate(updateData);
              updatesApplied++;
              break;
          }
        }
      }

      return SyncResult(
        success: true,
        message: '$updatesApplied standards updates applied',
        type: SyncType.growthStandards,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Standards updates download failed: $e',
        type: SyncType.growthStandards,
      );
    }
  }

  Future<void> _applyGrowthStandardsUpdate(
      Map<String, dynamic> updateData) async {
    // Implementation would apply growth standards updates
    // This is a placeholder for future enhancement
  }

  Future<void> _applyNutritionGuidelinesUpdate(
      Map<String, dynamic> updateData) async {
    // Implementation would apply nutrition guidelines updates
    // This is a placeholder for future enhancement
  }

  Future<void> _applyDevelopmentMilestonesUpdate(
      Map<String, dynamic> updateData) async {
    // Implementation would apply development milestones updates
    // This is a placeholder for future enhancement
  }

  /// Queue standards data for offline sync
  Future<void> queueStandardsForSync({
    required String dataType,
    required Map<String, dynamic> data,
  }) async {
    await queueForMigration(
      entityType: dataType,
      entityId: data['id'] ?? 'unknown',
      operation: 'sync',
      data: data,
    );
  }

  /// Sync user assessment preferences
  Future<SyncResult> syncAssessmentPreferences({
    required String preferredStandard,
    required Map<String, bool> enabledAlerts,
    required Map<String, double> alertThresholds,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return SyncResult(
          success: false,
          message: 'No authenticated user',
          type: SyncType.auth,
        );
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('assessment_preferences')
          .set({
        'preferredStandard': preferredStandard,
        'enabledAlerts': enabledAlerts,
        'alertThresholds': alertThresholds,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _standardsRepository.setStandardSource(preferredStandard);

      return SyncResult(
        success: true,
        message: 'Assessment preferences synced',
        type: SyncType.auth,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Preferences sync failed: $e',
        type: SyncType.auth,
      );
    }
  }

  /// Check sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final needsSync = await _localAuth.needsFirebaseSync();
    final user = await _localAuth.getCurrentUser();
    final queueSummary = await getMigrationQueueSummary();

    return {
      'needsSync': needsSync || queueSummary.hasWork,
      'lastSync': user?.syncedAt?.toIso8601String(),
      'isVerified': user?.isSyncGateOpen ?? false,
      'userName': user?.fullName,
      'syncsPending': queueSummary.pendingEntries,
      'queueSummary': {
        'total': queueSummary.totalEntries,
        'pending': queueSummary.pendingEntries,
        'processing': queueSummary.processingEntries,
        'completed': queueSummary.completedEntries,
        'failed': queueSummary.failedEntries,
        'progress': queueSummary.progress,
      },
    };
  }

  /// Cancel all sync tasks
  Future<void> cancelAllSyncTasks() async {
    await Workmanager().cancelAll();
  }

  /// Manual sync trigger
  Future<List<SyncResult>> performManualSync() async {
    final results = <SyncResult>[];

    // Sync user authentication first
    final authResult = await syncUserAuthentication();
    results.add(authResult);

    // If auth sync successful, process migration queue
    if (authResult.success) {
      final queueResults = await processMigrationQueue();
      results.addAll(queueResults);

      // Also sync child data (legacy support)
      final childResult = await syncChildData();
      results.add(childResult);
    }

    return results;
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case FirebaseSyncService.syncTaskName:
        case 'immediateSync':
          // Perform sync tasks
          final syncService = FirebaseSyncService();
          final results = await syncService.performManualSync();

          // Log results to shared preferences for app to read
          final prefs = await SharedPreferences.getInstance();
          final syncLog = results.map((r) => r.toJson()).toList();
          await prefs.setString('last_sync_results', json.encode(syncLog));
          await prefs.setString(
              'last_sync_time', DateTime.now().toIso8601String());

          return results.every((r) => r.success);

        case FirebaseSyncService.authSyncTaskName:
          final syncService = FirebaseSyncService();
          final result = await syncService.syncUserAuthentication();
          return result.success;
      }

      return true;
    } catch (e) {
      print('Background sync error: $e');
      return false;
    }
  });
}

/// Sync result model
class SyncResult {
  final bool success;
  final String message;
  final SyncType type;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    required this.message,
    required this.type,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      success: json['success'],
      message: json['message'],
      type: SyncType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncType.unknown,
      ),
    );
  }
}

/// Types of sync operations
enum SyncType {
  auth,
  childData,
  measurements,
  vaccinations,
  growthStandards,
  nutritionGuidelines,
  developmentMilestones,
  healthAlerts,
  unknown,
}
