import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';
import '../utils/validation_utils.dart';

class PasswordStrengthField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? errorText;
  final bool enabled;
  final String? helperText;
  final bool isConfirmField;
  final String? passwordToMatch;

  const PasswordStrengthField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.errorText,
    this.enabled = true,
    this.helperText,
    this.isConfirmField = false,
    this.passwordToMatch,
  });

  @override
  State<PasswordStrengthField> createState() => _PasswordStrengthFieldState();
}

class _PasswordStrengthFieldState extends State<PasswordStrengthField> {
  late TextEditingController _controller;
  String _selectedLanguage = 'en';
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _loadPreferences();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
      });
    }
  }

  String get _labelText {
    if (widget.isConfirmField) {
      switch (_selectedLanguage) {
        case 'si':
          return 'මුරපදය තහවුරු කරන්න';
        case 'ta':
          return 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';
        default:
          return 'Confirm Password';
      }
    }

    switch (_selectedLanguage) {
      case 'si':
        return 'මුරපදය';
      case 'ta':
        return 'கடவுச்சொல்';
      default:
        return 'Password';
    }
  }

  String get _helperText {
    if (widget.helperText != null) return widget.helperText!;

    if (widget.isConfirmField) {
      switch (_selectedLanguage) {
        case 'si':
          return 'ඉහත මුරපදය නැවත ඇතුළත් කරන්න';
        case 'ta':
          return 'மேலே உள்ள கடவுச்சொல்லை மீண்டும் உள்ளிடவும்';
        default:
          return 'Re-enter the password above';
      }
    }

    switch (_selectedLanguage) {
      case 'si':
        return 'අවම වශයෙන් 8 අකුරක් භාවිතා කරන්න';
      case 'ta':
        return 'குறைந்தது 8 எழுத்துக்களைப் பயன்படுத்தவும்';
      default:
        return 'Use at least 8 characters';
    }
  }

  bool get _isMatching {
    if (!widget.isConfirmField || widget.passwordToMatch == null) return true;
    return _controller.text == widget.passwordToMatch;
  }

  String? get _matchingError {
    if (!widget.isConfirmField || widget.passwordToMatch == null) return null;
    if (_controller.text.isEmpty) return null;

    if (!_isMatching) {
      switch (_selectedLanguage) {
        case 'si':
          return 'මුරපද නොගැලපේ';
        case 'ta':
          return 'கடவுச்சொல் பொருந்தவில்லை';
        default:
          return 'Passwords do not match';
      }
    }

    return null;
  }

  void _onTextChanged(String text) {
    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }
  }

  Widget _buildStrengthMeter() {
    if (widget.isConfirmField || _controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = ValidationUtils.getPasswordStrength(_controller.text);

    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveUtils.getResponsiveSpacing(context, 8),
        left: ResponsiveUtils.getResponsiveSpacing(context, 12),
        right: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength indicator text
          Text(
            strength.getDisplayText(_selectedLanguage),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              color: strength.getColor(),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),

          // Strength progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: switch (strength) {
                      PasswordStrength.weak => 0.33,
                      PasswordStrength.medium => 0.66,
                      PasswordStrength.strong => 1.0,
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(strength.getColor()),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.errorText ?? _matchingError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password field
        Focus(
          onFocusChange: (focused) {
            setState(() => _hasFocus = focused);
          },
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            obscureText: _obscureText,
            onChanged: _onTextChanged,
            onEditingComplete: widget.onEditingComplete,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
            decoration: InputDecoration(
              labelText: _labelText,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Matching indicator for confirm field
                  if (widget.isConfirmField && _controller.text.isNotEmpty)
                    Icon(
                      _isMatching ? Icons.check_circle : Icons.error,
                      color: _isMatching
                          ? const Color(0xFF10B981)
                          : Theme.of(context).colorScheme.error,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                    ),

                  if (widget.isConfirmField && _controller.text.isNotEmpty)
                    SizedBox(
                        width:
                            ResponsiveUtils.getResponsiveSpacing(context, 8)),

                  // Show/hide password toggle
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  ),
                ],
              ),
              errorText: displayError,
            ),
          ),
        ),

        // Password strength meter
        _buildStrengthMeter(),

        // Helper text
        if (displayError == null && _helperText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getResponsiveSpacing(context, 8),
              left: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            child: Text(
              _helperText,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
