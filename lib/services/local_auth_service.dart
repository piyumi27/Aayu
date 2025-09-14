import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_account.dart';

/// Local-first authentication service that works offline and syncs with Firebase
class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  static const String _keyCurrentUser = 'current_user';
  static const String _keyPendingSync = 'pending_sync';
  static const String _keyVerificationStatus = 'verification_status';
  
  final Uuid _uuid = Uuid();

  /// Register a new user locally
  Future<AuthResult> registerUser({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user already exists
      final existingUser = await _getStoredUser();
      if (existingUser != null) {
        // If the user exists with the same phone number and password, log them in
        if (existingUser.phoneNumber == phoneNumber &&
            existingUser.passwordHash == _hashPassword(password)) {
          // Update last login and log them in
          final updatedUser = existingUser.copyWith(
            lastLoginAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _storeUser(updatedUser);

          return AuthResult(
            success: true,
            message: 'Welcome back! You are now logged in.',
            user: updatedUser,
          );
        } else {
          return AuthResult(
            success: false,
            message: 'User already registered. Please login instead.',
          );
        }
      }
      
      // Create local user
      final user = UserAccount(
        id: _uuid.v4(),
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email?.isNotEmpty == true ? email : null,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
        needsSync: true,
      );
      
      // Store locally
      await _storeUser(user);
      await prefs.setBool(_keyPendingSync, true);
      
      return AuthResult(
        success: true,
        message: 'Account created successfully. You are now logged in.',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  /// Login user with local credentials
  Future<AuthResult> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final user = await _getStoredUser();
      
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No account found. Please register first.',
        );
      }
      
      if (user.phoneNumber != phoneNumber) {
        return AuthResult(
          success: false,
          message: 'Phone number not found.',
        );
      }
      
      if (user.passwordHash != _hashPassword(password)) {
        return AuthResult(
          success: false,
          message: 'Incorrect password.',
        );
      }
      
      // Update last login
      final updatedUser = user.copyWith(
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storeUser(updatedUser);
      
      return AuthResult(
        success: true,
        message: 'Login successful.',
        user: updatedUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Get current logged-in user
  Future<UserAccount?> getCurrentUser() async {
    return await _getStoredUser();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_logged_in') ?? false;
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear session-based dismissals so verification banner reappears on next login
    final keys = prefs.getKeys();
    final dismissalKeys = keys.where((key) => key.startsWith('verification_banner_dismissed_')).toList();
    for (final key in dismissalKeys) {
      await prefs.remove(key);
    }

    // Don't remove user data, just clear the logged-in flag
    // User data should persist for future logins
    await prefs.setBool('user_logged_in', false);
  }

  /// Update user profile
  Future<AuthResult> updateUserProfile({
    required String fullName,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final user = await _getStoredUser();
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No user logged in.',
        );
      }
      
      final updatedUser = user.copyWith(
        fullName: fullName,
        email: email,
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
        needsSync: true,
      );
      
      await _storeUser(updatedUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyPendingSync, true);
      
      return AuthResult(
        success: true,
        message: 'Profile updated successfully.',
        user: updatedUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _getStoredUser();
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No user logged in.',
        );
      }
      
      // Verify current password
      if (user.passwordHash != _hashPassword(currentPassword)) {
        return AuthResult(
          success: false,
          message: 'Current password is incorrect.',
        );
      }
      
      // Update password
      final updatedUser = user.copyWith(
        passwordHash: _hashPassword(newPassword),
        updatedAt: DateTime.now(),
        needsSync: true,
      );
      
      await _storeUser(updatedUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyPendingSync, true);
      
      return AuthResult(
        success: true,
        message: 'Password changed successfully.',
        user: updatedUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }

  /// Check if user needs Firebase sync
  Future<bool> needsFirebaseSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPendingSync) ?? false;
  }

  /// Mark user as synced with Firebase
  Future<void> markAsSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPendingSync, false);
    
    final user = await _getStoredUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        needsSync: false,
        syncedAt: DateTime.now(),
      );
      await _storeUser(updatedUser);
    }
  }

  /// Mark user as verified (after Firebase verification)
  Future<void> markAsVerified() async {
    final user = await _getStoredUser();
    if (user != null) {
      final verifiedUser = user.copyWith(
        isVerified: true,
        verifiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storeUser(verifiedUser);
    }
  }

  /// Get verification status
  Future<VerificationStatus> getVerificationStatus() async {
    final user = await _getStoredUser();
    if (user == null) {
      return VerificationStatus.notLoggedIn;
    }
    
    if (user.isVerified) {
      return VerificationStatus.verified;
    }
    
    if (user.needsSync) {
      return VerificationStatus.pendingSync;
    }
    
    return VerificationStatus.unverified;
  }

  /// Store user in local storage
  Future<void> _storeUser(UserAccount user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, json.encode(user.toJson()));
    await prefs.setBool('user_logged_in', true);
  }

  /// Get stored user from local storage
  Future<UserAccount?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyCurrentUser);
    
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserAccount.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate OTP for phone verification
  String generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
    return random.toString();
  }

  /// Simulate OTP verification (in real app, this would verify with SMS service)
  Future<bool> verifyOTP(String otp) async {
    // For demo purposes, accept any 6-digit OTP
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }
}

/// Authentication result model
class AuthResult {
  final bool success;
  final String message;
  final UserAccount? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

