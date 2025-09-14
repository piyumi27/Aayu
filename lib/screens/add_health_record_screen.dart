import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/vaccine.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';
import '../services/database_service.dart';

/// Professional Add Health Record screen for vaccines, supplements, and medications
class AddHealthRecordScreen extends StatefulWidget {
  final HealthRecordType? initialRecordType;
  final String? preselectedVaccineName;
  final String? preselectedVaccineId;

  const AddHealthRecordScreen({
    super.key,
    this.initialRecordType,
    this.preselectedVaccineName,
    this.preselectedVaccineId,
  });

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  // Form controllers
  final _nameController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _reminderTimeController = TextEditingController();
  
  // Form state
  HealthRecordType _selectedType = HealthRecordType.vaccine;
  DateTime? _selectedDueDate;
  TimeOfDay? _reminderTime;
  bool _setReminder = false;
  ReminderRepeat _reminderRepeat = ReminderRepeat.once;
  File? _selectedImage;
  
  // App state
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  
  // Autocomplete options
  final List<String> _vaccineOptions = [
    'MMR (Measles, Mumps, Rubella)',
    'DTaP (Diphtheria, Tetanus, Pertussis)',
    'IPV (Polio)',
    'Hib (Haemophilus influenzae type b)',
    'PCV (Pneumococcal)',
    'RV (Rotavirus)',
    'Hepatitis A',
    'Hepatitis B',
    'Varicella (Chickenpox)',
    'Influenza (Flu)',
    'COVID-19',
  ];
  
  final List<String> _supplementOptions = [
    'Vitamin D',
    'Iron',
    'Calcium',
    'Multivitamin',
    'Omega-3',
    'Probiotics',
    'Vitamin C',
    'Zinc',
  ];
  
  final List<String> _medicineOptions = [
    'Paracetamol/Acetaminophen',
    'Ibuprofen',
    'Amoxicillin',
    'Cough Syrup',
    'Antihistamine',
    'Oral Rehydration Salts',
    'Saline Drops',
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _reminderTimeController.text = '09:00 AM';
    _reminderTime = const TimeOfDay(hour: 9, minute: 0);

    // Initialize with preselected values if provided
    if (widget.initialRecordType != null) {
      _selectedType = widget.initialRecordType!;
    }

    if (widget.preselectedVaccineName != null) {
      _nameController.text = widget.preselectedVaccineName!;
    }
  }

  @override
  void dispose() {
    // Dispose controllers safely
    try {
      _nameController.dispose();
      _dueDateController.dispose();
      _notesController.dispose();
      _reminderTimeController.dispose();
    } catch (e) {
      // Ignore disposal errors to prevent crashes
      print('Controller disposal error: $e');
    }
    super.dispose();
  }

  /// Load user language preference
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      });
    }
  }

  /// Get autocomplete options based on selected type
  List<String> _getAutocompleteOptions() {
    switch (_selectedType) {
      case HealthRecordType.vaccine:
        return _vaccineOptions;
      case HealthRecordType.supplement:
        return _supplementOptions;
      case HealthRecordType.medicine:
        return _medicineOptions;
    }
  }

  /// Show date picker for due date
  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0086FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  /// Show time picker for reminder
  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0086FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _reminderTimeController.text = '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Save health record with proper error handling
  Future<void> _saveRecord() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty || _selectedDueDate == null) {
      _showMessage('Please fill in all required fields', isError: true);
      return;
    }

    // Prevent multiple saves
    if (_isLoading) return;

    // Check if widget is still mounted
    if (!mounted) return;

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ChildProvider>(context, listen: false);
      final selectedChild = provider.selectedChild;

      if (selectedChild == null) {
        if (mounted) {
          _showMessage('No child selected. Please select a child first.', isError: true);
        }
        return;
      }

      // Save based on record type
      switch (_selectedType) {
        case HealthRecordType.vaccine:
          await _saveVaccineRecord(provider, selectedChild.id);
          break;
        case HealthRecordType.supplement:
          await _saveSupplementRecord(provider, selectedChild.id);
          break;
        case HealthRecordType.medicine:
          await _saveMedicineRecord(provider, selectedChild.id);
          break;
      }

      // Double-check mounted state after async operation
      if (!mounted) return;

      // Show success message and navigate back
      _showMessageAndNavigateBack('Health record saved successfully!', isError: false);

    } catch (e) {
      // Handle any errors
      if (mounted) {
        // Show actual error for debugging
        if (kDebugMode) {
          print('❌ Health record save error: $e');
        }
        _showMessage('Failed to save record: ${e.toString()}', isError: true);
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Save vaccine record to database
  Future<void> _saveVaccineRecord(ChildProvider provider, String childId) async {
    const uuid = Uuid();
    final databaseService = DatabaseService();

    // Load vaccines to find matching vaccine
    await provider.loadVaccines();
    final vaccines = provider.vaccines;

    // Find vaccine by name (match with autocomplete options)
    final vaccineName = _nameController.text.trim();
    Vaccine? matchedVaccine;

    // Try to find exact match or partial match
    for (final vaccine in vaccines) {
      if (vaccine.name.toLowerCase().contains(vaccineName.toLowerCase()) ||
          vaccineName.toLowerCase().contains(vaccine.name.toLowerCase())) {
        matchedVaccine = vaccine;
        break;
      }
    }

    String vaccineId;

    // Use preselected vaccine ID if available (from notification)
    if (widget.preselectedVaccineId != null) {
      vaccineId = widget.preselectedVaccineId!;
    } else if (matchedVaccine == null) {
      // If no match found, create a custom vaccine entry
      vaccineId = 'custom_${uuid.v4()}';

      // Create custom vaccine entry in database
      final customVaccine = Vaccine(
        id: vaccineId,
        name: vaccineName,
        nameLocal: vaccineName, // Use same name for local
        description: 'Custom vaccine: $vaccineName',
        recommendedAgeMonths: provider.calculateAgeInMonths(provider.selectedChild!.birthDate),
        isMandatory: false,
        category: 'Custom',
      );

      await databaseService.insertVaccine(customVaccine);
    } else {
      vaccineId = matchedVaccine.id;
    }

    final record = VaccineRecord(
      id: uuid.v4(),
      childId: childId,
      vaccineId: vaccineId,
      givenDate: _selectedDueDate!,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sideEffectsNoted: null,
    );

    await provider.addVaccineRecord(record);
  }

  /// Save supplement record (for now, we'll use notes to track supplements)
  Future<void> _saveSupplementRecord(ChildProvider provider, String childId) async {
    const uuid = Uuid();
    final databaseService = DatabaseService();

    final supplementName = _nameController.text.trim();
    final vaccineId = 'supplement_${uuid.v4()}';

    // Create supplement vaccine entry in database
    final supplementVaccine = Vaccine(
      id: vaccineId,
      name: supplementName,
      nameLocal: supplementName,
      description: 'Supplement: $supplementName',
      recommendedAgeMonths: provider.calculateAgeInMonths(provider.selectedChild!.birthDate),
      isMandatory: false,
      category: 'Supplement',
    );

    await databaseService.insertVaccine(supplementVaccine);

    final record = VaccineRecord(
      id: uuid.v4(),
      childId: childId,
      vaccineId: vaccineId,
      givenDate: _selectedDueDate!,
      notes: 'Supplement: $supplementName${_notesController.text.trim().isNotEmpty ? ' - ${_notesController.text.trim()}' : ''}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sideEffectsNoted: null,
    );

    await provider.addVaccineRecord(record);
  }

  /// Save medicine record (similar to supplement)
  Future<void> _saveMedicineRecord(ChildProvider provider, String childId) async {
    const uuid = Uuid();
    final databaseService = DatabaseService();

    final medicineName = _nameController.text.trim();
    final vaccineId = 'medicine_${uuid.v4()}';

    // Create medicine vaccine entry in database
    final medicineVaccine = Vaccine(
      id: vaccineId,
      name: medicineName,
      nameLocal: medicineName,
      description: 'Medicine: $medicineName',
      recommendedAgeMonths: provider.calculateAgeInMonths(provider.selectedChild!.birthDate),
      isMandatory: false,
      category: 'Medicine',
    );

    await databaseService.insertVaccine(medicineVaccine);

    final record = VaccineRecord(
      id: uuid.v4(),
      childId: childId,
      vaccineId: vaccineId,
      givenDate: _selectedDueDate!,
      notes: 'Medicine: $medicineName${_notesController.text.trim().isNotEmpty ? ' - ${_notesController.text.trim()}' : ''}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sideEffectsNoted: null,
    );

    await provider.addVaccineRecord(record);
  }

  /// Show message using SnackBar
  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      // If SnackBar fails, just print to console
      print('Message: $message');
    }
  }

  /// Show success message and navigate back
  void _showMessageAndNavigateBack(String message, {required bool isError}) {
    if (!mounted) return;

    // Show message first
    _showMessage(message, isError: isError);

    // Small delay to ensure snackbar is shown, then navigate
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _navigateBack();
      }
    });
  }

  void _navigateBack() {
    if (!mounted) return;

    try {
      // Check if we can pop with GoRouter first
      if (GoRouter.of(context).canPop()) {
        context.pop(true); // Return success result
        return;
      }

      // If GoRouter can't pop, check Navigator
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true); // Return success result
        return;
      }

      // If neither can pop, navigate to home using go
      context.go('/');
    } catch (e) {
      // Final fallback - use go to navigate to home
      try {
        if (mounted) {
          context.go('/');
        }
      } catch (finalError) {
        // Log error but don't crash
        if (kDebugMode) {
          print('Navigation fallback failed: $finalError');
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();
    final provider = Provider.of<ChildProvider>(context);

    return PopScope(
      canPop: !_isLoading,
      onPopInvoked: (didPop) {
        if (!didPop && _isLoading) {
          // Prevent back navigation while saving
          _showMessage('Please wait while saving...', isError: false);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: _isLoading ? null : () {
            if (!_isLoading) {
              _navigateBack();
            }
          },
        ),
        title: Text(
          texts['title']!,
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildSelector(provider, texts),
            const SizedBox(height: 24),
            _buildTypeSelector(texts),
            const SizedBox(height: 24),
            _buildNameField(texts),
            const SizedBox(height: 24),
            _buildDueDateField(texts),
            const SizedBox(height: 24),
            _buildNotesField(texts),
            const SizedBox(height: 24),
            _buildReminderSection(texts),
            const SizedBox(height: 24),
            _buildPhotoSection(texts),
            const SizedBox(height: 32),
            _buildActionButtons(texts),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    );
  }

  /// Build child selector
  Widget _buildChildSelector(ChildProvider provider, Map<String, String> texts) {
    final selectedChild = provider.selectedChild;
    
    return GestureDetector(
      onTap: () => _showChildSelectionDialog(provider, texts),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0086FF).withValues(alpha: 0.1),
              backgroundImage: selectedChild?.photoUrl != null && selectedChild!.photoUrl!.isNotEmpty
                  ? (selectedChild!.photoUrl!.startsWith('http')
                      ? NetworkImage(selectedChild.photoUrl!) as ImageProvider
                      : FileImage(File(selectedChild.photoUrl!)))
                  : null,
              child: selectedChild?.photoUrl == null || selectedChild!.photoUrl!.isEmpty
                  ? (selectedChild != null
                      ? Text(
                          selectedChild.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0086FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : const Icon(Icons.person, color: Color(0xFF0086FF)))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texts['currentChild']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        selectedChild?.name ?? 'No child selected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more, color: Color(0xFF6B7280), size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show child selection dialog
  void _showChildSelectionDialog(ChildProvider provider, Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          texts['selectChild'] ?? 'Select Child',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.children.length,
            itemBuilder: (context, index) {
              final child = provider.children[index];
              final isSelected = child.id == provider.selectedChild?.id;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected 
                      ? const Color(0xFF0086FF) 
                      : const Color(0xFF0086FF).withValues(alpha: 0.1),
                  backgroundImage: child.photoUrl != null && child.photoUrl!.isNotEmpty
                      ? (child.photoUrl!.startsWith('http')
                          ? NetworkImage(child.photoUrl!) as ImageProvider
                          : FileImage(File(child.photoUrl!)))
                      : null,
                  child: child.photoUrl == null || child.photoUrl!.isEmpty
                      ? Text(
                          child.name[0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF0086FF),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  child.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                subtitle: Text(
                  provider.getAgeString(child.birthDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Color(0xFF0086FF))
                    : null,
                onTap: () {
                  provider.selectChild(child);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              texts['cancel'] ?? 'Cancel',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build type selector with inline chips
  Widget _buildTypeSelector(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['type']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        // Always show inline horizontal layout
        Row(
          children: HealthRecordType.values.map((type) {
            final isSelected = _selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != HealthRecordType.values.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() => _selectedType = type);
                    }
                  },
                  child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0086FF).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0086FF)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type.icon,
                            color: isSelected
                                ? const Color(0xFF0086FF)
                                : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              texts[type.name]!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF0086FF)
                                    : const Color(0xFF6B7280),
                                fontFamily: _selectedLanguage == 'si'
                                    ? 'NotoSerifSinhala'
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build name field with autocomplete
  Widget _buildNameField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['name']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return _getAutocompleteOptions().where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _nameController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _nameController.text = controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: texts['nameHint']!,
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
                suffixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0086FF), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                        onTap: () => onSelected(option),
                        dense: true,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build due date field
  Widget _buildDueDateField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['dueDate']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dueDateController,
          readOnly: true,
          onTap: _selectDueDate,
          decoration: InputDecoration(
            hintText: 'mm/dd/yyyy',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFF6B7280), size: 20),
                const SizedBox(width: 12),
                Icon(Icons.schedule, color: const Color(0xFF6B7280), size: 20),
                const SizedBox(width: 12),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0086FF), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  /// Build notes field
  Widget _buildNotesField(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['notes']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: texts['notesHint']!,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0086FF), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// Build reminder section
  Widget _buildReminderSection(Map<String, String> texts) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts['setReminder']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            Switch.adaptive(
              value: _setReminder,
              onChanged: (value) => setState(() => _setReminder = value),
              activeTrackColor: const Color(0xFF0086FF),
            ),
          ],
        ),
        if (_setReminder) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      texts['reminderTime']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectReminderTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _reminderTimeController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time, size: 18, color: Color(0xFF6B7280)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      texts['repeat']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    DropdownButton<ReminderRepeat>(
                      value: _reminderRepeat,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                      items: ReminderRepeat.values.map((repeat) => DropdownMenuItem(
                        value: repeat,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            texts[repeat.name]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A1A),
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                            ),
                          ),
                        ),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _reminderRepeat = value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build photo section
  Widget _buildPhotoSection(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['addPhoto']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        texts['photoHint']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(Map<String, String> texts) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () {
              if (mounted) {
                try {
                  Navigator.of(context).pop();
                } catch (e) {
                  context.pop();
                }
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _isLoading ? null : _saveRecord,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0086FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    texts['saveRecord']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Add Health Record',
        'currentChild': 'Current Child',
        'selectChild': 'Select Child',
        'type': 'Type',
        'vaccine': 'Vaccine',
        'supplement': 'Supplement',
        'medicine': 'Medicine',
        'name': 'Name',
        'nameHint': 'Start typing to search...',
        'dueDate': 'Due Date',
        'notes': 'Notes',
        'notesHint': 'Add any additional information about the medication or vaccine...',
        'setReminder': 'Set Reminder',
        'reminderTime': 'Reminder Time',
        'repeat': 'Repeat',
        'once': 'Once',
        'daily': 'Daily',
        'weekly': 'Weekly',
        'monthly': 'Monthly',
        'addPhoto': 'Add Photo (Optional)',
        'photoHint': 'Tap to upload a photo of the medication or prescription',
        'cancel': 'Cancel',
        'saveRecord': 'Save Record',
      },
      'si': {
        'title': 'සෞඛ්‍ය වාර්තාව එක් කරන්න',
        'currentChild': 'වත්මන් දරුවා',
        'selectChild': 'දරුවා තෝරන්න',
        'type': 'වර්ගය',
        'vaccine': 'එන්නත',
        'supplement': 'පරිපූරක',
        'medicine': 'ඖෂධ',
        'name': 'නම',
        'nameHint': 'සෙවීමට ටයිප් කිරීම ආරම්භ කරන්න...',
        'dueDate': 'නියමිත දිනය',
        'notes': 'සටහන්',
        'notesHint': 'ඖෂධය හෝ එන්නත් ගැන අමතර තොරතුරු එක් කරන්න...',
        'setReminder': 'සිහිකැඳවීම සකසන්න',
        'reminderTime': 'සිහිකැඳවීමේ වේලාව',
        'repeat': 'නැවත කරන්න',
        'once': 'වරක්',
        'daily': 'දිනපතා',
        'weekly': 'සතිපතා',
        'monthly': 'මාසිකව',
        'addPhoto': 'ඡායාරූපය එක් කරන්න (විකල්ප)',
        'photoHint': 'ඖෂධයේ හෝ වට්ටෝරුවේ ඡායාරූපයක් උඩුගත කිරීමට තට්ටු කරන්න',
        'cancel': 'අවලංගු කරන්න',
        'saveRecord': 'වාර්තාව සුරකින්න',
      },
      'ta': {
        'title': 'சுகாதார பதிவு சேர்க்க',
        'currentChild': 'தற்போதைய குழந்தை',
        'selectChild': 'குழந்தையை தேர்ந்தெடுக்கவும்',
        'type': 'வகை',
        'vaccine': 'தடுப்பூசி',
        'supplement': 'சப்ளிமெண்ட்',
        'medicine': 'மருந்து',
        'name': 'பெயர்',
        'nameHint': 'தேட தட்டச்சு செய்யத் தொடங்குங்கள்...',
        'dueDate': 'நிலுவை தேதி',
        'notes': 'குறிப்புகள்',
        'notesHint': 'மருந்து அல்லது தடுப்பூசி பற்றிய கூடுதல் தகவல்களை சேர்க்கவும்...',
        'setReminder': 'நினைவூட்டல் அமைக்க',
        'reminderTime': 'நினைவூட்டல் நேரம்',
        'repeat': 'மீண்டும்',
        'once': 'ஒருமுறை',
        'daily': 'தினசரி',
        'weekly': 'வாராந்தर',
        'monthly': 'மாதாந்தர',
        'addPhoto': 'புகைப்படம் சேர்க்க (விருப்பமானது)',
        'photoHint': 'மருந்து அல்லது மருத்துவர் பரிந்துரையின் புகைப்படத்தை பதிவேற்ற தட்டவும்',
        'cancel': 'ரத்து செய்',
        'saveRecord': 'பதிவு சேமி',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }
}

/// Health record type enum
enum HealthRecordType {
  vaccine(Icons.vaccines, 'vaccine'),
  supplement(Icons.medication, 'supplement'),
  medicine(Icons.local_pharmacy, 'medicine');

  const HealthRecordType(this.icon, this.name);
  final IconData icon;
  final String name;
}

/// Reminder repeat enum
enum ReminderRepeat {
  once('once'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const ReminderRepeat(this.name);
  final String name;
}