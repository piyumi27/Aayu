import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';
import '../widgets/safe_ink_well.dart';

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
    await prefs.setString('language', _selectedLanguage!);
    await prefs.setBool('language_selected', true);

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                        context, isSmallScreen ? 20 : 40)),

                // App logo/icon
                Container(
                  width: ResponsiveUtils.getResponsiveIconSize(
                      context, isSmallScreen ? 100 : 150),
                  height: ResponsiveUtils.getResponsiveIconSize(
                      context, isSmallScreen ? 100 : 150),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Center(
                      child: Text(
                        'ආයු',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, isSmallScreen ? 48 : 60),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0086FF),
                          fontFamily: 'NotoSerifSinhala',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                        context, isSmallScreen ? 30 : 60)),

                Text(
                  'Select Language / භාෂාව තෝරන්න',
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                        context, isSmallScreen ? 20 : 30)),

                // Language cards
                _buildLanguageCard(
                  context,
                  title: 'සිංහල',
                  subtitle: 'Sinhala',
                  languageCode: 'si',
                  isSelected: _selectedLanguage == 'si',
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

                _buildLanguageCard(
                  context,
                  title: 'English',
                  subtitle: 'ඉංග්‍රීසි',
                  languageCode: 'en',
                  isSelected: _selectedLanguage == 'en',
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

                _buildLanguageCard(
                  context,
                  title: 'தமிழ்',
                  subtitle: 'Tamil',
                  languageCode: 'ta',
                  isSelected: _selectedLanguage == 'ta',
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                        context, isSmallScreen ? 20 : 40)),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.getResponsiveSpacing(context, 56),
                  child: ElevatedButton(
                    onPressed: _selectedLanguage != null && !_isLoading
                        ? _saveLanguageAndProceed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0086FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: ResponsiveUtils.getResponsiveIconSize(
                                context, 24),
                            height: ResponsiveUtils.getResponsiveIconSize(
                                context, 24),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _getButtonText(),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
              ],
            ),
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
    return SafeInkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context, scale: 1.25),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0086FF).withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0086FF) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 24),
              height: ResponsiveUtils.getResponsiveIconSize(context, 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF0086FF) : Colors.grey[400]!,
                  width: 2,
                ),
                color:
                    isSelected ? const Color(0xFF0086FF) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? const Color(0xFF0086FF) : Colors.black87,
                      fontFamily: _getFontFamily(languageCode),
                    ),
                  ),
                  SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 14),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: ResponsiveUtils.getResponsiveIconSize(context, 28),
                color: const Color(0xFF0086FF),
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
      case 'en':
        return 'Continue';
      case 'ta':
        return 'தொடர்க';
      default:
        return 'Continue';
    }
  }

  String? _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'si':
        return 'NotoSerifSinhala';
      case 'ta':
        return 'NotoSerifSinhala';
      default:
        return null;
    }
  }
}
