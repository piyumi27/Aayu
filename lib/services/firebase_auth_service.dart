import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  // Phone verification variables
  static String? _verificationId;
  static int? _resendToken;

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send OTP to phone number
  static Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerification,
  }) async {
    try {
      // Format phone number (add country code if not present)
      String formattedPhoneNumber = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhoneNumber = '+94$phoneNumber'; // Sri Lankan country code
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerification != null) {
            onAutoVerification(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number entered is invalid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = 'Verification failed: ${e.message}';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  // Verify OTP and sign in
  static Future<UserCredential?> verifyOTP({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final String vId = verificationId ?? _verificationId ?? '';
      if (vId.isEmpty) {
        throw Exception('Verification ID is missing');
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: otp,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code is invalid.';
          break;
        case 'session-expired':
          errorMessage = 'The verification session has expired.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Verification failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Save user profile data to Firestore
  static Future<void> saveUserProfile({
    required String uid,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile data from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Check if user profile exists
  static Future<bool> userProfileExists(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (data != null) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(uid).update(data);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete the user account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticate(String phoneNumber, String otp) async {
    try {
      final user = _auth.currentUser;
      if (user != null && _verificationId != null) {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Failed to re-authenticate: $e');
    }
  }
}