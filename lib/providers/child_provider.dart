import 'package:flutter/foundation.dart';
import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/vaccine.dart';
import '../models/medication.dart';
import '../services/database_service.dart';
import '../services/medication_service.dart';
import '../services/notifications/scheduling_engine.dart';

class ChildProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationSchedulingEngine _schedulingEngine = NotificationSchedulingEngine();
  final MedicationService _medicationService = MedicationService();
  
  List<Child> _children = [];
  Child? _selectedChild;
  List<GrowthRecord> _growthRecords = [];
  List<VaccineRecord> _vaccineRecords = [];
  List<Vaccine> _vaccines = [];
  List<Medication> _medications = [];
  
  List<Child> get children => _children;
  Child? get selectedChild => _selectedChild;
  List<GrowthRecord> get growthRecords => _growthRecords;
  List<VaccineRecord> get vaccineRecords => _vaccineRecords;
  List<Vaccine> get vaccines => _vaccines;
  List<Medication> get medications => _medications;

  Future<void> loadChildren() async {
    _children = await _databaseService.getChildren();
    if (_children.isNotEmpty && _selectedChild == null) {
      _selectedChild = _children.first;
      await loadChildData(_selectedChild!.id);
    }
    notifyListeners();
  }

  Future<void> loadChildData(String childId) async {
    _growthRecords = await _databaseService.getGrowthRecords(childId);
    _vaccineRecords = await _databaseService.getVaccineRecords(childId);
    notifyListeners();
  }

  Future<void> loadVaccines() async {
    _vaccines = await _databaseService.getVaccines();
    notifyListeners();
  }

  Future<void> loadMedications() async {
    await _medicationService.initialize();
    _medications = _medicationService.medications;
    notifyListeners();
  }

  Future<void> addChild(Child child) async {
    await _databaseService.insertChild(child);
    await loadChildren();
    
    // Schedule notifications for the new child
    try {
      await _schedulingEngine.scheduleNotificationsForChild(child);
      if (kDebugMode) {
        print('✅ Notifications scheduled for child: ${child.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule notifications for ${child.name}: $e');
      }
    }
  }

  Future<void> updateChild(Child child) async {
    await _databaseService.updateChild(child);
    await loadChildren();
    
    // Reschedule notifications for the updated child
    try {
      await _schedulingEngine.scheduleNotificationsForChild(child);
      if (kDebugMode) {
        print('✅ Notifications rescheduled for child: ${child.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to reschedule notifications for ${child.name}: $e');
      }
    }
  }

  Future<void> selectChild(Child child) async {
    _selectedChild = child;
    await loadChildData(child.id);
    notifyListeners();
  }

  Future<void> addGrowthRecord(GrowthRecord record) async {
    await _databaseService.insertGrowthRecord(record);
    if (_selectedChild != null) {
      await loadChildData(_selectedChild!.id);
    }
  }

  Future<void> addVaccineRecord(VaccineRecord record) async {
    await _databaseService.insertVaccineRecord(record);
    if (_selectedChild != null) {
      await loadChildData(_selectedChild!.id);
    }
  }

  int calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  String getAgeString(DateTime birthDate) {
    final months = calculateAgeInMonths(birthDate);
    if (months < 12) {
      return '$months month${months != 1 ? 's' : ''}';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      String result = '$years year${years != 1 ? 's' : ''}';
      if (remainingMonths > 0) {
        result += ' $remainingMonths month${remainingMonths != 1 ? 's' : ''}';
      }
      return result;
    }
  }

  List<Vaccine> getUpcomingVaccines() {
    if (_selectedChild == null) return [];
    
    final ageInMonths = calculateAgeInMonths(_selectedChild!.birthDate);
    final givenVaccineIds = _vaccineRecords.map((r) => r.vaccineId).toSet();
    
    return _vaccines.where((vaccine) {
      return !givenVaccineIds.contains(vaccine.id) &&
             vaccine.recommendedAgeMonths <= ageInMonths + 3;
    }).toList();
  }

  List<Vaccine> getOverdueVaccines() {
    if (_selectedChild == null) return [];
    
    final ageInMonths = calculateAgeInMonths(_selectedChild!.birthDate);
    final givenVaccineIds = _vaccineRecords.map((r) => r.vaccineId).toSet();
    
    return _vaccines.where((vaccine) {
      return !givenVaccineIds.contains(vaccine.id) &&
             vaccine.recommendedAgeMonths < ageInMonths;
    }).toList();
  }

  List<Medication> getMedicationsByType(MedicationType type) {
    return _medications.where((med) => med.type == type).toList();
  }

  List<Medication> getMedicationsByCategory(String category) {
    // Since Medication doesn't have a category field, filter by type name
    // or by indication/description containing the category
    return _medications.where((med) => 
        med.type.name.contains(category.toLowerCase()) ||
        (med.indication?.toLowerCase().contains(category.toLowerCase()) ?? false) ||
        med.description.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }

  List<Medication> searchMedications(String query) {
    final lowerQuery = query.toLowerCase();
    return _medications.where((med) =>
        med.name.toLowerCase().contains(lowerQuery) ||
        med.nameLocal.toLowerCase().contains(lowerQuery) ||
        med.type.name.toLowerCase().contains(lowerQuery) ||
        (med.genericName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (med.indication?.toLowerCase().contains(lowerQuery) ?? false) ||
        med.description.toLowerCase().contains(lowerQuery)).toList();
  }
}