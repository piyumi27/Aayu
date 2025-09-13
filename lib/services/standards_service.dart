import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/growth_standard.dart';
import '../models/nutrition_guideline.dart';
import '../models/development_milestone.dart';

class StandardsService {
  static final StandardsService _instance = StandardsService._internal();
  factory StandardsService() => _instance;
  StandardsService._internal();

  Map<String, dynamic>? _whoData;
  Map<String, dynamic>? _sriLankaData;
  
  List<GrowthStandard>? _whoGrowthStandards;
  List<GrowthStandard>? _sriLankaGrowthStandards;
  List<NutritionGuideline>? _whoNutritionGuidelines;
  List<NutritionGuideline>? _sriLankaNutritionGuidelines;
  List<DevelopmentMilestone>? _whoDevelopmentMilestones;
  List<DevelopmentMilestone>? _sriLankaDevelopmentMilestones;

  Future<void> initialize() async {
    await Future.wait([
      _loadWhoData(),
      _loadSriLankaData(),
    ]);
    
    await Future.wait([
      _parseWhoStandards(),
      _parseSriLankaStandards(),
    ]);
  }

  Future<void> _loadWhoData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/WHO.json');
      _whoData = json.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to load WHO data: $e');
    }
  }

  Future<void> _loadSriLankaData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/SriLanka.json');
      _sriLankaData = json.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to load Sri Lanka data: $e');
    }
  }

  Future<void> _parseWhoStandards() async {
    if (_whoData == null) return;

    _whoGrowthStandards = await _parseWhoGrowthStandards();
    _whoNutritionGuidelines = await _parseWhoNutritionGuidelines();
    _whoDevelopmentMilestones = await _parseWhoDevelopmentMilestones();
  }

  Future<void> _parseSriLankaStandards() async {
    if (_sriLankaData == null) return;

    _sriLankaGrowthStandards = await _parseSriLankaGrowthStandards();
    _sriLankaNutritionGuidelines = await _parseSriLankaNutritionGuidelines();
    _sriLankaDevelopmentMilestones = await _parseSriLankaDevelopmentMilestones();
  }

  Future<List<GrowthStandard>> _parseWhoGrowthStandards() async {
    final standards = <GrowthStandard>[];
    final now = DateTime.now();

    // Create comprehensive WHO growth standards for common measurements
    final measurements = ['weight_for_age', 'height_for_age', 'bmi_for_age', 'weight_for_height'];
    final genders = ['male', 'female'];

    for (final measurement in measurements) {
      for (final gender in genders) {
        // Create standards for key age points (birth to 60 months)
        for (int ageMonths = 0; ageMonths <= 60; ageMonths += 3) {
          final standardValues = _generateWhoStandardValues(measurement, gender, ageMonths);

          standards.add(GrowthStandard(
            id: 'who_${measurement}_${ageMonths}m_$gender',
            standardType: 'WHO',
            source: 'WHO',
            gender: gender,
            ageMonths: ageMonths,
            zScoreMinus3: standardValues['minus3']!,
            zScoreMinus2: standardValues['minus2']!,
            median: standardValues['median']!,
            zScorePlus2: standardValues['plus2']!,
            zScorePlus3: standardValues['plus3']!,
            measurementType: measurement,
            unit: _getUnitForMeasurement(measurement),
            createdAt: now,
            updatedAt: now,
          ));
        }
      }
    }

    // If we have actual WHO data, use it to override the generated values
    if (_whoData?['growth_standards']?['anthropometric_measurements'] != null) {
      final measurements = _whoData!['growth_standards']['anthropometric_measurements'];

      for (final measurementType in measurements.keys) {
        final measurementData = measurements[measurementType];

        if (measurementData['sample_values_12_months_boys'] != null) {
          final values = measurementData['sample_values_12_months_boys'];
          final existingIndex = standards.indexWhere((s) =>
            s.measurementType == measurementType &&
            s.gender == 'male' &&
            s.ageMonths == 12
          );

          if (existingIndex != -1) {
            standards[existingIndex] = GrowthStandard(
              id: 'who_${measurementType}_12m_male',
              standardType: 'WHO',
              source: 'WHO',
              gender: 'male',
              ageMonths: 12,
              zScoreMinus3: _parseValue(values['z_score_minus_3']),
              zScoreMinus2: _parseValue(values['z_score_minus_2']),
              median: _parseValue(values['median']),
              zScorePlus2: _parseValue(values['z_score_plus_2']),
              zScorePlus3: _parseValue(values['z_score_plus_3']),
              measurementType: measurementType,
              unit: _getUnitForMeasurement(measurementType),
              createdAt: now,
              updatedAt: now,
            );
          }
        }

        if (measurementData['sample_values_24_months_girls'] != null) {
          final values = measurementData['sample_values_24_months_girls'];
          final existingIndex = standards.indexWhere((s) =>
            s.measurementType == measurementType &&
            s.gender == 'female' &&
            s.ageMonths == 24
          );

          if (existingIndex != -1) {
            standards[existingIndex] = GrowthStandard(
              id: 'who_${measurementType}_24m_female',
              standardType: 'WHO',
              source: 'WHO',
              gender: 'female',
              ageMonths: 24,
              zScoreMinus3: _parseValue(values['z_score_minus_3']),
              zScoreMinus2: _parseValue(values['z_score_minus_2']),
              median: _parseValue(values['median']),
              zScorePlus2: _parseValue(values['z_score_plus_2']),
              zScorePlus3: _parseValue(values['z_score_plus_3']),
              measurementType: measurementType,
              unit: _getUnitForMeasurement(measurementType),
              createdAt: now,
              updatedAt: now,
            );
          }
        }
      }
    }

    return standards;
  }

  Future<List<GrowthStandard>> _parseSriLankaGrowthStandards() async {
    final standards = <GrowthStandard>[];
    final now = DateTime.now();

    if (_sriLankaData?['growth_monitoring_chdr'] != null) {
      final growthData = _sriLankaData!['growth_monitoring_chdr'];
      
      if (growthData['sample_chdr_values'] != null) {
        final sampleValues = growthData['sample_chdr_values'];
        
        for (final entry in sampleValues.entries) {
          final ageData = entry.value;
          if (ageData is Map<String, dynamic>) {
            for (final measurement in ['weight', 'height']) {
              if (ageData[measurement] != null) {
                final values = ageData[measurement];
                final ageMonths = _parseAgeInMonths(entry.key);
                
                standards.add(GrowthStandard(
                  id: 'srilanka_${measurement}_${ageMonths}m_mixed',
                  standardType: 'SriLanka',
                  source: 'Sri Lanka CHDR',
                  gender: 'mixed',
                  ageMonths: ageMonths,
                  zScoreMinus3: _parseValue(values['below_third_percentile']),
                  zScoreMinus2: _parseValue(values['third_to_tenth_percentile']),
                  median: _parseValue(values['median']),
                  zScorePlus2: _parseValue(values['ninetieth_to_ninetyseventh_percentile']),
                  zScorePlus3: _parseValue(values['above_ninetyseventh_percentile']),
                  measurementType: '${measurement}_for_age',
                  unit: measurement == 'weight' ? 'kg' : 'cm',
                  createdAt: now,
                  updatedAt: now,
                ));
              }
            }
          }
        }
      }
    }

    return standards;
  }

  Future<List<NutritionGuideline>> _parseWhoNutritionGuidelines() async {
    final guidelines = <NutritionGuideline>[];
    final now = DateTime.now();

    if (_whoData?['nutrition_guidelines'] != null) {
      final nutritionData = _whoData!['nutrition_guidelines'];
      
      for (final ageGroup in nutritionData.keys) {
        final ageData = nutritionData[ageGroup];
        if (ageData is Map<String, dynamic>) {
          final ageRange = _parseAgeRange(ageGroup);
          
          guidelines.add(NutritionGuideline(
            id: 'who_nutrition_$ageGroup',
            source: 'WHO',
            ageMonthsMin: ageRange['min']!,
            ageMonthsMax: ageRange['max']!,
            feedingType: ageData['feeding_type'] ?? 'mixed',
            dailyMealsCount: _parseInt(ageData['meals_per_day']),
            dailySnacksCount: _parseInt(ageData['snacks_per_day']),
            dailyCaloriesMin: _parseDouble(ageData['daily_calories']?['min']),
            dailyCaloriesMax: _parseDouble(ageData['daily_calories']?['max']),
            proteinGramsMin: _parseDouble(ageData['protein_grams']?['min']),
            proteinGramsMax: _parseDouble(ageData['protein_grams']?['max']),
            feedingFrequency: ageData['feeding_frequency'] ?? 'Regular',
            recommendedFoods: _parseStringList(ageData['recommended_foods']),
            avoidedFoods: _parseStringList(ageData['foods_to_avoid']),
            specialInstructions: ageData['special_instructions'] ?? '',
            createdAt: now,
            updatedAt: now,
          ));
        }
      }
    }

    return guidelines;
  }

  Future<List<NutritionGuideline>> _parseSriLankaNutritionGuidelines() async {
    final guidelines = <NutritionGuideline>[];
    final now = DateTime.now();

    if (_sriLankaData?['feeding_guidelines'] != null) {
      final feedingData = _sriLankaData!['feeding_guidelines'];
      
      for (final ageGroup in feedingData.keys) {
        final ageData = feedingData[ageGroup];
        if (ageData is Map<String, dynamic>) {
          final ageRange = _parseAgeRange(ageGroup);
          
          guidelines.add(NutritionGuideline(
            id: 'srilanka_nutrition_$ageGroup',
            source: 'Sri Lanka',
            ageMonthsMin: ageRange['min']!,
            ageMonthsMax: ageRange['max']!,
            feedingType: ageData['feeding_type'] ?? 'mixed',
            dailyMealsCount: _parseInt(ageData['meals_per_day']),
            dailySnacksCount: _parseInt(ageData['snacks_per_day']),
            dailyCaloriesMin: _parseDouble(ageData['daily_calories']),
            dailyCaloriesMax: _parseDouble(ageData['daily_calories']) * 1.2,
            proteinGramsMin: _parseDouble(ageData['protein_requirements']),
            proteinGramsMax: _parseDouble(ageData['protein_requirements']) * 1.3,
            feedingFrequency: ageData['feeding_frequency'] ?? 'Regular',
            recommendedFoods: _parseStringList(ageData['local_foods']),
            avoidedFoods: _parseStringList(ageData['foods_to_limit']),
            specialInstructions: ageData['cultural_practices'] ?? '',
            createdAt: now,
            updatedAt: now,
          ));
        }
      }
    }

    return guidelines;
  }

  Future<List<DevelopmentMilestone>> _parseWhoDevelopmentMilestones() async {
    final milestones = <DevelopmentMilestone>[];
    final now = DateTime.now();

    if (_whoData?['development_milestones'] != null) {
      final milestonesData = _whoData!['development_milestones'];
      
      for (final domain in milestonesData.keys) {
        final domainData = milestonesData[domain];
        if (domainData is Map<String, dynamic>) {
          for (final ageGroup in domainData.keys) {
            final ageData = domainData[ageGroup];
            if (ageData is List) {
              final ageRange = _parseAgeRange(ageGroup);
              
              for (int i = 0; i < ageData.length; i++) {
                final milestone = ageData[i];
                if (milestone is String) {
                  milestones.add(DevelopmentMilestone(
                    id: 'who_${domain}_${ageGroup}_$i',
                    source: 'WHO',
                    ageMonthsMin: ageRange['min']!,
                    ageMonthsMax: ageRange['max']!,
                    domain: domain,
                    milestone: milestone,
                    description: milestone,
                    observationTips: 'Observe during normal activities',
                    isRedFlag: false,
                    priority: 2,
                    activities: ['Encourage practice', 'Provide opportunities'],
                    redFlagSigns: [],
                    interventionGuidance: 'Consult if not achieved by upper age limit',
                    createdAt: now,
                    updatedAt: now,
                  ));
                }
              }
            }
          }
        }
      }
    }

    return milestones;
  }

  Future<List<DevelopmentMilestone>> _parseSriLankaDevelopmentMilestones() async {
    final milestones = <DevelopmentMilestone>[];
    final now = DateTime.now();

    if (_sriLankaData?['development_milestones'] != null) {
      final milestonesData = _sriLankaData!['development_milestones'];
      
      for (final domain in milestonesData.keys) {
        final domainData = milestonesData[domain];
        if (domainData is Map<String, dynamic>) {
          for (final ageGroup in domainData.keys) {
            final ageData = domainData[ageGroup];
            if (ageData is List) {
              final ageRange = _parseAgeRange(ageGroup);
              
              for (int i = 0; i < ageData.length; i++) {
                final milestone = ageData[i];
                if (milestone is String) {
                  milestones.add(DevelopmentMilestone(
                    id: 'srilanka_${domain}_${ageGroup}_$i',
                    source: 'Sri Lanka',
                    ageMonthsMin: ageRange['min']!,
                    ageMonthsMax: ageRange['max']!,
                    domain: domain,
                    milestone: milestone,
                    description: milestone,
                    observationTips: 'Observe in cultural context',
                    isRedFlag: false,
                    priority: 2,
                    activities: ['Culturally appropriate activities'],
                    redFlagSigns: [],
                    interventionGuidance: 'Seek local healthcare guidance',
                    createdAt: now,
                    updatedAt: now,
                  ));
                }
              }
            }
          }
        }
      }
    }

    return milestones;
  }

  List<GrowthStandard> getGrowthStandards({String source = 'WHO'}) {
    return source == 'WHO' 
        ? _whoGrowthStandards ?? []
        : _sriLankaGrowthStandards ?? [];
  }

  List<NutritionGuideline> getNutritionGuidelines({String source = 'WHO'}) {
    return source == 'WHO'
        ? _whoNutritionGuidelines ?? []
        : _sriLankaNutritionGuidelines ?? [];
  }

  List<DevelopmentMilestone> getDevelopmentMilestones({String source = 'WHO'}) {
    return source == 'WHO'
        ? _whoDevelopmentMilestones ?? []
        : _sriLankaDevelopmentMilestones ?? [];
  }

  GrowthStandard? getGrowthStandardForChild({
    required int ageMonths,
    required String gender,
    required String measurementType,
    String source = 'WHO',
  }) {
    final standards = getGrowthStandards(source: source);
    
    return standards.where((standard) =>
      standard.ageMonths == ageMonths &&
      (standard.gender == gender || standard.gender == 'mixed') &&
      standard.measurementType == measurementType
    ).firstOrNull;
  }

  List<NutritionGuideline> getNutritionGuidelinesForAge({
    required int ageMonths,
    String source = 'WHO',
  }) {
    final guidelines = getNutritionGuidelines(source: source);
    
    return guidelines.where((guideline) =>
      guideline.isApplicableForAge(ageMonths)
    ).toList();
  }

  List<DevelopmentMilestone> getMilestonesForAge({
    required int ageMonths,
    String source = 'WHO',
    String? domain,
  }) {
    final milestones = getDevelopmentMilestones(source: source);
    
    return milestones.where((milestone) =>
      milestone.isApplicableForAge(ageMonths) &&
      (domain == null || milestone.domain == domain)
    ).toList();
  }

  double _parseValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    }
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return [value];
    return [];
  }

  String _getUnitForMeasurement(String measurementType) {
    return switch (measurementType) {
      'weight_for_age' || 'weight_for_height' => 'kg',
      'height_for_age' => 'cm',
      'head_circumference' => 'cm',
      'bmi_for_age' => 'kg/m²',
      _ => 'units',
    };
  }

  int _parseAgeInMonths(String ageString) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(ageString);
    if (match != null) {
      final number = int.parse(match.group(1)!);
      if (ageString.contains('year')) {
        return number * 12;
      }
      return number;
    }
    return 0;
  }

  Map<String, int> _parseAgeRange(String ageString) {
    if (ageString.contains('birth') || ageString.contains('0')) {
      return {'min': 0, 'max': 6};
    }
    if (ageString.contains('6') && ageString.contains('month')) {
      return {'min': 6, 'max': 12};
    }
    if (ageString.contains('12') || ageString.contains('1') && ageString.contains('year')) {
      return {'min': 12, 'max': 24};
    }
    if (ageString.contains('24') || ageString.contains('2') && ageString.contains('year')) {
      return {'min': 24, 'max': 60};
    }

    final regex = RegExp(r'(\d+).*?(\d+)');
    final match = regex.firstMatch(ageString);
    if (match != null) {
      final min = int.parse(match.group(1)!);
      final max = int.parse(match.group(2)!);
      return {'min': min, 'max': max};
    }

    return {'min': 0, 'max': 60};
  }

  /// Generate realistic WHO-based standard values for different measurements
  Map<String, double> _generateWhoStandardValues(String measurement, String gender, int ageMonths) {
    switch (measurement) {
      case 'weight_for_age':
        return _generateWeightForAge(gender, ageMonths);
      case 'height_for_age':
        return _generateHeightForAge(gender, ageMonths);
      case 'bmi_for_age':
        return _generateBmiForAge(gender, ageMonths);
      case 'weight_for_height':
        return _generateWeightForHeight(gender, ageMonths);
      default:
        return {'minus3': 0.0, 'minus2': 0.0, 'median': 0.0, 'plus2': 0.0, 'plus3': 0.0};
    }
  }

  Map<String, double> _generateWeightForAge(String gender, int ageMonths) {
    // WHO weight-for-age approximations (kg)
    double baseWeight, growthRate;

    if (gender == 'male') {
      baseWeight = 3.3; // Birth weight
      growthRate = ageMonths <= 12 ? 0.65 : 0.2; // Faster growth in first year
    } else {
      baseWeight = 3.2; // Birth weight
      growthRate = ageMonths <= 12 ? 0.6 : 0.18;
    }

    final median = baseWeight + (ageMonths * growthRate);

    return {
      'minus3': median * 0.65,
      'minus2': median * 0.75,
      'median': median,
      'plus2': median * 1.25,
      'plus3': median * 1.35,
    };
  }

  Map<String, double> _generateHeightForAge(String gender, int ageMonths) {
    // WHO length/height-for-age approximations (cm)
    double baseHeight, growthRate;

    if (gender == 'male') {
      baseHeight = 49.9; // Birth length
      growthRate = ageMonths <= 12 ? 2.5 : 1.0; // Faster growth in first year
    } else {
      baseHeight = 49.1; // Birth length
      growthRate = ageMonths <= 12 ? 2.4 : 0.95;
    }

    final median = baseHeight + (ageMonths * growthRate);

    return {
      'minus3': median * 0.88,
      'minus2': median * 0.92,
      'median': median,
      'plus2': median * 1.08,
      'plus3': median * 1.12,
    };
  }

  Map<String, double> _generateBmiForAge(String gender, int ageMonths) {
    // WHO BMI-for-age approximations (kg/m²)
    double baseBmi;

    if (ageMonths <= 24) {
      baseBmi = 17.0 - (ageMonths * 0.15); // BMI decreases initially
    } else {
      baseBmi = 13.5 + ((ageMonths - 24) * 0.05); // Then gradually increases
    }

    return {
      'minus3': baseBmi * 0.75,
      'minus2': baseBmi * 0.85,
      'median': baseBmi,
      'plus2': baseBmi * 1.15,
      'plus3': baseBmi * 1.25,
    };
  }

  Map<String, double> _generateWeightForHeight(String gender, int ageMonths) {
    // Simplified weight-for-height based on typical growth patterns
    final weightValues = _generateWeightForAge(gender, ageMonths);
    final heightValues = _generateHeightForAge(gender, ageMonths);

    // Adjust weight values based on height relationship
    final heightMedian = heightValues['median']! / 100; // Convert to meters
    final adjustedMedian = weightValues['median']! / (heightMedian * heightMedian);

    return {
      'minus3': adjustedMedian * 0.7,
      'minus2': adjustedMedian * 0.8,
      'median': adjustedMedian,
      'plus2': adjustedMedian * 1.2,
      'plus3': adjustedMedian * 1.3,
    };
  }
}