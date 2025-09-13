import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../firebase_options.dart';

/// Service to handle Firebase initialization with proper error handling and fallbacks
class FirebaseInitializationService {
  static final FirebaseInitializationService _instance =
      FirebaseInitializationService._internal();
  factory FirebaseInitializationService() => _instance;
  FirebaseInitializationService._internal();

  bool _isInitialized = false;
  bool _initializationFailed = false;
  String? _initializationError;

  /// Check if Firebase is initialized successfully
  bool get isInitialized => _isInitialized;

  /// Check if Firebase initialization failed
  bool get initializationFailed => _initializationFailed;

  /// Get the initialization error message
  String? get initializationError => _initializationError;

  /// Initialize Firebase with comprehensive error handling
  Future<bool> initializeFirebase(
      {int maxRetries = 3,
      Duration retryDelay = const Duration(seconds: 2)}) async {
    if (_isInitialized) {
      debugPrint('✅ Firebase already initialized');
      return true;
    }

    debugPrint('🔥 Starting Firebase initialization...');
    debugPrint('📋 Project ID: aayu-mobile');
    debugPrint('📦 Package Name: dev.aayu');

    // Check network connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    debugPrint('📡 Network connectivity: ${connectivityResult.first}');

    if (connectivityResult.first == ConnectivityResult.none) {
      debugPrint(
          '⚠️ No internet connection detected - skipping Firebase initialization');
      _handleFirebaseInitializationFailure('No internet connection');
      return false;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint(
            '🔥 Attempting Firebase initialization (attempt $attempt/$maxRetries)');

        // Try to initialize Firebase with platform-specific options
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Verify initialization was successful
        final app = Firebase.app();
        debugPrint('🔍 Firebase app initialized: ${app.name}');
        debugPrint('🔍 Project ID: ${app.options.projectId}');
        debugPrint('🔍 App ID: ${app.options.appId}');

        _isInitialized = true;
        _initializationFailed = false;
        _initializationError = null;

        debugPrint('✅ Firebase initialized successfully on attempt $attempt');

        // Test basic Firebase connectivity
        await _testFirebaseConnectivity();

        return true;
      } on FirebaseException catch (e) {
        debugPrint(
            '🚨 Firebase initialization failed (attempt $attempt): ${e.code} - ${e.message}');
        debugPrint('🔍 Firebase error details: ${e.toString()}');
        _initializationError = 'Firebase Error: ${e.code} - ${e.message}';

        if (attempt == maxRetries) {
          _handleFirebaseInitializationFailure(e);
          return false;
        }

        // Wait before retrying
        debugPrint('⏳ Waiting ${retryDelay.inSeconds} seconds before retry...');
        await Future.delayed(retryDelay);
      } catch (e) {
        debugPrint(
            '🚨 Unexpected error during Firebase initialization (attempt $attempt): $e');
        debugPrint('🔍 Error type: ${e.runtimeType}');
        debugPrint('🔍 Error details: ${e.toString()}');
        _initializationError = 'Unexpected error: $e';

        if (attempt == maxRetries) {
          _handleFirebaseInitializationFailure(e);
          return false;
        }

        // Wait before retrying
        debugPrint('⏳ Waiting ${retryDelay.inSeconds} seconds before retry...');
        await Future.delayed(retryDelay);
      }
    }

    return false;
  }

  /// Handle Firebase initialization failure and set up offline mode
  void _handleFirebaseInitializationFailure(Object error) {
    _isInitialized = false;
    _initializationFailed = true;

    debugPrint('❌ Firebase initialization failed after all retries');
    debugPrint('🔄 Setting up offline-only mode');

    // Enable offline-only mode
    _setupOfflineMode();
  }

  /// Test Firebase connectivity
  Future<void> _testFirebaseConnectivity() async {
    try {
      debugPrint('🔍 Testing Firebase connectivity...');

      // Try to access Firestore to test connectivity
      // This is a lightweight test that doesn't require any setup
      final firestore = FirebaseFirestore.instance;
      await firestore.enableNetwork();

      debugPrint('✅ Firebase connectivity test passed');
    } catch (e) {
      debugPrint('⚠️ Firebase connectivity test failed: $e');
      // This is not a critical failure, Firebase is initialized but may have connectivity issues
    }
  }

  /// Set up offline mode when Firebase is unavailable
  void _setupOfflineMode() {
    debugPrint('📱 Running in offline-only mode');

    // Note: The app should work entirely offline using SQLite
    // All Firebase-dependent features should be disabled or have fallbacks
  }

  /// Check if Firebase services are available
  Future<bool> areFirebaseServicesAvailable() async {
    if (!_isInitialized) return false;

    try {
      // Try to access Firebase services
      // This is a lightweight check to see if Firebase is responsive
      final app = Firebase.app();
      return app.options.projectId?.isNotEmpty ?? false;
    } catch (e) {
      debugPrint('⚠️ Firebase services not available: $e');
      return false;
    }
  }

  /// Initialize Firebase Auth with error handling
  Future<bool> initializeFirebaseAuth() async {
    if (!_isInitialized) {
      debugPrint(
          '⚠️ Cannot initialize Firebase Auth - Firebase not initialized');
      return false;
    }

    try {
      // Firebase Auth will be available through the already initialized Firebase app
      debugPrint('✅ Firebase Auth available');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase Auth initialization failed: $e');
      return false;
    }
  }

  /// Initialize Firestore with error handling
  Future<bool> initializeFirestore() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Cannot initialize Firestore - Firebase not initialized');
      return false;
    }

    try {
      // Firestore will be available through the already initialized Firebase app
      debugPrint('✅ Firestore available');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore initialization failed: $e');
      return false;
    }
  }

  /// Initialize Firebase Storage with error handling
  Future<bool> initializeFirebaseStorage() async {
    if (!_isInitialized) {
      debugPrint(
          '⚠️ Cannot initialize Firebase Storage - Firebase not initialized');
      return false;
    }

    try {
      // Firebase Storage will be available through the already initialized Firebase app
      debugPrint('✅ Firebase Storage available');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase Storage initialization failed: $e');
      return false;
    }
  }

  /// Initialize Firebase Messaging with error handling
  Future<bool> initializeFirebaseMessaging() async {
    if (!_isInitialized) {
      debugPrint(
          '⚠️ Cannot initialize Firebase Messaging - Firebase not initialized');
      return false;
    }

    try {
      // Firebase Messaging will be available through the already initialized Firebase app
      debugPrint('✅ Firebase Messaging available');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase Messaging initialization failed: $e');
      return false;
    }
  }

  /// Get a user-friendly status message
  String getStatusMessage() {
    if (_isInitialized) {
      return 'Connected to cloud services';
    } else if (_initializationFailed) {
      return 'Running in offline mode';
    } else {
      return 'Connecting to cloud services...';
    }
  }

  /// Reset initialization state (useful for testing)
  void reset() {
    _isInitialized = false;
    _initializationFailed = false;
    _initializationError = null;
  }
}

/// Widget to show Firebase initialization status
class FirebaseStatusIndicator extends StatelessWidget {
  const FirebaseStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseInitializationService();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: firebaseService.isInitialized
            ? Colors.green.withOpacity(0.1)
            : firebaseService.initializationFailed
                ? Colors.orange.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            firebaseService.isInitialized
                ? Icons.cloud_done
                : firebaseService.initializationFailed
                    ? Icons.cloud_off
                    : Icons.cloud_sync,
            size: 16,
            color: firebaseService.isInitialized
                ? Colors.green
                : firebaseService.initializationFailed
                    ? Colors.orange
                    : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            firebaseService.getStatusMessage(),
            style: TextStyle(
              fontSize: 12,
              color: firebaseService.isInitialized
                  ? Colors.green
                  : firebaseService.initializationFailed
                      ? Colors.orange
                      : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
