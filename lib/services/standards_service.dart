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
      final String jsonString = await rootBundle.loadString('assets/data/Srilanka.json');
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

    if (_whoData?['growth_standards']?['anthropometric_measurements'] != null) {
      final measurements = _whoData!['growth_standards']['anthropometric_measurements'];
      
      for (final measurementType in measurements.keys) {
        final measurementData = measurements[measurementType];
        
        if (measurementData['sample_values_12_months_boys'] != null) {
          final values = measurementData['sample_values_12_months_boys'];
          standards.add(GrowthStandard(
            id: 'who_${measurementType}_12m_boys',
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
          ));
        }

        if (measurementData['sample_values_24_months_girls'] != null) {
          final values = measurementData['sample_values_24_months_girls'];
          standards.add(GrowthStandard(
            id: 'who_${measurementType}_24m_girls',
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
          ));
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
}