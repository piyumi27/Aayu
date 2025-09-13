class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final double? birthWeight;
  final double? birthHeight;
  final String? bloodType;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.birthWeight,
    this.birthHeight,
    this.bloodType,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'bloodType': bloodType,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      name: map['name'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
      birthWeight: map['birthWeight']?.toDouble(),
      birthHeight: map['birthHeight']?.toDouble(),
      bloodType: map['bloodType'],
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? birthWeight,
    double? birthHeight,
    String? bloodType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      bloodType: bloodType ?? this.bloodType,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate age in months from birth date
  int get ageInMonths {
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    final days = now.day - birthDate.day;

    int totalMonths = years * 12 + months;

    // If the day of birth hasn't occurred this month, subtract 1
    if (days < 0) {
      totalMonths--;
    }

    return totalMonths >= 0 ? totalMonths : 0;
  }

  /// Calculate age in years
  int get ageInYears {
    return (ageInMonths / 12).floor();
  }

  /// Get formatted age string
  String get formattedAge {
    final months = ageInMonths;
    if (months < 12) {
      return '$months months';
    } else {
      final years = ageInYears;
      final remainingMonths = months - (years * 12);
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? 'year' : 'years'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths months';
      }
    }
  }
}
