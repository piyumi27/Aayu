import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../services/local_auth_service.dart' as auth;
import '../utils/responsive_utils.dart';
import '../utils/validation_utils.dart';
import '../widgets/sri_lanka_phone_field.dart';

class VerificationCenterScreen extends StatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  State<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends State<VerificationCenterScreen> 
    with TickerProviderStateMixin {
  final auth.LocalAuthService _authService = auth.LocalAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  String _selectedLanguage = 'en';
  UserAccount? _currentUser;
  String? _errorMessage;
  String? _successMessage;
  
  // Email verification
  bool _isEmailLoading = false;
  DateTime? _lastEmailSent;
  
  // Phone verification
  bool _isPhoneLoading = false;
  String _phoneNumber = '';
  String _otpCode = '';
  String? _verificationId;
  bool _showOtpInput = false;
  int _otpCountdown = 0;
  late AnimationController _countdownController;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _countdownController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await _authService.getCurrentUser();
    
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
        _currentUser = user;
        if (user?.phoneNumber.isNotEmpty == true) {
          _phoneNumber = user!.phoneNumber;
        }
      });
    }
  }

  String get _screenTitle {
    switch (_selectedLanguage) {
      case 'si': return 'ගිණුම් සත්‍යාපනය';
      case 'ta': return 'கணக்கு சரிபார்ப்பு';
      default: return 'Account Verification';
    }
  }

  String get _currentStatusTitle {
    switch (_selectedLanguage) {
      case 'si': return 'වත්මන් තත්වය';
      case 'ta': return 'தற்போதைய நிலை';
      default: return 'Current Status';
    }
  }

  String get _emailVerificationTitle {
    switch (_selectedLanguage) {
      case 'si': return 'ඊමේල් සත්‍යාපනය';
      case 'ta': return 'மின்னஞ்சல் சரிபார்ப்பு';
      default: return 'Email Verification';
    }
  }

  String get _phoneVerificationTitle {
    switch (_selectedLanguage) {
      case 'si': return 'දුරකථන සත්‍යාපනය';
      case 'ta': return 'தொலைபேசி சரிபார்ப்பு';
      default: return 'Phone Verification';
    }
  }

  String get _resendEmailText {
    switch (_selectedLanguage) {
      case 'si': return 'ඊමේල් නැවත යවන්න';
      case 'ta': return 'மின்னஞ்சலை மீண்டும் அனுப்பவும்';
      default: return 'Resend Email';
    }
  }

  String get _iVerifiedText {
    switch (_selectedLanguage) {
      case 'si': return 'මම සත්‍යාපනය කර ඇත';
      case 'ta': return 'நான் சரிபார்த்துவிட்டேன்';
      default: return 'I\'ve Verified';
    }
  }

  String get _sendCodeText {
    switch (_selectedLanguage) {
      case 'si': return 'කේතය යවන්න';
      case 'ta': return 'குறியீட்டை அனுப்பவும்';
      default: return 'Send Code';
    }
  }

  String get _verifyCodeText {
    switch (_selectedLanguage) {
      case 'si': return 'කේතය සත්‍යාපනය කරන්න';
      case 'ta': return 'குறியீட்டை சரிபார்க்கவும்';
      default: return 'Verify Code';
    }
  }

  Future<void> _resendEmailVerification() async {
    if (_isEmailLoading) return;
    
    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _lastEmailSent = DateTime.now();
          _successMessage = 'Verification email sent. Please check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification email: ${e.toString()}';
      });
    } finally {
      setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    if (_isEmailLoading) return;
    
    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          // Update local user
          if (_currentUser != null) {
            final updatedUser = _currentUser!.copyWith(
              isEmailVerified: true,
              verifiedAt: DateTime.now(),
              isVerified: true,
              needsSync: false,
            );
            // Save updated user locally
            setState(() {
              _currentUser = updatedUser;
              _successMessage = 'Email verified successfully! Cloud features are now available.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Email not yet verified. Please check your inbox and click the verification link.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check verification status: ${e.toString()}';
      });
    } finally {
      setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _sendPhoneVerification() async {
    if (_isPhoneLoading || !ValidationUtils.validateSriLankaLocal(
        ValidationUtils.extractSriLankaLocal(_phoneNumber),)) {
      return;
    }
    
    setState(() {
      _isPhoneLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _verifyPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = 'Phone verification failed: ${e.message}';
            _isPhoneLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _showOtpInput = true;
            _isPhoneLoading = false;
            _successMessage = 'Verification code sent to your phone.';
          });
          _startCountdown();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isPhoneLoading = false;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification code: ${e.toString()}';
        _isPhoneLoading = false;
      });
    }
  }

  Future<void> _verifyOtpCode() async {
    if (_isPhoneLoading || _verificationId == null || _otpCode.length != 6) return;
    
    setState(() {
      _isPhoneLoading = true;
      _errorMessage = null;
    });
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpCode,
      );
      await _verifyPhoneCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid verification code. Please try again.';
        _isPhoneLoading = false;
      });
    }
  }

  Future<void> _verifyPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
      } else {
        await _firebaseAuth.signInWithCredential(credential);
      }
      
      // Update local user
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          isPhoneVerified: true,
          verifiedAt: DateTime.now(),
          isVerified: true,
          needsSync: false,
        );
        setState(() {
          _currentUser = updatedUser;
          _successMessage = 'Phone verified successfully! Cloud features are now available.';
          _showOtpInput = false;
          _isPhoneLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Phone verification failed: ${e.toString()}';
        _isPhoneLoading = false;
      });
    }
  }

  void _startCountdown() {
    setState(() => _otpCountdown = 30);
    _countdownController.reset();
    _countdownController.forward();
    
    _countdownController.addListener(() {
      setState(() {
        _otpCountdown = (30 * (1 - _countdownController.value)).round();
      });
    });
  }

  Widget _buildStatusCard() {
    final status = _currentUser?.verificationStatus ?? VerificationStatus.unverified;
    final color = switch (status) {
      VerificationStatus.verified => const Color(0xFF10B981),
      VerificationStatus.pendingSync => const Color(0xFFF59E0B),
      _ => const Color(0xFF6B7280),
    };
    
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, scale: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStatusTitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            
            Row(
              children: [
                Icon(
                  status == VerificationStatus.verified 
                    ? Icons.verified_user 
                    : Icons.pending,
                  color: color,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                ),
                
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.displayText,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      
                      if (_currentUser != null)
                        Text(
                          _currentUser!.getVerificationPrompt(_selectedLanguage),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailVerificationCard() {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, scale: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                
                Text(
                  _emailVerificationTitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                if (_currentUser?.isEmailVerified == true)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF10B981),
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            
            if (_currentUser?.email != null) ...[
              Text(
                _currentUser!.email!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              
              if (!(_currentUser?.isEmailVerified ?? false)) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isEmailLoading ? null : _resendEmailVerification,
                        icon: _isEmailLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.send),
                        label: Text(_resendEmailText),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isEmailLoading ? null : _checkEmailVerification,
                        icon: _isEmailLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh),
                        label: Text(_iVerifiedText),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneVerificationCard() {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context, scale: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                
                Text(
                  _phoneVerificationTitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                if (_currentUser?.isPhoneVerified == true)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF10B981),
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            
            if (!(_currentUser?.isPhoneVerified ?? false)) ...[
              SriLankaPhoneField(
                initialValue: _phoneNumber,
                onChanged: (value) => setState(() => _phoneNumber = value),
                enabled: !_showOtpInput,
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              
              if (!_showOtpInput) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPhoneLoading ? null : _sendPhoneVerification,
                    icon: _isPhoneLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send),
                    label: Text(_sendCodeText),
                  ),
                ),
              ] else ...[
                TextField(
                  onChanged: (value) => setState(() => _otpCode = value),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(),
                    counterText: _otpCountdown > 0 ? '00:${_otpCountdown.toString().padLeft(2, '0')}' : null,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPhoneLoading || _otpCode.length != 6 ? null : _verifyOtpCode,
                    icon: _isPhoneLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.verified_user),
                    label: Text(_verifyCodeText),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success message
              if (_successMessage != null) ...[
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFF10B981)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFF10B981)),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      Expanded(child: Text(_successMessage!)),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    border: Border.all(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Current status
              _buildStatusCard(),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
              
              // Email verification
              _buildEmailVerificationCard(),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              
              // Phone verification
              _buildPhoneVerificationCard(),
            ],
          ),
        ),
      ),
    );
  }
}