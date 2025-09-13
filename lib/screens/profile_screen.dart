import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../services/local_auth_service.dart';
import '../utils/responsive_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalAuthService _authService = LocalAuthService();

  String _selectedLanguage = 'en';
  UserAccount? _currentUser;
  bool _isLoading = true;

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
      _isLoading = false;
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Profile',
        'personalInfo': 'Personal Information',
        'fullName': 'Full Name',
        'email': 'Email Address',
        'phoneNumber': 'Phone Number',
        'accountInfo': 'Account Information',
        'memberSince': 'Member Since',
        'accountStatus': 'Account Status',
        'verified': 'Verified',
        'unverified': 'Unverified',
        'verifyNow': 'Verify Now',
        'editProfile': 'Edit Profile',
        'settings': 'Settings',
        'notProvided': 'Not provided',
        'loading': 'Loading...',
      },
      'si': {
        'title': 'පැතිකඩ',
        'personalInfo': 'පුද්ගලික තොරතුරු',
        'fullName': 'සම්පූර්ණ නම',
        'email': 'විද්‍යුත් තැපැල් ලිපිනය',
        'phoneNumber': 'දුරකථන අංකය',
        'accountInfo': 'ගිණුම් තොරතුරු',
        'memberSince': 'සාමාජිකයා වූ දිනය',
        'accountStatus': 'ගිණුම් තත්ත්වය',
        'verified': 'සත්‍යාපිත',
        'unverified': 'සත්‍යාපනය නොකළ',
        'verifyNow': 'දැන් සත්‍යාපනය කරන්න',
        'editProfile': 'පැතිකඩ සංස්කරණය',
        'settings': 'සැකසීම්',
        'notProvided': 'ලබා දී නැත',
        'loading': 'පූරණය වෙමින්...',
      },
      'ta': {
        'title': 'சுயவிவரம்',
        'personalInfo': 'தனிப்பட்ட தகவல்',
        'fullName': 'முழு பெயர்',
        'email': 'மின்னஞ்சல் முகவரி',
        'phoneNumber': 'தொலைபேசி எண்',
        'accountInfo': 'கணக்கு தகவல்',
        'memberSince': 'உறுப்பினரான நாள்',
        'accountStatus': 'கணக்கு நிலை',
        'verified': 'சரிபார்க்கப்பட்டது',
        'unverified': 'சரிபார்க்கப்படவில்லை',
        'verifyNow': 'இப்போது சரிபார்க்கவும்',
        'editProfile': 'சுயவிவரத்தைத் திருத்து',
        'settings': 'அமைப்புகள்',
        'notProvided': 'வழங்கப்படவில்லை',
        'loading': 'ஏற்றுகிறது...',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  ImageProvider? _getUserProfileImage() {
    if (_currentUser?.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty) {
      final file = File(_currentUser!.photoUrl!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();

    if (_isLoading) {
      return Scaffold(
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(texts['title']!),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text('No user data found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          texts['title']!,
          style: TextStyle(
            color: Colors.black87,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF1A1A1A),
            ),
            onPressed: () => context.push('/settings'),
            tooltip: texts['settings']!,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

            // Profile Header
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, 80),
                    height: ResponsiveUtils.getResponsiveIconSize(context, 80),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _getUserProfileImage() == null
                          ? LinearGradient(
                              colors: [
                                const Color(0xFF0086FF),
                                const Color(0xFF0086FF).withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                    ),
                    child: _getUserProfileImage() != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveIconSize(
                                    context, 40)),
                            child: Image(
                              image: _getUserProfileImage()!,
                              width: ResponsiveUtils.getResponsiveIconSize(
                                  context, 80),
                              height: ResponsiveUtils.getResponsiveIconSize(
                                  context, 80),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Colors.white,
                            size: ResponsiveUtils.getResponsiveIconSize(
                                context, 40),
                          ),
                  ),

                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 16)),

                  // User Name
                  Text(
                    _currentUser!.fullName,
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

                  // Verification Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtils.getResponsiveSpacing(context, 12),
                      vertical:
                          ResponsiveUtils.getResponsiveSpacing(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: _currentUser!.isSyncGateOpen
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentUser!.isSyncGateOpen
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentUser!.isSyncGateOpen
                              ? Icons.verified
                              : Icons.warning_outlined,
                          size: ResponsiveUtils.getResponsiveIconSize(
                              context, 16),
                          color: _currentUser!.isSyncGateOpen
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                                context, 4)),
                        Text(
                          _currentUser!.isSyncGateOpen
                              ? texts['verified']!
                              : texts['unverified']!,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 12),
                            fontWeight: FontWeight.w600,
                            color: _currentUser!.isSyncGateOpen
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_currentUser!.isSyncGateOpen) ...[
                    SizedBox(
                        height:
                            ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/verification-center'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0086FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          texts['verifyNow']!,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 14),
                            fontWeight: FontWeight.w600,
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

            // Personal Information Section
            _buildInfoSection(
              title: texts['personalInfo']!,
              items: [
                _InfoItem(
                  label: texts['fullName']!,
                  value: _currentUser!.fullName,
                  icon: Icons.person_outline,
                ),
                _InfoItem(
                  label: texts['email']!,
                  value: _currentUser!.email?.isNotEmpty == true
                      ? _currentUser!.email!
                      : texts['notProvided']!,
                  icon: Icons.email_outlined,
                ),
                _InfoItem(
                  label: texts['phoneNumber']!,
                  value: _currentUser!.phoneNumber,
                  icon: Icons.phone_outlined,
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

            // Account Information Section
            _buildInfoSection(
              title: texts['accountInfo']!,
              items: [
                _InfoItem(
                  label: texts['memberSince']!,
                  value: _formatJoinDate(_currentUser!.createdAt),
                  icon: Icons.calendar_today_outlined,
                ),
                _InfoItem(
                  label: texts['accountStatus']!,
                  value: _currentUser!.isSyncGateOpen
                      ? texts['verified']!
                      : texts['unverified']!,
                  icon: _currentUser!.isSyncGateOpen
                      ? Icons.verified
                      : Icons.warning_outlined,
                ),
              ],
            ),

            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          ...items
              .map((item) => Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: ResponsiveUtils.getResponsiveIconSize(
                              context, 40),
                          height: ResponsiveUtils.getResponsiveIconSize(
                              context, 40),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0086FF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            item.icon,
                            size: ResponsiveUtils.getResponsiveIconSize(
                                context, 20),
                            color: const Color(0xFF0086FF),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                                context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 12),
                                  color: const Color(0xFF6B7280),
                                  fontFamily: _selectedLanguage == 'si'
                                      ? 'NotoSerifSinhala'
                                      : null,
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveUtils.getResponsiveSpacing(
                                      context, 2)),
                              Text(
                                item.value,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 16),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A1A),
                                  fontFamily: _selectedLanguage == 'si'
                                      ? 'NotoSerifSinhala'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
