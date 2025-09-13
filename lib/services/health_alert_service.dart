import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/nutrition_guideline.dart';
import '../models/development_milestone.dart';
import '../models/notification.dart';
import '../repositories/standards_repository.dart';
import '../services/growth_calculation_service.dart';
import '../services/notification_service.dart';

class HealthAlertService {
  static final HealthAlertService _instance = HealthAlertService._internal();
  factory HealthAlertService() => _instance;
  HealthAlertService._internal();

  final StandardsRepository _standardsRepository = StandardsRepository();
  final GrowthCalculationService _growthCalculationService = GrowthCalculationService();
  final NotificationService _notificationService = NotificationService();

  Future<List<HealthAlert>> assessChildHealth({
    required Child child,
    required List<GrowthRecord> growthRecords,
    required List<MilestoneRecord> milestoneRecords,
    String? standardSource,
  }) async {
    final alerts = <HealthAlert>[];

    if (growthRecords.isNotEmpty) {
      final growthAlerts = await _assessGrowthAlerts(
        child: child,
        growthRecords: growthRecords,
        standardSource: standardSource,
      );
      alerts.addAll(growthAlerts);
    }

    final nutritionAlerts = await _assessNutritionAlerts(
      child: child,
      growthRecords: growthRecords,
      standardSource: standardSource,
    );
    alerts.addAll(nutritionAlerts);

    final developmentAlerts = await _assessDevelopmentAlerts(
      child: child,
      milestoneRecords: milestoneRecords,
      standardSource: standardSource,
    );
    alerts.addAll(developmentAlerts);

    final vaccineAlerts = await _assessVaccinationAlerts(child);
    alerts.addAll(vaccineAlerts);

    for (final alert in alerts.where((a) => a.shouldNotify)) {
      await _triggerNotification(alert);
    }

    return alerts.where((alert) => alert.isActive).toList();
  }

  Future<List<HealthAlert>> _assessGrowthAlerts({
    required Child child,
    required List<GrowthRecord> growthRecords,
    String? standardSource,
  }) async {
    final alerts = <HealthAlert>[];
    
    if (growthRecords.isEmpty) return alerts;

    final latestRecord = growthRecords.last;
    final assessment = await _growthCalculationService.calculateGrowthAssessment(
      child: child,
      growthRecord: latestRecord,
      standardSource: standardSource,
    );

    if (assessment.weightForAgeZScore < -3) {
      alerts.add(HealthAlert(
        id: 'severe_underweight_${child.id}',
        childId: child.id,
        type: AlertType.severeUnderweight,
        severity: AlertSeverity.critical,
        title: 'Severe Underweight Detected',
        message: 'Child\'s weight is severely below normal (Z-score: ${assessment.weightForAgeZScore.toStringAsFixed(1)})',
        recommendations: [
          'Seek immediate medical attention',
          'Consider therapeutic feeding program',
          'Monitor daily weight gain',
          'Check for underlying medical conditions',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.weightForAgeZScore},
      ));
    } else if (assessment.weightForAgeZScore < -2) {
      alerts.add(HealthAlert(
        id: 'moderate_underweight_${child.id}',
        childId: child.id,
        type: AlertType.moderateUnderweight,
        severity: AlertSeverity.high,
        title: 'Moderate Underweight',
        message: 'Child\'s weight is below normal range (Z-score: ${assessment.weightForAgeZScore.toStringAsFixed(1)})',
        recommendations: [
          'Increase feeding frequency',
          'Focus on energy-dense foods',
          'Consult healthcare provider',
          'Monitor weekly measurements',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.weightForAgeZScore},
      ));
    }

    if (assessment.heightForAgeZScore < -3) {
      alerts.add(HealthAlert(
        id: 'severe_stunting_${child.id}',
        childId: child.id,
        type: AlertType.severeStunting,
        severity: AlertSeverity.critical,
        title: 'Severe Stunting Detected',
        message: 'Child\'s height is severely below normal (Z-score: ${assessment.heightForAgeZScore.toStringAsFixed(1)})',
        recommendations: [
          'Immediate nutrition intervention required',
          'Long-term feeding support needed',
          'Monitor developmental milestones',
          'Refer to specialist',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.heightForAgeZScore},
      ));
    } else if (assessment.heightForAgeZScore < -2) {
      alerts.add(HealthAlert(
        id: 'moderate_stunting_${child.id}',
        childId: child.id,
        type: AlertType.moderateStunting,
        severity: AlertSeverity.high,
        title: 'Stunting Detected',
        message: 'Child shows signs of chronic malnutrition (Z-score: ${assessment.heightForAgeZScore.toStringAsFixed(1)})',
        recommendations: [
          'Enhanced nutrition program needed',
          'Regular monitoring required',
          'Focus on balanced diet',
          'Consult nutrition specialist',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.heightForAgeZScore},
      ));
    }

    if (assessment.weightForHeightZScore < -3) {
      alerts.add(HealthAlert(
        id: 'severe_wasting_${child.id}',
        childId: child.id,
        type: AlertType.severeWasting,
        severity: AlertSeverity.critical,
        title: 'Severe Acute Malnutrition',
        message: 'Child has severe wasting (Z-score: ${assessment.weightForHeightZScore.toStringAsFixed(1)})',
        recommendations: [
          'Emergency medical intervention',
          'Therapeutic feeding required',
          'Daily monitoring essential',
          'Hospitalization may be needed',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.weightForHeightZScore},
      ));
    } else if (assessment.weightForHeightZScore < -2) {
      alerts.add(HealthAlert(
        id: 'moderate_wasting_${child.id}',
        childId: child.id,
        type: AlertType.moderateWasting,
        severity: AlertSeverity.high,
        title: 'Moderate Acute Malnutrition',
        message: 'Child has moderate wasting (Z-score: ${assessment.weightForHeightZScore.toStringAsFixed(1)})',
        recommendations: [
          'Increased feeding frequency',
          'High-energy foods',
          'Close monitoring',
          'Medical consultation needed',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'zScore': assessment.weightForHeightZScore},
      ));
    }

    if (assessment.weightForHeightZScore > 2 || assessment.bmiForAgeZScore > 2) {
      alerts.add(HealthAlert(
        id: 'overweight_${child.id}',
        childId: child.id,
        type: AlertType.overweight,
        severity: AlertSeverity.moderate,
        title: 'Overweight Detected',
        message: 'Child is above normal weight range',
        recommendations: [
          'Monitor portion sizes',
          'Increase physical activity',
          'Limit sugary foods',
          'Consult pediatric nutritionist',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {
          'weightForHeightZScore': assessment.weightForHeightZScore,
          'bmiForAgeZScore': assessment.bmiForAgeZScore,
        },
      ));
    }

    if (growthRecords.length >= 2) {
      final growthVelocity = await _growthCalculationService.calculateGrowthVelocity(
        growthRecords: growthRecords.take(2).toList(),
        child: child,
        standardSource: standardSource,
      );

      if (!growthVelocity.isAdequateGrowth) {
        alerts.add(HealthAlert(
          id: 'poor_growth_velocity_${child.id}',
          childId: child.id,
          type: AlertType.poorGrowthVelocity,
          severity: AlertSeverity.moderate,
          title: 'Poor Growth Velocity',
          message: 'Child\'s growth rate is slower than expected',
          recommendations: [
            'Assess feeding practices',
            'Review nutritional intake',
            'Monitor more frequently',
            'Consult healthcare provider',
          ],
          createdAt: DateTime.now(),
          isActive: true,
          shouldNotify: true,
          data: {
            'weightVelocity': growthVelocity.weightVelocityPerMonth,
            'heightVelocity': growthVelocity.heightVelocityPerMonth,
          },
        ));
      }
    }

    return alerts;
  }

  Future<List<HealthAlert>> _assessNutritionAlerts({
    required Child child,
    required List<GrowthRecord> growthRecords,
    String? standardSource,
  }) async {
    final alerts = <HealthAlert>[];
    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    
    final guidelines = await _standardsRepository.getNutritionGuidelinesForAge(
      ageMonths: childAgeMonths,
      source: standardSource,
    );

    if (guidelines.isEmpty) return alerts;

    final guideline = guidelines.first;

    if (childAgeMonths < 6) {
      alerts.add(HealthAlert(
        id: 'exclusive_breastfeeding_${child.id}',
        childId: child.id,
        type: AlertType.breastfeedingReminder,
        severity: AlertSeverity.info,
        title: 'Exclusive Breastfeeding Period',
        message: 'Continue exclusive breastfeeding until 6 months',
        recommendations: [
          'Breastfeed on demand',
          'No water or other liquids needed',
          'Ensure proper latch',
          'Maintain maternal nutrition',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: false,
        data: {'ageMonths': childAgeMonths},
      ));
    } else if (childAgeMonths == 6) {
      alerts.add(HealthAlert(
        id: 'complementary_feeding_${child.id}',
        childId: child.id,
        type: AlertType.complementaryFeedingStart,
        severity: AlertSeverity.info,
        title: 'Start Complementary Feeding',
        message: 'Time to introduce solid foods alongside breastfeeding',
        recommendations: [
          'Start with single-ingredient foods',
          'Introduce new foods gradually',
          'Continue breastfeeding',
          'Watch for allergic reactions',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'ageMonths': childAgeMonths},
      ));
    }

    return alerts;
  }

  Future<List<HealthAlert>> _assessDevelopmentAlerts({
    required Child child,
    required List<MilestoneRecord> milestoneRecords,
    String? standardSource,
  }) async {
    final alerts = <HealthAlert>[];
    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    
    final expectedMilestones = await _standardsRepository.getMilestonesForAge(
      ageMonths: childAgeMonths,
      source: standardSource,
    );

    final achievedMilestoneIds = milestoneRecords
        .where((record) => record.achieved)
        .map((record) => record.milestoneId)
        .toSet();

    final missedMilestones = expectedMilestones
        .where((milestone) => !achievedMilestoneIds.contains(milestone.id))
        .toList();

    final criticalMissed = missedMilestones.where((m) => m.priority <= 2).toList();
    final redFlags = missedMilestones.where((m) => m.isRedFlag).toList();

    if (redFlags.isNotEmpty || criticalMissed.length >= 3) {
      alerts.add(HealthAlert(
        id: 'development_delay_${child.id}',
        childId: child.id,
        type: AlertType.developmentDelay,
        severity: AlertSeverity.high,
        title: 'Development Delay Concern',
        message: 'Multiple important milestones may be delayed',
        recommendations: [
          'Schedule developmental assessment',
          'Contact pediatrician',
          'Consider early intervention',
          'Engage in stimulating activities',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {
          'missedCount': criticalMissed.length,
          'redFlagCount': redFlags.length,
        },
      ));
    } else if (criticalMissed.length >= 2) {
      alerts.add(HealthAlert(
        id: 'milestone_monitoring_${child.id}',
        childId: child.id,
        type: AlertType.milestoneMonitoring,
        severity: AlertSeverity.moderate,
        title: 'Monitor Development Progress',
        message: 'Some milestones may need attention',
        recommendations: [
          'Continue observing development',
          'Encourage practice activities',
          'Discuss with healthcare provider',
          'Monitor next few weeks',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: false,
        data: {
          'missedCount': criticalMissed.length,
        },
      ));
    }

    return alerts;
  }

  Future<List<HealthAlert>> _assessVaccinationAlerts(Child child) async {
    final alerts = <HealthAlert>[];
    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    
    final dueVaccines = await _getDueVaccines(child.id, childAgeMonths);
    final overdueVaccines = await _getOverdueVaccines(child.id, childAgeMonths);

    if (overdueVaccines.isNotEmpty) {
      alerts.add(HealthAlert(
        id: 'overdue_vaccines_${child.id}',
        childId: child.id,
        type: AlertType.overdueVaccinations,
        severity: AlertSeverity.high,
        title: 'Overdue Vaccinations',
        message: '${overdueVaccines.length} vaccination(s) are overdue',
        recommendations: [
          'Schedule vaccination appointment immediately',
          'Contact healthcare provider',
          'Update vaccination record',
          'Follow catch-up schedule if needed',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'overdueCount': overdueVaccines.length},
      ));
    } else if (dueVaccines.isNotEmpty) {
      alerts.add(HealthAlert(
        id: 'due_vaccines_${child.id}',
        childId: child.id,
        type: AlertType.upcomingVaccinations,
        severity: AlertSeverity.info,
        title: 'Upcoming Vaccinations',
        message: '${dueVaccines.length} vaccination(s) are due soon',
        recommendations: [
          'Schedule vaccination appointment',
          'Prepare vaccination record',
          'Check for any contraindications',
          'Plan for post-vaccination care',
        ],
        createdAt: DateTime.now(),
        isActive: true,
        shouldNotify: true,
        data: {'dueCount': dueVaccines.length},
      ));
    }

    return alerts;
  }

  Future<void> _triggerNotification(HealthAlert alert) async {
    // Create a simple notification without accessing private methods
    // This is a simplified approach - in a real implementation, you would
    // add a public method to NotificationService or use a different approach
    print('Health Alert: ${alert.title} - ${alert.message}');
  }

  NotificationCategory _getNotificationCategory(AlertType type) {
    switch (type) {
      case AlertType.severeUnderweight:
      case AlertType.moderateUnderweight:
      case AlertType.severeStunting:
      case AlertType.moderateStunting:
      case AlertType.severeWasting:
      case AlertType.moderateWasting:
      case AlertType.overweight:
      case AlertType.obesity:
      case AlertType.poorGrowthVelocity:
        return NotificationCategory.healthAlerts;
      case AlertType.breastfeedingReminder:
      case AlertType.complementaryFeedingStart:
      case AlertType.nutritionDeficiency:
      case AlertType.feedingSchedule:
        return NotificationCategory.tipsGuidance;
      case AlertType.developmentDelay:
      case AlertType.milestoneMonitoring:
        return NotificationCategory.healthAlerts;
      case AlertType.overdueVaccinations:
      case AlertType.upcomingVaccinations:
        return NotificationCategory.reminders;
    }
  }

  NotificationPriority _getNotificationPriority(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return NotificationPriority.critical;
      case AlertSeverity.high:
        return NotificationPriority.high;
      case AlertSeverity.moderate:
        return NotificationPriority.medium;
      case AlertSeverity.info:
        return NotificationPriority.low;
    }
  }

  Future<List<String>> _getDueVaccines(String childId, int ageMonths) async {
    return [];
  }

  Future<List<String>> _getOverdueVaccines(String childId, int ageMonths) async {
    return [];
  }

  int _calculateCurrentAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30.44).round();
  }

  Future<void> resolveAlert(String alertId) async {
    await _standardsRepository.resolveDevelopmentAlert(alertId);
  }

  Future<List<HealthAlert>> getActiveAlertsForChild(String childId) async {
    final developmentAlerts = await _standardsRepository.getDevelopmentAlerts(childId);
    
    return developmentAlerts.map((alert) => HealthAlert(
      id: alert.id,
      childId: alert.childId,
      type: AlertType.fromString(alert.alertType),
      severity: AlertSeverity.fromString(alert.severity),
      title: alert.title,
      message: alert.description,
      recommendations: alert.recommendations.split('|'),
      createdAt: alert.createdAt,
      isActive: !alert.isResolved,
      shouldNotify: alert.requiresEvaluation,
      data: {},
    )).toList();
  }
}

class HealthAlert {
  final String id;
  final String childId;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final List<String> recommendations;
  final DateTime createdAt;
  final bool isActive;
  final bool shouldNotify;
  final Map<String, dynamic> data;

  HealthAlert({
    required this.id,
    required this.childId,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.recommendations,
    required this.createdAt,
    required this.isActive,
    required this.shouldNotify,
    required this.data,
  });
}

enum AlertType {
  severeUnderweight,
  moderateUnderweight,
  severeStunting,
  moderateStunting,
  severeWasting,
  moderateWasting,
  overweight,
  obesity,
  poorGrowthVelocity,
  breastfeedingReminder,
  complementaryFeedingStart,
  developmentDelay,
  milestoneMonitoring,
  overdueVaccinations,
  upcomingVaccinations,
  nutritionDeficiency,
  feedingSchedule;

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AlertType.milestoneMonitoring,
    );
  }
}

enum AlertSeverity {
  info,
  moderate,
  high,
  critical;

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => AlertSeverity.info,
    );
  }
}

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.severeUnderweight:
        return 'Severe Underweight';
      case AlertType.moderateUnderweight:
        return 'Moderate Underweight';
      case AlertType.severeStunting:
        return 'Severe Stunting';
      case AlertType.moderateStunting:
        return 'Moderate Stunting';
      case AlertType.severeWasting:
        return 'Severe Wasting';
      case AlertType.moderateWasting:
        return 'Moderate Wasting';
      case AlertType.overweight:
        return 'Overweight';
      case AlertType.obesity:
        return 'Obesity';
      case AlertType.poorGrowthVelocity:
        return 'Poor Growth Velocity';
      case AlertType.breastfeedingReminder:
        return 'Breastfeeding Reminder';
      case AlertType.complementaryFeedingStart:
        return 'Start Complementary Feeding';
      case AlertType.developmentDelay:
        return 'Development Delay';
      case AlertType.milestoneMonitoring:
        return 'Milestone Monitoring';
      case AlertType.overdueVaccinations:
        return 'Overdue Vaccinations';
      case AlertType.upcomingVaccinations:
        return 'Upcoming Vaccinations';
      case AlertType.nutritionDeficiency:
        return 'Nutrition Deficiency';
      case AlertType.feedingSchedule:
        return 'Feeding Schedule';
    }
  }

  String get iconName {
    switch (this) {
      case AlertType.severeUnderweight:
      case AlertType.moderateUnderweight:
        return 'scale';
      case AlertType.severeStunting:
      case AlertType.moderateStunting:
        return 'height';
      case AlertType.severeWasting:
      case AlertType.moderateWasting:
        return 'warning';
      case AlertType.overweight:
      case AlertType.obesity:
        return 'trending_up';
      case AlertType.poorGrowthVelocity:
        return 'trending_down';
      case AlertType.breastfeedingReminder:
      case AlertType.complementaryFeedingStart:
        return 'baby_changing_station';
      case AlertType.developmentDelay:
      case AlertType.milestoneMonitoring:
        return 'child_care';
      case AlertType.overdueVaccinations:
      case AlertType.upcomingVaccinations:
        return 'vaccines';
      case AlertType.nutritionDeficiency:
      case AlertType.feedingSchedule:
        return 'restaurant';
    }
  }
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Information';
      case AlertSeverity.moderate:
        return 'Moderate';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  String get colorName {
    switch (this) {
      case AlertSeverity.info:
        return 'blue';
      case AlertSeverity.moderate:
        return 'orange';
      case AlertSeverity.high:
        return 'red';
      case AlertSeverity.critical:
        return 'deepRed';
    }
  }
}