import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _birthHeightController = TextEditingController();
  
  DateTime? _birthDate;
  String? _gender;
  File? _profileImage;
  String _selectedLanguage = 'en';
  bool _isValid = false;

  // Error messages
  String? _nameError;
  String? _dobError;
  String? _genderError;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Add Your Child',
        'addPhoto': 'Add photo (optional)',
        'childName': 'Child Name',
        'nameRequired': 'Name is required',
        'dateOfBirth': 'Date of Birth',
        'dobRequired': 'Date of birth is required',
        'gender': 'Gender',
        'genderRequired': 'Gender is required',
        'male': 'Male',
        'female': 'Female',
        'birthWeight': 'Birth Weight (kg)',
        'birthHeight': 'Birth Height (cm)',
        'helperText': 'Leave blank if unknown',
        'saveProfile': 'Save Profile',
        'profileSaved': 'Profile saved locally – sync later',
        'selectBirthDate': 'Select birth date',
      },
      'si': {
        'title': 'ඔබේ දරුවා එක් කරන්න',
        'addPhoto': 'ඡායාරූපය එක් කරන්න (විකල්ප)',
        'childName': 'දරුවාගේ නම',
        'nameRequired': 'නම අවශ්‍යයි',
        'dateOfBirth': 'උපන් දිනය',
        'dobRequired': 'උපන් දිනය අවශ්‍යයි',
        'gender': 'ලිංගය',
        'genderRequired': 'ලිංගය අවශ්‍යයි',
        'male': 'පිරිමි',
        'female': 'ගැහැණු',
        'birthWeight': 'උපන් බර (කිලෝ)',
        'birthHeight': 'උපන් උස (සෙමී)',
        'helperText': 'නොදන්නා නම් හිස්ව තබන්න',
        'saveProfile': 'පැතිකඩ සුරකින්න',
        'profileSaved': 'පැතිකඩ ස්ථානිකව සුරකින ලදී – පසුව සමමුහුර්ත කරන්න',
        'selectBirthDate': 'උපන් දිනය තෝරන්න',
      },
      'ta': {
        'title': 'உங்கள் குழந்தையை சேர்க்கவும்',
        'addPhoto': 'புகைப்படம் சேர்க்கவும் (விருப்பம்)',
        'childName': 'குழந்தையின் பெயர்',
        'nameRequired': 'பெயர் அவசியம்',
        'dateOfBirth': 'பிறந்த தேதி',
        'dobRequired': 'பிறந்த தேதி அவசியம்',
        'gender': 'பாலினம்',
        'genderRequired': 'பாலினம் அவசியம்',
        'male': 'ஆண்',
        'female': 'பெண்',
        'birthWeight': 'பிறப்பு எடை (கிலோ)',
        'birthHeight': 'பிறப்பு உயரம் (செமீ)',
        'helperText': 'தெரியாவிட்டால் காலியாக விடுங்கள்',
        'saveProfile': 'சுயவிவரத்தை சேமிக்கவும்',
        'profileSaved': 'சுயவிவரம் உள்ளே சேமிக்கப்பட்டது – பின்னர் ஒத்திசைக்கவும்',
        'selectBirthDate': 'பிறந்த தேதியை தேர்ந்தெடுக்கவும்',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  void _validateForm() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? _getLocalizedText()['nameRequired'] : null;
      _dobError = _birthDate == null ? _getLocalizedText()['dobRequired'] : null;
      _genderError = _gender == null ? _getLocalizedText()['genderRequired'] : null;
      
      _isValid = _nameController.text.isNotEmpty && 
                 _birthDate != null && 
                 _gender != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF202124)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          texts['title']!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF202124),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with avatar
                  _buildAvatarSection(texts),
                  
                  // Form card
                  _buildFormCard(texts),
                ],
              ),
            ),
          ),
          
          // Bottom fixed action bar
          _buildBottomActionBar(texts),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(Map<String, String> texts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
                color: Colors.grey[50],
              ),
              child: _profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts['addPhoto']!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(Map<String, String> texts) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Name
              _buildTextField(
                controller: _nameController,
                label: texts['childName']!,
                errorText: _nameError,
              ),
              
              const SizedBox(height: 20),
              
              // Date of Birth
              _buildDateField(texts),
              
              const SizedBox(height: 20),
              
              // Gender Toggle Chips
              _buildGenderSelection(texts),
              
              const SizedBox(height: 24),
              
              // Optional birth measurements
              _buildOptionalMeasurements(texts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0086FF), width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF5252)),
            ),
          ),
          onChanged: (_) => _validateForm(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFFF5252),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? texts['selectBirthDate']!
                        : _birthDate!.toString().split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      color: _birthDate == null ? Colors.grey[600] : Colors.black87,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_dobError != null) ...[
          const SizedBox(height: 4),
          Text(
            _dobError!,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFFF5252),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
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
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderChip(
              label: texts['male']!,
              value: 'Male',
              icon: Icons.male,
            ),
            const SizedBox(width: 12),
            _buildGenderChip(
              label: texts['female']!,
              value: 'Female',
              icon: Icons.female,
            ),
          ],
        ),
        if (_genderError != null) ...[
          const SizedBox(height: 4),
          Text(
            _genderError!,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFFF5252),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
        _validateForm();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0086FF) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF555555),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : const Color(0xFF555555),
                fontWeight: FontWeight.w500,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalMeasurements(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),
        Text(
          texts['helperText']!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: _isValid ? _saveChild : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0086FF),
            disabledBackgroundColor: const Color(0xFF0086FF).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            texts['saveProfile']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
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
      _validateForm();
    }
  }

  Future<void> _saveChild() async {
    final texts = _getLocalizedText();
    
    try {
      final now = DateTime.now();
      final child = Child(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender!,
        birthWeight: _birthWeightController.text.isEmpty
            ? null
            : double.tryParse(_birthWeightController.text),
        birthHeight: _birthHeightController.text.isEmpty
            ? null
            : double.tryParse(_birthHeightController.text),
        bloodType: null, // Removed from new design
        photoUrl: null, // Will be uploaded later
        createdAt: now,
        updatedAt: now,
      );

      // Save to local database and sync with Firebase
      await context.read<ChildProvider>().addChild(child);
      
      if (mounted) {
        // Show success toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              texts['profileSaved']!,
              style: TextStyle(
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate based on child age
        _navigateBasedOnAge(child);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateBasedOnAge(Child child) {
    final now = DateTime.now();
    final ageInMonths = (now.difference(child.birthDate).inDays / 30.44).round();
    
    if (ageInMonths < 6) {
      // TODO: Navigate to Pre-6-Month Countdown screen
      // For now, navigate to dashboard
      context.go('/');
    } else {
      // Navigate to Dashboard
      context.go('/');
    }
  }
}