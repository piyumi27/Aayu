import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/development_milestone.dart';
import '../repositories/standards_repository.dart';
import '../services/growth_calculation_service.dart';
import '../services/health_alert_service.dart';
import '../services/firebase_sync_service.dart';

/// Integrated health monitoring service that orchestrates all Phase 2 services
class HealthMonitoringService {
  static final HealthMonitoringService _instance =
      HealthMonitoringService._internal();
  factory HealthMonitoringService() => _instance;
  HealthMonitoringService._internal();

  final StandardsRepository _standardsRepository = StandardsRepository();
  final GrowthCalculationService _growthCalculationService =
      GrowthCalculationService();
  final HealthAlertService _healthAlertService = HealthAlertService();
  final FirebaseSyncService _syncService = FirebaseSyncService();

  /// Comprehensive health assessment for a child
  Future<ChildHealthReport> performHealthAssessment({
    required Child child,
    required List<GrowthRecord> growthRecords,
    required List<MilestoneRecord> milestoneRecords,
    String? preferredStandard,
    bool syncToCloud = true,
  }) async {
    // Ensure standards repository is initialized
    await _standardsRepository.initialize();

    // Set preferred standard if provided
    if (preferredStandard != null) {
      _standardsRepository.setStandardSource(preferredStandard);
    }

    // Calculate growth assessments for all records
    final growthAssessments =
        await _growthCalculationService.calculateHistoricalAssessments(
      child: child,
      growthRecords: growthRecords,
      standardSource: preferredStandard,
    );

    // Calculate growth velocity if sufficient data
    GrowthVelocity? growthVelocity;
    if (growthRecords.length >= 2) {
      growthVelocity = await _growthCalculationService.calculateGrowthVelocity(
        growthRecords: growthRecords,
        child: child,
        standardSource: preferredStandard,
      );
    }

    // Assess all health alerts
    final healthAlerts = await _healthAlertService.assessChildHealth(
      child: child,
      growthRecords: growthRecords,
      milestoneRecords: milestoneRecords,
      standardSource: preferredStandard,
    );

    // Get nutritional recommendations
    final nutritionGuidelines = await _getNutritionRecommendations(
      child: child,
      latestGrowthRecord: growthRecords.isNotEmpty ? growthRecords.last : null,
      standardSource: preferredStandard,
    );

    // Get development recommendations
    final developmentRecommendations = await _getDevelopmentRecommendations(
      child: child,
      milestoneRecords: milestoneRecords,
      standardSource: preferredStandard,
    );

    // Create comprehensive report
    final report = ChildHealthReport(
      child: child,
      assessmentDate: DateTime.now(),
      standardSource: _standardsRepository.currentStandardSource,
      growthAssessments: growthAssessments,
      growthVelocity: growthVelocity,
      healthAlerts: healthAlerts,
      nutritionGuidelines: nutritionGuidelines,
      developmentRecommendations: developmentRecommendations,
      overallRiskLevel: _determineOverallRisk(healthAlerts),
      keyRecommendations:
          _generateKeyRecommendations(healthAlerts, growthAssessments),
    );

    // Sync to cloud if requested and connectivity allows
    if (syncToCloud) {
      await _syncHealthData(report);
    }

    return report;
  }

  /// Get age-appropriate nutrition recommendations
  Future<List<NutritionRecommendation>> _getNutritionRecommendations({
    required Child child,
    GrowthRecord? latestGrowthRecord,
    String? standardSource,
  }) async {
    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    final guidelines = await _standardsRepository.getNutritionGuidelinesForAge(
      ageMonths: childAgeMonths,
      source: standardSource,
    );

    final recommendations = <NutritionRecommendation>[];

    for (final guideline in guidelines) {
      recommendations.add(NutritionRecommendation(
        ageGroup: guideline.getAgeRangeDescription(),
        dailyMeals: guideline.dailyMealsCount,
        dailySnacks: guideline.dailySnacksCount,
        calorieRange:
            '${guideline.dailyCaloriesMin.toInt()}-${guideline.dailyCaloriesMax.toInt()} kcal',
        proteinRange:
            '${guideline.proteinGramsMin.toInt()}-${guideline.proteinGramsMax.toInt()}g',
        recommendedFoods: guideline.recommendedFoods,
        avoidedFoods: guideline.avoidedFoods,
        specialInstructions: guideline.specialInstructions,
      ));
    }

    return recommendations;
  }

  /// Get development recommendations based on child's milestone progress
  Future<List<DevelopmentRecommendation>> _getDevelopmentRecommendations({
    required Child child,
    required List<MilestoneRecord> milestoneRecords,
    String? standardSource,
  }) async {
    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    final expectedMilestones = await _standardsRepository.getMilestonesForAge(
      ageMonths: childAgeMonths,
      source: standardSource,
    );

    final achievedIds = milestoneRecords
        .where((record) => record.achieved)
        .map((record) => record.milestoneId)
        .toSet();

    final recommendations = <DevelopmentRecommendation>[];

    // Group milestones by domain
    final milestonesByDomain = <String, List<DevelopmentMilestone>>{};
    for (final milestone in expectedMilestones) {
      milestonesByDomain.putIfAbsent(milestone.domain, () => []).add(milestone);
    }

    for (final entry in milestonesByDomain.entries) {
      final domain = entry.key;
      final milestones = entry.value;

      final achieved =
          milestones.where((m) => achievedIds.contains(m.id)).length;
      final total = milestones.length;
      final progress = total > 0 ? achieved / total : 0.0;

      final upcomingMilestones =
          milestones.where((m) => !achievedIds.contains(m.id)).take(3).toList();

      recommendations.add(DevelopmentRecommendation(
        domain: domain,
        domainDisplayName: DevelopmentDomain.fromString(domain).displayName,
        progress: progress,
        achievedCount: achieved,
        totalCount: total,
        upcomingMilestones: upcomingMilestones.map((m) => m.milestone).toList(),
        activities:
            upcomingMilestones.expand((m) => m.activities).toSet().toList(),
        concerns: milestones
            .where((m) => m.isRedFlag && !achievedIds.contains(m.id))
            .map((m) => m.milestone)
            .toList(),
      ));
    }

    return recommendations;
  }

  /// Sync health data to cloud for backup and analysis
  Future<void> _syncHealthData(ChildHealthReport report) async {
    try {
      // Sync standards preferences
      await _syncService.syncStandardsData();

      // Sync health alerts (anonymized for community insights)
      final alertData = report.healthAlerts
          .map((alert) => {
                'id': alert.id,
                'type': alert.type.name,
                'severity': alert.severity.name,
                'title': alert.title,
                'message': alert.message,
                'createdAt': alert.createdAt.toIso8601String(),
              })
          .toList();

      await _syncService.syncHealthAlerts(alertData);

      // Queue assessment preferences for sync
      await _syncService.syncAssessmentPreferences(
        preferredStandard: report.standardSource,
        enabledAlerts: {
          'growth': true,
          'nutrition': true,
          'development': true,
          'vaccination': true,
        },
        alertThresholds: {
          'severe_malnutrition': -3.0,
          'moderate_malnutrition': -2.0,
          'overweight': 2.0,
        },
      );
    } catch (e) {
      print('Health data sync failed: $e');
    }
  }

  RiskLevel _determineOverallRisk(List<HealthAlert> alerts) {
    if (alerts.any((alert) => alert.severity == AlertSeverity.critical)) {
      return RiskLevel.critical;
    } else if (alerts.any((alert) => alert.severity == AlertSeverity.high)) {
      return RiskLevel.high;
    } else if (alerts
        .any((alert) => alert.severity == AlertSeverity.moderate)) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.low;
    }
  }

  List<String> _generateKeyRecommendations(
    List<HealthAlert> alerts,
    List<GrowthAssessment> growthAssessments,
  ) {
    final recommendations = <String>[];

    // Add critical alert recommendations first
    final criticalAlerts =
        alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    for (final alert in criticalAlerts.take(2)) {
      recommendations.addAll(alert.recommendations.take(2));
    }

    // Add high priority alert recommendations
    final highAlerts =
        alerts.where((a) => a.severity == AlertSeverity.high).toList();
    for (final alert in highAlerts.take(2)) {
      recommendations.addAll(alert.recommendations.take(1));
    }

    // Add general growth recommendations
    if (growthAssessments.isNotEmpty) {
      final latestAssessment = growthAssessments.last;
      if (latestAssessment.nutritionalStatus == NutritionalStatus.normal) {
        recommendations
            .add('Continue current feeding practices - child is growing well');
      }
    }

    // Remove duplicates and limit to top 5 recommendations
    return recommendations.toSet().take(5).toList();
  }

  int _calculateCurrentAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30.44).round();
  }

  /// Switch between WHO and Sri Lankan standards
  Future<void> switchStandards(String newSource) async {
    _standardsRepository.setStandardSource(newSource);

    // Sync the preference change
    await _syncService.syncAssessmentPreferences(
      preferredStandard: newSource,
      enabledAlerts: {
        'growth': true,
        'nutrition': true,
        'development': true,
        'vaccination': true,
      },
      alertThresholds: {
        'severe_malnutrition': -3.0,
        'moderate_malnutrition': -2.0,
        'overweight': 2.0,
      },
    );
  }

  /// Get standards comparison between WHO and Sri Lankan standards
  Future<StandardsComparison> compareStandards({
    required Child child,
    required GrowthRecord growthRecord,
  }) async {
    final whoAssessment =
        await _growthCalculationService.calculateGrowthAssessment(
      child: child,
      growthRecord: growthRecord,
      standardSource: 'WHO',
    );

    final sriLankaAssessment =
        await _growthCalculationService.calculateGrowthAssessment(
      child: child,
      growthRecord: growthRecord,
      standardSource: 'SriLanka',
    );

    return StandardsComparison(
      whoAssessment: whoAssessment,
      sriLankaAssessment: sriLankaAssessment,
      differenceInWeightZScore: (whoAssessment.weightForAgeZScore -
              sriLankaAssessment.weightForAgeZScore)
          .abs(),
      differenceInHeightZScore: (whoAssessment.heightForAgeZScore -
              sriLankaAssessment.heightForAgeZScore)
          .abs(),
      recommendedStandard: _recommendStandardBasedOnComparison(
          whoAssessment, sriLankaAssessment),
    );
  }

  String _recommendStandardBasedOnComparison(
    GrowthAssessment whoAssessment,
    GrowthAssessment sriLankaAssessment,
  ) {
    // Recommend Sri Lankan standards if both show similar results
    // or if Sri Lankan standards are more appropriate for local context
    if ((whoAssessment.nutritionalStatus ==
            sriLankaAssessment.nutritionalStatus) ||
        (sriLankaAssessment.riskLevel.index <= whoAssessment.riskLevel.index)) {
      return 'SriLanka';
    }
    return 'WHO';
  }

  /// Get health monitoring summary for dashboard
  Future<HealthSummary> getHealthSummary({
    required Child child,
    required List<GrowthRecord> growthRecords,
    required List<MilestoneRecord> milestoneRecords,
  }) async {
    final activeAlerts =
        await _healthAlertService.getActiveAlertsForChild(child.id);

    GrowthAssessment? latestAssessment;
    if (growthRecords.isNotEmpty) {
      latestAssessment =
          await _growthCalculationService.calculateGrowthAssessment(
        child: child,
        growthRecord: growthRecords.last,
      );
    }

    final childAgeMonths = _calculateCurrentAge(child.birthDate);
    final expectedMilestones = await _standardsRepository.getMilestonesForAge(
      ageMonths: childAgeMonths,
    );

    final achievedIds = milestoneRecords
        .where((record) => record.achieved)
        .map((record) => record.milestoneId)
        .toSet();

    final developmentProgress = expectedMilestones.isNotEmpty
        ? achievedIds.length / expectedMilestones.length
        : 0.0;

    return HealthSummary(
      overallStatus:
          latestAssessment?.nutritionalStatus.displayName ?? 'No data',
      riskLevel: latestAssessment?.riskLevel ?? RiskLevel.low,
      activeAlertsCount: activeAlerts.length,
      developmentProgress: developmentProgress,
      lastAssessmentDate:
          growthRecords.isNotEmpty ? growthRecords.last.date : null,
      nextRecommendedAction:
          _getNextRecommendedAction(activeAlerts, latestAssessment),
    );
  }

  String _getNextRecommendedAction(
    List<HealthAlert> alerts,
    GrowthAssessment? assessment,
  ) {
    if (alerts.any((a) => a.severity == AlertSeverity.critical)) {
      return 'Seek immediate medical attention';
    } else if (alerts.any((a) => a.severity == AlertSeverity.high)) {
      return 'Consult healthcare provider';
    } else if (assessment?.riskLevel == RiskLevel.moderate) {
      return 'Monitor closely and follow recommendations';
    } else {
      return 'Continue regular monitoring';
    }
  }
}

// Supporting classes for the comprehensive health report

class ChildHealthReport {
  final Child child;
  final DateTime assessmentDate;
  final String standardSource;
  final List<GrowthAssessment> growthAssessments;
  final GrowthVelocity? growthVelocity;
  final List<HealthAlert> healthAlerts;
  final List<NutritionRecommendation> nutritionGuidelines;
  final List<DevelopmentRecommendation> developmentRecommendations;
  final RiskLevel overallRiskLevel;
  final List<String> keyRecommendations;

  ChildHealthReport({
    required this.child,
    required this.assessmentDate,
    required this.standardSource,
    required this.growthAssessments,
    required this.growthVelocity,
    required this.healthAlerts,
    required this.nutritionGuidelines,
    required this.developmentRecommendations,
    required this.overallRiskLevel,
    required this.keyRecommendations,
  });
}

class NutritionRecommendation {
  final String ageGroup;
  final int dailyMeals;
  final int dailySnacks;
  final String calorieRange;
  final String proteinRange;
  final List<String> recommendedFoods;
  final List<String> avoidedFoods;
  final String specialInstructions;

  NutritionRecommendation({
    required this.ageGroup,
    required this.dailyMeals,
    required this.dailySnacks,
    required this.calorieRange,
    required this.proteinRange,
    required this.recommendedFoods,
    required this.avoidedFoods,
    required this.specialInstructions,
  });
}

class DevelopmentRecommendation {
  final String domain;
  final String domainDisplayName;
  final double progress;
  final int achievedCount;
  final int totalCount;
  final List<String> upcomingMilestones;
  final List<String> activities;
  final List<String> concerns;

  DevelopmentRecommendation({
    required this.domain,
    required this.domainDisplayName,
    required this.progress,
    required this.achievedCount,
    required this.totalCount,
    required this.upcomingMilestones,
    required this.activities,
    required this.concerns,
  });
}

class StandardsComparison {
  final GrowthAssessment whoAssessment;
  final GrowthAssessment sriLankaAssessment;
  final double differenceInWeightZScore;
  final double differenceInHeightZScore;
  final String recommendedStandard;

  StandardsComparison({
    required this.whoAssessment,
    required this.sriLankaAssessment,
    required this.differenceInWeightZScore,
    required this.differenceInHeightZScore,
    required this.recommendedStandard,
  });
}

class HealthSummary {
  final String overallStatus;
  final RiskLevel riskLevel;
  final int activeAlertsCount;
  final double developmentProgress;
  final DateTime? lastAssessmentDate;
  final String nextRecommendedAction;

  HealthSummary({
    required this.overallStatus,
    required this.riskLevel,
    required this.activeAlertsCount,
    required this.developmentProgress,
    required this.lastAssessmentDate,
    required this.nextRecommendedAction,
  });
}
