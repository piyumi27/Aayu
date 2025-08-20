import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? fullName; // null for login, provided for registration
  final String verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.fullName,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  String _selectedLanguage = 'en';
  String? _errorMessage;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _startResendCountdown();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 45; // Start from 45 seconds as per specification
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      setState(() {
        _errorMessage = _getLocalizedText()['otpRequired']!;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuthService.verifyOTP(
        otp: otp,
        verificationId: widget.verificationId,
      );

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        
        // Save user profile if this is registration
        if (widget.fullName != null) {
          await FirebaseAuthService.saveUserProfile(
            uid: user.uid,
            phoneNumber: widget.phoneNumber,
            fullName: widget.fullName!,
          );
        }

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_logged_in', true);
        await prefs.setString('user_phone', widget.phoneNumber);
        if (widget.fullName != null) {
          await prefs.setString('user_name', widget.fullName!);
        }

        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuthService.sendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          _startResendCountdown();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getLocalizedText()['otpResent']!),
                backgroundColor: const Color(0xFF28A745),
              ),
            );
          }
        },
        onError: (error) {
          setState(() {
            _errorMessage = error;
          });
        },
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _onOTPDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    if (index == 5 && value.isNotEmpty) {
      final otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 6) {
        _verifyOTP();
      }
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Verify Phone Number',
        'subtitle': 'Enter the 6-digit code sent to',
        'otpHint': 'Enter OTP',
        'verifyButton': 'Verify',
        'resendCode': 'Resend Code',
        'resendIn': 'Resend in',
        'seconds': 'seconds',
        'otpRequired': 'Please enter the complete OTP',
        'otpResent': 'OTP sent successfully',
        'backToLogin': 'Back to Login',
      },
      'si': {
        'title': 'දුරකථන අංකය තහවුරු කරන්න',
        'subtitle': 'එවන ලද අංක 6කින් යුත් කේතය ඇතුළු කරන්න',
        'otpHint': 'OTP ඇතුළු කරන්න',
        'verifyButton': 'තහවුරු කරන්න',
        'resendCode': 'නැවත එවන්න',
        'resendIn': 'නැවත එවන්නේ',
        'seconds': 'තත්පර',
        'otpRequired': 'කරුණාකර සම්පූර්ණ OTP ඇතුළු කරන්න',
        'otpResent': 'OTP සාර්ථකව එවා ඇත',
        'backToLogin': 'පුරනය වීමට',
      },
      'ta': {
        'title': 'தொலைபேசி எண்ணை சரிபார்க்கவும்',
        'subtitle': 'அனுப்பப்பட்ட 6 இலக்க குறியீட்டை உள்ளிடவும்',
        'otpHint': 'OTP ஐ உள்ளிடவும்',
        'verifyButton': 'சரிபார்க்கவும்',
        'resendCode': 'மீண்டும் அனுப்பவும்',
        'resendIn': 'மீண்டும் அனுப்ப',
        'seconds': 'வினாடிகள்',
        'otpRequired': 'முழு OTP ஐ உள்ளிடவும்',
        'otpResent': 'OTP வெற்றிகரமாக அனுப்பப்பட்டது',
        'backToLogin': 'உள்நுழைவுக்கு திரும்பவும்',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).viewInsets.bottom - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 32,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
              
              // Header
              Text(
                texts['title']!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle with phone number
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6C757D),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  children: [
                    TextSpan(text: '${texts['subtitle']} '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Responsive OTP Input Fields with underlines
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6C757D), width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6C757D), width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF007BFF), width: 3),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) => _onOTPDigitChanged(value, index),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Timer text in '00:45 Resend' format
              Center(
                child: Text(
                  _resendCountdown > 0
                      ? '${_resendCountdown.toString().padLeft(2, '0')}:00 Resend'
                      : 'Resend',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // 48dp Primary Verify Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            texts['verifyButton']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resend Code Button (only when timer expires)
              if (_resendCountdown <= 0)
                Center(
                  child: TextButton(
                    onPressed: _isResending ? null : _resendOTP,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF007BFF),
                            ),
                          )
                        : Text(
                            texts['resendCode']!,
                            style: TextStyle(
                              color: const Color(0xFF007BFF),
                              fontWeight: FontWeight.w600,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
              
              const Spacer(),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text(
                    texts['backToLogin']!,
                    style: TextStyle(
                      color: const Color(0xFF6C757D),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}