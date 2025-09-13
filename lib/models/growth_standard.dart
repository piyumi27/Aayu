class GrowthStandard {
  final String id;
  final String standardType;
  final String source;
  final String gender;
  final int ageMonths;
  final double zScoreMinus3;
  final double zScoreMinus2;
  final double median;
  final double zScorePlus2;
  final double zScorePlus3;
  final String measurementType;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrowthStandard({
    required this.id,
    required this.standardType,
    required this.source,
    required this.gender,
    required this.ageMonths,
    required this.zScoreMinus3,
    required this.zScoreMinus2,
    required this.median,
    required this.zScorePlus2,
    required this.zScorePlus3,
    required this.measurementType,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'standardType': standardType,
      'source': source,
      'gender': gender,
      'ageMonths': ageMonths,
      'zScoreMinus3': zScoreMinus3,
      'zScoreMinus2': zScoreMinus2,
      'median': median,
      'zScorePlus2': zScorePlus2,
      'zScorePlus3': zScorePlus3,
      'measurementType': measurementType,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GrowthStandard.fromMap(Map<String, dynamic> map) {
    return GrowthStandard(
      id: map['id'],
      standardType: map['standardType'],
      source: map['source'],
      gender: map['gender'],
      ageMonths: map['ageMonths'],
      zScoreMinus3: map['zScoreMinus3'].toDouble(),
      zScoreMinus2: map['zScoreMinus2'].toDouble(),
      median: map['median'].toDouble(),
      zScorePlus2: map['zScorePlus2'].toDouble(),
      zScorePlus3: map['zScorePlus3'].toDouble(),
      measurementType: map['measurementType'],
      unit: map['unit'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  double calculateZScore(double actualValue) {
    if (actualValue <= zScoreMinus3) return -3.0;
    if (actualValue <= zScoreMinus2) {
      return -3.0 +
          ((actualValue - zScoreMinus3) / (zScoreMinus2 - zScoreMinus3));
    }
    if (actualValue <= median) {
      return -2.0 +
          ((actualValue - zScoreMinus2) / (median - zScoreMinus2)) * 2.0;
    }
    if (actualValue <= zScorePlus2) {
      return ((actualValue - median) / (zScorePlus2 - median)) * 2.0;
    }
    if (actualValue <= zScorePlus3) {
      return 2.0 + ((actualValue - zScorePlus2) / (zScorePlus3 - zScorePlus2));
    }
    return 3.0;
  }

  String getNutritionalStatus() {
    return switch (measurementType) {
      'weight_for_age' => _getWeightForAgeStatus(),
      'height_for_age' => _getHeightForAgeStatus(),
      'weight_for_height' => _getWeightForHeightStatus(),
      'bmi_for_age' => _getBmiForAgeStatus(),
      _ => 'Unknown measurement type',
    };
  }

  String _getWeightForAgeStatus() {
    return 'Weight for age standard';
  }

  String _getHeightForAgeStatus() {
    return 'Height for age standard';
  }

  String _getWeightForHeightStatus() {
    return 'Weight for height standard';
  }

  String _getBmiForAgeStatus() {
    return 'BMI for age standard';
  }
}

class NutritionalClassification {
  final String category;
  final String severity;
  final String description;
  final double zScoreThreshold;
  final String recommendations;

  const NutritionalClassification({
    required this.category,
    required this.severity,
    required this.description,
    required this.zScoreThreshold,
    required this.recommendations,
  });

  static const List<NutritionalClassification> weightForAgeClassifications = [
    NutritionalClassification(
      category: 'Severely Underweight',
      severity: 'severe',
      description: 'Child is severely underweight for their age',
      zScoreThreshold: -3.0,
      recommendations:
          'Immediate medical attention required. Refer to health facility.',
    ),
    NutritionalClassification(
      category: 'Moderately Underweight',
      severity: 'moderate',
      description: 'Child is moderately underweight for their age',
      zScoreThreshold: -2.0,
      recommendations: 'Nutritional counseling and monitoring required.',
    ),
    NutritionalClassification(
      category: 'Normal',
      severity: 'normal',
      description: 'Child has normal weight for their age',
      zScoreThreshold: 2.0,
      recommendations: 'Continue healthy feeding practices.',
    ),
    NutritionalClassification(
      category: 'Overweight',
      severity: 'mild',
      description: 'Child is overweight for their age',
      zScoreThreshold: 3.0,
      recommendations:
          'Review feeding practices and increase physical activity.',
    ),
  ];

  static const List<NutritionalClassification> heightForAgeClassifications = [
    NutritionalClassification(
      category: 'Severely Stunted',
      severity: 'severe',
      description: 'Child is severely stunted (chronic malnutrition)',
      zScoreThreshold: -3.0,
      recommendations:
          'Immediate intervention required. Long-term nutritional support.',
    ),
    NutritionalClassification(
      category: 'Moderately Stunted',
      severity: 'moderate',
      description: 'Child is moderately stunted',
      zScoreThreshold: -2.0,
      recommendations: 'Enhanced nutrition and monitoring required.',
    ),
    NutritionalClassification(
      category: 'Normal',
      severity: 'normal',
      description: 'Child has normal height for their age',
      zScoreThreshold: 2.0,
      recommendations: 'Maintain current feeding practices.',
    ),
  ];

  static NutritionalClassification getClassificationForZScore(
    double zScore,
    String measurementType,
  ) {
    final classifications = switch (measurementType) {
      'weight_for_age' => weightForAgeClassifications,
      'height_for_age' => heightForAgeClassifications,
      _ => weightForAgeClassifications,
    };

    for (int i = 0; i < classifications.length - 1; i++) {
      if (zScore < classifications[i].zScoreThreshold) {
        return classifications[i];
      }
    }
    return classifications.last;
  }
}
