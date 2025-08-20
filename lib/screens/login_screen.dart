import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedLanguage = 'en';

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuthService.sendOTP(
        phoneNumber: _phoneController.text,
        onCodeSent: (verificationId) {
          if (mounted) {
            context.push('/otp-verification', extra: {
              'phoneNumber': _phoneController.text,
              'verificationId': verificationId,
              'isLogin': true,
            });
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onAutoVerification: (credential) async {
          // Handle auto-verification if possible
          try {
            final userCredential = await FirebaseAuthService.verifyOTP(
              otp: credential.smsCode ?? '',
            );

            if (userCredential != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('user_logged_in', true);
              await prefs.setString('user_phone', _phoneController.text);

              if (mounted) {
                context.go('/');
              }
            }
          } catch (e) {
            // If auto-verification fails, proceed with manual OTP entry
            if (mounted) {
              context.push('/otp-verification', extra: {
                'phoneNumber': _phoneController.text,
                'verificationId': credential.verificationId,
                'isLogin': true,
              });
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Welcome Back',
        'subtitle': 'Sign in to continue',
        'phoneLabel': 'Phone Number',
        'phoneHint': 'Enter your phone number',
        'passwordLabel': 'Password',
        'passwordHint': 'Enter your password',
        'loginButton': 'Login',
        'forgotPassword': 'Forgot Password?',
        'createAccount': 'Create New Account',
        'privacyNote': 'By logging in, you agree to our Terms & Privacy Policy',
        'phoneRequired': 'Phone number is required',
        'phoneInvalid': 'Enter a valid phone number',
        'passwordRequired': 'Password is required',
        'passwordShort': 'Password must be at least 6 characters',
      },
      'si': {
        'title': 'නැවත පිළිගනිමු',
        'subtitle': 'දිගටම කරගෙන යාමට පුරනය වන්න',
        'phoneLabel': 'දුරකථන අංකය',
        'phoneHint': 'ඔබේ දුරකථන අංකය ඇතුළු කරන්න',
        'passwordLabel': 'මුරපදය',
        'passwordHint': 'ඔබේ මුරපදය ඇතුළු කරන්න',
        'loginButton': 'පුරනය වන්න',
        'forgotPassword': 'මුරපදය අමතකද?',
        'createAccount': 'නව ගිණුමක් සාදන්න',
        'privacyNote': 'පුරනය වීමෙන්, ඔබ අපගේ කොන්දේසි සහ රහස්‍යතා ප්‍රතිපත්තියට එකඟ වේ',
        'phoneRequired': 'දුරකථන අංකය අවශ්‍යය',
        'phoneInvalid': 'වලංගු දුරකථන අංකයක් ඇතුළු කරන්න',
        'passwordRequired': 'මුරපදය අවශ්‍යය',
        'passwordShort': 'මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය',
      },
      'ta': {
        'title': 'மீண்டும் வரவேற்கிறோம்',
        'subtitle': 'தொடர உள்நுழையவும்',
        'phoneLabel': 'தொலைபேசி எண்',
        'phoneHint': 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்',
        'passwordLabel': 'கடவுச்சொல்',
        'passwordHint': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
        'loginButton': 'உள்நுழையவும்',
        'forgotPassword': 'கடவுச்சொல் மறந்துவிட்டதா?',
        'createAccount': 'புதிய கணக்கை உருவாக்கவும்',
        'privacyNote': 'உள்நுழைவதன் மூலம், எங்கள் விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்',
        'phoneRequired': 'தொலைபேசி எண் தேவை',
        'phoneInvalid': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்',
        'passwordRequired': 'கடவுச்சொல் தேவை',
        'passwordShort': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகளாக இருக்க வேண்டும்',
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

  String? _validatePassword(String? value) {
    final texts = _getLocalizedText();
    if (value == null || value.isEmpty) {
      return texts['passwordRequired'];
    }
    if (value.length < 6) {
      return texts['passwordShort'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          texts['title']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Header
                Text(
                  texts['title']!,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  texts['subtitle']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6C757D),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
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
                  decoration: InputDecoration(
                    hintText: texts['phoneHint'],
                    hintStyle: TextStyle(
                      color: const Color(0xFF6C757D),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF6C757D)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Password Field
                Text(
                  texts['passwordLabel']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: texts['passwordHint'],
                    hintStyle: TextStyle(
                      color: const Color(0xFF6C757D),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C757D)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF6C757D),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: Text(
                      texts['forgotPassword']!,
                      style: TextStyle(
                        color: const Color(0xFF007BFF),
                        fontWeight: FontWeight.w500,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
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
                            texts['loginButton']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Create Account Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/register');
                    },
                    child: Text(
                      texts['createAccount']!,
                      style: TextStyle(
                        color: const Color(0xFF007BFF),
                        fontWeight: FontWeight.w500,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Privacy Note
                Text(
                  texts['privacyNote']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF6C757D),
                    height: 1.4,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}