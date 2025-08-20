import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isLoading = false;

  Future<void> _saveLanguageAndProceed() async {
    if (_selectedLanguage == null) return;

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', _selectedLanguage!);
    await prefs.setBool('language_selected', true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E90FF).withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.child_care,
                        size: 90,
                        color: Color(0xFF1E90FF),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Select Language / භාෂාව තෝරන්න',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  children: [
                    _buildLanguageCard(
                      context,
                      title: 'සිංහල',
                      subtitle: 'Sinhala',
                      languageCode: 'si',
                      isSelected: _selectedLanguage == 'si',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageCard(
                      context,
                      title: 'English',
                      subtitle: 'ඉංග්‍රීසි',
                      languageCode: 'en',
                      isSelected: _selectedLanguage == 'en',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageCard(
                      context,
                      title: 'தமிழ்',
                      subtitle: 'Tamil',
                      languageCode: 'ta',
                      isSelected: _selectedLanguage == 'ta',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedLanguage != null && !_isLoading
                      ? _saveLanguageAndProceed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _getButtonText(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E90FF).withOpacity(0.08) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E90FF),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF1E90FF) : Colors.black87,
                      fontFamily: languageCode == 'si'
                          ? 'NotoSerifSinhala'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF1E90FF).withOpacity(0.8) : Colors.black54,
                      fontFamily: subtitle.contains('සිංහල')
                          ? 'NotoSerifSinhala'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1E90FF),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_selectedLanguage) {
      case 'si':
        return 'ඉදිරියට';
      case 'ta':
        return 'தொடர';
      case 'en':
      default:
        return 'Continue';
    }
  }
}