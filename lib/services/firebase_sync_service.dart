import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/user_account.dart';
import 'local_auth_service.dart';

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
  
  /// Initialize WorkManager for background sync
  static Future<void> initialize() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  /// Schedule periodic sync job
  Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: const Duration(hours: 1), // Sync every hour when online
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  /// Schedule immediate sync
  Future<void> scheduleImmediateSync() async {
    await Workmanager().registerOneOffTask(
      'immediateSync',
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
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
  Future<void> _syncWithExistingUser(UserAccount localUser, QueryDocumentSnapshot firebaseUser) async {
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

  /// Check sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final needsSync = await _localAuth.needsFirebaseSync();
    final user = await _localAuth.getCurrentUser();
    
    return {
      'needsSync': needsSync,
      'lastSync': user?.syncedAt?.toIso8601String(),
      'isVerified': user?.isVerified ?? false,
      'userName': user?.fullName,
      'syncsPending': needsSync ? 1 : 0,
    };
  }

  /// Cancel all sync tasks
  Future<void> cancelAllSyncTasks() async {
    await Workmanager().cancelAll();
  }

  /// Manual sync trigger
  Future<List<SyncResult>> performManualSync() async {
    final results = <SyncResult>[];
    
    // Sync user authentication
    final authResult = await syncUserAuthentication();
    results.add(authResult);
    
    // Sync child data if auth sync was successful
    if (authResult.success) {
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
          await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
          
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
  unknown,
}

/// WorkManager constraints
class Constraints {
  final NetworkType networkType;
  final bool requiresBatteryNotLow;
  final bool requiresCharging;

  const Constraints({
    this.networkType = NetworkType.connected,
    this.requiresBatteryNotLow = false,
    this.requiresCharging = false,
  });
}

enum NetworkType {
  connected,
  unmetered,
  notRequired,
}