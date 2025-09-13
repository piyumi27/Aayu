import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/vaccine.dart';
import '../utils/sri_lankan_vaccination_schedule.dart';

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
      version: 5,
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
        photoPath TEXT,
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
    await _createNotificationTables(db);
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

  Future<void> _createNotificationTables(Database db) async {
    // Notification tokens table
    await db.execute('''
      CREATE TABLE notification_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL,
        platform TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Notification templates table
    await db.execute('''
      CREATE TABLE notification_templates (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        titleKey TEXT NOT NULL,
        contentKey TEXT NOT NULL,
        priority TEXT NOT NULL,
        channelId TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Scheduled notifications table
    await db.execute('''
      CREATE TABLE scheduled_notifications (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        childId TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        channelId TEXT NOT NULL,
        payload TEXT,
        scheduledDate TEXT NOT NULL,
        isRepeating INTEGER NOT NULL DEFAULT 0,
        repeatInterval TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        isSent INTEGER NOT NULL DEFAULT 0,
        sentAt TEXT,
        createdAt TEXT NOT NULL,
        cancelledAt TEXT,
        FOREIGN KEY (childId) REFERENCES children (id)
      )
    ''');

    // Notification history table
    await db.execute('''
      CREATE TABLE notification_history (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        category TEXT,
        priority TEXT,
        channelId TEXT,
        data TEXT,
        payload TEXT,
        receivedState TEXT,
        receivedAt TEXT NOT NULL,
        tappedAt TEXT,
        isProcessed INTEGER NOT NULL DEFAULT 0,
        isRead INTEGER NOT NULL DEFAULT 0,
        isShown INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Notification preferences table
    await db.execute('''
      CREATE TABLE notification_preferences (
        id TEXT PRIMARY KEY,
        userId TEXT,
        category TEXT NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        soundEnabled INTEGER NOT NULL DEFAULT 1,
        vibrationEnabled INTEGER NOT NULL DEFAULT 1,
        quietHoursStart TEXT,
        quietHoursEnd TEXT,
        allowCriticalDuringQuietHours INTEGER NOT NULL DEFAULT 1,
        maxNotificationsPerDay INTEGER DEFAULT 10,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Notification analytics table
    await db.execute('''
      CREATE TABLE notification_analytics (
        id TEXT PRIMARY KEY,
        notificationId TEXT NOT NULL,
        event TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        metadata TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Notification rules table for smart scheduling
    await db.execute('''
      CREATE TABLE notification_rules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        conditions TEXT NOT NULL,
        actions TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 1,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Insert default notification preferences
    await _insertDefaultNotificationPreferences(db);
    
    // Insert default notification templates
    await _insertDefaultNotificationTemplates(db);
    
    // Populate Sri Lankan vaccination schedule
    await _populateVaccines(db);
  }

  Future<void> _insertDefaultNotificationPreferences(Database db) async {
    final defaultPreferences = [
      {
        'id': 'health_alerts',
        'category': 'health_alerts',
        'isEnabled': 1,
        'soundEnabled': 1,
        'vibrationEnabled': 1,
        'allowCriticalDuringQuietHours': 1,
        'maxNotificationsPerDay': 5,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'vaccination_reminders',
        'category': 'vaccination_reminders',
        'isEnabled': 1,
        'soundEnabled': 1,
        'vibrationEnabled': 1,
        'allowCriticalDuringQuietHours': 1,
        'maxNotificationsPerDay': 3,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'growth_reminders',
        'category': 'growth_reminders',
        'isEnabled': 1,
        'soundEnabled': 1,
        'vibrationEnabled': 0,
        'allowCriticalDuringQuietHours': 0,
        'maxNotificationsPerDay': 2,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'feeding_reminders',
        'category': 'feeding_reminders',
        'isEnabled': 1,
        'soundEnabled': 0,
        'vibrationEnabled': 0,
        'allowCriticalDuringQuietHours': 0,
        'maxNotificationsPerDay': 8,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'tips_guidance',
        'category': 'tips_guidance',
        'isEnabled': 1,
        'soundEnabled': 0,
        'vibrationEnabled': 0,
        'allowCriticalDuringQuietHours': 0,
        'maxNotificationsPerDay': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final pref in defaultPreferences) {
      await db.insert('notification_preferences', pref);
    }
  }

  Future<void> _insertDefaultNotificationTemplates(Database db) async {
    final defaultTemplates = [
      {
        'id': 'health_alert_critical',
        'type': 'health_alert',
        'category': 'critical_health_alerts',
        'titleKey': 'notification.health_alert.critical.title',
        'contentKey': 'notification.health_alert.critical.content',
        'priority': 'critical',
        'channelId': 'critical_health_alerts',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'vaccination_reminder_due',
        'type': 'vaccination_reminder',
        'category': 'vaccination_reminders',
        'titleKey': 'notification.vaccination.due.title',
        'contentKey': 'notification.vaccination.due.content',
        'priority': 'high',
        'channelId': 'vaccination_reminders',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'growth_check_monthly',
        'type': 'growth_reminder',
        'category': 'growth_reminders',
        'titleKey': 'notification.growth.monthly.title',
        'contentKey': 'notification.growth.monthly.content',
        'priority': 'medium',
        'channelId': 'growth_reminders',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'milestone_check_reminder',
        'type': 'milestone_reminder',
        'category': 'milestone_reminders',
        'titleKey': 'notification.milestone.check.title',
        'contentKey': 'notification.milestone.check.content',
        'priority': 'medium',
        'channelId': 'milestone_reminders',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final template in defaultTemplates) {
      await db.insert('notification_templates', template);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createStandardsTables(db);
    }
    if (oldVersion < 3) {
      await _createNotificationTables(db);
    }
    if (oldVersion < 4) {
      await _upgradeNotificationHistoryTable(db);
    }
    if (oldVersion < 5) {
      await _addPhotoPathToGrowthRecords(db);
    }
  }

  Future<void> _upgradeNotificationHistoryTable(Database db) async {
    try {
      // Add category and priority columns to notification_history table
      await db.execute('ALTER TABLE notification_history ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE notification_history ADD COLUMN priority TEXT');

      // Update existing records with default values based on type
      await db.execute('''
        UPDATE notification_history
        SET category = CASE
          WHEN type LIKE '%health%' OR type LIKE '%critical%' THEN 'health_alert'
          WHEN type LIKE '%vaccination%' OR type LIKE '%vaccine%' THEN 'vaccination'
          WHEN type LIKE '%growth%' OR type LIKE '%measurement%' THEN 'growth'
          WHEN type LIKE '%milestone%' THEN 'milestone'
          WHEN type LIKE '%feeding%' OR type LIKE '%nutrition%' THEN 'feeding'
          WHEN type LIKE '%medication%' THEN 'medication'
          ELSE 'general'
        END
        WHERE category IS NULL
      ''');

      await db.execute('''
        UPDATE notification_history
        SET priority = CASE
          WHEN type LIKE '%critical%' OR type LIKE '%urgent%' THEN 'critical'
          WHEN type LIKE '%important%' OR type LIKE '%alert%' THEN 'high'
          WHEN type LIKE '%reminder%' THEN 'medium'
          ELSE 'low'
        END
        WHERE priority IS NULL
      ''');
    } catch (e) {
      // If the columns already exist, ignore the error
      print('Migration note: notification_history columns may already exist');
    }
  }

  /// Add photoPath column to growth_records table for existing users
  Future<void> _addPhotoPathToGrowthRecords(Database db) async {
    try {
      // Add photoPath column to growth_records table
      await db.execute('ALTER TABLE growth_records ADD COLUMN photoPath TEXT');
      print('✅ Added photoPath column to growth_records table');
    } catch (e) {
      // If the column already exists, ignore the error
      print('Migration note: photoPath column may already exist in growth_records table');
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

  Future<void> _populateVaccines(Database db) async {
    final vaccines = SriLankanVaccinationSchedule.vaccines;
    for (final vaccine in vaccines) {
      await db.insert(
        'vaccines',
        vaccine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}