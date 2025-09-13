import '../models/growth_standard.dart';
import '../models/nutrition_guideline.dart';
import '../models/development_milestone.dart';
import '../services/database_service.dart';
import '../services/standards_service.dart';

class StandardsRepository {
  static final StandardsRepository _instance = StandardsRepository._internal();
  factory StandardsRepository() => _instance;
  StandardsRepository._internal();

  final DatabaseService _databaseService = DatabaseService();
  final StandardsService _standardsService = StandardsService();

  String _currentStandardSource = 'WHO';
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _standardsService.initialize();
    await _populateDatabase();
    _isInitialized = true;
  }

  Future<void> _populateDatabase() async {
    final db = await _databaseService.database;
    
    final existingStandards = await db.query('growth_standards', limit: 1);
    if (existingStandards.isNotEmpty) {
      return;
    }

    final whoGrowthStandards = _standardsService.getGrowthStandards(source: 'WHO');
    final sriLankaGrowthStandards = _standardsService.getGrowthStandards(source: 'SriLanka');
    final whoNutritionGuidelines = _standardsService.getNutritionGuidelines(source: 'WHO');
    final sriLankaNutritionGuidelines = _standardsService.getNutritionGuidelines(source: 'SriLanka');
    final whoDevelopmentMilestones = _standardsService.getDevelopmentMilestones(source: 'WHO');
    final sriLankaDevelopmentMilestones = _standardsService.getDevelopmentMilestones(source: 'SriLanka');

    for (final standard in [...whoGrowthStandards, ...sriLankaGrowthStandards]) {
      await db.insert('growth_standards', standard.toMap());
    }

    for (final guideline in [...whoNutritionGuidelines, ...sriLankaNutritionGuidelines]) {
      await db.insert('nutrition_guidelines', guideline.toMap());
    }

    for (final milestone in [...whoDevelopmentMilestones, ...sriLankaDevelopmentMilestones]) {
      await db.insert('development_milestones', milestone.toMap());
    }
  }

  void setStandardSource(String source) {
    if (source == 'WHO' || source == 'SriLanka') {
      _currentStandardSource = source;
    }
  }

  String get currentStandardSource => _currentStandardSource;

  Future<List<GrowthStandard>> getGrowthStandards({String? source}) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'growth_standards',
      where: 'source = ?',
      whereArgs: [effectiveSource],
      orderBy: 'ageMonths ASC, measurementType ASC',
    );

    return maps.map((map) => GrowthStandard.fromMap(map)).toList();
  }

  Future<GrowthStandard?> getGrowthStandardForChild({
    required int ageMonths,
    required String gender,
    required String measurementType,
    String? source,
  }) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'growth_standards',
      where: 'source = ? AND ageMonths = ? AND (gender = ? OR gender = ?) AND measurementType = ?',
      whereArgs: [effectiveSource, ageMonths, gender, 'mixed', measurementType],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return GrowthStandard.fromMap(maps.first);
  }

  Future<List<NutritionGuideline>> getNutritionGuidelines({String? source}) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'nutrition_guidelines',
      where: 'source = ?',
      whereArgs: [effectiveSource],
      orderBy: 'ageMonthsMin ASC',
    );

    return maps.map((map) => NutritionGuideline.fromMap(map)).toList();
  }

  Future<List<NutritionGuideline>> getNutritionGuidelinesForAge({
    required int ageMonths,
    String? source,
  }) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'nutrition_guidelines',
      where: 'source = ? AND ageMonthsMin <= ? AND ageMonthsMax >= ?',
      whereArgs: [effectiveSource, ageMonths, ageMonths],
      orderBy: 'ageMonthsMin ASC',
    );

    return maps.map((map) => NutritionGuideline.fromMap(map)).toList();
  }

  Future<List<DevelopmentMilestone>> getDevelopmentMilestones({String? source}) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'development_milestones',
      where: 'source = ?',
      whereArgs: [effectiveSource],
      orderBy: 'ageMonthsMin ASC, priority ASC',
    );

    return maps.map((map) => DevelopmentMilestone.fromMap(map)).toList();
  }

  Future<List<DevelopmentMilestone>> getMilestonesForAge({
    required int ageMonths,
    String? domain,
    String? source,
  }) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    String whereClause = 'source = ? AND ageMonthsMin <= ? AND ageMonthsMax >= ?';
    List<dynamic> whereArgs = [effectiveSource, ageMonths, ageMonths];

    if (domain != null) {
      whereClause += ' AND domain = ?';
      whereArgs.add(domain);
    }

    final maps = await db.query(
      'development_milestones',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'priority ASC, ageMonthsMin ASC',
    );

    return maps.map((map) => DevelopmentMilestone.fromMap(map)).toList();
  }

  Future<double> calculateZScore({
    required double actualValue,
    required int ageMonths,
    required String gender,
    required String measurementType,
    String? source,
  }) async {
    final standard = await getGrowthStandardForChild(
      ageMonths: ageMonths,
      gender: gender,
      measurementType: measurementType,
      source: source,
    );

    if (standard == null) return 0.0;
    return standard.calculateZScore(actualValue);
  }

  Future<NutritionalClassification> getNutritionalClassification({
    required double zScore,
    required String measurementType,
  }) async {
    return NutritionalClassification.getClassificationForZScore(zScore, measurementType);
  }

  Future<List<String>> getAvailableSources() async {
    await initialize();
    final db = await _databaseService.database;
    
    final maps = await db.rawQuery('SELECT DISTINCT source FROM growth_standards');
    return maps.map((map) => map['source'] as String).toList();
  }

  Future<void> addMilestoneRecord(MilestoneRecord record) async {
    final db = await _databaseService.database;
    await db.insert('milestone_records', record.toMap());
  }

  Future<List<MilestoneRecord>> getMilestoneRecords(String childId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'milestone_records',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'observedDate DESC',
    );

    return maps.map((map) => MilestoneRecord.fromMap(map)).toList();
  }

  Future<void> addNutritionalAlert(NutritionalAlert alert) async {
    final db = await _databaseService.database;
    await db.insert('nutritional_alerts', alert.toMap());
  }

  Future<void> addDevelopmentAlert(DevelopmentAlert alert) async {
    final db = await _databaseService.database;
    await db.insert('development_alerts', alert.toMap());
  }

  Future<List<DevelopmentAlert>> getDevelopmentAlerts(String childId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'development_alerts',
      where: 'childId = ? AND resolvedAt IS NULL',
      whereArgs: [childId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => DevelopmentAlert.fromMap(map)).toList();
  }

  Future<void> resolveDevelopmentAlert(String alertId) async {
    final db = await _databaseService.database;
    await db.update(
      'development_alerts',
      {'resolvedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  Future<Map<String, int>> getStandardsStats() async {
    await initialize();
    final db = await _databaseService.database;
    
    final growthStandardsCount = await db.rawQuery('SELECT COUNT(*) as count FROM growth_standards');
    final nutritionGuidelinesCount = await db.rawQuery('SELECT COUNT(*) as count FROM nutrition_guidelines');
    final milestonesCount = await db.rawQuery('SELECT COUNT(*) as count FROM development_milestones');
    
    return {
      'growthStandards': growthStandardsCount.first['count'] as int,
      'nutritionGuidelines': nutritionGuidelinesCount.first['count'] as int,
      'developmentMilestones': milestonesCount.first['count'] as int,
    };
  }

  Future<void> clearAllStandards() async {
    final db = await _databaseService.database;
    await db.delete('growth_standards');
    await db.delete('nutrition_guidelines');
    await db.delete('development_milestones');
    _isInitialized = false;
  }

  Future<void> refreshStandards() async {
    await clearAllStandards();
    await initialize();
  }

  Future<List<GrowthStandard>> getGrowthStandardsForMeasurement({
    required String measurementType,
    required String gender,
    String? source,
  }) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final maps = await db.query(
      'growth_standards',
      where: 'source = ? AND measurementType = ? AND (gender = ? OR gender = ?)',
      whereArgs: [effectiveSource, measurementType, gender, 'mixed'],
      orderBy: 'ageMonths ASC',
    );

    return maps.map((map) => GrowthStandard.fromMap(map)).toList();
  }

  Future<bool> hasDataForAge(int ageMonths, {String? source}) async {
    await initialize();
    final db = await _databaseService.database;
    
    final effectiveSource = source ?? _currentStandardSource;
    final growthData = await db.query(
      'growth_standards',
      where: 'source = ? AND ageMonths = ?',
      whereArgs: [effectiveSource, ageMonths],
      limit: 1,
    );

    return growthData.isNotEmpty;
  }
}