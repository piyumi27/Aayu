import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../utils/responsive_utils.dart';

class VerificationBanner extends StatefulWidget {
  final UserAccount? user;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onResendEmail;
  final VoidCallback? onUsePhone;
  final bool isDismissible;
  
  const VerificationBanner({
    super.key,
    this.user,
    this.onVerifyNow,
    this.onResendEmail,
    this.onUsePhone,
    this.isDismissible = true,
  });

  @override
  State<VerificationBanner> createState() => _VerificationBannerState();
}

class _VerificationBannerState extends State<VerificationBanner> 
    with SingleTickerProviderStateMixin {
  String _selectedLanguage = 'en';
  bool _isDismissed = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start entrance animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
        // Use session-based dismissal key
        final sessionKey = 'verification_banner_dismissed_${widget.user?.id ?? 'current'}';
        _isDismissed = prefs.getBool(sessionKey) ?? false;
      });
    }
  }

  Future<void> _dismissBanner() async {
    if (!widget.isDismissible) return;
    
    await _animationController.reverse();
    
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      // Use session-based dismissal (reappears on next login)
      final sessionKey = 'verification_banner_dismissed_${widget.user?.id ?? 'current'}';
      await prefs.setBool(sessionKey, true);
      setState(() => _isDismissed = true);
    }
  }

  String get _title {
    switch (_selectedLanguage) {
      case 'si': return 'ගිණුම සත්‍යාපනය කරන්න';
      case 'ta': return 'கணக்கைச் சரிபார்க்கவும்';
      default: return 'Verify Account';
    }
  }

  String get _message {
    switch (_selectedLanguage) {
      case 'si': return 'ක්ලවුඩ් විශේෂාංග අගුළු ඇරීමට ඔබේ ගිණුම සත්‍යාපනය කරන්න';
      case 'ta': return 'கிளவுட் அம்சங்களைத் திறக்க உங்கள் கணக்கைச் சரிபార்க்கவும்';
      default: return 'Please verify your account to sync and unlock cloud features';
    }
  }

  String get _verifyNowText {
    switch (_selectedLanguage) {
      case 'si': return 'දැන් සත්‍යාපනය කරන්න';
      case 'ta': return 'இப்போது சரிபார்க்கவும்';
      default: return 'Verify Now';
    }
  }

  String get _resendEmailText {
    switch (_selectedLanguage) {
      case 'si': return 'ඊමේල් නැවත යවන්න';
      case 'ta': return 'மின்னஞ்சலை மீண்டும் அனுப்பவும்';
      default: return 'Resend Email';
    }
  }

  String get _usePhoneText {
    switch (_selectedLanguage) {
      case 'si': return 'දුරකථන භාවිතා කරන්න';
      case 'ta': return 'தொலைபேசியைப் பயன்படுத்தவும்';
      default: return 'Use Phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if dismissed, no user, or already verified
    if (_isDismissed || widget.user == null || widget.user!.isSyncGateOpen) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFED7AA), // Light orange
              const Color(0xFFFECBB0), // Lighter orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFF59E0B), // Orange border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon, title, and dismiss button
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFF59E0B),
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      _title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  if (widget.isDismissible)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: const Color(0xFF92400E),
                        size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      ),
                      onPressed: _dismissBanner,
                      tooltip: 'Dismiss',
                    ),
                ],
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              
              // Message
              Text(
                _message,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: const Color(0xFF92400E),
                  height: 1.4,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              
              // Action buttons
              Wrap(
                spacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
                runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 8),
                children: [
                  // Primary verify button
                  ElevatedButton.icon(
                    onPressed: widget.onVerifyNow,
                    icon: Icon(
                      Icons.verified_user,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                    ),
                    label: Text(_verifyNowText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                        vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  // Email verification actions
                  if (widget.user!.authMethod == AuthMethod.email) ...[
                    OutlinedButton.icon(
                      onPressed: widget.onResendEmail,
                      icon: Icon(
                        Icons.email,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                      ),
                      label: Text(_resendEmailText),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF92400E),
                        side: const BorderSide(color: Color(0xFF92400E)),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                  
                  // Phone verification option
                  TextButton.icon(
                    onPressed: widget.onUsePhone,
                    icon: Icon(
                      Icons.phone,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                    ),
                    label: Text(_usePhoneText),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF92400E),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                        vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}