import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_auth_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/sri_lanka_phone_field.dart';
import '../widgets/password_strength_field.dart';
import '../widgets/gmail_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _phoneNumber = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_password != _confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.registerUser(
        fullName: _fullName,
        phoneNumber: _phoneNumber,
        password: _password,
        email: _email.isNotEmpty ? _email : null,
      );
      
      if (result.success && mounted) {
        // Registration successful - navigate to verification center
        context.go('/verification-center');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed: ${e.toString()}';
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
        'title': 'Create Account',
        'subtitle': 'Join Aayu to track your child\'s nutrition and growth',
        'fullNameLabel': 'Full Name',
        'fullNameHint': 'Enter your full name',
        'emailLabel': 'Email (Optional)',
        'phoneLabel': 'Phone Number',
        'passwordLabel': 'Password',
        'confirmPasswordLabel': 'Confirm Password',
        'registerButton': 'Create Account',
        'haveAccount': 'Already have an account?',
        'signIn': 'Sign In',
        'loading': 'Creating account...',
        'privacyText': 'By creating an account, you agree to our Terms of Service and Privacy Policy',
      },
      'si': {
        'title': 'ගිණුමක් සාදන්න',
        'subtitle': 'ඔබේ දරුවාගේ පෝෂණය සහ වර්ධනය නිරීක්ෂණ කිරීමට ආයු වෙත සම්බන්ධ වන්න',
        'fullNameLabel': 'සම්පූර්ණ නම',
        'fullNameHint': 'ඔබේ සම්පූර්ණ නම ඇතුළත් කරන්න',
        'emailLabel': 'විද්‍යුත් තැපෑල (විකල්පයකි)',
        'phoneLabel': 'දුරකථන අංකය',
        'passwordLabel': 'මුරපදය',
        'confirmPasswordLabel': 'මුරපදය තහවුරු කරන්න',
        'registerButton': 'ගිණුමක් සාදන්න',
        'haveAccount': 'දැනටමත් ගිණුමක් තිබේද?',
        'signIn': 'ප්‍රවේශ වන්න',
        'loading': 'ගිණුම සාදමින්...',
        'privacyText': 'ගිණුමක් සෑදීමෙන්, ඔබ අපගේ සේවා නියමයන්ට සහ රහස්‍යතා ප්‍රතිපත්තියට එකඟ වේ',
      },
      'ta': {
        'title': 'கணக்கை உருவாக்கு',
        'subtitle': 'உங்கள் குழந்தையின் ஊட்டச்சத்து மற்றும் வளர்ச்சியைக் கண்காணிக்க ஆயுவில் சேரவும்',
        'fullNameLabel': 'முழு பெயர்',
        'fullNameHint': 'உங்கள் முழு பெயரை உள்ளிடுங்கள்',
        'emailLabel': 'மின்னஞ்சல் (விரும்பினால்)',
        'phoneLabel': 'தொலைபேசி எண்',
        'passwordLabel': 'கடவுச்சொல்',
        'confirmPasswordLabel': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
        'registerButton': 'கணக்கை உருவாக்கு',
        'haveAccount': 'ஏற்கனவே கணக்கு உள்ளதா?',
        'signIn': 'உள்நுழையுங்கள்',
        'loading': 'கணக்கை உருவாக்குகிறது...',
        'privacyText': 'கணக்கை உருவாக்குவதன் மூலம், எங்கள் சேவை நிபந்தனைகள் மற்றும் தனியுரிமைக் கொள்கையை ஒப்புக்கொள்கிறீர்கள்',
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
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A1A),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
                
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
                        Icons.person_add,
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
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
                
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
                
                // Full name field
                TextFormField(
                  onChanged: (value) => setState(() => _fullName = value.trim()),
                  enabled: !_isLoading,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  decoration: InputDecoration(
                    labelText: texts['fullNameLabel']!,
                    hintText: texts['fullNameHint']!,
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: ResponsiveUtils.getResponsivePadding(context),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Email field (optional)
                GmailField(
                  onChanged: (email) => setState(() => _email = email),
                  enabled: !_isLoading,
                  helperText: 'Optional - for account recovery',
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Phone number field
                SriLankaPhoneField(
                  onChanged: (phone) => setState(() => _phoneNumber = phone),
                  enabled: !_isLoading,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Password field
                PasswordStrengthField(
                  onChanged: (password) => setState(() => _password = password),
                  enabled: !_isLoading,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Confirm password field
                PasswordStrengthField(
                  isConfirmField: true,
                  passwordToMatch: _password,
                  onChanged: (password) => setState(() => _confirmPassword = password),
                  enabled: !_isLoading,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // Register button
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 48),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            texts['registerButton']!,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Privacy policy text
                Text(
                  texts['privacyText']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF9CA3AF),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      texts['haveAccount']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        texts['signIn']!,
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