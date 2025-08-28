import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';

class EditChildProfileScreen extends StatefulWidget {
  final String? childId;
  
  const EditChildProfileScreen({
    super.key,
    this.childId,
  });

  @override
  State<EditChildProfileScreen> createState() => _EditChildProfileScreenState();
}

class _EditChildProfileScreenState extends State<EditChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _birthHeightController = TextEditingController();
  
  String _selectedLanguage = 'en';
  String _selectedGender = 'Male';
  DateTime? _birthDate;
  File? _profileImage;
  bool _isLoading = false;
  bool _removeExistingPhoto = false;
  Child? _child;
  
  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    super.dispose();
  }

  Future<void> _loadChildData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      
      // Load specific child if childId provided, otherwise use selected child or first child
      if (widget.childId != null) {
        try {
          _child = childProvider.children.firstWhere(
            (child) => child.id == widget.childId,
          );
        } catch (e) {
          // Child not found, use selected child or first child
          _child = childProvider.selectedChild ?? 
                   (childProvider.children.isNotEmpty ? childProvider.children.first : null);
        }
      } else {
        _child = childProvider.selectedChild ?? 
                 (childProvider.children.isNotEmpty ? childProvider.children.first : null);
      }
      
      if (_child != null) {
        _nameController.text = _child!.name;
        _selectedGender = _child!.gender;
        _birthDate = _child!.birthDate;
        _birthWeightController.text = _child!.birthWeight?.toString() ?? '';
        _birthHeightController.text = _child!.birthHeight?.toString() ?? '';
      }
    });
    
    // Listen for changes
    _nameController.addListener(_onTextChanged);
    _birthWeightController.addListener(_onTextChanged);
    _birthHeightController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      // Track changes
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'editChildProfile': 'Edit Child Profile',
        'tapToChangeProfilePicture': 'Tap to change profile picture',
        'childName': 'Child Name',
        'dateOfBirth': 'Date of Birth',
        'gender': 'Gender',
        'male': 'Male',
        'female': 'Female',
        'birthWeight': 'Birth Weight (kg)',
        'birthHeight': 'Birth Height (cm)',
        'optional': 'Optional',
        'saveChanges': 'Save Changes',
        'deleteChild': 'Delete Child Profile',
        'nameRequired': 'Child name is required',
        'nameMinLength': 'Name must be at least 2 characters',
        'dobRequired': 'Date of birth is required',
        'selectBirthDate': 'Select birth date',
        'confirmDelete': 'Confirm Child Profile Deletion',
        'deleteWarning': 'This action cannot be undone. All data for this child, including growth records, vaccination history, and measurements will be permanently deleted.',
        'typeChildName': 'Type the child\'s name to confirm:',
        'cancel': 'Cancel',
        'deleteConfirm': 'Delete Child Profile',
        'changesSaved': 'Child profile updated successfully',
        'savingChanges': 'Saving changes...',
        'selectImageSource': 'Select Image Source',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'removePhoto': 'Remove Photo',
        'ageDisplay': 'Age: {age}',
        'selectChild': 'Select Child',
        'noChildren': 'No children found',
        'addChildFirst': 'Add a child first from the home screen',
      },
      'si': {
        'editChildProfile': 'ළමා පැතිකඩ සංස්කරණය',
        'tapToChangeProfilePicture': 'පැතිකඩ පින්තූරය වෙනස් කිරීමට ස්පර්ශ කරන්න',
        'childName': 'ළමයාගේ නම',
        'dateOfBirth': 'උපන් දිනය',
        'gender': 'ලිංගය',
        'male': 'පිරිමි',
        'female': 'ගැහැණු',
        'birthWeight': 'උපන් බර (කිලෝ)',
        'birthHeight': 'උපන් උස (සෙමී)',
        'optional': 'විකල්ප',
        'saveChanges': 'වෙනස්කම් සුරකින්න',
        'deleteChild': 'ළමා පැතිකඩ මකන්න',
        'nameRequired': 'ළමයාගේ නම අවශ්‍යයි',
        'nameMinLength': 'නම අවම අක්ෂර 2ක් විය යුතුයි',
        'dobRequired': 'උපන් දිනය අවශ්‍යයි',
        'selectBirthDate': 'උපන් දිනය තෝරන්න',
        'confirmDelete': 'ළමා පැතිකඩ මැකීම සනාථ කරන්න',
        'deleteWarning': 'මෙම ක්‍රියාව අවලංගු කළ නොහැක. මෙම ළමයා සඳහා වන සියලුම දත්ත, වර්ධන වාර්තා, එන්නත් ඉතිහාසය සහ මිනුම් ස්ථිරවම මකා දමනු ලැබේ.',
        'typeChildName': 'තහවුරු කිරීම සඳහා ළමයාගේ නම ටයිප් කරන්න:',
        'cancel': 'අවලංගු කරන්න',
        'deleteConfirm': 'ළමා පැතිකඩ මකන්න',
        'changesSaved': 'ළමා පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී',
        'savingChanges': 'වෙනස්කම් සුරකිමින්...',
        'selectImageSource': 'පින්තූර මූලාශ්‍රය තෝරන්න',
        'camera': 'කැමරාව',
        'gallery': 'ගැලරිය',
        'removePhoto': 'ඡායාරූපය ඉවත් කරන්න',
        'ageDisplay': 'වයස: {age}',
        'selectChild': 'ළමයා තෝරන්න',
        'noChildren': 'ළමයින් හමු නොවිය',
        'addChildFirst': 'මුලින්ම මුල් පිටුවෙන් ළමයෙකු එකතු කරන්න',
      },
      'ta': {
        'editChildProfile': 'குழந்தை சுயவிவரத்தைத் திருத்து',
        'tapToChangeProfilePicture': 'சுயவிவர படத்தை மாற்ற தட்டவும்',
        'childName': 'குழந்தையின் பெயர்',
        'dateOfBirth': 'பிறந்த தேதி',
        'gender': 'பாலினம்',
        'male': 'ஆண்',
        'female': 'பெண்',
        'birthWeight': 'பிறப்பு எடை (கிலோ)',
        'birthHeight': 'பிறப்பு உயரம் (செமீ)',
        'optional': 'விருப்பமானது',
        'saveChanges': 'மாற்றங்களைச் சேமி',
        'deleteChild': 'குழந்தை சுயவிவரத்தை நீக்கு',
        'nameRequired': 'குழந்தையின் பெயர் தேவை',
        'nameMinLength': 'பெயர் குறைந்தது 2 எழுத்துகள் இருக்க வேண்டும்',
        'dobRequired': 'பிறந்த தேதி தேவை',
        'selectBirthDate': 'பிறந்த தேதியைத் தேர்ந்தெடுக்கவும்',
        'confirmDelete': 'குழந்தை சுயவிவர நீக்கலை உறுதிப்படுத்தவும்',
        'deleteWarning': 'இந்த செயலை மாற்ற முடியாது. இந்த குழந்தைக்கான அனைத்து தரவுகளும், வளர்ச்சி பதிவுகள், தடுப்பூசி வரலாறு மற்றும் அளவீடுகள் ஆகியவை நிரந்தரமாக நீக்கப்படும்.',
        'typeChildName': 'உறுதிப்படுத்த குழந்தையின் பெயரை தட்டச்சு செய்யவும்:',
        'cancel': 'ரத்து செய்',
        'deleteConfirm': 'குழந்தை சுயவிவரத்தை நீக்கு',
        'changesSaved': 'குழந்தை சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
        'savingChanges': 'மாற்றங்களைச் சேமிக்கிறது...',
        'selectImageSource': 'படத்தின் மூலத்தைத் தேர்ந்தெடுக்கவும்',
        'camera': 'கேமரா',
        'gallery': 'காட்சியகம்',
        'removePhoto': 'புகைப்படத்தை அகற்று',
        'ageDisplay': 'வயது: {age}',
        'selectChild': 'குழந்தையைத் தேர்ந்தெடுக்கவும்',
        'noChildren': 'குழந்தைகள் எதுவும் கிடைக்கவில்லை',
        'addChildFirst': 'முதல் பக்கத்தில் இருந்து முதலில் ஒரு குழந்தையைச் சேர்க்கவும்',
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
          texts['editChildProfile']!,
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
                
                // Child Selector
                _buildChildSelector(texts),
                
                const SizedBox(height: 32),
                
                // Profile Picture Section
                if (_child != null) _buildProfilePictureSection(texts),
                
                if (_child != null) ...[
                  const SizedBox(height: 48),
                  
                  // Form Fields
                  _buildNameField(texts),
                  const SizedBox(height: 24),
                  
                  _buildDateOfBirthField(texts),
                const SizedBox(height: 24),
                
                _buildGenderSelection(texts),
                const SizedBox(height: 24),
                
                // Optional measurements section
                _buildOptionalMeasurementsSection(texts),
                
                const SizedBox(height: 48),
                
                  // Action Buttons
                  _buildSaveButton(texts),
                  const SizedBox(height: 16),
                  
                  _buildDeleteChildButton(texts),
                  
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildSelector(Map<String, String> texts) {
    return Consumer<ChildProvider>(
      builder: (context, childProvider, child) {
        if (childProvider.children.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
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
                Icon(
                  Icons.child_care_outlined,
                  size: 48,
                  color: const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 16),
                Text(
                  texts['noChildren']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texts['addChildFirst']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  texts['selectChild']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: childProvider.children.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final child = childProvider.children[index];
                  final isSelected = _child?.id == child.id;
                  final age = _calculateAge(child.birthDate);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? const Color(0xFF0086FF) 
                          : const Color(0xFFF3F4F6),
                      child: Icon(
                        child.gender == 'Male' ? Icons.boy : Icons.girl,
                        color: isSelected 
                            ? Colors.white
                            : (child.gender == 'Male' 
                                ? const Color(0xFF0086FF)
                                : const Color(0xFFFF69B4)),
                      ),
                    ),
                    title: Text(
                      child.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    subtitle: Text(
                      texts['ageDisplay']!.replaceAll('{age}', age),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                          )
                        : null,
                    onTap: () {
                      _selectChild(child);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final days = difference.inDays;
    
    if (days < 30) {
      return '$days days';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months months';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      if (remainingMonths == 0) {
        return '$years years';
      } else {
        return '$years years $remainingMonths months';
      }
    }
  }

  void _selectChild(Child child) {
    setState(() {
      _child = child;
      _nameController.text = child.name;
      _selectedGender = child.gender;
      _birthDate = child.birthDate;
      _birthWeightController.text = child.birthWeight?.toString() ?? '';
      _birthHeightController.text = child.birthHeight?.toString() ?? '';
      // Reset profile image when switching children
      _profileImage = null;
    });
  }

  ImageProvider? _getProfileImageProvider() {
    // Priority: 1. New selected image 2. Existing saved image 3. No image
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_child?.photoUrl != null && _child!.photoUrl!.isNotEmpty) {
      return FileImage(File(_child!.photoUrl!));
    }
    return null;
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
                backgroundImage: _getProfileImageProvider(),
                child: _getProfileImageProvider() == null
                    ? Icon(
                        _selectedGender == 'Male' ? Icons.boy : Icons.girl,
                        size: 60,
                        color: _selectedGender == 'Male' 
                            ? const Color(0xFF0086FF)
                            : const Color(0xFFFF69B4),
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
        if (_birthDate != null) ...[
          const SizedBox(height: 8),
          Text(
            texts['ageDisplay']!.replaceAll('{age}', _child?.formattedAge ?? ''),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0086FF),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['childName']!,
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
            hintText: texts['childName']!,
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

  Widget _buildDateOfBirthField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['dateOfBirth']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? texts['selectBirthDate']!
                        : _birthDate!.toString().split(' ')[0],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      color: _birthDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A1A),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF0086FF), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['gender']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderChip(
                label: texts['male']!,
                value: 'Male',
                icon: Icons.boy,
                color: const Color(0xFF0086FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderChip(
                label: texts['female']!,
                value: 'Female',
                icon: Icons.girl,
                color: const Color(0xFFFF69B4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: isSelected ? color : const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalMeasurementsSection(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['optional']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _birthWeightController,
                label: texts['birthWeight']!,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _birthHeightController,
                label: texts['birthHeight']!,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
            hintText: label,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ),
      ],
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
          ? const SizedBox(
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

  Widget _buildDeleteChildButton(Map<String, String> texts) {
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
        texts['deleteChild']!,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF0086FF),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
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
            
            if (_getProfileImageProvider() != null)
              _buildImageSourceOption(Icons.delete_outline, texts['removePhoto']!, () {
                Navigator.of(context).pop();
                setState(() {
                  _profileImage = null;
                  _removeExistingPhoto = true;
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
          _removeExistingPhoto = false; // Reset removal flag when new image is selected
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedText()['dobRequired']!),
          backgroundColor: const Color(0xFFFF4D4D),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Save profile image to local storage if changed
      String? photoUrl = _child?.photoUrl;
      if (_profileImage != null) {
        // Save new image to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'child_${_child!.id}_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedImage = await _profileImage!.copy('${appDir.path}/$fileName');
        photoUrl = savedImage.path;
      } else if (_removeExistingPhoto) {
        // Remove existing photo
        photoUrl = null;
      }
      
      // Create updated child object
      final updatedChild = _child!.copyWith(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthDate: _birthDate,
        birthWeight: double.tryParse(_birthWeightController.text.trim()),
        birthHeight: double.tryParse(_birthHeightController.text.trim()),
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );
      
      // Update child through provider
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      await childProvider.updateChild(updatedChild);
      
      if (!mounted) return;
      
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
      
      // Update local state to reflect saved changes
      setState(() {
        _child = updatedChild;
        _profileImage = null;
        _removeExistingPhoto = false;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF4D4D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(Map<String, String> texts) {
    final confirmController = TextEditingController();
    bool canDelete = false;
    final childName = _nameController.text.trim();
    
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
                texts['typeChildName']!,
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
                    canDelete = value.trim().toLowerCase() == childName.toLowerCase();
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
                // TODO: Implement delete child functionality
                Navigator.of(context).pop(); // Return to previous screen
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
}