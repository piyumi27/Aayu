import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';
import '../utils/validation_utils.dart';

class SriLankaPhoneField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? errorText;
  final bool enabled;
  final String? helperText;

  const SriLankaPhoneField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.errorText,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<SriLankaPhoneField> createState() => _SriLankaPhoneFieldState();
}

class _SriLankaPhoneFieldState extends State<SriLankaPhoneField> {
  late TextEditingController _controller;
  String _selectedLanguage = 'en';
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.initialValue != null
            ? ValidationUtils.extractSriLankaLocal(widget.initialValue!)
            : '');
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

  String get _placeholder {
    switch (_selectedLanguage) {
      case 'si':
        return '7XXXXXXXX';
      case 'ta':
        return '7XXXXXXXX';
      default:
        return '7XXXXXXXX';
    }
  }

  String get _labelText {
    switch (_selectedLanguage) {
      case 'si':
        return 'දුරකථන අංකය';
      case 'ta':
        return 'தொலைபேசி எண்';
      default:
        return 'Phone Number';
    }
  }

  String get _helperText {
    if (widget.helperText != null) return widget.helperText!;

    switch (_selectedLanguage) {
      case 'si':
        return '0 නොමැතිව 9 ඉලක්කම් ඇතුළත් කරන්න (උදා: 7XXXXXXXX)';
      case 'ta':
        return '0 இல்லாமல் 9 இலக்கங்களை உள்ளிடவும் (உதா: 7XXXXXXXX)';
      default:
        return 'Enter 9 digits without leading zero (e.g., 7XXXXXXXX)';
    }
  }

  void _onTextChanged(String text) {
    // Normalize input (remove leading 0, keep only digits)
    final normalized = ValidationUtils.normalizeSriLankaInput(text);

    // Limit to 9 digits
    if (normalized.length > 9) {
      final truncated = normalized.substring(0, 9);
      _controller.value = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
      return;
    }

    // Update controller if normalization changed the text
    if (normalized != text && normalized.length <= 9) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    // Notify parent of changes
    if (widget.onChanged != null) {
      final e164 = normalized.length == 9 &&
              ValidationUtils.validateSriLankaLocal(normalized)
          ? ValidationUtils.buildE164SriLanka(normalized)
          : normalized;
      widget.onChanged!(e164);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = ValidationUtils.validateSriLankaLocal(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country prefix and input field
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorText != null
                  ? Theme.of(context).colorScheme.error
                  : _hasFocus
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Fixed Sri Lanka country prefix
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: const Color(0xFF0086FF).withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ValidationUtils.sriLankaFlag,
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 20),
                      ),
                    ),
                    SizedBox(
                        width:
                            ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    Text(
                      ValidationUtils.sriLankaCountryCode,
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 48,
                color: Theme.of(context).dividerColor,
              ),

              // Phone number input
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _hasFocus = focused);
                  },
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    onChanged: _onTextChanged,
                    onEditingComplete: widget.onEditingComplete,
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                    ),
                    decoration: InputDecoration(
                      hintText: _placeholder,
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          ResponsiveUtils.getResponsivePadding(context),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                isValid ? Icons.check_circle : Icons.error,
                                color: isValid
                                    ? const Color(0xFF10B981)
                                    : Theme.of(context).colorScheme.error,
                                size: ResponsiveUtils.getResponsiveIconSize(
                                    context, 20),
                              ),
                              onPressed: null,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Helper text or error text
        if (widget.errorText != null || _helperText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getResponsiveSpacing(context, 8),
              left: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            child: Text(
              widget.errorText ?? _helperText,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: widget.errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

        // Display formatted E.164 preview when valid
        if (isValid && _controller.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getResponsiveSpacing(context, 4),
              left: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            child: Text(
              ValidationUtils.formatSriLankaDisplay(_controller.text),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
