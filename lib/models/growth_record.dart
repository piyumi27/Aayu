class GrowthRecord {
  final String id;
  final String childId;
  final DateTime date;
  final double weight;
  final double height;
  final double? headCircumference;
  final String? notes;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrowthRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.notes,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'headCircumference': headCircumference,
      'notes': notes,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      id: map['id'],
      childId: map['childId'],
      date: DateTime.parse(map['date']),
      weight: map['weight'].toDouble(),
      height: map['height'].toDouble(),
      headCircumference: map['headCircumference']?.toDouble(),
      notes: map['notes'],
      photoPath: map['photoPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
