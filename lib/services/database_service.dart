import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/vaccine.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aayu.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE children (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthWeight REAL,
        birthHeight REAL,
        bloodType TEXT,
        photoUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_records (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        headCircumference REAL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        nameLocal TEXT NOT NULL,
        description TEXT NOT NULL,
        recommendedAgeMonths INTEGER NOT NULL,
        isMandatory INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccine_records (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        vaccineId TEXT NOT NULL,
        givenDate TEXT NOT NULL,
        location TEXT,
        doctorName TEXT,
        batchNumber TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id),
        FOREIGN KEY (vaccineId) REFERENCES vaccines (id)
      )
    ''');

    await _createStandardsTables(db);
    await _insertDefaultVaccines(db);
  }

  Future<void> _insertDefaultVaccines(Database db) async {
    final vaccines = [
      {'id': 'bcg', 'name': 'BCG', 'nameLocal': 'බීසීජී', 'description': 'Tuberculosis vaccine', 'recommendedAgeMonths': 0, 'isMandatory': 1, 'category': 'birth'},
      {'id': 'hepb_birth', 'name': 'Hepatitis B', 'nameLocal': 'හෙපටයිටිස් බී', 'description': 'Hepatitis B vaccine - Birth dose', 'recommendedAgeMonths': 0, 'isMandatory': 1, 'category': 'birth'},
      {'id': 'opv_0', 'name': 'OPV 0', 'nameLocal': 'ඕපීවී 0', 'description': 'Oral Polio vaccine - Birth dose', 'recommendedAgeMonths': 0, 'isMandatory': 1, 'category': 'birth'},
      {'id': 'pentavalent_1', 'name': 'Pentavalent 1', 'nameLocal': 'පංචසංයුජ 1', 'description': 'DPT-HepB-Hib vaccine - 1st dose', 'recommendedAgeMonths': 2, 'isMandatory': 1, 'category': '2months'},
      {'id': 'opv_1', 'name': 'OPV 1', 'nameLocal': 'ඕපීවී 1', 'description': 'Oral Polio vaccine - 1st dose', 'recommendedAgeMonths': 2, 'isMandatory': 1, 'category': '2months'},
      {'id': 'pentavalent_2', 'name': 'Pentavalent 2', 'nameLocal': 'පංචසංයුජ 2', 'description': 'DPT-HepB-Hib vaccine - 2nd dose', 'recommendedAgeMonths': 4, 'isMandatory': 1, 'category': '4months'},
      {'id': 'opv_2', 'name': 'OPV 2', 'nameLocal': 'ඕපීවී 2', 'description': 'Oral Polio vaccine - 2nd dose', 'recommendedAgeMonths': 4, 'isMandatory': 1, 'category': '4months'},
      {'id': 'pentavalent_3', 'name': 'Pentavalent 3', 'nameLocal': 'පංචසංයුජ 3', 'description': 'DPT-HepB-Hib vaccine - 3rd dose', 'recommendedAgeMonths': 6, 'isMandatory': 1, 'category': '6months'},
      {'id': 'opv_3', 'name': 'OPV 3', 'nameLocal': 'ඕපීවී 3', 'description': 'Oral Polio vaccine - 3rd dose', 'recommendedAgeMonths': 6, 'isMandatory': 1, 'category': '6months'},
      {'id': 'mmr', 'name': 'MMR', 'nameLocal': 'එම්එම්ආර්', 'description': 'Measles, Mumps, Rubella vaccine', 'recommendedAgeMonths': 9, 'isMandatory': 1, 'category': '9months'},
      {'id': 'je', 'name': 'Japanese Encephalitis', 'nameLocal': 'ජපන් මොළ දැවිල්ල', 'description': 'Japanese Encephalitis vaccine', 'recommendedAgeMonths': 9, 'isMandatory': 1, 'category': '9months'},
    ];

    for (var vaccine in vaccines) {
      await db.insert('vaccines', vaccine);
    }
  }

  Future<void> _createStandardsTables(Database db) async {
    await db.execute('''
      CREATE TABLE growth_standards (
        id TEXT PRIMARY KEY,
        standardType TEXT NOT NULL,
        source TEXT NOT NULL,
        gender TEXT NOT NULL,
        ageMonths INTEGER NOT NULL,
        zScoreMinus3 REAL NOT NULL,
        zScoreMinus2 REAL NOT NULL,
        median REAL NOT NULL,
        zScorePlus2 REAL NOT NULL,
        zScorePlus3 REAL NOT NULL,
        measurementType TEXT NOT NULL,
        unit TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE nutrition_guidelines (
        id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        ageMonthsMin INTEGER NOT NULL,
        ageMonthsMax INTEGER NOT NULL,
        feedingType TEXT NOT NULL,
        dailyMealsCount INTEGER NOT NULL,
        dailySnacksCount INTEGER NOT NULL,
        dailyCaloriesMin REAL NOT NULL,
        dailyCaloriesMax REAL NOT NULL,
        proteinGramsMin REAL NOT NULL,
        proteinGramsMax REAL NOT NULL,
        feedingFrequency TEXT NOT NULL,
        recommendedFoods TEXT NOT NULL,
        avoidedFoods TEXT NOT NULL,
        specialInstructions TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE feeding_recommendations (
        id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        ageMonthsMin INTEGER NOT NULL,
        ageMonthsMax INTEGER NOT NULL,
        mealType TEXT NOT NULL,
        foodCategory TEXT NOT NULL,
        foodItem TEXT NOT NULL,
        portionSize TEXT NOT NULL,
        frequency TEXT NOT NULL,
        preparationNotes TEXT NOT NULL,
        isLocalFood INTEGER NOT NULL,
        nutritionalBenefits TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE development_milestones (
        id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        ageMonthsMin INTEGER NOT NULL,
        ageMonthsMax INTEGER NOT NULL,
        domain TEXT NOT NULL,
        milestone TEXT NOT NULL,
        description TEXT NOT NULL,
        observationTips TEXT NOT NULL,
        isRedFlag INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        activities TEXT NOT NULL,
        redFlagSigns TEXT NOT NULL,
        interventionGuidance TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE milestone_records (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        milestoneId TEXT NOT NULL,
        observedDate TEXT NOT NULL,
        achieved INTEGER NOT NULL,
        observerNotes TEXT NOT NULL,
        concerns TEXT,
        confidenceLevel INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id),
        FOREIGN KEY (milestoneId) REFERENCES development_milestones (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE nutritional_alerts (
        id TEXT PRIMARY KEY,
        alertType TEXT NOT NULL,
        severity TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        actionRequired TEXT NOT NULL,
        requiresImmediateAttention INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE development_alerts (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        alertType TEXT NOT NULL,
        severity TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        missedMilestones TEXT NOT NULL,
        redFlags TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        requiresEvaluation INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        resolvedAt TEXT,
        FOREIGN KEY (childId) REFERENCES children (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createStandardsTables(db);
    }
  }

  Future<String> insertChild(Child child) async {
    final db = await database;
    await db.insert('children', child.toMap());
    return child.id;
  }

  Future<List<Child>> getChildren() async {
    final db = await database;
    final maps = await db.query('children');
    return maps.map((map) => Child.fromMap(map)).toList();
  }

  Future<Child?> getChild(String id) async {
    final db = await database;
    final maps = await db.query(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Child.fromMap(maps.first);
  }

  Future<void> updateChild(Child child) async {
    final db = await database;
    await db.update(
      'children',
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }

  Future<void> deleteChild(String id) async {
    final db = await database;
    await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> insertGrowthRecord(GrowthRecord record) async {
    final db = await database;
    await db.insert('growth_records', record.toMap());
    return record.id;
  }

  Future<List<GrowthRecord>> getGrowthRecords(String childId) async {
    final db = await database;
    final maps = await db.query(
      'growth_records',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => GrowthRecord.fromMap(map)).toList();
  }

  Future<List<Vaccine>> getVaccines() async {
    final db = await database;
    final maps = await db.query('vaccines', orderBy: 'recommendedAgeMonths');
    return maps.map((map) => Vaccine.fromMap(map)).toList();
  }

  Future<String> insertVaccineRecord(VaccineRecord record) async {
    final db = await database;
    await db.insert('vaccine_records', record.toMap());
    return record.id;
  }

  Future<List<VaccineRecord>> getVaccineRecords(String childId) async {
    final db = await database;
    final maps = await db.query(
      'vaccine_records',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'givenDate DESC',
    );
    return maps.map((map) => VaccineRecord.fromMap(map)).toList();
  }
}