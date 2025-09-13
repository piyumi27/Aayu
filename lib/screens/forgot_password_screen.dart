import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendResetOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await FirebaseAuthService.sendOTP(
        phoneNumber: _phoneController.text,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() {
              _successMessage = _getLocalizedText()['otpSent']!;
            });
            
            // Navigate to OTP verification with password reset flag
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.push('/otp-verification', extra: {
                  'phoneNumber': _phoneController.text,
                  'verificationId': verificationId,
                  'isPasswordReset': true,
                },);
              }
            });
          }
        },
        onError: (error) {
          setState(() {
            _errorMessage = error;
          });
        },
        onAutoVerification: (credential) async {
          // For password reset, we don't want auto-verification
          // Always go through manual OTP entry for security
          if (mounted) {
            context.push('/otp-verification', extra: {
              'phoneNumber': _phoneController.text,
              'verificationId': credential.verificationId,
              'isPasswordReset': true,
            },);
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Forgot Password',
        'subtitle': 'Enter your phone number to reset your password',
        'instructions': 'We will send you a verification code to reset your password securely.',
        'phoneLabel': 'Phone Number',
        'phoneHint': 'Enter your phone number',
        'sendOtpButton': 'Send OTP',
        'backToLogin': 'Back to Login',
        'phoneRequired': 'Phone number is required',
        'phoneInvalid': 'Enter a valid phone number',
        'otpSent': 'OTP sent successfully! Redirecting to verification...',
      },
      'si': {
        'title': 'මුරපදය අමතකද',
        'subtitle': 'ඔබේ මුරපදය නැවත සැකසීමට දුරකථන අංකය ඇතුළු කරන්න',
        'instructions': 'ඔබේ මුරපදය ආරක්ෂිතව නැවත සැකසීම සඳහා අපි ඔබට සත්‍යාපන කේතයක් එවන්නෙමු.',
        'phoneLabel': 'දුරකථන අංකය',
        'phoneHint': 'ඔබේ දුරකථන අංකය ඇතුළු කරන්න',
        'sendOtpButton': 'OTP එවන්න',
        'backToLogin': 'පුරනය වීමට',
        'phoneRequired': 'දුරකථන අංකය අවශ්‍යය',
        'phoneInvalid': 'වලංගු දුරකථන අංකයක් ඇතුළු කරන්න',
        'otpSent': 'OTP සාර්ථකව එවා ඇත! සත්‍යාපනයට යොමු කරමින්...',
      },
      'ta': {
        'title': 'கடவுச்சொல் மறந்துவிட்டதா',
        'subtitle': 'உங்கள் கடவுச்சொல்லை மீட்டமைக்க தொலைபேசி எண்ணை உள்ளிடவும்',
        'instructions': 'உங்கள் கடவுச்சொல்லை பாதுகாப்பாக மீட்டமைக்க நாங்கள் உங்களுக்கு ஒரு சரிபார்ப்பு குறியீட்டை அனுப்புவோம்.',
        'phoneLabel': 'தொலைபேசி எண்',
        'phoneHint': 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்',
        'sendOtpButton': 'OTP அனுப்பவும்',
        'backToLogin': 'உள்நுழைவுக்கு திரும்பவும்',
        'phoneRequired': 'தொலைபேசி எண் தேவை',
        'phoneInvalid': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்',
        'otpSent': 'OTP வெற்றிகரமாக அனுப்பப்பட்டது! சரிபார்ப்புக்கு திருப்பி விடுகிறோம்...',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  String? _validatePhone(String? value) {
    final texts = _getLocalizedText();
    if (value == null || value.isEmpty) {
      return texts['phoneRequired'];
    }
    if (value.length < 10) {
      return texts['phoneInvalid'];
    }
    return null;
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
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
                
                // Subtitle
                Text(
                  texts['subtitle']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6C757D),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1E90FF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          texts['instructions']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF6C757D),
                            height: 1.4,
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Phone Number Field
                Text(
                  texts['phoneLabel']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: texts['phoneHint'],
                    hintStyle: TextStyle(
                      color: const Color(0xFF6C757D),
                      fontSize: 16,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E90FF),
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Success Message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32CD32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF32CD32).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF32CD32),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: const Color(0xFF32CD32),
                              fontSize: 14,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Send OTP Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
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
                            texts['sendOtpButton']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: Text(
                      texts['backToLogin']!,
                      style: TextStyle(
                        color: const Color(0xFF1E90FF),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Additional Security Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.security,
                        color: Color(0xFF6C757D),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your account security is important to us. We will send you a secure verification code to verify your identity.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6C757D),
                          height: 1.4,
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}