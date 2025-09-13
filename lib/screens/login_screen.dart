import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_auth_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/sri_lanka_phone_field.dart';
import '../widgets/password_strength_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  String _password = '';
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  String? _errorMessage;
  
  final LocalAuthService _authService = LocalAuthService();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.loginUser(
        phoneNumber: _phoneNumber,
        password: _password,
      );
      
      if (result.success && mounted) {
        // Login successful - navigate to verification center if not verified
        final user = result.user!;
        if (user.isSyncGateOpen) {
          // User is verified, go to main app
          context.go('/');
        } else {
          // User needs verification, go to verification center
          context.go('/verification-center');
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Welcome Back',
        'subtitle': 'Sign in to continue tracking your child\'s growth',
        'phoneLabel': 'Phone Number',
        'passwordLabel': 'Password',
        'loginButton': 'Sign In',
        'noAccount': 'Don\'t have an account?',
        'signUp': 'Create Account',
        'forgotPassword': 'Forgot Password?',
        'loading': 'Signing in...',
      },
      'si': {
        'title': 'නැවත සාදරයෙන් පිළිගන්නවා',
        'subtitle': 'ඔබේ දරුවාගේ වර්ධනය නිරීක්ෂණ කිරීම දිගටම කරගෙන යාමට ප්‍රවේශ වන්න',
        'phoneLabel': 'දුරකථන අංකය',
        'passwordLabel': 'මුරපදය',
        'loginButton': 'ප්‍රවේශ වන්න',
        'noAccount': 'ගිණුමක් නැද්ද?',
        'signUp': 'ගිණුමක් සාදන්න',
        'forgotPassword': 'මුරපදය අමතක ද?',
        'loading': 'ප්‍රවේශ වෙමින්...',
      },
      'ta': {
        'title': 'மீண்டும் வரவேற்கிறோம்',
        'subtitle': 'உங்கள் குழந்தையின் வளர்ச்சியைத் தொடர்ந்து கண்காணிக்க உள்நுழையுங்கள்',
        'phoneLabel': 'தொலைபேசி எண்',
        'passwordLabel': 'கடவுச்சொல்',
        'loginButton': 'உள்நுழையுங்கள்',
        'noAccount': 'கணக்கு இல்லையா?',
        'signUp': 'கணக்கை உருவாக்கு',
        'forgotPassword': 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?',
        'loading': 'உள்நுழைகிறது...',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                
                // Header with icon
                Column(
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveIconSize(context, 80),
                      height: ResponsiveUtils.getResponsiveIconSize(context, 80),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0086FF),
                            const Color(0xFF0086FF).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 40),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                    Text(
                      texts['title']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    Text(
                      texts['subtitle']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                
                // Error message
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
                
                // Phone number field
                SriLankaPhoneField(
                  onChanged: (phone) {
                    setState(() {
                      _phoneNumber = phone;
                    });
                  },
                  enabled: !_isLoading,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Password field
                PasswordStrengthField(
                  onChanged: (password) {
                    setState(() {
                      _password = password;
                    });
                  },
                  enabled: !_isLoading,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.push('/forgot-password'),
                    child: Text(
                      texts['forgotPassword']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF0086FF),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // Login button
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 48),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? const Color(0xFFE5E7EB) : const Color(0xFF0086FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                height: ResponsiveUtils.getResponsiveIconSize(context, 20),
                                child: const CircularProgressIndicator(
                                  color: Color(0xFF6B7280),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                              Text(
                                texts['loading']!,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            texts['loginButton']!,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      texts['noAccount']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.push('/register'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        texts['signUp']!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          color: const Color(0xFF0086FF),
                          fontWeight: FontWeight.w600,
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}