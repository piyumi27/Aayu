import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  
  // Password strength variables
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _passwordController.addListener(_checkPasswordStrength);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    final texts = _getLocalizedText();
    
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    double strength = 0.0;
    String strengthText = texts['weak']!;
    Color strengthColor = Colors.red;

    // Check password criteria
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    if (strength >= 0.75) {
      strengthText = texts['strong']!;
      strengthColor = const Color(0xFF28A745);
    } else if (strength >= 0.5) {
      strengthText = texts['medium']!;
      strengthColor = Colors.orange;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate registration process
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, accept registration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_in', true);
    await prefs.setString('user_phone', _phoneController.text);
    await prefs.setString('user_name', _fullNameController.text);

    if (mounted) {
      context.go('/');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Create Account',
        'subtitle': 'Sign up to get started',
        'fullNameLabel': 'Full Name',
        'fullNameHint': 'Enter your full name',
        'phoneLabel': 'Phone Number',
        'phoneHint': 'Enter your phone number',
        'passwordLabel': 'Password',
        'passwordHint': 'Enter your password',
        'confirmPasswordLabel': 'Confirm Password',
        'confirmPasswordHint': 'Confirm your password',
        'rememberMe': 'Remember me',
        'registerButton': 'Register',
        'alreadyHaveAccount': 'Already have an account? Login',
        'privacyNote': 'By registering you agree to our Terms & Privacy Policy',
        'fullNameRequired': 'Full name is required',
        'phoneRequired': 'Phone number is required',
        'phoneInvalid': 'Enter a valid phone number',
        'passwordRequired': 'Password is required',
        'passwordShort': 'Password must be at least 6 characters',
        'passwordMismatch': 'Passwords do not match',
        'weak': 'Weak',
        'medium': 'Medium',
        'strong': 'Strong',
      },
      'si': {
        'title': 'ගිණුමක් සාදන්න',
        'subtitle': 'ආරම්භ කිරීමට ලියාපදිංචි වන්න',
        'fullNameLabel': 'සම්පූර්ණ නම',
        'fullNameHint': 'ඔබේ සම්පූර්ණ නම ඇතුළු කරන්න',
        'phoneLabel': 'දුරකථන අංකය',
        'phoneHint': 'ඔබේ දුරකථන අංකය ඇතුළු කරන්න',
        'passwordLabel': 'මුරපදය',
        'passwordHint': 'ඔබේ මුරපදය ඇතුළු කරන්න',
        'confirmPasswordLabel': 'මුරපදය තහවුරු කරන්න',
        'confirmPasswordHint': 'ඔබේ මුරපදය තහවුරු කරන්න',
        'rememberMe': 'මතක තබා ගන්න',
        'registerButton': 'ලියාපදිංචි වන්න',
        'alreadyHaveAccount': 'දැනටමත් ගිණුමක් තිබේද? පුරනය වන්න',
        'privacyNote': 'ලියාපදිංචි වීමෙන් ඔබ අපගේ කොන්දේසි සහ රහස්‍යතා ප්‍රතිපත්තියට එකඟ වේ',
        'fullNameRequired': 'සම්පූර්ණ නම අවශ්‍යය',
        'phoneRequired': 'දුරකථන අංකය අවශ්‍යය',
        'phoneInvalid': 'වලංගු දුරකථන අංකයක් ඇතුළු කරන්න',
        'passwordRequired': 'මුරපදය අවශ්‍යය',
        'passwordShort': 'මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය',
        'passwordMismatch': 'මුරපද නොගැලපේ',
        'weak': 'දුර්වල',
        'medium': 'මධ්‍යම',
        'strong': 'ශක්තිමත්',
      },
      'ta': {
        'title': 'கணக்கை உருவாக்கவும்',
        'subtitle': 'தொடங்க பதிவு செய்யவும்',
        'fullNameLabel': 'முழு பெயர்',
        'fullNameHint': 'உங்கள் முழு பெயரை உள்ளிடவும்',
        'phoneLabel': 'தொலைபேசி எண்',
        'phoneHint': 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்',
        'passwordLabel': 'கடவுச்சொல்',
        'passwordHint': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
        'confirmPasswordLabel': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
        'confirmPasswordHint': 'உங்கள் கடவுச்சொல்லை உறுதிப்படுத்தவும்',
        'rememberMe': 'என்னை நினைவில் கொள்ளுங்கள்',
        'registerButton': 'பதிவு செய்யவும்',
        'alreadyHaveAccount': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையவும்',
        'privacyNote': 'பதிவு செய்வதன் மூலம் எங்கள் விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஒப்புக்கொள்கிறீர்கள்',
        'fullNameRequired': 'முழு பெயர் தேவை',
        'phoneRequired': 'தொலைபேசி எண் தேவை',
        'phoneInvalid': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்',
        'passwordRequired': 'கடவுச்சொல் தேவை',
        'passwordShort': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகளாக இருக்க வேண்டும்',
        'passwordMismatch': 'கடவுச்சொற்கள் பொருந்தவில்லை',
        'weak': 'பலவீனமான',
        'medium': 'நடுத்தர',
        'strong': 'வலுவான',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  String? _validateFullName(String? value) {
    final texts = _getLocalizedText();
    if (value == null || value.trim().isEmpty) {
      return texts['fullNameRequired'];
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    final texts = _getLocalizedText();
    if (value != _passwordController.text) {
      return texts['passwordMismatch'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
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
                const SizedBox(height: 32),
                
                // Full Name Field
                Text(
                  texts['fullNameLabel']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  validator: _validateFullName,
                  decoration: InputDecoration(
                    hintText: texts['fullNameHint'],
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
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF6C757D)),
                  ),
                ),
                const SizedBox(height: 16),
                
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
                const SizedBox(height: 16),
                
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
                
                // Password Strength Meter
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _passwordStrengthText,
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                
                // Confirm Password Field
                Text(
                  texts['confirmPasswordLabel']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    hintText: texts['confirmPasswordHint'],
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
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF6C757D),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF007BFF),
                    ),
                    Expanded(
                      child: Text(
                        texts['rememberMe']!,
                        style: TextStyle(
                          color: const Color(0xFF6C757D),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Register Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            texts['registerButton']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
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
                const SizedBox(height: 24),
                
                // Already Have Account Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: Text(
                      texts['alreadyHaveAccount']!,
                      style: TextStyle(
                        color: const Color(0xFF007BFF),
                        fontWeight: FontWeight.w500,
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
    );
  }
}