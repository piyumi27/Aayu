import 'dart:convert';
import 'package:flutter/services.dart';

/// Service to load and manage vaccination schedules from assets
class VaccinationScheduleService {
  static final VaccinationScheduleService _instance = VaccinationScheduleService._internal();
  factory VaccinationScheduleService() => _instance;
  VaccinationScheduleService._internal();

  Map<String, dynamic>? _sriLankaSchedule;
  Map<String, dynamic>? _whoSchedule;

  /// Load vaccination schedules from assets
  Future<void> loadSchedules() async {
    try {
      // Load Sri Lanka schedule
      final sriLankaJson = await rootBundle.loadString('assets/data/SriLanka.json');
      _sriLankaSchedule = json.decode(sriLankaJson);

      // Load WHO schedule
      final whoJson = await rootBundle.loadString('assets/data/WHO.json');
      _whoSchedule = json.decode(whoJson);

      print('✅ Vaccination schedules loaded successfully');
    } catch (e) {
      print('❌ Error loading vaccination schedules: $e');
    }
  }

  /// Get vaccination schedule for a child based on age in months
  List<VaccineScheduleItem> getVaccinesForAge(int ageInMonths, {bool useSriLankaSchedule = true}) {
    final schedule = useSriLankaSchedule ? _sriLankaSchedule : _whoSchedule;
    if (schedule == null) return [];

    final List<VaccineScheduleItem> vaccines = [];
    final vaccineSchedule = schedule['national_immunization_schedule']?['current_schedule_2025'] ??
                           schedule['vaccination_schedule'];

    if (vaccineSchedule == null) return vaccines;

    // Convert age in months to appropriate schedule keys
    for (final entry in vaccineSchedule.entries) {
      final ageKey = entry.key as String;
      final ageInMonthsFromKey = _parseAgeFromKey(ageKey);

      if (ageInMonthsFromKey != null && ageInMonthsFromKey <= ageInMonths + 3) {
        final vaccinesAtAge = entry.value as Map<String, dynamic>;

        for (final vaccineEntry in vaccinesAtAge.entries) {
          final vaccineName = vaccineEntry.key;
          final vaccineData = vaccineEntry.value as Map<String, dynamic>;

          vaccines.add(VaccineScheduleItem(
            name: _formatVaccineName(vaccineName),
            ageInMonths: ageInMonthsFromKey,
            timing: vaccineData['timing'] ?? '',
            components: vaccineData['components'] as List<dynamic>? ?? [],
            isOverdue: ageInMonthsFromKey < ageInMonths - 1,
            isDue: ageInMonthsFromKey >= ageInMonths - 1 && ageInMonthsFromKey <= ageInMonths + 1,
            isUpcoming: ageInMonthsFromKey > ageInMonths + 1,
          ));
        }
      }
    }

    // Sort by age
    vaccines.sort((a, b) => a.ageInMonths.compareTo(b.ageInMonths));
    return vaccines;
  }

  /// Get upcoming vaccines for a child (next 3 months)
  List<VaccineScheduleItem> getUpcomingVaccines(int ageInMonths, {bool useSriLankaSchedule = true}) {
    final allVaccines = getVaccinesForAge(ageInMonths + 3, useSriLankaSchedule: useSriLankaSchedule);
    return allVaccines.where((v) => v.ageInMonths > ageInMonths).take(5).toList();
  }

  /// Get overdue vaccines for a child
  List<VaccineScheduleItem> getOverdueVaccines(int ageInMonths, {bool useSriLankaSchedule = true}) {
    final allVaccines = getVaccinesForAge(ageInMonths, useSriLankaSchedule: useSriLankaSchedule);
    return allVaccines.where((v) => v.isOverdue).toList();
  }

  /// Parse age from schedule key (e.g., "2_months" -> 2, "18_months" -> 18, "birth" -> 0)
  int? _parseAgeFromKey(String key) {
    switch (key.toLowerCase()) {
      case 'birth':
        return 0;
      case '6_weeks':
        return 1; // Approximately 1.5 months
      case '10_weeks':
        return 2; // Approximately 2.5 months
      case '14_weeks':
        return 3; // Approximately 3.5 months
      case '2_months':
        return 2;
      case '4_months':
        return 4;
      case '6_months':
        return 6;
      case '9_months':
        return 9;
      case '12_months':
        return 12;
      case '15_18_months':
        return 15;
      case '18_months':
        return 18;
      case '3_years':
        return 36;
      case '4_6_years':
        return 48;
      default:
        // Try to extract number from string like "2_months"
        final match = RegExp(r'(\d+)_months?').firstMatch(key);
        if (match != null) {
          return int.tryParse(match.group(1)!);
        }
        // Try to extract years like "3_years"
        final yearMatch = RegExp(r'(\d+)_years?').firstMatch(key);
        if (yearMatch != null) {
          return int.tryParse(yearMatch.group(1)!) != null
              ? int.parse(yearMatch.group(1)!) * 12
              : null;
        }
        return null;
    }
  }

  /// Format vaccine name for display
  String _formatVaccineName(String name) {
    switch (name.toLowerCase()) {
      case 'bcg':
        return 'BCG';
      case 'pentavalent_1':
        return 'Pentavalent (1st dose)';
      case 'pentavalent_2':
        return 'Pentavalent (2nd dose)';
      case 'pentavalent_3':
        return 'Pentavalent (3rd dose)';
      case 'opv_1':
        return 'OPV (1st dose)';
      case 'opv_2':
        return 'OPV (2nd dose)';
      case 'opv_3':
        return 'OPV (3rd dose)';
      case 'opv_4':
        return 'OPV (4th dose)';
      case 'fipv_1':
        return 'IPV (1st dose)';
      case 'fipv_2':
        return 'IPV (2nd dose)';
      case 'live_je':
        return 'Japanese Encephalitis';
      case 'mmr_1':
        return 'MMR (1st dose)';
      case 'mmr_2':
        return 'MMR (2nd dose)';
      case 'dtp_4':
        return 'DTP (4th dose)';
      case 'hepatitis_b':
        return 'Hepatitis B';
      case 'dpt1':
      case 'dpt2':
      case 'dpt3':
        return name.toUpperCase();
      case 'hib1':
      case 'hib2':
      case 'hib3':
        return name.substring(0, 3).toUpperCase() + ' (' + name.substring(3) + ')';
      default:
        return name.replaceAll('_', ' ').split(' ').map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }
}

/// Model for vaccine schedule item
class VaccineScheduleItem {
  final String name;
  final int ageInMonths;
  final String timing;
  final List<dynamic> components;
  final bool isOverdue;
  final bool isDue;
  final bool isUpcoming;

  VaccineScheduleItem({
    required this.name,
    required this.ageInMonths,
    required this.timing,
    required this.components,
    required this.isOverdue,
    required this.isDue,
    required this.isUpcoming,
  });

  /// Get age string for display (e.g., "2 months", "3 years")
  String get ageString {
    if (ageInMonths == 0) return 'Birth';
    if (ageInMonths < 12) return '$ageInMonths month${ageInMonths != 1 ? 's' : ''}';

    final years = ageInMonths ~/ 12;
    final remainingMonths = ageInMonths % 12;

    if (remainingMonths == 0) {
      return '$years year${years != 1 ? 's' : ''}';
    } else {
      return '$years year${years != 1 ? 's' : ''} $remainingMonths month${remainingMonths != 1 ? 's' : ''}';
    }
  }

  /// Get status for UI display
  VaccineScheduleStatus get status {
    if (isOverdue) return VaccineScheduleStatus.overdue;
    if (isDue) return VaccineScheduleStatus.due;
    return VaccineScheduleStatus.upcoming;
  }
}

/// Status enum for vaccine schedule items
enum VaccineScheduleStatus {
  overdue,
  due,
  upcoming,
}