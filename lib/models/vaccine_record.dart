class VaccineRecord {
  final String id;
  final String childId;
  final String vaccineId;
  final DateTime givenDate;
  final String? location;
  final String? doctor;
  final String? batchNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaccineRecord({
    required this.id,
    required this.childId,
    required this.vaccineId,
    required this.givenDate,
    this.location,
    this.doctor,
    this.batchNumber,
    this.notes,
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
      'doctor': doctor,
      'batchNumber': batchNumber,
      'notes': notes,
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
      doctor: map['doctor'],
      batchNumber: map['batchNumber'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}