import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../services/local_auth_service.dart';
import '../utils/responsive_utils.dart';

class VerificationCenterScreen extends StatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  State<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends State<VerificationCenterScreen> {
  final LocalAuthService _authService = LocalAuthService();
  
  String _selectedLanguage = 'en';
  UserAccount? _currentUser;
  String? _errorMessage;
  String? _successMessage;
  
  // Email verification
  bool _isEmailLoading = false;
  bool _emailSent = false;
  
  // Phone verification  
  bool _isPhoneLoading = false;
  String _otpCode = '';
  int _resendCountdown = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await _authService.getCurrentUser();
    
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _currentUser = user;
    });
  }
  
  Future<void> _sendEmailVerification() async {
    if (_currentUser?.email == null || _currentUser!.email!.isEmpty) {
      setState(() {
        _errorMessage = 'No email address found. Please update your profile first.';
      });
      return;
    }
    
    setState(() {
      _isEmailLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simulate sending email verification
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _emailSent = true;
        _successMessage = 'Verification email sent to ${_currentUser!.email}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isEmailLoading = false;
      });
    }
  }
  
  Future<void> _sendPhoneOTP() async {
    setState(() {
      _isPhoneLoading = true;
      _errorMessage = null;
      _resendCountdown = 30;
    });
    
    try {
      // Simulate sending OTP
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _successMessage = 'OTP sent to ${_currentUser!.phoneNumber}';
      });
      
      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isPhoneLoading = false;
      });
    }
  }
  
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startCountdown();
      }
    });
  }
  
  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }
    
    setState(() {
      _isPhoneLoading = true;
      _errorMessage = null;
    });
    
    try {
      final isValid = await _authService.verifyOTP(_otpCode);
      
      if (isValid) {
        await _authService.markAsVerified();
        
        setState(() {
          _successMessage = 'Phone number verified successfully!';
        });
        
        // Navigate to main app after successful verification
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/');
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isPhoneLoading = false;
      });
    }
  }
  
  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Verification?',
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'You can use the app offline without verification. Cloud features like data sync and backup will be available after verification.',
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0086FF),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Verify Your Account',
        'subtitle': 'Verify your email or phone to enable cloud sync and backup',
        'emailSection': 'Email Verification',
        'emailHint': 'We\'ll send a verification link to your email',
        'sendEmail': 'Send Verification Email',
        'emailSent': 'Check your email and click the verification link',
        'phoneSection': 'Phone Verification',
        'phoneHint': 'We\'ll send a 6-digit code to your phone',
        'sendOTP': 'Send OTP',
        'resendIn': 'Resend in',
        'seconds': 'seconds',
        'resend': 'Resend OTP',
        'otpHint': 'Enter 6-digit code',
        'verifyOTP': 'Verify Code',
        'skipButton': 'Skip for Now',
        'continueOffline': 'Continue Using App Offline',
      },
      'si': {
        'title': 'ඔබේ ගිණුම සත්‍යාපනය කරන්න',
        'subtitle': 'ක්ලවුඩ් සමමුහුර්තකරණය සහ උපස්ථකරණය සක්‍රිය කිරීමට ඔබේ විද්‍යුත් තැපෑල හෝ දුරකථනය සත්‍යාපනය කරන්න',
        'emailSection': 'විද්‍යුත් තැපෑල සත්‍යාපනය',
        'emailHint': 'අපි ඔබේ විද්‍යුත් තැපෑලට සත්‍යාපන සබැඳියක් යවන්නෙමු',
        'sendEmail': 'සත්‍යාපන තැපෑල යවන්න',
        'emailSent': 'ඔබේ විද්‍යුත් තැපෑල පරීක්ෂා කර සත්‍යාපන සබැඳිය ක්ලික් කරන්න',
        'phoneSection': 'දුරකථන සත්‍යාපනය',
        'phoneHint': 'අපි ඔබේ දුරකථනයට ඉලක්කම් 6ක කේතයක් යවන්නෙමු',
        'sendOTP': 'OTP යවන්න',
        'resendIn': 'නැවත යවන්න',
        'seconds': 'තත්පර',
        'resend': 'OTP නැවත යවන්න',
        'otpHint': 'ඉලක්කම් 6 ඇතුළත් කරන්න',
        'verifyOTP': 'කේතය සත්‍යාපනය කරන්න',
        'skipButton': 'දැනට මග හරින්න',
        'continueOffline': 'ඕෆ්ලයින් යෙදුම භාවිතා කරන්න',
      },
      'ta': {
        'title': 'உங்கள் கணக்கை சரிபார்க்கவும்',
        'subtitle': 'மேகக்கணி ஒத்திசைவு மற்றும் காப்புப்பிரதியை செயல்படுத்த உங்கள் மின்னஞ்சல் அல்லது தொலைபேசியை சரிபார்க்கவும்',
        'emailSection': 'மின்னஞ்சல் சரிபார்ப்பு',
        'emailHint': 'உங்கள் மின்னஞ்சலுக்கு சரிபார்ப்பு இணைப்பை அனுப்புவோம்',
        'sendEmail': 'சரிபார்ப்பு மின்னஞ்சல் அனுப்பு',
        'emailSent': 'உங்கள் மின்னஞ்சலைச் சரிபார்த்து சரிபார்ப்பு இணைப்பைக் கிளிக் செய்யவும்',
        'phoneSection': 'தொலைபேசி சரிபார்ப்பு',
        'phoneHint': 'உங்கள் தொலைபேசிக்கு 6-இலக்க குறியீட்டை அனுப்புவோம்',
        'sendOTP': 'OTP அனுப்பு',
        'resendIn': 'மீண்டும் அனுப்பு',
        'seconds': 'விநாடிகள்',
        'resend': 'OTP மீண்டும் அனுப்பு',
        'otpHint': '6-இலக்க குறியீட்டை உள்ளிடவும்',
        'verifyOTP': 'குறியீட்டை சரிபார்க்கவும்',
        'skipButton': 'இப்போதைக்கு தவிர்க்கவும்',
        'continueOffline': 'ஆஃப்லைனில் ஆப்பைப் பயன்படுத்தவும்',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }
  
  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    if (_currentUser == null) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          texts['title']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skipVerification,
            child: Text(
              texts['skipButton']!,
              style: TextStyle(
                color: const Color(0xFF0086FF),
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                texts['subtitle']!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: const Color(0xFF6B7280),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
              
              // Success/Error Messages
              if (_errorMessage != null) ...[
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              if (_successMessage != null) ...[
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0086FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0086FF).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: const Color(0xFF0086FF),
                        size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            color: const Color(0xFF0086FF),
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Email Verification Section
              if (_currentUser!.email != null && _currentUser!.email!.isNotEmpty) ...[
                _buildVerificationCard(
                  icon: Icons.email_outlined,
                  title: texts['emailSection']!,
                  subtitle: texts['emailHint']!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentUser!.email!,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                      
                      if (_emailSent)
                        Container(
                          padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0086FF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mark_email_read,
                                color: const Color(0xFF0086FF),
                                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                              ),
                              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                              Expanded(
                                child: Text(
                                  texts['emailSent']!,
                                  style: TextStyle(
                                    color: const Color(0xFF0086FF),
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(context, 48),
                          child: ElevatedButton(
                            onPressed: _isEmailLoading ? null : _sendEmailVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEmailLoading ? const Color(0xFFE5E7EB) : const Color(0xFF0086FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isEmailLoading
                                ? SizedBox(
                                    width: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                    height: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                    child: const CircularProgressIndicator(
                                      color: Color(0xFF6B7280),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    texts['sendEmail']!,
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: const Color(0xFFE5E7EB))),
                    Padding(
                      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: const Color(0xFFE5E7EB))),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
              ],
              
              // Phone Verification Section
              _buildVerificationCard(
                icon: Icons.phone_outlined,
                title: texts['phoneSection']!,
                subtitle: texts['phoneHint']!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentUser!.phoneNumber,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                    
                    // OTP Input
                    TextFormField(
                      onChanged: (value) => setState(() => _otpCode = value),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: texts['otpHint']!,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xFF0086FF),
                          ),
                        ),
                        contentPadding: ResponsiveUtils.getResponsivePadding(context),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                    
                    // Send OTP / Verify Button
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(context, 48),
                            child: ElevatedButton(
                              onPressed: _isPhoneLoading ? null : (_otpCode.length == 6 ? _verifyOTP : _sendPhoneOTP),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPhoneLoading ? const Color(0xFFE5E7EB) : const Color(0xFF0086FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isPhoneLoading
                                  ? SizedBox(
                                      width: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                      height: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                      child: const CircularProgressIndicator(
                                        color: Color(0xFF6B7280),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _otpCode.length == 6 ? texts['verifyOTP']! : texts['sendOTP']!,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Resend countdown
                    if (_resendCountdown > 0) ...[
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      Center(
                        child: Text(
                          '${texts['resendIn']!} $_resendCountdown ${texts['seconds']!}',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ] else if (_resendCountdown == 0 && _otpCode.length < 6) ...[
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      Center(
                        child: TextButton(
                          onPressed: _sendPhoneOTP,
                          child: Text(
                            texts['resend']!,
                            style: TextStyle(
                              color: const Color(0xFF0086FF),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                              fontWeight: FontWeight.w600,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
              
              // Continue Offline Button
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 48),
                child: OutlinedButton(
                  onPressed: _skipVerification,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF0086FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    texts['continueOffline']!,
                    style: TextStyle(
                      color: const Color(0xFF0086FF),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVerificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveUtils.getResponsiveIconSize(context, 48),
                height: ResponsiveUtils.getResponsiveIconSize(context, 48),
                decoration: BoxDecoration(
                  color: const Color(0xFF0086FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0086FF),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
          
          child,
        ],
      ),
    );
  }
}