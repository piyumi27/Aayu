import 'package:flutter/material.dart';

/// Medication types
enum MedicationType {
  supplement,
  medicine,
  vitamin,
  mineral,
  prescription,
  overTheCounter,
}

/// Medication schedule frequency
enum MedicationFrequency {
  once,
  twice,
  thrice,
  fourTimes,
  asNeeded,
  custom,
}

/// Dosage units
enum DosageUnit {
  mg,
  ml,
  drops,
  tablets,
  teaspoons,
  capsules,
  sachets,
}

/// Medication status
enum MedicationStatus {
  active,
  paused,
  completed,
  discontinued,
}

/// Medication model for tracking child medications and supplements
class Medication {
  final String id;
  final String childId;
  final String name;
  final String nameLocal; // Sinhala/Tamil name
  final String? genericName;
  final MedicationType type;
  final String description;
  final double dosage;
  final DosageUnit dosageUnit;
  final MedicationFrequency frequency;
  final int? customFrequencyHours; // For custom frequency
  final DateTime startDate;
  final DateTime? endDate;
  final MedicationStatus status;
  final String? prescribedBy;
  final String? indication; // What it's for
  final List<String> sideEffects;
  final List<String> instructions;
  final String? notes;
  final bool isImportant; // Critical medications
  final String? reminderSound;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.childId,
    required this.name,
    required this.nameLocal,
    this.genericName,
    required this.type,
    required this.description,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    this.customFrequencyHours,
    required this.startDate,
    this.endDate,
    required this.status,
    this.prescribedBy,
    this.indication,
    this.sideEffects = const [],
    this.instructions = const [],
    this.notes,
    this.isImportant = false,
    this.reminderSound,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get medication frequency as hours
  int get frequencyInHours {
    switch (frequency) {
      case MedicationFrequency.once:
        return 24;
      case MedicationFrequency.twice:
        return 12;
      case MedicationFrequency.thrice:
        return 8;
      case MedicationFrequency.fourTimes:
        return 6;
      case MedicationFrequency.custom:
        return customFrequencyHours ?? 24;
      case MedicationFrequency.asNeeded:
        return 0;
    }
  }

  /// Get frequency display text
  String get frequencyText {
    switch (frequency) {
      case MedicationFrequency.once:
        return 'Once daily';
      case MedicationFrequency.twice:
        return 'Twice daily';
      case MedicationFrequency.thrice:
        return 'Three times daily';
      case MedicationFrequency.fourTimes:
        return 'Four times daily';
      case MedicationFrequency.custom:
        return 'Every ${customFrequencyHours ?? 24} hours';
      case MedicationFrequency.asNeeded:
        return 'As needed';
    }
  }

  /// Get dosage display text
  String get dosageText {
    return '$dosage ${dosageUnit.name}';
  }

  /// Check if medication is currently active
  bool get isActive {
    if (status != MedicationStatus.active) return false;

    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }

  /// Get next dose time based on frequency
  DateTime? getNextDoseTime(DateTime lastDoseTime) {
    if (frequency == MedicationFrequency.asNeeded) return null;

    return lastDoseTime.add(Duration(hours: frequencyInHours));
  }

  /// Check if medication is overdue
  bool isOverdue(DateTime lastDoseTime) {
    if (!isActive || frequency == MedicationFrequency.asNeeded) return false;

    final nextDose = getNextDoseTime(lastDoseTime);
    if (nextDose == null) return false;

    return DateTime.now().isAfter(nextDose.add(const Duration(minutes: 30)));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'nameLocal': nameLocal,
      'genericName': genericName,
      'type': type.index,
      'description': description,
      'dosage': dosage,
      'dosageUnit': dosageUnit.index,
      'frequency': frequency.index,
      'customFrequencyHours': customFrequencyHours,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.index,
      'prescribedBy': prescribedBy,
      'indication': indication,
      'sideEffects': sideEffects.join(','),
      'instructions': instructions.join(','),
      'notes': notes,
      'isImportant': isImportant,
      'reminderSound': reminderSound,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      childId: map['childId'],
      name: map['name'],
      nameLocal: map['nameLocal'],
      genericName: map['genericName'],
      type: MedicationType.values[map['type']],
      description: map['description'],
      dosage: map['dosage'].toDouble(),
      dosageUnit: DosageUnit.values[map['dosageUnit']],
      frequency: MedicationFrequency.values[map['frequency']],
      customFrequencyHours: map['customFrequencyHours'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      status: MedicationStatus.values[map['status']],
      prescribedBy: map['prescribedBy'],
      indication: map['indication'],
      sideEffects: map['sideEffects']?.split(',') ?? [],
      instructions: map['instructions']?.split(',') ?? [],
      notes: map['notes'],
      isImportant: map['isImportant'] ?? false,
      reminderSound: map['reminderSound'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Medication copyWith({
    String? id,
    String? childId,
    String? name,
    String? nameLocal,
    String? genericName,
    MedicationType? type,
    String? description,
    double? dosage,
    DosageUnit? dosageUnit,
    MedicationFrequency? frequency,
    int? customFrequencyHours,
    DateTime? startDate,
    DateTime? endDate,
    MedicationStatus? status,
    String? prescribedBy,
    String? indication,
    List<String>? sideEffects,
    List<String>? instructions,
    String? notes,
    bool? isImportant,
    String? reminderSound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      name: name ?? this.name,
      nameLocal: nameLocal ?? this.nameLocal,
      genericName: genericName ?? this.genericName,
      type: type ?? this.type,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      customFrequencyHours: customFrequencyHours ?? this.customFrequencyHours,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      indication: indication ?? this.indication,
      sideEffects: sideEffects ?? this.sideEffects,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      isImportant: isImportant ?? this.isImportant,
      reminderSound: reminderSound ?? this.reminderSound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Medication dose record for tracking when doses are taken
class MedicationDoseRecord {
  final String id;
  final String childId;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final double? actualDosage;
  final bool isTaken;
  final bool isSkipped;
  final String? notes;
  final String? sideEffectsNoted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationDoseRecord({
    required this.id,
    required this.childId,
    required this.medicationId,
    required this.scheduledTime,
    this.actualTime,
    this.actualDosage,
    required this.isTaken,
    this.isSkipped = false,
    this.notes,
    this.sideEffectsNoted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if dose is overdue
  bool get isOverdue {
    if (isTaken || isSkipped) return false;
    return DateTime.now()
        .isAfter(scheduledTime.add(const Duration(minutes: 30)));
  }

  /// Get status color
  Color get statusColor {
    if (isTaken) return Colors.green;
    if (isSkipped) return Colors.orange;
    if (isOverdue) return Colors.red;
    return Colors.blue;
  }

  /// Get status icon
  IconData get statusIcon {
    if (isTaken) return Icons.check_circle;
    if (isSkipped) return Icons.cancel;
    if (isOverdue) return Icons.warning;
    return Icons.schedule;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'actualDosage': actualDosage,
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'notes': notes,
      'sideEffectsNoted': sideEffectsNoted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicationDoseRecord.fromMap(Map<String, dynamic> map) {
    return MedicationDoseRecord(
      id: map['id'],
      childId: map['childId'],
      medicationId: map['medicationId'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      actualTime:
          map['actualTime'] != null ? DateTime.parse(map['actualTime']) : null,
      actualDosage: map['actualDosage']?.toDouble(),
      isTaken: map['isTaken'] ?? false,
      isSkipped: map['isSkipped'] ?? false,
      notes: map['notes'],
      sideEffectsNoted: map['sideEffectsNoted'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  MedicationDoseRecord copyWith({
    String? id,
    String? childId,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? actualTime,
    double? actualDosage,
    bool? isTaken,
    bool? isSkipped,
    String? notes,
    String? sideEffectsNoted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationDoseRecord(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      actualDosage: actualDosage ?? this.actualDosage,
      isTaken: isTaken ?? this.isTaken,
      isSkipped: isSkipped ?? this.isSkipped,
      notes: notes ?? this.notes,
      sideEffectsNoted: sideEffectsNoted ?? this.sideEffectsNoted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Predefined common Sri Lankan child medications and supplements
class CommonMedications {
  static const List<Map<String, dynamic>> supplements = [
    {
      'name': 'Vitamin D Drops',
      'nameLocal': 'විටමින් D ඩ්‍රොප්ස්',
      'type': MedicationType.vitamin,
      'description': 'Essential for bone development and immune system',
      'commonDosage': 400.0,
      'dosageUnit': DosageUnit.drops,
      'frequency': MedicationFrequency.once,
      'indication': 'Vitamin D deficiency prevention',
    },
    {
      'name': 'Iron Syrup',
      'nameLocal': 'යකඩ සිරප්',
      'type': MedicationType.supplement,
      'description': 'Prevents iron deficiency anemia',
      'commonDosage': 5.0,
      'dosageUnit': DosageUnit.ml,
      'frequency': MedicationFrequency.once,
      'indication': 'Iron deficiency anemia prevention',
    },
    {
      'name': 'Calcium Syrup',
      'nameLocal': 'කැල්සියම් සිරප්',
      'type': MedicationType.supplement,
      'description': 'Essential for bone and teeth development',
      'commonDosage': 5.0,
      'dosageUnit': DosageUnit.ml,
      'frequency': MedicationFrequency.twice,
      'indication': 'Calcium deficiency prevention',
    },
    {
      'name': 'Multivitamin Drops',
      'nameLocal': 'බහු විටමින් ඩ්‍රොප්ස්',
      'type': MedicationType.vitamin,
      'description': 'Complete vitamin supplement for growing children',
      'commonDosage': 1.0,
      'dosageUnit': DosageUnit.ml,
      'frequency': MedicationFrequency.once,
      'indication': 'General nutrition support',
    },
    {
      'name': 'Zinc Syrup',
      'nameLocal': 'සින්ක් සිරප්',
      'type': MedicationType.supplement,
      'description': 'Supports immune system and growth',
      'commonDosage': 2.5,
      'dosageUnit': DosageUnit.ml,
      'frequency': MedicationFrequency.once,
      'indication': 'Zinc deficiency prevention',
    },
  ];

  static const List<Map<String, dynamic>> medications = [
    {
      'name': 'Paracetamol Syrup',
      'nameLocal': 'පැරසිටමෝල් සිරප්',
      'type': MedicationType.medicine,
      'description': 'Pain relief and fever reduction',
      'commonDosage': 5.0,
      'dosageUnit': DosageUnit.ml,
      'frequency': MedicationFrequency.asNeeded,
      'indication': 'Fever and pain relief',
    },
    {
      'name': 'Oral Rehydration Salts',
      'nameLocal': 'මුඛ ජලකරණ ලවණ',
      'type': MedicationType.medicine,
      'description': 'Prevents dehydration during diarrhea',
      'commonDosage': 1.0,
      'dosageUnit': DosageUnit.sachets,
      'frequency': MedicationFrequency.asNeeded,
      'indication': 'Diarrhea and dehydration',
    },
    {
      'name': 'Probiotics',
      'nameLocal': 'ප්‍රෝබයොටික්',
      'type': MedicationType.supplement,
      'description': 'Supports digestive health',
      'commonDosage': 1.0,
      'dosageUnit': DosageUnit.sachets,
      'frequency': MedicationFrequency.once,
      'indication': 'Digestive health support',
    },
  ];
}
