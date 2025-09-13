import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';
import '../utils/validation_utils.dart';

class GmailField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? errorText;
  final bool enabled;
  final String? helperText;

  const GmailField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.errorText,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<GmailField> createState() => _GmailFieldState();
}

class _GmailFieldState extends State<GmailField> {
  late TextEditingController _controller;
  String _selectedLanguage = 'en';
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.initialValue != null
            ? ValidationUtils.extractGmailLocalPart(widget.initialValue!)
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
        return 'amalka.r';
      case 'ta':
        return 'amalka.r';
      default:
        return 'yourname';
    }
  }

  String get _labelText {
    switch (_selectedLanguage) {
      case 'si':
        return 'Gmail ලිපිනය';
      case 'ta':
        return 'Gmail முகவரி';
      default:
        return 'Gmail Address';
    }
  }

  String get _helperText {
    if (widget.helperText != null) return widget.helperText!;

    switch (_selectedLanguage) {
      case 'si':
        return 'අකුරු, සංඛ්‍යා, තිත්, යටි ඉර, ප්ලස් හෝ හයිෆන් භාවිතා කරන්න';
      case 'ta':
        return 'எழுத்துகள், எண்கள், புள்ளிகள், அடிக்கோடுகள், பிளஸ் அல்லது ஹைபன்களைப் பயன்படுத்தவும்';
      default:
        return 'Use letters, numbers, dots, underscores, plus or hyphens';
    }
  }

  void _onTextChanged(String text) {
    // Convert to lowercase for Gmail normalization
    final normalized = text.toLowerCase();

    // Limit to 64 characters for Gmail local part
    if (normalized.length > 64) {
      final truncated = normalized.substring(0, 64);
      _controller.value = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
      return;
    }

    // Update controller if normalization changed the text
    if (normalized != text && normalized.length <= 64) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    // Notify parent of changes
    if (widget.onChanged != null) {
      final fullEmail = normalized.isNotEmpty
          ? ValidationUtils.buildGmailAddress(normalized)
          : normalized;
      widget.onChanged!(fullEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = ValidationUtils.validateGmailLocalPart(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email input field with @gmail.com suffix
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
              // Email local part input
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _hasFocus = focused);
                  },
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      // Allow only Gmail-safe characters
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9._%+-]')),
                      LengthLimitingTextInputFormatter(64),
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
                          ? Icon(
                              isValid ? Icons.check_circle : Icons.error,
                              color: isValid
                                  ? const Color(0xFF10B981)
                                  : Theme.of(context).colorScheme.error,
                              size: ResponsiveUtils.getResponsiveIconSize(
                                  context, 20),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Fixed @gmail.com suffix
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: const Color(0xFF0086FF).withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Text(
                  ValidationUtils.gmailSuffix,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

        // Display full email preview when valid
        if (isValid && _controller.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.getResponsiveSpacing(context, 4),
              left: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            child: Text(
              ValidationUtils.buildGmailAddress(_controller.text),
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
