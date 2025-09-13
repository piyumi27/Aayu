import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../services/local_auth_service.dart' as auth;
import '../utils/responsive_utils.dart';
import '../widgets/safe_ink_well.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  String _syncStatus = 'up-to-date'; // 'up-to-date', 'pending', 'error'
  UserAccount? _currentUser;
  VerificationStatus _verificationStatus = VerificationStatus.notLoggedIn;
  
  final auth.LocalAuthService _authService = auth.LocalAuthService();
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _syncStatus = prefs.getString('sync_status') ?? 'up-to-date';
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    final verificationStatus = await _authService.getVerificationStatus();
    
    if (mounted) {
      setState(() {
        _currentUser = user;
        _verificationStatus = verificationStatus;
        
        // Update sync status based on verification
        if (verificationStatus == VerificationStatus.pendingSync) {
          _syncStatus = 'pending';
        } else if (verificationStatus == VerificationStatus.verified) {
          _syncStatus = 'up-to-date';
        }
      });
    }
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    if (mounted) {
      setState(() {
        _selectedLanguage = language;
      });
    }
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'settings': 'Settings',
        'account': 'ACCOUNT',
        'editProfile': 'Edit Profile',
        'changePassword': 'Change Password',
        'preferences': 'PREFERENCES',
        'language': 'Language',
        'notifications': 'Notifications',
        'units': 'Units',
        'dataSyncStatus': 'Data Sync Status',
        'support': 'SUPPORT',
        'helpSupport': 'Help & Support',
        'about': 'About ආයු',
        'session': 'SESSION',
        'logout': 'Logout',
        'english': 'English',
        'sinhala': 'සිංහල',
        'tamil': 'தமிழ்',
        'selectLanguage': 'Select Language',
        'metric': 'Metric',
        'imperial': 'Imperial',
        'upToDate': 'Up-to-date',
        'pending': 'Pending',
        'syncError': 'Sync Error',
        'confirmLogout': 'Confirm Logout',
        'logoutMessage': 'Are you sure you want to logout?',
        'cancel': 'Cancel',
        'logoutButton': 'Logout',
        'comingSoon': 'Coming Soon',
        'featureInDevelopment': 'This feature is currently in development.',
        'ok': 'OK',
        'verificationStatus': 'Verification Status',
        'accountVerification': 'Account Verification',
        'children': 'CHILDREN',
        'editChildProfiles': 'Edit Child Profiles',
      },
      'si': {
        'settings': 'සැකසීම්',
        'account': 'ගිණුම',
        'editProfile': 'පැතිකඩ සංස්කරණය',
        'changePassword': 'මුරපදය වෙනස් කරන්න',
        'preferences': 'මනාපයන්',
        'language': 'භාෂාව',
        'notifications': 'දැනුම්දීම්',
        'units': 'ඒකක',
        'dataSyncStatus': 'දත්ත සමමුහුර්ත කිරීමේ තත්ත්වය',
        'support': 'සහාය',
        'helpSupport': 'උදව් සහ සහාය',
        'about': 'ආයු ගැන',
        'session': 'සැසිය',
        'logout': 'ඉවත් වන්න',
        'english': 'English',
        'sinhala': 'සිංහල',
        'tamil': 'தமிழ்',
        'selectLanguage': 'භාෂාව තෝරන්න',
        'metric': 'මෙට්‍රික්',
        'imperial': 'ඉම්පීරියල්',
        'upToDate': 'යාවත්කාලීනයි',
        'pending': 'අපේක්‍ෂාවෙන්',
        'syncError': 'සමමුහුර්තකරණ දෝෂය',
        'confirmLogout': 'ඉවත්වීම සනාථ කරන්න',
        'logoutMessage': 'ඔබට ඇත්තටම ඉවත් වීමට අවශ්‍යද?',
        'cancel': 'අවලංගු කරන්න',
        'logoutButton': 'ඉවත් වන්න',
        'comingSoon': 'ඉක්මනින් එනවා',
        'featureInDevelopment': 'මෙම විශේෂාංගය දැනට සංවර්ධනය වෙමින් පවතී.',
        'ok': 'හරි',
        'verificationStatus': 'සත්‍යාපන තත්ත්වය',
        'accountVerification': 'ගිණුම් සත්‍යාපනය',
        'children': 'ළමයින්',
        'editChildProfiles': 'ළමා පැතිකඩ සංස්කරණය',
      },
      'ta': {
        'settings': 'அமைப்புகள்',
        'account': 'கணக்கு',
        'editProfile': 'சுயவிவரத்தைத் திருத்து',
        'changePassword': 'கடவுச்சொல்லை மாற்று',
        'preferences': 'விருப்பத்தேர்வுகள்',
        'language': 'மொழி',
        'notifications': 'அறிவிப்புகள்',
        'units': 'அலகுகள்',
        'dataSyncStatus': 'தரவு ஒத்திசைவு நிலை',
        'support': 'ஆதரவு',
        'helpSupport': 'உதவி மற்றும் ஆதரவு',
        'about': 'ආයු பற்றி',
        'session': 'அமர்வு',
        'logout': 'வெளியேறு',
        'english': 'English',
        'sinhala': 'සිංහල',
        'tamil': 'தமிழ்',
        'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
        'metric': 'மெட்ரிக்',
        'imperial': 'இம்பீரியல்',
        'upToDate': 'புதுப்பிக்கப்பட்டது',
        'pending': 'நிலுவையில்',
        'syncError': 'ஒத்திசைவு பிழை',
        'confirmLogout': 'வெளியேறுவதை உறுதிப்படுத்து',
        'logoutMessage': 'நீங்கள் உண்மையில் வெளியேற விரும்புகிறீர்களா?',
        'cancel': 'ரத்து செய்',
        'logoutButton': 'வெளியேறு',
        'comingSoon': 'விரைவில் வரும்',
        'featureInDevelopment': 'இந்த அம்சம் தற்போது வளர்ச்சியில் உள்ளது.',
        'ok': 'சரி',
        'verificationStatus': 'சரிபார்ப்பு நிலை',
        'accountVerification': 'கணக்கு சரிபார்ப்பு',
        'children': 'குழந்தைகள்',
        'editChildProfiles': 'குழந்தை சுயவிவரங்களைத் திருத்து',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          texts['settings']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Account Section
            _buildSectionHeader(texts['account']!),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.person_outline,
                title: texts['editProfile']!,
                onTap: () => context.push('/edit-parent-profile'),
                hasChevron: true,
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.verified_user_outlined,
                title: texts['verificationStatus']!,
                trailing: _buildVerificationBadge(),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.lock_outline,
                title: texts['changePassword']!,
                onTap: () => _showComingSoonDialog(context, texts),
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Children Section
            _buildSectionHeader(texts['children']!),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.child_care_outlined,
                title: texts['editChildProfiles']!,
                onTap: () => context.push('/edit-child-profile'),
                hasChevron: true,
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Preferences Section
            _buildSectionHeader(texts['preferences']!),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.language_outlined,
                title: texts['language']!,
                trailing: Text(
                  _getLanguageDisplayName(texts),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    color: const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                onTap: () => _showLanguagePicker(context, texts),
                hasChevron: true,
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.notifications_outlined,
                title: texts['notifications']!,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _saveNotificationPreference,
                  activeThumbColor: const Color(0xFF0086FF),
                ),
                hasChevron: true,
                onTap: () => context.push('/notification-preferences'),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.straighten_outlined,
                title: texts['units']!,
                trailing: Text(
                  texts['metric']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    color: const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                hasChevron: true,
                onTap: () => _showComingSoonDialog(context, texts),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.sync_outlined,
                title: texts['dataSyncStatus']!,
                trailing: _buildSyncBadge(texts),
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Support Section
            _buildSectionHeader(texts['support']!),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.help_outline,
                title: texts['helpSupport']!,
                onTap: () => context.push('/help-support'),
                hasChevron: true,
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.info_outline,
                title: texts['about']!,
                onTap: () => context.push('/about-aayu'),
                hasChevron: true,
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Session Section
            _buildSectionHeader(texts['session']!),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.logout,
                title: texts['logout']!,
                titleColor: const Color(0xFFEF4444),
                iconColor: const Color(0xFFEF4444),
                onTap: () => _showLogoutDialog(context, texts),
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // App Version Footer
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Text(
                      'ආයු',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0086FF),
                        fontFamily: 'NotoSerifSinhala',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge() {
    Color badgeColor = const Color(0xFF9CA3AF);
    String badgeText = 'Unknown';
    
    switch (_verificationStatus) {
      case VerificationStatus.verified:
        badgeColor = const Color(0xFF0086FF);
        badgeText = _selectedLanguage == 'si' 
            ? _verificationStatus.displayTextSinhala
            : _selectedLanguage == 'ta'
                ? _verificationStatus.displayTextTamil
                : _verificationStatus.displayText;
        break;
      case VerificationStatus.pendingSync:
        badgeColor = const Color(0xFFF59E0B);
        badgeText = _selectedLanguage == 'si' 
            ? _verificationStatus.displayTextSinhala
            : _selectedLanguage == 'ta'
                ? _verificationStatus.displayTextTamil
                : _verificationStatus.displayText;
        break;
      case VerificationStatus.unverified:
        badgeColor = const Color(0xFFEF4444);
        badgeText = _selectedLanguage == 'si' 
            ? _verificationStatus.displayTextSinhala
            : _selectedLanguage == 'ta'
                ? _verificationStatus.displayTextTamil
                : _verificationStatus.displayText;
        break;
      case VerificationStatus.notLoggedIn:
        badgeColor = const Color(0xFF9CA3AF);
        badgeText = _selectedLanguage == 'si' 
            ? _verificationStatus.displayTextSinhala
            : _selectedLanguage == 'ta'
                ? _verificationStatus.displayTextTamil
                : _verificationStatus.displayText;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF888888),
          letterSpacing: 0.5,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    bool hasChevron = false,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return SafeInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? const Color(0xFF6B7280),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (hasChevron) 
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFD1D5DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 56),
      color: const Color(0xFFF3F4F6),
    );
  }

  Widget _buildSyncBadge(Map<String, String> texts) {
    Color badgeColor = const Color(0xFF0086FF);
    String badgeText = texts['upToDate']!;
    
    switch (_syncStatus) {
      case 'up-to-date':
        badgeColor = const Color(0xFF0086FF);
        badgeText = texts['upToDate']!;
        break;
      case 'pending':
        badgeColor = const Color(0xFFF59E0B);
        badgeText = texts['pending']!;
        break;
      case 'error':
        badgeColor = const Color(0xFFEF4444);
        badgeText = texts['syncError']!;
        break;
      default:
        badgeColor = const Color(0xFF0086FF);
        badgeText = texts['upToDate']!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  String _getLanguageDisplayName(Map<String, String> texts) {
    switch (_selectedLanguage) {
      case 'si':
        return texts['sinhala']!;
      case 'ta':
        return texts['tamil']!;
      default:
        return texts['english']!;
    }
  }

  void _showLanguagePicker(BuildContext context, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              texts['selectLanguage']!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Language options
            _buildLanguageOption('en', texts['english']!, '🇬🇧', texts),
            _buildLanguageOption('si', texts['sinhala']!, '🇱🇰', texts),
            _buildLanguageOption('ta', texts['tamil']!, '🇱🇰', texts),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag, Map<String, String> texts) {
    final isSelected = _selectedLanguage == code;
    
    return SafeInkWell(
      onTap: () {
        _saveLanguagePreference(code);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0086FF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0086FF) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0086FF) : const Color(0xFF1A1A1A),
                  fontFamily: code == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0086FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          texts['confirmLogout']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        content: Text(
          texts['logoutMessage']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              texts['cancel']!,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout functionality
              _showComingSoonDialog(context, texts);
            },
            child: Text(
              texts['logoutButton']!,
              style: TextStyle(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          texts['comingSoon']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        content: Text(
          texts['featureInDevelopment']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              texts['ok']!,
              style: TextStyle(
                color: const Color(0xFF0086FF),
                fontWeight: FontWeight.w600,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}