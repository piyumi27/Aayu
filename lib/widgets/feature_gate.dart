import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';
import '../utils/responsive_utils.dart';

class FeatureGate extends StatefulWidget {
  final Widget child;
  final UserAccount? user;
  final String featureName;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onRemindLater;
  final bool isEnabled;
  
  const FeatureGate({
    super.key,
    required this.child,
    this.user,
    required this.featureName,
    this.onVerifyNow,
    this.onRemindLater,
    this.isEnabled = true,
  });

  @override
  State<FeatureGate> createState() => _FeatureGateState();
}

class _FeatureGateState extends State<FeatureGate> {
  String _selectedLanguage = 'en';
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
      });
    }
  }

  bool get _isGateOpen {
    return widget.user?.isSyncGateOpen ?? false;
  }

  String get _modalTitle {
    switch (_selectedLanguage) {
      case 'si': return 'ගිණුම සත්‍යාපනය අවශ්‍යයි';
      case 'ta': return 'கணக்கு சரிபார்ப்பு தேவை';
      default: return 'Account Verification Required';
    }
  }

  String get _modalMessage {
    switch (_selectedLanguage) {
      case 'si': return 'ඔබේ දරුවාගේ දත්ත සමමුහුර්ත කිරීමට සහ ක්ලවුඩ් විශේෂාංග අගුළු ඇරීමට ඔබේ ඊමේල් හෝ දුරකථන අංකය සත්‍යාපනය කරන්න.';
      case 'ta': return 'உங்கள் குழந்தையின் தரவை ஒத்திசைக்கவும், கிளவுட் அம்சங்களைத் திறக்கவும் உங்கள் மின்னஞ்சல் அல்லது தொலைபேசி எண்ணைச் சரிபார்க்கவும்.';
      default: return 'Verify your email or phone to sync your child\'s data and unlock cloud features.';
    }
  }

  String get _verifyNowText {
    switch (_selectedLanguage) {
      case 'si': return 'දැන් සත්‍යාපනය කරන්න';
      case 'ta': return 'இப்போது சரிபார்க்கவும்';
      default: return 'Verify Now';
    }
  }

  String get _remindLaterText {
    switch (_selectedLanguage) {
      case 'si': return 'පසුව මතක් කරන්න';
      case 'ta': return 'பின்னர் நினைவூட்டவும்';
      default: return 'Remind Me Later';
    }
  }

  void _showVerificationModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: ResponsiveUtils.getResponsivePadding(context, scale: 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock icon
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: const Color(0xFFF59E0B),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 48),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
              
              // Title
              Text(
                _modalTitle,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              
              // Message
              Text(
                _modalMessage,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onRemindLater?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_remindLaterText),
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onVerifyNow?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_verifyNowText),
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

  @override
  Widget build(BuildContext context) {
    // If gate is open or feature is disabled, show child normally
    if (_isGateOpen || !widget.isEnabled) {
      return widget.child;
    }
    
    // Otherwise, wrap with lock overlay
    return Stack(
      children: [
        // Original child (disabled)
        AbsorbPointer(
          absorbing: true,
          child: Opacity(
            opacity: 0.6,
            child: widget.child,
          ),
        ),
        
        // Lock overlay
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showVerificationModal,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock,
                      color: const Color(0xFFF59E0B),
                      size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Extension to easily wrap widgets with feature gates
extension FeatureGateExtension on Widget {
  Widget gated({
    required String featureName,
    UserAccount? user,
    VoidCallback? onVerifyNow,
    VoidCallback? onRemindLater,
    bool isEnabled = true,
  }) {
    return FeatureGate(
      featureName: featureName,
      user: user,
      onVerifyNow: onVerifyNow,
      onRemindLater: onRemindLater,
      isEnabled: isEnabled,
      child: this,
    );
  }
}