class DevelopmentMilestone {
  final String id;
  final String source;
  final int ageMonthsMin;
  final int ageMonthsMax;
  final String domain;
  final String milestone;
  final String description;
  final String observationTips;
  final bool isRedFlag;
  final int priority;
  final List<String> activities;
  final List<String> redFlagSigns;
  final String interventionGuidance;
  final DateTime createdAt;
  final DateTime updatedAt;

  DevelopmentMilestone({
    required this.id,
    required this.source,
    required this.ageMonthsMin,
    required this.ageMonthsMax,
    required this.domain,
    required this.milestone,
    required this.description,
    required this.observationTips,
    required this.isRedFlag,
    required this.priority,
    required this.activities,
    required this.redFlagSigns,
    required this.interventionGuidance,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'ageMonthsMin': ageMonthsMin,
      'ageMonthsMax': ageMonthsMax,
      'domain': domain,
      'milestone': milestone,
      'description': description,
      'observationTips': observationTips,
      'isRedFlag': isRedFlag ? 1 : 0,
      'priority': priority,
      'activities': activities.join('|'),
      'redFlagSigns': redFlagSigns.join('|'),
      'interventionGuidance': interventionGuidance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DevelopmentMilestone.fromMap(Map<String, dynamic> map) {
    return DevelopmentMilestone(
      id: map['id'],
      source: map['source'],
      ageMonthsMin: map['ageMonthsMin'],
      ageMonthsMax: map['ageMonthsMax'],
      domain: map['domain'],
      milestone: map['milestone'],
      description: map['description'],
      observationTips: map['observationTips'],
      isRedFlag: map['isRedFlag'] == 1,
      priority: map['priority'],
      activities: map['activities'].toString().split('|'),
      redFlagSigns: map['redFlagSigns'].toString().split('|'),
      interventionGuidance: map['interventionGuidance'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  bool isApplicableForAge(int ageMonths) {
    return ageMonths >= ageMonthsMin && ageMonths <= ageMonthsMax;
  }

  String getAgeRangeDescription() {
    if (ageMonthsMin == ageMonthsMax) {
      return '${ageMonthsMin} months';
    }
    return '${ageMonthsMin}-${ageMonthsMax} months';
  }

  String getDomainIcon() {
    return switch (domain.toLowerCase()) {
      'motor' || 'gross_motor' => 'directions_run',
      'fine_motor' => 'pan_tool',
      'language' || 'communication' => 'chat',
      'cognitive' => 'psychology',
      'social' || 'social_emotional' => 'people',
      'adaptive' || 'self_care' => 'self_improvement',
      _ => 'child_care',
    };
  }

  String getPriorityLabel() {
    return switch (priority) {
      1 => 'Critical',
      2 => 'High',
      3 => 'Medium',
      4 => 'Low',
      _ => 'Unknown',
    };
  }
}

class MilestoneRecord {
  final String id;
  final String childId;
  final String milestoneId;
  final DateTime observedDate;
  final bool achieved;
  final String observerNotes;
  final String? concerns;
  final int confidenceLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilestoneRecord({
    required this.id,
    required this.childId,
    required this.milestoneId,
    required this.observedDate,
    required this.achieved,
    required this.observerNotes,
    this.concerns,
    required this.confidenceLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'milestoneId': milestoneId,
      'observedDate': observedDate.toIso8601String(),
      'achieved': achieved ? 1 : 0,
      'observerNotes': observerNotes,
      'concerns': concerns,
      'confidenceLevel': confidenceLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MilestoneRecord.fromMap(Map<String, dynamic> map) {
    return MilestoneRecord(
      id: map['id'],
      childId: map['childId'],
      milestoneId: map['milestoneId'],
      observedDate: DateTime.parse(map['observedDate']),
      achieved: map['achieved'] == 1,
      observerNotes: map['observerNotes'],
      concerns: map['concerns'],
      confidenceLevel: map['confidenceLevel'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class DevelopmentAlert {
  final String id;
  final String childId;
  final String alertType;
  final String severity;
  final String title;
  final String description;
  final List<String> missedMilestones;
  final List<String> redFlags;
  final String recommendations;
  final bool requiresEvaluation;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  DevelopmentAlert({
    required this.id,
    required this.childId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    required this.missedMilestones,
    required this.redFlags,
    required this.recommendations,
    required this.requiresEvaluation,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'alertType': alertType,
      'severity': severity,
      'title': title,
      'description': description,
      'missedMilestones': missedMilestones.join('|'),
      'redFlags': redFlags.join('|'),
      'recommendations': recommendations,
      'requiresEvaluation': requiresEvaluation ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory DevelopmentAlert.fromMap(Map<String, dynamic> map) {
    return DevelopmentAlert(
      id: map['id'],
      childId: map['childId'],
      alertType: map['alertType'],
      severity: map['severity'],
      title: map['title'],
      description: map['description'],
      missedMilestones: map['missedMilestones'].toString().split('|'),
      redFlags: map['redFlags'].toString().split('|'),
      recommendations: map['recommendations'],
      requiresEvaluation: map['requiresEvaluation'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      resolvedAt:
          map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
    );
  }

  bool get isResolved => resolvedAt != null;

  static DevelopmentAlert createDelayAlert({
    required String childId,
    required List<DevelopmentMilestone> missedMilestones,
    required int childAgeMonths,
  }) {
    final now = DateTime.now();

    final criticalMissed =
        missedMilestones.where((m) => m.priority <= 2).toList();
    final hasRedFlags = missedMilestones.any((m) => m.isRedFlag);

    String severity = 'info';
    String title = 'Development Tracking';
    String description = 'Regular milestone monitoring';
    bool requiresEvaluation = false;

    if (hasRedFlags || criticalMissed.length >= 3) {
      severity = 'severe';
      title = 'Development Delay Alert';
      description = 'Multiple critical milestones missed or red flags present';
      requiresEvaluation = true;
    } else if (criticalMissed.length >= 2) {
      severity = 'moderate';
      title = 'Development Concern';
      description = 'Some important milestones may be delayed';
      requiresEvaluation = true;
    } else if (missedMilestones.isNotEmpty) {
      severity = 'mild';
      title = 'Milestone Monitoring';
      description = 'Continue observing development progress';
    }

    return DevelopmentAlert(
      id: 'dev_alert_${now.millisecondsSinceEpoch}',
      childId: childId,
      alertType: 'development_delay',
      severity: severity,
      title: title,
      description: description,
      missedMilestones: missedMilestones.map((m) => m.milestone).toList(),
      redFlags: missedMilestones
          .where((m) => m.isRedFlag)
          .map((m) => m.milestone)
          .toList(),
      recommendations: _getRecommendationsForSeverity(severity),
      requiresEvaluation: requiresEvaluation,
      createdAt: now,
    );
  }

  static String _getRecommendationsForSeverity(String severity) {
    return switch (severity) {
      'severe' =>
        'Immediate developmental evaluation recommended. Contact pediatrician for referral to early intervention services.',
      'moderate' =>
        'Schedule appointment with pediatrician to discuss development. Consider early intervention assessment.',
      'mild' =>
        'Continue monitoring and encouraging activities. Discuss with pediatrician at next visit.',
      _ => 'Continue regular development monitoring and activities.',
    };
  }
}

enum DevelopmentDomain {
  grossMotor('Gross Motor', 'Large muscle movements and balance'),
  fineMotor('Fine Motor', 'Small muscle movements and hand-eye coordination'),
  language('Language', 'Communication and speech development'),
  cognitive('Cognitive', 'Thinking, learning, and problem-solving'),
  socialEmotional('Social-Emotional', 'Social skills and emotional regulation'),
  adaptive('Adaptive', 'Self-care and daily living skills');

  const DevelopmentDomain(this.displayName, this.description);

  final String displayName;
  final String description;

  static DevelopmentDomain fromString(String domain) {
    return switch (domain.toLowerCase()) {
      'gross_motor' || 'motor' => DevelopmentDomain.grossMotor,
      'fine_motor' => DevelopmentDomain.fineMotor,
      'language' || 'communication' => DevelopmentDomain.language,
      'cognitive' => DevelopmentDomain.cognitive,
      'social' || 'social_emotional' => DevelopmentDomain.socialEmotional,
      'adaptive' || 'self_care' => DevelopmentDomain.adaptive,
      _ => DevelopmentDomain.grossMotor,
    };
  }
}
