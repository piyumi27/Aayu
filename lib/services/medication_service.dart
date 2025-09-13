import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/medication.dart';
import 'database_service.dart';
import 'notification_service.dart';

/// Service for managing medications and supplements
class MedicationService extends ChangeNotifier {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Medication> _medications = [];
  List<MedicationDoseRecord> _doseRecords = [];

  List<Medication> get medications => List.unmodifiable(_medications);
  List<MedicationDoseRecord> get doseRecords => List.unmodifiable(_doseRecords);

  /// Initialize medication service
  Future<void> initialize() async {
    await _createTables();
    await loadMedications();
    await loadDoseRecords();
  }

  /// Create medication tables
  Future<void> _createTables() async {
    final db = await _databaseService.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        name TEXT NOT NULL,
        nameLocal TEXT NOT NULL,
        genericName TEXT,
        type INTEGER NOT NULL,
        description TEXT NOT NULL,
        dosage REAL NOT NULL,
        dosageUnit INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        customFrequencyHours INTEGER,
        startDate TEXT NOT NULL,
        endDate TEXT,
        status INTEGER NOT NULL,
        prescribedBy TEXT,
        indication TEXT,
        sideEffects TEXT,
        instructions TEXT,
        notes TEXT,
        isImportant INTEGER NOT NULL DEFAULT 0,
        reminderSound TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_dose_records (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        medicationId TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        actualTime TEXT,
        actualDosage REAL,
        isTaken INTEGER NOT NULL DEFAULT 0,
        isSkipped INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        sideEffectsNoted TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE,
        FOREIGN KEY (medicationId) REFERENCES medications (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_child ON medications(childId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_dose_records_medication ON medication_dose_records(medicationId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_dose_records_scheduled ON medication_dose_records(scheduledTime)');
  }

  /// Load all medications from database
  Future<void> loadMedications() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medications',
        orderBy: 'createdAt DESC',
      );

      _medications = maps.map((map) => Medication.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading medications: $e');
    }
  }

  /// Load all dose records from database
  Future<void> loadDoseRecords() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medication_dose_records',
        orderBy: 'scheduledTime DESC',
      );

      _doseRecords =
          maps.map((map) => MedicationDoseRecord.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading dose records: $e');
    }
  }

  /// Get medications for a specific child
  List<Medication> getMedicationsForChild(String childId) {
    return _medications.where((med) => med.childId == childId).toList();
  }

  /// Get active medications for a specific child
  List<Medication> getActiveMedicationsForChild(String childId) {
    return _medications
        .where((med) => med.childId == childId && med.isActive)
        .toList();
  }

  /// Get medications by status
  List<Medication> getMedicationsByStatus(
      String childId, MedicationStatus status) {
    return _medications
        .where((med) => med.childId == childId && med.status == status)
        .toList();
  }

  /// Get medications by type
  List<Medication> getMedicationsByType(String childId, MedicationType type) {
    return _medications
        .where((med) => med.childId == childId && med.type == type)
        .toList();
  }

  /// Get overdue medications for a child
  List<Medication> getOverdueMedications(String childId) {
    final activeMeds = getActiveMedicationsForChild(childId);
    final overdue = <Medication>[];

    for (final med in activeMeds) {
      if (med.frequency == MedicationFrequency.asNeeded) continue;

      final lastDose = getLastDoseRecord(med.id);
      final lastDoseTime = lastDose?.actualTime ?? med.startDate;

      if (med.isOverdue(lastDoseTime)) {
        overdue.add(med);
      }
    }

    return overdue;
  }

  /// Get upcoming medications (due in next 2 hours)
  List<Medication> getUpcomingMedications(String childId) {
    final activeMeds = getActiveMedicationsForChild(childId);
    final upcoming = <Medication>[];
    final now = DateTime.now();
    final twoHoursFromNow = now.add(const Duration(hours: 2));

    for (final med in activeMeds) {
      if (med.frequency == MedicationFrequency.asNeeded) continue;

      final lastDose = getLastDoseRecord(med.id);
      final lastDoseTime = lastDose?.actualTime ?? med.startDate;
      final nextDoseTime = med.getNextDoseTime(lastDoseTime);

      if (nextDoseTime != null &&
          nextDoseTime.isAfter(now) &&
          nextDoseTime.isBefore(twoHoursFromNow)) {
        upcoming.add(med);
      }
    }

    return upcoming;
  }

  /// Get dose records for a medication
  List<MedicationDoseRecord> getDoseRecordsForMedication(String medicationId) {
    return _doseRecords
        .where((record) => record.medicationId == medicationId)
        .toList();
  }

  /// Get last dose record for a medication
  MedicationDoseRecord? getLastDoseRecord(String medicationId) {
    final records = getDoseRecordsForMedication(medicationId);
    if (records.isEmpty) return null;

    records.sort((a, b) =>
        b.actualTime?.compareTo(a.actualTime ?? DateTime(1970)) ?? -1);
    return records.first;
  }

  /// Get today's doses for a child
  List<MedicationDoseRecord> getTodaysDoses(String childId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _doseRecords
        .where((record) =>
            record.childId == childId &&
            record.scheduledTime.isAfter(startOfDay) &&
            record.scheduledTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Add new medication
  Future<bool> addMedication(Medication medication) async {
    try {
      final db = await _databaseService.database;
      await db.insert('medications', medication.toMap());

      _medications.add(medication);
      notifyListeners();

      // Generate dose schedule for the medication
      await _generateDoseSchedule(medication);

      return true;
    } catch (e) {
      if (kDebugMode) print('Error adding medication: $e');
      return false;
    }
  }

  /// Update medication
  Future<bool> updateMedication(Medication medication) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'medications',
        medication.toMap(),
        where: 'id = ?',
        whereArgs: [medication.id],
      );

      final index = _medications.indexWhere((med) => med.id == medication.id);
      if (index != -1) {
        _medications[index] = medication;
        notifyListeners();

        // Update dose schedule if medication changed
        await _updateDoseSchedule(medication);
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating medication: $e');
      return false;
    }
  }

  /// Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      final db = await _databaseService.database;
      await db
          .delete('medications', where: 'id = ?', whereArgs: [medicationId]);

      _medications.removeWhere((med) => med.id == medicationId);
      _doseRecords.removeWhere((record) => record.medicationId == medicationId);
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) print('Error deleting medication: $e');
      return false;
    }
  }

  /// Record a dose as taken
  Future<bool> recordDoseTaken(
    String medicationId, {
    DateTime? actualTime,
    double? actualDosage,
    String? notes,
    String? sideEffectsNoted,
  }) async {
    try {
      final medication =
          _medications.firstWhere((med) => med.id == medicationId);
      final now = DateTime.now();

      final doseRecord = MedicationDoseRecord(
        id: '${medicationId}_${now.millisecondsSinceEpoch}',
        childId: medication.childId,
        medicationId: medicationId,
        scheduledTime: _getScheduledTimeForNow(medication),
        actualTime: actualTime ?? now,
        actualDosage: actualDosage ?? medication.dosage,
        isTaken: true,
        notes: notes,
        sideEffectsNoted: sideEffectsNoted,
        createdAt: now,
        updatedAt: now,
      );

      final db = await _databaseService.database;
      await db.insert('medication_dose_records', doseRecord.toMap());

      _doseRecords.add(doseRecord);
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) print('Error recording dose: $e');
      return false;
    }
  }

  /// Record a dose as skipped
  Future<bool> recordDoseSkipped(String medicationId, String reason) async {
    try {
      final medication =
          _medications.firstWhere((med) => med.id == medicationId);
      final now = DateTime.now();

      final doseRecord = MedicationDoseRecord(
        id: '${medicationId}_${now.millisecondsSinceEpoch}',
        childId: medication.childId,
        medicationId: medicationId,
        scheduledTime: _getScheduledTimeForNow(medication),
        isTaken: false,
        isSkipped: true,
        notes: reason,
        createdAt: now,
        updatedAt: now,
      );

      final db = await _databaseService.database;
      await db.insert('medication_dose_records', doseRecord.toMap());

      _doseRecords.add(doseRecord);
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) print('Error recording skipped dose: $e');
      return false;
    }
  }

  /// Generate dose schedule for a medication
  Future<void> _generateDoseSchedule(Medication medication) async {
    if (medication.frequency == MedicationFrequency.asNeeded) return;

    final now = DateTime.now();
    final endDate = medication.endDate ?? now.add(const Duration(days: 30));

    // Generate scheduled doses for the next 7 days
    var scheduleDate =
        medication.startDate.isAfter(now) ? medication.startDate : now;
    final scheduleEndDate = now.add(const Duration(days: 7));

    while (scheduleDate.isBefore(scheduleEndDate) &&
        scheduleDate.isBefore(endDate)) {
      final doseTimes = _getDoseTimesForDay(medication, scheduleDate);

      for (final doseTime in doseTimes) {
        // Check if dose record already exists
        final existingRecord = _doseRecords.any((record) =>
            record.medicationId == medication.id &&
            record.scheduledTime.isAtSameMomentAs(doseTime));

        if (!existingRecord) {
          final doseRecord = MedicationDoseRecord(
            id: '${medication.id}_${doseTime.millisecondsSinceEpoch}',
            childId: medication.childId,
            medicationId: medication.id,
            scheduledTime: doseTime,
            isTaken: false,
            createdAt: now,
            updatedAt: now,
          );

          final db = await _databaseService.database;
          await db.insert('medication_dose_records', doseRecord.toMap());
          _doseRecords.add(doseRecord);
        }
      }

      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    notifyListeners();
  }

  /// Update dose schedule when medication changes
  Future<void> _updateDoseSchedule(Medication medication) async {
    // Remove future scheduled doses
    final now = DateTime.now();
    final db = await _databaseService.database;

    await db.delete(
      'medication_dose_records',
      where:
          'medicationId = ? AND scheduledTime > ? AND isTaken = 0 AND isSkipped = 0',
      whereArgs: [medication.id, now.toIso8601String()],
    );

    _doseRecords.removeWhere((record) =>
        record.medicationId == medication.id &&
        record.scheduledTime.isAfter(now) &&
        !record.isTaken &&
        !record.isSkipped);

    // Generate new schedule
    await _generateDoseSchedule(medication);
  }

  /// Get dose times for a specific day
  List<DateTime> _getDoseTimesForDay(Medication medication, DateTime day) {
    final doseTimes = <DateTime>[];

    switch (medication.frequency) {
      case MedicationFrequency.once:
        doseTimes.add(DateTime(day.year, day.month, day.day, 8, 0)); // 8 AM
        break;
      case MedicationFrequency.twice:
        doseTimes.add(DateTime(day.year, day.month, day.day, 8, 0)); // 8 AM
        doseTimes.add(DateTime(day.year, day.month, day.day, 20, 0)); // 8 PM
        break;
      case MedicationFrequency.thrice:
        doseTimes.add(DateTime(day.year, day.month, day.day, 8, 0)); // 8 AM
        doseTimes.add(DateTime(day.year, day.month, day.day, 14, 0)); // 2 PM
        doseTimes.add(DateTime(day.year, day.month, day.day, 20, 0)); // 8 PM
        break;
      case MedicationFrequency.fourTimes:
        doseTimes.add(DateTime(day.year, day.month, day.day, 8, 0)); // 8 AM
        doseTimes.add(DateTime(day.year, day.month, day.day, 12, 0)); // 12 PM
        doseTimes.add(DateTime(day.year, day.month, day.day, 16, 0)); // 4 PM
        doseTimes.add(DateTime(day.year, day.month, day.day, 20, 0)); // 8 PM
        break;
      case MedicationFrequency.custom:
        final hours = medication.customFrequencyHours ?? 24;
        var currentTime = DateTime(day.year, day.month, day.day, 8, 0);
        final endOfDay = DateTime(day.year, day.month, day.day, 23, 59);

        while (currentTime.isBefore(endOfDay)) {
          doseTimes.add(currentTime);
          currentTime = currentTime.add(Duration(hours: hours));
        }
        break;
      case MedicationFrequency.asNeeded:
        // No scheduled doses for as-needed medications
        break;
    }

    return doseTimes;
  }

  /// Get scheduled time for current dose
  DateTime _getScheduledTimeForNow(Medication medication) {
    final now = DateTime.now();
    final todayDoses = _getDoseTimesForDay(medication, now);

    // Find the closest scheduled time
    DateTime? closestTime;
    Duration? closestDuration;

    for (final doseTime in todayDoses) {
      final duration = (now.difference(doseTime)).abs();
      if (closestDuration == null || duration < closestDuration) {
        closestTime = doseTime;
        closestDuration = duration;
      }
    }

    return closestTime ?? now;
  }

  /// Get medication adherence statistics
  Map<String, double> getMedicationAdherence(String medicationId,
      {int days = 7}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final records = _doseRecords
        .where((record) =>
            record.medicationId == medicationId &&
            record.scheduledTime.isAfter(startDate) &&
            record.scheduledTime.isBefore(endDate))
        .toList();

    final totalScheduled = records.length;
    final taken = records.where((r) => r.isTaken).length;
    final skipped = records.where((r) => r.isSkipped).length;
    final missed = totalScheduled - taken - skipped;

    if (totalScheduled == 0) {
      return {
        'adherence': 0.0,
        'taken': 0.0,
        'skipped': 0.0,
        'missed': 0.0,
      };
    }

    return {
      'adherence': (taken / totalScheduled) * 100,
      'taken': (taken / totalScheduled) * 100,
      'skipped': (skipped / totalScheduled) * 100,
      'missed': (missed / totalScheduled) * 100,
    };
  }

  /// Search medications
  List<Medication> searchMedications(String query, {String? childId}) {
    final lowerQuery = query.toLowerCase();

    return _medications.where((med) {
      if (childId != null && med.childId != childId) return false;

      return med.name.toLowerCase().contains(lowerQuery) ||
          med.nameLocal.toLowerCase().contains(lowerQuery) ||
          (med.genericName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (med.indication?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get medication statistics for a child
  Map<String, int> getMedicationStats(String childId) {
    final childMeds = getMedicationsForChild(childId);

    return {
      'total': childMeds.length,
      'active':
          childMeds.where((m) => m.status == MedicationStatus.active).length,
      'supplements':
          childMeds.where((m) => m.type == MedicationType.supplement).length,
      'medications':
          childMeds.where((m) => m.type == MedicationType.medicine).length,
      'overdue': getOverdueMedications(childId).length,
      'upcoming': getUpcomingMedications(childId).length,
    };
  }
}
