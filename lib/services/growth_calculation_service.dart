import 'dart:math' as math;
import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/growth_standard.dart';
import '../repositories/standards_repository.dart';

class GrowthCalculationService {
  static final GrowthCalculationService _instance = GrowthCalculationService._internal();
  factory GrowthCalculationService() => _instance;
  GrowthCalculationService._internal();

  final StandardsRepository _standardsRepository = StandardsRepository();

  Future<GrowthAssessment> calculateGrowthAssessment({
    required Child child,
    required GrowthRecord growthRecord,
    String? standardSource,
  }) async {
    final childAgeMonths = _calculateAgeInMonths(child.birthDate, growthRecord.date);
    
    final weightForAgeZScore = await _calculateWeightForAgeZScore(
      weight: growthRecord.weight,
      ageMonths: childAgeMonths,
      gender: child.gender,
      standardSource: standardSource,
    );

    final heightForAgeZScore = await _calculateHeightForAgeZScore(
      height: growthRecord.height,
      ageMonths: childAgeMonths,
      gender: child.gender,
      standardSource: standardSource,
    );

    final weightForHeightZScore = await _calculateWeightForHeightZScore(
      weight: growthRecord.weight,
      height: growthRecord.height,
      ageMonths: childAgeMonths,
      gender: child.gender,
      standardSource: standardSource,
    );

    final bmiForAgeZScore = await _calculateBMIForAgeZScore(
      weight: growthRecord.weight,
      height: growthRecord.height,
      ageMonths: childAgeMonths,
      gender: child.gender,
      standardSource: standardSource,
    );

    double? headCircumferenceZScore;
    if (growthRecord.headCircumference != null) {
      headCircumferenceZScore = await _calculateHeadCircumferenceZScore(
        headCircumference: growthRecord.headCircumference!,
        ageMonths: childAgeMonths,
        gender: child.gender,
        standardSource: standardSource,
      );
    }

    return GrowthAssessment(
      childId: child.id,
      assessmentDate: growthRecord.date,
      ageMonths: childAgeMonths,
      weight: growthRecord.weight,
      height: growthRecord.height,
      headCircumference: growthRecord.headCircumference,
      weightForAgeZScore: weightForAgeZScore,
      heightForAgeZScore: heightForAgeZScore,
      weightForHeightZScore: weightForHeightZScore,
      bmiForAgeZScore: bmiForAgeZScore,
      headCircumferenceZScore: headCircumferenceZScore,
      nutritionalStatus: _determineNutritionalStatus(
        weightForAgeZScore: weightForAgeZScore,
        heightForAgeZScore: heightForAgeZScore,
        weightForHeightZScore: weightForHeightZScore,
      ),
      riskLevel: _determineRiskLevel(
        weightForAgeZScore: weightForAgeZScore,
        heightForAgeZScore: heightForAgeZScore,
        weightForHeightZScore: weightForHeightZScore,
      ),
      recommendations: _generateRecommendations(
        weightForAgeZScore: weightForAgeZScore,
        heightForAgeZScore: heightForAgeZScore,
        weightForHeightZScore: weightForHeightZScore,
        ageMonths: childAgeMonths,
      ),
    );
  }

  Future<double> _calculateWeightForAgeZScore({
    required double weight,
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: 'weight_for_age',
      source: standardSource,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(weight);
  }

  Future<double> _calculateHeightForAgeZScore({
    required double height,
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: 'height_for_age',
      source: standardSource,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(height);
  }

  Future<double> _calculateWeightForHeightZScore({
    required double weight,
    required double height,
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: 'weight_for_height',
      source: standardSource,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(weight);
  }

  Future<double> _calculateBMIForAgeZScore({
    required double weight,
    required double height,
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    final bmi = weight / math.pow(height / 100, 2);
    
    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: 'bmi_for_age',
      source: standardSource,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(bmi);
  }

  Future<double> _calculateHeadCircumferenceZScore({
    required double headCircumference,
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: 'head_circumference',
      source: standardSource,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(headCircumference);
  }

  int _calculateAgeInMonths(DateTime birthDate, DateTime measurementDate) {
    final difference = measurementDate.difference(birthDate);
    return (difference.inDays / 30.44).round();
  }

  NutritionalStatus _determineNutritionalStatus({
    required double weightForAgeZScore,
    required double heightForAgeZScore,
    required double weightForHeightZScore,
  }) {
    if (weightForAgeZScore < -3 || heightForAgeZScore < -3 || weightForHeightZScore < -3) {
      return NutritionalStatus.severeAcuteMalnutrition;
    } else if (weightForAgeZScore < -2 || heightForAgeZScore < -2 || weightForHeightZScore < -2) {
      return NutritionalStatus.moderateAcuteMalnutrition;
    } else if (heightForAgeZScore < -2) {
      return NutritionalStatus.stunting;
    } else if (weightForHeightZScore > 2 || weightForAgeZScore > 2) {
      return NutritionalStatus.overweight;
    } else if (weightForHeightZScore > 3 || weightForAgeZScore > 3) {
      return NutritionalStatus.obesity;
    } else {
      return NutritionalStatus.normal;
    }
  }

  RiskLevel _determineRiskLevel({
    required double weightForAgeZScore,
    required double heightForAgeZScore,
    required double weightForHeightZScore,
  }) {
    if (weightForAgeZScore < -3 || heightForAgeZScore < -3 || weightForHeightZScore < -3) {
      return RiskLevel.critical;
    } else if (weightForAgeZScore < -2 || heightForAgeZScore < -2 || weightForHeightZScore < -2) {
      return RiskLevel.high;
    } else if (weightForAgeZScore < -1 || heightForAgeZScore < -1 || weightForHeightZScore < -1) {
      return RiskLevel.moderate;
    } else if (weightForHeightZScore > 2 || weightForAgeZScore > 2) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.low;
    }
  }

  List<String> _generateRecommendations({
    required double weightForAgeZScore,
    required double heightForAgeZScore,
    required double weightForHeightZScore,
    required int ageMonths,
  }) {
    final recommendations = <String>[];

    if (weightForAgeZScore < -3 || heightForAgeZScore < -3 || weightForHeightZScore < -3) {
      recommendations.addAll([
        'Immediate medical attention required',
        'Refer to nutrition specialist',
        'Consider therapeutic feeding program',
        'Monitor daily weight and height',
        'Check for underlying medical conditions',
      ]);
    } else if (weightForAgeZScore < -2 || heightForAgeZScore < -2 || weightForHeightZScore < -2) {
      recommendations.addAll([
        'Increase feeding frequency and quantity',
        'Focus on energy-dense foods',
        'Monitor weekly measurements',
        'Consult healthcare provider',
        'Ensure adequate micronutrient intake',
      ]);
    } else if (weightForHeightZScore > 2 || weightForAgeZScore > 2) {
      recommendations.addAll([
        'Monitor portion sizes',
        'Increase physical activity',
        'Focus on nutritious, lower-calorie foods',
        'Limit sugary drinks and snacks',
        'Consult pediatric nutritionist',
      ]);
    } else {
      recommendations.addAll([
        'Continue current feeding practices',
        'Maintain regular growth monitoring',
        'Ensure balanced, age-appropriate diet',
        'Encourage physical activity',
        'Regular pediatric check-ups',
      ]);
    }

    if (ageMonths < 6) {
      recommendations.add('Exclusive breastfeeding recommended');
    } else if (ageMonths < 24) {
      recommendations.add('Continue breastfeeding with complementary foods');
    }

    return recommendations;
  }

  Future<GrowthVelocity> calculateGrowthVelocity({
    required List<GrowthRecord> growthRecords,
    required Child child,
    String? standardSource,
  }) async {
    if (growthRecords.length < 2) {
      return GrowthVelocity.insufficient();
    }

    growthRecords.sort((a, b) => a.date.compareTo(b.date));
    
    final first = growthRecords.first;
    final last = growthRecords.last;
    final timeDiffMonths = _calculateAgeInMonths(first.date, last.date);
    
    if (timeDiffMonths == 0) {
      return GrowthVelocity.insufficient();
    }

    final weightVelocity = (last.weight - first.weight) / timeDiffMonths;
    final heightVelocity = (last.height - first.height) / timeDiffMonths;
    
    final expectedWeightVelocity = await _getExpectedWeightVelocity(
      ageMonths: _calculateAgeInMonths(child.birthDate, last.date),
      gender: child.gender,
      standardSource: standardSource,
    );
    
    final expectedHeightVelocity = await _getExpectedHeightVelocity(
      ageMonths: _calculateAgeInMonths(child.birthDate, last.date),
      gender: child.gender,
      standardSource: standardSource,
    );

    return GrowthVelocity(
      weightVelocityPerMonth: weightVelocity,
      heightVelocityPerMonth: heightVelocity,
      expectedWeightVelocity: expectedWeightVelocity,
      expectedHeightVelocity: expectedHeightVelocity,
      isAdequateWeightGain: weightVelocity >= (expectedWeightVelocity * 0.8),
      isAdequateHeightGain: heightVelocity >= (expectedHeightVelocity * 0.8),
      timePeriodMonths: timeDiffMonths,
    );
  }

  Future<double> _getExpectedWeightVelocity({
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    if (ageMonths < 3) return 0.8;
    if (ageMonths < 6) return 0.6;
    if (ageMonths < 12) return 0.4;
    if (ageMonths < 24) return 0.25;
    return 0.15;
  }

  Future<double> _getExpectedHeightVelocity({
    required int ageMonths,
    required String gender,
    String? standardSource,
  }) async {
    if (ageMonths < 3) return 3.5;
    if (ageMonths < 6) return 2.0;
    if (ageMonths < 12) return 1.3;
    if (ageMonths < 24) return 1.0;
    return 0.8;
  }

  Future<List<GrowthAssessment>> calculateHistoricalAssessments({
    required Child child,
    required List<GrowthRecord> growthRecords,
    String? standardSource,
  }) async {
    final assessments = <GrowthAssessment>[];
    
    for (final record in growthRecords) {
      final assessment = await calculateGrowthAssessment(
        child: child,
        growthRecord: record,
        standardSource: standardSource,
      );
      assessments.add(assessment);
    }
    
    return assessments;
  }
}

class GrowthAssessment {
  final String childId;
  final DateTime assessmentDate;
  final int ageMonths;
  final double weight;
  final double height;
  final double? headCircumference;
  final double weightForAgeZScore;
  final double heightForAgeZScore;
  final double weightForHeightZScore;
  final double bmiForAgeZScore;
  final double? headCircumferenceZScore;
  final NutritionalStatus nutritionalStatus;
  final RiskLevel riskLevel;
  final List<String> recommendations;

  GrowthAssessment({
    required this.childId,
    required this.assessmentDate,
    required this.ageMonths,
    required this.weight,
    required this.height,
    this.headCircumference,
    required this.weightForAgeZScore,
    required this.heightForAgeZScore,
    required this.weightForHeightZScore,
    required this.bmiForAgeZScore,
    this.headCircumferenceZScore,
    required this.nutritionalStatus,
    required this.riskLevel,
    required this.recommendations,
  });

  double get bmi => weight / math.pow(height / 100, 2);

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'ageMonths': ageMonths,
      'weight': weight,
      'height': height,
      'headCircumference': headCircumference,
      'weightForAgeZScore': weightForAgeZScore,
      'heightForAgeZScore': heightForAgeZScore,
      'weightForHeightZScore': weightForHeightZScore,
      'bmiForAgeZScore': bmiForAgeZScore,
      'headCircumferenceZScore': headCircumferenceZScore,
      'nutritionalStatus': nutritionalStatus.name,
      'riskLevel': riskLevel.name,
      'recommendations': recommendations.join('|'),
    };
  }
}

class GrowthVelocity {
  final double weightVelocityPerMonth;
  final double heightVelocityPerMonth;
  final double expectedWeightVelocity;
  final double expectedHeightVelocity;
  final bool isAdequateWeightGain;
  final bool isAdequateHeightGain;
  final int timePeriodMonths;

  GrowthVelocity({
    required this.weightVelocityPerMonth,
    required this.heightVelocityPerMonth,
    required this.expectedWeightVelocity,
    required this.expectedHeightVelocity,
    required this.isAdequateWeightGain,
    required this.isAdequateHeightGain,
    required this.timePeriodMonths,
  });

  factory GrowthVelocity.insufficient() {
    return GrowthVelocity(
      weightVelocityPerMonth: 0,
      heightVelocityPerMonth: 0,
      expectedWeightVelocity: 0,
      expectedHeightVelocity: 0,
      isAdequateWeightGain: false,
      isAdequateHeightGain: false,
      timePeriodMonths: 0,
    );
  }

  bool get isAdequateGrowth => isAdequateWeightGain && isAdequateHeightGain;
}

enum NutritionalStatus {
  severeAcuteMalnutrition,
  moderateAcuteMalnutrition,
  stunting,
  normal,
  overweight,
  obesity,
}

enum RiskLevel {
  low,
  moderate,
  high,
  critical,
}

extension NutritionalStatusExtension on NutritionalStatus {
  String get displayName {
    switch (this) {
      case NutritionalStatus.severeAcuteMalnutrition:
        return 'Severe Acute Malnutrition';
      case NutritionalStatus.moderateAcuteMalnutrition:
        return 'Moderate Acute Malnutrition';
      case NutritionalStatus.stunting:
        return 'Stunting';
      case NutritionalStatus.normal:
        return 'Normal';
      case NutritionalStatus.overweight:
        return 'Overweight';
      case NutritionalStatus.obesity:
        return 'Obesity';
    }
  }

  String get description {
    switch (this) {
      case NutritionalStatus.severeAcuteMalnutrition:
        return 'Child requires immediate medical intervention';
      case NutritionalStatus.moderateAcuteMalnutrition:
        return 'Child needs enhanced nutrition support';
      case NutritionalStatus.stunting:
        return 'Child shows signs of chronic malnutrition';
      case NutritionalStatus.normal:
        return 'Child is growing normally';
      case NutritionalStatus.overweight:
        return 'Child is above normal weight range';
      case NutritionalStatus.obesity:
        return 'Child requires weight management support';
    }
  }
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.low:
        return 'Continue regular monitoring';
      case RiskLevel.moderate:
        return 'Increased monitoring recommended';
      case RiskLevel.high:
        return 'Frequent monitoring and intervention needed';
      case RiskLevel.critical:
        return 'Immediate medical attention required';
    }
  }
}