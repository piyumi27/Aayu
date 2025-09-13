class NutritionGuideline {
  final String id;
  final String source;
  final int ageMonthsMin;
  final int ageMonthsMax;
  final String feedingType;
  final int dailyMealsCount;
  final int dailySnacksCount;
  final double dailyCaloriesMin;
  final double dailyCaloriesMax;
  final double proteinGramsMin;
  final double proteinGramsMax;
  final String feedingFrequency;
  final List<String> recommendedFoods;
  final List<String> avoidedFoods;
  final String specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionGuideline({
    required this.id,
    required this.source,
    required this.ageMonthsMin,
    required this.ageMonthsMax,
    required this.feedingType,
    required this.dailyMealsCount,
    required this.dailySnacksCount,
    required this.dailyCaloriesMin,
    required this.dailyCaloriesMax,
    required this.proteinGramsMin,
    required this.proteinGramsMax,
    required this.feedingFrequency,
    required this.recommendedFoods,
    required this.avoidedFoods,
    required this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'ageMonthsMin': ageMonthsMin,
      'ageMonthsMax': ageMonthsMax,
      'feedingType': feedingType,
      'dailyMealsCount': dailyMealsCount,
      'dailySnacksCount': dailySnacksCount,
      'dailyCaloriesMin': dailyCaloriesMin,
      'dailyCaloriesMax': dailyCaloriesMax,
      'proteinGramsMin': proteinGramsMin,
      'proteinGramsMax': proteinGramsMax,
      'feedingFrequency': feedingFrequency,
      'recommendedFoods': recommendedFoods.join(','),
      'avoidedFoods': avoidedFoods.join(','),
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NutritionGuideline.fromMap(Map<String, dynamic> map) {
    return NutritionGuideline(
      id: map['id'],
      source: map['source'],
      ageMonthsMin: map['ageMonthsMin'],
      ageMonthsMax: map['ageMonthsMax'],
      feedingType: map['feedingType'],
      dailyMealsCount: map['dailyMealsCount'],
      dailySnacksCount: map['dailySnacksCount'],
      dailyCaloriesMin: map['dailyCaloriesMin'].toDouble(),
      dailyCaloriesMax: map['dailyCaloriesMax'].toDouble(),
      proteinGramsMin: map['proteinGramsMin'].toDouble(),
      proteinGramsMax: map['proteinGramsMax'].toDouble(),
      feedingFrequency: map['feedingFrequency'],
      recommendedFoods: map['recommendedFoods'].toString().split(','),
      avoidedFoods: map['avoidedFoods'].toString().split(','),
      specialInstructions: map['specialInstructions'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  bool isApplicableForAge(int ageMonths) {
    return ageMonths >= ageMonthsMin && ageMonths <= ageMonthsMax;
  }

  String getAgeRangeDescription() {
    if (ageMonthsMin == 0 && ageMonthsMax <= 6) {
      return 'Birth to 6 months';
    } else if (ageMonthsMin == 6 && ageMonthsMax <= 12) {
      return '6-12 months';
    } else if (ageMonthsMin == 12 && ageMonthsMax <= 24) {
      return '1-2 years';
    } else if (ageMonthsMin == 24 && ageMonthsMax <= 60) {
      return '2-5 years';
    } else {
      return '${ageMonthsMin}-${ageMonthsMax} months';
    }
  }
}

class FeedingRecommendation {
  final String id;
  final String source;
  final int ageMonthsMin;
  final int ageMonthsMax;
  final String mealType;
  final String foodCategory;
  final String foodItem;
  final String portionSize;
  final String frequency;
  final String preparationNotes;
  final bool isLocalFood;
  final String nutritionalBenefits;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedingRecommendation({
    required this.id,
    required this.source,
    required this.ageMonthsMin,
    required this.ageMonthsMax,
    required this.mealType,
    required this.foodCategory,
    required this.foodItem,
    required this.portionSize,
    required this.frequency,
    required this.preparationNotes,
    required this.isLocalFood,
    required this.nutritionalBenefits,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'ageMonthsMin': ageMonthsMin,
      'ageMonthsMax': ageMonthsMax,
      'mealType': mealType,
      'foodCategory': foodCategory,
      'foodItem': foodItem,
      'portionSize': portionSize,
      'frequency': frequency,
      'preparationNotes': preparationNotes,
      'isLocalFood': isLocalFood ? 1 : 0,
      'nutritionalBenefits': nutritionalBenefits,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FeedingRecommendation.fromMap(Map<String, dynamic> map) {
    return FeedingRecommendation(
      id: map['id'],
      source: map['source'],
      ageMonthsMin: map['ageMonthsMin'],
      ageMonthsMax: map['ageMonthsMax'],
      mealType: map['mealType'],
      foodCategory: map['foodCategory'],
      foodItem: map['foodItem'],
      portionSize: map['portionSize'],
      frequency: map['frequency'],
      preparationNotes: map['preparationNotes'],
      isLocalFood: map['isLocalFood'] == 1,
      nutritionalBenefits: map['nutritionalBenefits'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  bool isApplicableForAge(int ageMonths) {
    return ageMonths >= ageMonthsMin && ageMonths <= ageMonthsMax;
  }
}

class NutritionalAlert {
  final String id;
  final String alertType;
  final String severity;
  final String title;
  final String description;
  final String recommendations;
  final List<String> symptoms;
  final String actionRequired;
  final bool requiresImmediateAttention;
  final DateTime createdAt;

  NutritionalAlert({
    required this.id,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.symptoms,
    required this.actionRequired,
    required this.requiresImmediateAttention,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alertType': alertType,
      'severity': severity,
      'title': title,
      'description': description,
      'recommendations': recommendations,
      'symptoms': symptoms.join(','),
      'actionRequired': actionRequired,
      'requiresImmediateAttention': requiresImmediateAttention ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NutritionalAlert.fromMap(Map<String, dynamic> map) {
    return NutritionalAlert(
      id: map['id'],
      alertType: map['alertType'],
      severity: map['severity'],
      title: map['title'],
      description: map['description'],
      recommendations: map['recommendations'],
      symptoms: map['symptoms'].toString().split(','),
      actionRequired: map['actionRequired'],
      requiresImmediateAttention: map['requiresImmediateAttention'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static NutritionalAlert createMalnutritionAlert({
    required String type,
    required double zScore,
    required String measurementType,
  }) {
    final now = DateTime.now();
    
    if (zScore < -3.0) {
      return NutritionalAlert(
        id: 'alert_${now.millisecondsSinceEpoch}',
        alertType: type,
        severity: 'severe',
        title: 'Severe Malnutrition Detected',
        description: 'Child shows signs of severe acute malnutrition (Z-score < -3)',
        recommendations: 'Immediate medical attention required. Refer to nearest health facility.',
        symptoms: ['Very low weight/height for age', 'Visible wasting', 'Poor appetite'],
        actionRequired: 'Seek immediate medical care',
        requiresImmediateAttention: true,
        createdAt: now,
      );
    } else if (zScore < -2.0) {
      return NutritionalAlert(
        id: 'alert_${now.millisecondsSinceEpoch}',
        alertType: type,
        severity: 'moderate',
        title: 'Moderate Malnutrition Detected',
        description: 'Child shows signs of moderate malnutrition (Z-score < -2)',
        recommendations: 'Enhanced nutrition and regular monitoring required.',
        symptoms: ['Below normal weight/height for age', 'Reduced appetite'],
        actionRequired: 'Consult healthcare provider for nutrition plan',
        requiresImmediateAttention: false,
        createdAt: now,
      );
    } else {
      return NutritionalAlert(
        id: 'alert_${now.millisecondsSinceEpoch}',
        alertType: 'info',
        severity: 'normal',
        title: 'Normal Growth',
        description: 'Child is within normal growth parameters',
        recommendations: 'Continue current feeding practices',
        symptoms: [],
        actionRequired: 'Regular monitoring',
        requiresImmediateAttention: false,
        createdAt: now,
      );
    }
  }
}