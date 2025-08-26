import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';

class EditParentProfileScreen extends StatefulWidget {
  const EditParentProfileScreen({super.key});

  @override
  State<EditParentProfileScreen> createState() => _EditParentProfileScreenState();
}

class _EditParentProfileScreenState extends State<EditParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedLanguage = 'en';
  File? _profileImage;
  bool _isLoading = false;
  
  // Mock data - replace with actual user data
  bool _emailVerified = true;
  bool _phoneVerified = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      // Load mock data - replace with actual user data from database
      _nameController.text = 'Sarah Johnson';
      _emailController.text = 'sarah.johnson@example.com';
      _phoneController.text = '+1 (555) 123-4567';
    });
    
    // Listen for changes
    _nameController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      // Track changes
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'editProfile': 'Edit Profile',
        'tapToChangeProfilePicture': 'Tap to change profile picture',
        'fullName': 'Full Name',
        'emailAddress': 'Email Address',
        'phoneNumber': 'Phone Number',
        'verified': 'Verified',
        'changePassword': 'Change Password',
        'saveChanges': 'Save Changes',
        'deleteAccount': 'Delete Account',
        'nameRequired': 'Name is required',
        'nameMinLength': 'Name must be at least 2 characters',
        'confirmDelete': 'Confirm Account Deletion',
        'deleteWarning': 'This action cannot be undone. All your data, including child profiles, growth records, and settings will be permanently deleted.',
        'typeDelete': 'Type "DELETE" to confirm:',
        'cancel': 'Cancel',
        'deleteConfirm': 'Delete Account',
        'changesSaved': 'Changes saved successfully',
        'savingChanges': 'Saving changes...',
        'comingSoon': 'Coming Soon',
        'featureInDevelopment': 'This feature is currently in development.',
        'ok': 'OK',
        'selectImageSource': 'Select Image Source',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'removePhoto': 'Remove Photo',
      },
      'si': {
        'editProfile': 'පැතිකඩ සංස්කරණය',
        'tapToChangeProfilePicture': 'පැතිකඩ පින්තූරය වෙනස් කිරීමට ස්පර්ශ කරන්න',
        'fullName': 'සම්පූර්ණ නම',
        'emailAddress': 'ඊමේල් ලිපිනය',
        'phoneNumber': 'දුරකථන අංකය',
        'verified': 'සත්‍යාපිතයි',
        'changePassword': 'මුරපදය වෙනස් කරන්න',
        'saveChanges': 'වෙනස්කම් සුරකින්න',
        'deleteAccount': 'ගිණුම මකන්න',
        'nameRequired': 'නම අවශ්‍යයි',
        'nameMinLength': 'නම අවම අක්ෂර 2ක් විය යුතුයි',
        'confirmDelete': 'ගිණුම මැකීම සනාථ කරන්න',
        'deleteWarning': 'මෙම ක්‍රියාව අවලංගු කළ නොහැක. ළමා පැතිකඩ, වර්ධන වාර්තා සහ සැකසීම් ඇතුළුව ඔබේ සියලුම දත්ත ස්ථිරවම මකා දමනු ලැබේ.',
        'typeDelete': 'තහවුරු කිරීම සඳහා "DELETE" ටයිප් කරන්න:',
        'cancel': 'අවලංගු කරන්න',
        'deleteConfirm': 'ගිණුම මකන්න',
        'changesSaved': 'වෙනස්කම් සාර්ථකව සුරකින ලදී',
        'savingChanges': 'වෙනස්කම් සුරකිමින්...',
        'comingSoon': 'ඉක්මනින් එනවා',
        'featureInDevelopment': 'මෙම විශේෂාංගය දැනට සංවර්ධනය වෙමින් පවතී.',
        'ok': 'හරි',
        'selectImageSource': 'පින්තූර මූලාශ්‍රය තෝරන්න',
        'camera': 'කැමරාව',
        'gallery': 'ගැලරිය',
        'removePhoto': 'ඡායාරූපය ඉවත් කරන්න',
      },
      'ta': {
        'editProfile': 'சுயவிவரத்தைத் திருத்து',
        'tapToChangeProfilePicture': 'சுயவிவர படத்தை மாற்ற தட்டவும்',
        'fullName': 'முழுப்பெயர்',
        'emailAddress': 'மின்னஞ்சல் முகவரி',
        'phoneNumber': 'தொலைபேசி எண்',
        'verified': 'சரிபார்க்கப்பட்டது',
        'changePassword': 'கடவுச்சொல்லை மாற்று',
        'saveChanges': 'மாற்றங்களைச் சேமி',
        'deleteAccount': 'கணக்கை நீக்கு',
        'nameRequired': 'பெயர் தேவை',
        'nameMinLength': 'பெயர் குறைந்தது 2 எழுத்துகள் இருக்க வேண்டும்',
        'confirmDelete': 'கணக்கு நீக்கலை உறுதிப்படுத்தவும்',
        'deleteWarning': 'இந்த செயலை மாற்ற முடியாது. உங்கள் அனைத்து தரவுகளும், குழந்தை சுயவிவரங்கள், வளர்ச்சி பதிவுகள் மற்றும் அமைப்புகள் ஆகியவை நிரந்தரமாக நீக்கப்படும்.',
        'typeDelete': 'உறுதிப்படுத்த "DELETE" என தட்டச்சு செய்யவும்:',
        'cancel': 'ரத்து செய்',
        'deleteConfirm': 'கணக்கை நீக்கு',
        'changesSaved': 'மாற்றங்கள் வெற்றிகரமாகச் சேமிக்கப்பட்டன',
        'savingChanges': 'மாற்றங்களைச் சேமிக்கிறது...',
        'comingSoon': 'விரைவில் வரும்',
        'featureInDevelopment': 'இந்த அம்சம் தற்போது வளர்ச்சியில் உள்ளது.',
        'ok': 'சரி',
        'selectImageSource': 'படத்தின் மூலத்தைத் தேர்ந்தெடுக்கவும்',
        'camera': 'கேமரா',
        'gallery': 'காட்சியகம்',
        'removePhoto': 'புகைப்படத்தை அகற்று',
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
          texts['editProfile']!,
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
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Profile Picture Section
                _buildProfilePictureSection(texts),
                
                const SizedBox(height: 48),
                
                // Form Fields
                _buildNameField(texts),
                const SizedBox(height: 24),
                
                _buildEmailField(texts),
                const SizedBox(height: 24),
                
                _buildPhoneField(texts),
                const SizedBox(height: 32),
                
                // Change Password Button
                _buildChangePasswordButton(texts),
                
                const SizedBox(height: 48),
                
                // Action Buttons
                _buildSaveButton(texts),
                const SizedBox(height: 16),
                
                _buildDeleteAccountButton(texts),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(Map<String, String> texts) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: _profileImage != null 
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null 
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: const Color(0xFF9CA3AF),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF007BFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          texts['tapToChangeProfilePicture']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['fullName']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: texts['fullName']!,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return texts['nameRequired']!;
            }
            if (value.trim().length < 2) {
              return texts['nameMinLength']!;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['emailAddress']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          enabled: false,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_emailVerified) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      texts['verified']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['phoneNumber']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          enabled: false,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_phoneVerified) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      texts['verified']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton(Map<String, String> texts) {
    return TextButton(
      onPressed: () => _showComingSoonDialog(texts),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        texts['changePassword']!,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF007BFF),
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  Widget _buildSaveButton(Map<String, String> texts) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveChanges,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _isLoading ? texts['savingChanges']! : texts['saveChanges']!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
    );
  }

  Widget _buildDeleteAccountButton(Map<String, String> texts) {
    return OutlinedButton(
      onPressed: () => _showDeleteConfirmationDialog(texts),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF4D4D),
        side: const BorderSide(color: Color(0xFFFF4D4D), width: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        texts['deleteAccount']!,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    final texts = _getLocalizedText();
    
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
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              texts['selectImageSource']!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildImageSourceOption(Icons.camera_alt, texts['camera']!, () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            }),
            
            _buildImageSourceOption(Icons.photo_library, texts['gallery']!, () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
            }),
            
            if (_profileImage != null)
              _buildImageSourceOption(Icons.delete_outline, texts['removePhoto']!, () {
                Navigator.of(context).pop();
                setState(() {
                  _profileImage = null;
                });
              }),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B7280)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implement actual save functionality
      await Future.delayed(const Duration(seconds: 1));
      
      final texts = _getLocalizedText();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            texts['changesSaved']!,
            style: TextStyle(
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      setState(() {
        // Changes saved
      });
      
    } catch (e) {
      // Handle error
      print('Error saving changes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(Map<String, String> texts) {
    final confirmController = TextEditingController();
    bool canDelete = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            texts['confirmDelete']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts['deleteWarning']!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                texts['typeDelete']!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    canDelete = value.trim().toUpperCase() == 'DELETE';
                  });
                },
              ),
            ],
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
              onPressed: canDelete ? () {
                Navigator.of(context).pop();
                _showComingSoonDialog(texts);
              } : null,
              child: Text(
                texts['deleteConfirm']!,
                style: TextStyle(
                  color: canDelete ? const Color(0xFFFF4D4D) : const Color(0xFFD1D5DB),
                  fontWeight: FontWeight.w600,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(Map<String, String> texts) {
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
                color: const Color(0xFF007BFF),
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