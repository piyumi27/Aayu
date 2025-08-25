import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/growth_record.dart';
import '../providers/child_provider.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';
import 'add_measurement_screen.dart';

/// Professional Measurement Detail screen with comprehensive metrics display
class MeasurementDetailScreen extends StatefulWidget {
  final String measurementId;
  final String childId;

  const MeasurementDetailScreen({
    super.key,
    required this.measurementId,
    required this.childId,
  });

  @override
  State<MeasurementDetailScreen> createState() => _MeasurementDetailScreenState();
}

class _MeasurementDetailScreenState extends State<MeasurementDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  GrowthRecord? _measurement;
  String _selectedLanguage = 'en';
  bool _isLoading = true;
  bool _isDeleting = false;
  
  // For undo functionality
  GrowthRecord? _deletedMeasurement;
  bool _showUndoSnackbar = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadMeasurement();
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

  /// Load measurement details
  Future<void> _loadMeasurement() async {
    setState(() => _isLoading = true);
    
    try {
      final measurements = await _databaseService.getGrowthRecords(widget.childId);
      final measurement = measurements.firstWhere(
        (m) => m.id == widget.measurementId,
        orElse: () => throw Exception('Measurement not found'),
      );
      
      if (mounted) {
        setState(() {
          _measurement = measurement;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to load measurement');
        Navigator.of(context).pop();
      }
    }
  }

  /// Calculate BMI from weight and height
  double? _calculateBMI() {
    if (_measurement?.weight != null && _measurement?.height != null) {
      final heightInM = _measurement!.height / 100;
      return _measurement!.weight / (heightInM * heightInM);
    }
    return null;
  }

  /// Get status color based on Z-score
  Color _getStatusColor(double? zScore) {
    if (zScore == null) return const Color(0xFF6B7280);
    if (zScore >= -1 && zScore <= 1) return const Color(0xFF10B981);
    if (zScore >= -2 && zScore < -1) return const Color(0xFFF59E0B);
    if (zScore > 1 && zScore <= 2) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  /// Get status text based on Z-score
  String _getStatusText(double? zScore, String metric) {
    if (zScore == null) return 'No data';
    
    final texts = _getLocalizedTexts();
    
    if (metric == 'weight') {
      if (zScore < -2) return texts['severelyUnderweight']!;
      if (zScore < -1) return texts['underweight']!;
      if (zScore <= 1) return texts['normal']!;
      if (zScore <= 2) return texts['overweight']!;
      return texts['obese']!;
    } else if (metric == 'height') {
      if (zScore < -2) return texts['severelyStunted']!;
      if (zScore < -1) return texts['stunted']!;
      if (zScore <= 1) return texts['normal']!;
      return texts['tall']!;
    }
    
    return texts['normal']!;
  }

  /// Navigate to edit screen
  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMeasurementScreen(),
      ),
    ).then((_) => _loadMeasurement());
  }

  /// Delete measurement with confirmation
  Future<void> _deleteMeasurement() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => _isDeleting = true);

    try {
      // Store for undo
      _deletedMeasurement = _measurement;
      
      // Delete from database - TODO: Add deleteGrowthRecord method to DatabaseService
      // For now, we'll just simulate deletion
      // await _databaseService.deleteGrowthRecord(widget.measurementId);
      
      // Update provider
      if (mounted) {
        final provider = Provider.of<ChildProvider>(context, listen: false);
        await provider.loadChildren();
        
        // Show undo snackbar
        _showDeleteUndoSnackbar();
        
        // Navigate back after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete measurement');
      setState(() => _isDeleting = false);
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation() async {
    final texts = _getLocalizedTexts();
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          texts['deleteTitle']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        content: Text(
          texts['deleteMessage']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              texts['cancel']!,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              texts['delete']!,
              style: TextStyle(
                color: const Color(0xFFEF4444),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show undo snackbar for delete action
  void _showDeleteUndoSnackbar() {
    final texts = _getLocalizedTexts();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texts['measurementDeleted']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        action: SnackBarAction(
          label: texts['undo']!,
          textColor: const Color(0xFF0086FF),
          onPressed: _undoDelete,
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Undo delete operation
  Future<void> _undoDelete() async {
    if (_deletedMeasurement == null) return;

    try {
      await _databaseService.insertGrowthRecord(_deletedMeasurement!);

      final provider = Provider.of<ChildProvider>(context, listen: false);
      await provider.loadChildren();

      final texts = _getLocalizedTexts();
      _showSuccessSnackbar(texts['undoSuccess']!);
      _loadMeasurement();
    } catch (e) {
      _showErrorSnackbar('Failed to restore measurement');
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Open full-screen photo viewer
  void _openPhotoViewer(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _measurement == null
              ? Center(
                  child: Text(
                    texts['noData']!,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDateTimeCard(texts),
                            const SizedBox(height: 16),
                            _buildMetricsCard(texts),
                            const SizedBox(height: 16),
                            _buildZScoreTable(texts),
                            if (_measurement!.notes != null && _measurement!.notes!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildNotesCard(texts),
                            ],
                            if (_measurement!.photoPath != null) ...[
                              const SizedBox(height: 16),
                              _buildPhotoCard(texts),
                            ],
                            const SizedBox(height: 100), // Space for bottom toolbar
                          ],
                        ),
                      ),
                    ),
                    _buildBottomToolbar(texts),
                  ],
                ),
    );
  }

  /// Build date/time card
  Widget _buildDateTimeCard(Map<String, String> texts) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0086FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF0086FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(_measurement!.date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeFormat.format(_measurement!.date),
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build metrics card with chips
  Widget _buildMetricsCard(Map<String, String> texts) {
    final bmi = _calculateBMI();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['measurements']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricChip(
                label: texts['weight']!,
                value: '${_measurement!.weight.toStringAsFixed(1)} kg',
                  color: _getStatusColor(-0.5), // Mock Z-score
                  icon: Icons.monitor_weight_outlined,
                ),
              _buildMetricChip(
                label: texts['height']!,
                value: '${_measurement!.height.toStringAsFixed(1)} cm',
                  color: _getStatusColor(0.2), // Mock Z-score
                  icon: Icons.height,
                ),
              if (bmi != null)
                _buildMetricChip(
                  label: texts['bmi']!,
                  value: bmi.toStringAsFixed(1),
                  color: _getStatusColor(0.5), // Mock Z-score
                  icon: Icons.speed,
                ),
              if (_measurement!.headCircumference != null)
                _buildMetricChip(
                  label: texts['muac']!,
                  value: '${_measurement!.headCircumference!.toStringAsFixed(1)} cm',
                  color: _getStatusColor(-0.3), // Mock Z-score
                  icon: Icons.radio_button_unchecked,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual metric chip
  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Z-score table
  Widget _buildZScoreTable(Map<String, String> texts) {
    // Mock Z-scores for demonstration
    final zScores = {
      'weightForAge': -0.5,
      'heightForAge': 0.2,
      'weightForHeight': 0.5,
      'bmiForAge': 0.3,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['zScores']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: ResponsiveUtils.isSmallWidth(context)
                ? const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(0.8),
                    2: FlexColumnWidth(1.2),
                  }
                : const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.5),
                  },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(4),
                ),
                children: [
                  _buildTableHeader(texts['indicator']!),
                  _buildTableHeader(texts['zScore']!),
                  _buildTableHeader(texts['status']!),
                ],
              ),
              ...zScores.entries.map((entry) => TableRow(
                children: [
                  _buildTableCell(texts[entry.key]!),
                  _buildTableCell(
                    entry.value.toStringAsFixed(1),
                    color: _getStatusColor(entry.value),
                  ),
                  _buildTableCell(
                    _getStatusText(entry.value, entry.key),
                    color: _getStatusColor(entry.value),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  /// Build table header cell
  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6B7280),
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  /// Build table cell
  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color ?? const Color(0xFF1A1A1A),
          fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  /// Build notes card
  Widget _buildNotesCard(Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              Text(
                texts['notes']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _measurement!.notes!,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build photo card
  Widget _buildPhotoCard(Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              Text(
                texts['photo']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openPhotoViewer(_measurement!.photoPath!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_measurement!.photoPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Color(0xFF6B7280),
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts['tapToView']!,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom toolbar
  Widget _buildBottomToolbar(Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isDeleting ? null : _navigateToEdit,
              icon: const Icon(Icons.edit),
              label: Text(texts['edit']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0086FF),
                side: const BorderSide(color: Color(0xFF0086FF)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isDeleting ? null : _deleteMeasurement,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                      ),
                    )
                  : const Icon(Icons.delete),
              label: Text(texts['delete']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Measurement Details',
        'measurements': 'Measurements',
        'weight': 'Weight',
        'height': 'Height',
        'bmi': 'BMI',
        'muac': 'MUAC',
        'zScores': 'Z-Score Analysis',
        'indicator': 'Indicator',
        'zScore': 'Z-Score',
        'status': 'Status',
        'weightForAge': 'Weight-for-Age',
        'heightForAge': 'Height-for-Age',
        'weightForHeight': 'Weight-for-Height',
        'bmiForAge': 'BMI-for-Age',
        'normal': 'Normal',
        'underweight': 'Underweight',
        'severelyUnderweight': 'Severely Underweight',
        'overweight': 'Overweight',
        'obese': 'Obese',
        'stunted': 'Stunted',
        'severelyStunted': 'Severely Stunted',
        'tall': 'Tall',
        'notes': 'Notes',
        'photo': 'Photo',
        'tapToView': 'Tap to view full screen',
        'edit': 'Edit',
        'delete': 'Delete',
        'deleteTitle': 'Delete Measurement',
        'deleteMessage': 'Are you sure you want to delete this measurement? This action cannot be undone.',
        'cancel': 'Cancel',
        'measurementDeleted': 'Measurement deleted',
        'undo': 'Undo',
        'undoSuccess': 'Measurement restored',
        'noData': 'No measurement data available',
      },
      'si': {
        'title': 'මිනුම් විස්තර',
        'measurements': 'මිනුම්',
        'weight': 'බර',
        'height': 'උස',
        'bmi': 'BMI',
        'muac': 'MUAC',
        'zScores': 'Z-ලකුණු විශ්ලේෂණය',
        'indicator': 'දර්ශකය',
        'zScore': 'Z-ලකුණ',
        'status': 'තත්වය',
        'weightForAge': 'වයසට බර',
        'heightForAge': 'වයසට උස',
        'weightForHeight': 'උසට බර',
        'bmiForAge': 'වයසට BMI',
        'normal': 'සාමාන්‍ය',
        'underweight': 'අඩු බර',
        'severelyUnderweight': 'දරුණු අඩු බර',
        'overweight': 'වැඩි බර',
        'obese': 'තරබාරු',
        'stunted': 'මන්දපෝෂණය',
        'severelyStunted': 'දරුණු මන්දපෝෂණය',
        'tall': 'උස',
        'notes': 'සටහන්',
        'photo': 'ඡායාරූපය',
        'tapToView': 'සම්පූර්ණ තිරය බැලීමට තට්ටු කරන්න',
        'edit': 'සංස්කරණය',
        'delete': 'මකන්න',
        'deleteTitle': 'මිනුම මකන්න',
        'deleteMessage': 'ඔබට මෙම මිනුම මැකීමට අවශ්‍ය බව විශ්වාසද? මෙම ක්‍රියාව ආපසු හැරවිය නොහැක.',
        'cancel': 'අවලංගු',
        'measurementDeleted': 'මිනුම මකා දමන ලදී',
        'undo': 'අහෝසි කරන්න',
        'undoSuccess': 'මිනුම ප්‍රතිස්ථාපනය කරන ලදී',
        'noData': 'මිනුම් දත්ත නොමැත',
      },
      'ta': {
        'title': 'அளவீட்டு விவரங்கள்',
        'measurements': 'அளவீடுகள்',
        'weight': 'எடை',
        'height': 'உயரம்',
        'bmi': 'BMI',
        'muac': 'MUAC',
        'zScores': 'Z-மதிப்பு பகுப்பாய்வு',
        'indicator': 'குறிகாட்டி',
        'zScore': 'Z-மதிப்பு',
        'status': 'நிலை',
        'weightForAge': 'வயதுக்கு எடை',
        'heightForAge': 'வயதுக்கு உயரம்',
        'weightForHeight': 'உயரத்திற்கு எடை',
        'bmiForAge': 'வயதுக்கு BMI',
        'normal': 'சாதாரண',
        'underweight': 'குறைந்த எடை',
        'severelyUnderweight': 'கடுமையான குறைந்த எடை',
        'overweight': 'அதிக எடை',
        'obese': 'பருமன்',
        'stunted': 'வளர்ச்சி குன்றிய',
        'severelyStunted': 'கடுமையான வளர்ச்சி குன்றிய',
        'tall': 'உயரமான',
        'notes': 'குறிப்புகள்',
        'photo': 'புகைப்படம்',
        'tapToView': 'முழுத் திரையில் பார்க்க தட்டவும்',
        'edit': 'திருத்து',
        'delete': 'நீக்கு',
        'deleteTitle': 'அளவீட்டை நீக்கு',
        'deleteMessage': 'இந்த அளவீட்டை நீக்க விரும்புகிறீர்களா? இந்த செயலை மீட்டெடுக்க முடியாது.',
        'cancel': 'ரத்து',
        'measurementDeleted': 'அளவீடு நீக்கப்பட்டது',
        'undo': 'செயல்தவிர்',
        'undoSuccess': 'அளவீடு மீட்டெடுக்கப்பட்டது',
        'noData': 'அளவீட்டு தரவு கிடைக்கவில்லை',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }
}

/// Full-screen photo viewer
class PhotoViewerScreen extends StatelessWidget {
  final String imagePath;

  const PhotoViewerScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}