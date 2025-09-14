class Vaccine {
  final String id;
  final String name;
  final String nameLocal;
  final String description;
  final int recommendedAgeMonths;
  final bool isMandatory;
  final String category;

  Vaccine({
    required this.id,
    required this.name,
    required this.nameLocal,
    required this.description,
    required this.recommendedAgeMonths,
    required this.isMandatory,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameLocal': nameLocal,
      'description': description,
      'recommendedAgeMonths': recommendedAgeMonths,
      'isMandatory': isMandatory,
      'category': category,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'],
      name: map['name'],
      nameLocal: map['nameLocal'],
      description: map['description'],
      recommendedAgeMonths: map['recommendedAgeMonths'],
      isMandatory: map['isMandatory'] == 1,
      category: map['category'],
    );
  }
}

class VaccineRecord {
  final String id;
  final String childId;
  final String vaccineId;
  final DateTime givenDate;
  final String? location;
  final String? doctorName;
  final String? batchNumber;
  final String? notes;
  final String? sideEffectsNoted;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaccineRecord({
    required this.id,
    required this.childId,
    required this.vaccineId,
    required this.givenDate,
    this.location,
    this.doctorName,
    this.batchNumber,
    this.notes,
    this.sideEffectsNoted,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'vaccineId': vaccineId,
      'givenDate': givenDate.toIso8601String(),
      'location': location,
      'doctorName': doctorName,
      'batchNumber': batchNumber,
      'notes': notes,
      // 'sideEffectsNoted': sideEffectsNoted, // Excluded - not in database schema
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VaccineRecord.fromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'],
      childId: map['childId'],
      vaccineId: map['vaccineId'],
      givenDate: DateTime.parse(map['givenDate']),
      location: map['location'],
      doctorName: map['doctorName'],
      batchNumber: map['batchNumber'],
      notes: map['notes'],
      sideEffectsNoted: map['sideEffectsNoted'], // Will be null since not in DB
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}