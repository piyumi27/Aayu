import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/growth_record.dart';
import '../providers/child_provider.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _muacController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  String _selectedLanguage = 'en';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _muacController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Add Measurement',
        'date': 'Date',
        'weight': 'Weight (kg)',
        'height': 'Height (cm)',
        'muac': 'MUAC (cm) - Optional',
        'muacHint': 'Mid-Upper Arm Circumference',
        'notes': 'Notes',
        'notesHint': 'Add any additional notes here...',
        'photo': 'Photo (Optional)',
        'addPhoto': 'Add Photo',
        'photoHint': 'Add a photo to track visual progress',
        'cancel': 'Cancel',
        'save': 'Save Measurement',
        'weightRequired': 'Weight is required',
        'heightRequired': 'Height is required',
        'invalidWeight': 'Enter a valid weight',
        'invalidHeight': 'Enter a valid height',
        'savingMeasurement': 'Saving measurement...',
        'measurementSaved': 'Measurement saved successfully',
        'measurementError': 'Failed to save measurement',
      },
      'si': {
        'title': 'මැනීම එක් කරන්න',
        'date': 'දිනය',
        'weight': 'බර (කි.ග්‍රෑ.)',
        'height': 'උස (සෙ.මී.)',
        'muac': 'MUAC (සෙ.මී.) - විකල්ප',
        'muacHint': 'මැද ඉහළ අත වට ප්‍රමාණය',
        'notes': 'සටහන්',
        'notesHint': 'අමතර සටහන් මෙහි එක් කරන්න...',
        'photo': 'ඡායාරූපය (විකල්ප)',
        'addPhoto': 'ඡායාරූපය එක් කරන්න',
        'photoHint': 'දෘශ්‍ය ප්‍රගතිය නිරීක්ෂණය සඳහා ඡායාරූපයක් එක් කරන්න',
        'cancel': 'අවලංගු',
        'save': 'මැනීම සුරකින්න',
        'weightRequired': 'බර අවශ්‍යයි',
        'heightRequired': 'උස අවශ්‍යයි',
        'invalidWeight': 'වලංගු බරක් ඇතුළු කරන්න',
        'invalidHeight': 'වලංගු උසක් ඇතුළු කරන්න',
        'savingMeasurement': 'මැනීම සුරකිමින්...',
        'measurementSaved': 'මැනීම සාර්ථකව සුරකින ලදී',
        'measurementError': 'මැනීම සුරැකීමට අසමත් විය',
      },
      'ta': {
        'title': 'அளவீடு சேர்க்க',
        'date': 'தேதி',
        'weight': 'எடை (கிலோ)',
        'height': 'உயரம் (செமீ)',
        'muac': 'MUAC (செமீ) - விருப்பம்',
        'muacHint': 'மேல் கை சுற்றளவு',
        'notes': 'குறிப்புகள்',
        'notesHint': 'கூடுதல் குறிப்புகள் இங்கே சேர்க்கவும்...',
        'photo': 'புகைப்படம் (விருப்பம்)',
        'addPhoto': 'புகைப்படம் சேர்க்கவும்',
        'photoHint': 'காட்சி முன்னேற்றத்தை கண்காணிக்க புகைப்படம் சேர்க்கவும்',
        'cancel': 'ரத்து',
        'save': 'அளவீடு சேமி',
        'weightRequired': 'எடை தேவை',
        'heightRequired': 'உயரம் தேவை',
        'invalidWeight': 'சரியான எடையை உள்ளிடவும்',
        'invalidHeight': 'சரியான உயரத்தை உள்ளிடவும்',
        'savingMeasurement': 'அளவீடு சேமிக்கப்படுகிறது...',
        'measurementSaved': 'அளவீடு வெற்றிகரமாக சேமிக்கப்பட்டது',
        'measurementError': 'அளவீடு சேமிக்க முடியவில்லை',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0086FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveMeasurement() async {
    final texts = _getLocalizedText();
    
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      final selectedChild = childProvider.selectedChild;

      if (selectedChild == null) {
        throw Exception('No child selected');
      }

      final now = DateTime.now();
      final growthRecord = GrowthRecord(
        id: 'growth_${selectedChild.id}_${now.millisecondsSinceEpoch}',
        childId: selectedChild.id,
        date: _selectedDate,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        headCircumference: _muacController.text.isNotEmpty 
            ? double.parse(_muacController.text) 
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: now,
        updatedAt: now,
      );

      await childProvider.addGrowthRecord(growthRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(texts['measurementSaved']!),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(texts['measurementError']!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          texts['title']!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFE0E0E0),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              _buildLabel(texts['date']!),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 24),

              // Weight Field
              _buildLabel(texts['weight']!),
              const SizedBox(height: 8),
              _buildNumberField(
                controller: _weightController,
                unit: 'kg',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return texts['weightRequired'];
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0 || weight > 500) {
                    return texts['invalidWeight'];
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Height Field
              _buildLabel(texts['height']!),
              const SizedBox(height: 8),
              _buildNumberField(
                controller: _heightController,
                unit: 'cm',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return texts['heightRequired'];
                  }
                  final height = double.tryParse(value);
                  if (height == null || height <= 0 || height > 300) {
                    return texts['invalidHeight'];
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // MUAC Field (Optional)
              Row(
                children: [
                  Text(
                    texts['muac']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      texts['muacHint']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildNumberField(
                controller: _muacController,
                unit: 'cm',
                isOptional: true,
              ),
              const SizedBox(height: 24),

              // Notes Section
              _buildLabel(texts['notes']!),
              const SizedBox(height: 8),
              _buildNotesField(),
              const SizedBox(height: 24),

              // Photo Picker
              _buildLabel(texts['photo']!),
              const SizedBox(height: 8),
              _buildPhotoPicker(),
              const SizedBox(height: 32),

              // Footer Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        texts['cancel']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Save Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMeasurement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0086FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    texts['save']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF333333),
        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String unit,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: isOptional ? null : validator,
      decoration: InputDecoration(
        hintText: '0.0',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        suffixText: unit,
        suffixStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0086FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final texts = _getLocalizedText();
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: texts['notesHint'],
        hintStyle: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0086FF), width: 2),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    final texts = _getLocalizedText();
    return Row(
      children: [
        // Photo Thumbnail
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF9CA3AF),
                  size: 32,
                ),
        ),
        const SizedBox(width: 16),
        // Add Photo Button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add, color: Color(0xFF0086FF)),
                label: Text(
                  texts['addPhoto']!,
                  style: TextStyle(
                    color: const Color(0xFF0086FF),
                    fontWeight: FontWeight.w600,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              Text(
                texts['photoHint']!,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}