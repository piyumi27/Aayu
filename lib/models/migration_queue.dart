import 'package:uuid/uuid.dart';

/// Queue entry for data that needs to be migrated to Firestore after verification
class MigrationQueueEntry {
  final String id;
  final String entityType; // 'user', 'child', 'measurement', 'vaccination'
  final String entityId;
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int retryCount;
  final String? errorMessage;
  final MigrationStatus status;
  
  MigrationQueueEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.createdAt,
    this.processedAt,
    this.retryCount = 0,
    this.errorMessage,
    this.status = MigrationStatus.pending,
  });

  factory MigrationQueueEntry.create({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) {
    final uuid = Uuid();
    return MigrationQueueEntry(
      id: uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      createdAt: DateTime.now(),
    );
  }

  MigrationQueueEntry copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? processedAt,
    int? retryCount,
    String? errorMessage,
    MigrationStatus? status,
  }) {
    return MigrationQueueEntry(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'status': status.name,
    };
  }

  factory MigrationQueueEntry.fromJson(Map<String, dynamic> json) {
    return MigrationQueueEntry(
      id: json['id'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      operation: json['operation'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'],
      status: MigrationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MigrationStatus.pending,
      ),
    );
  }

  /// Check if entry can be retried
  bool get canRetry => retryCount < 3 && status == MigrationStatus.failed;

  /// Get priority for processing order
  int get priority {
    // Higher numbers = higher priority
    switch (entityType) {
      case 'user': return 100; // Process users first
      case 'child': return 90;  // Then children
      case 'measurement': return 80;  // Then measurements
      case 'vaccination': return 70;  // Then vaccinations
      default: return 50;
    }
  }

  @override
  String toString() {
    return 'MigrationQueueEntry{id: $id, entityType: $entityType, operation: $operation, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MigrationQueueEntry && 
           other.id == id && 
           other.entityId == entityId;
  }

  @override
  int get hashCode => id.hashCode ^ entityId.hashCode;
}

/// Status of migration queue entries
enum MigrationStatus {
  pending,
  processing,
  completed,
  failed;
  
  String getDisplayText(String language) {
    switch (this) {
      case MigrationStatus.pending:
        switch (language) {
          case 'si': return 'බලාපොරොත්තුවෙන්';
          case 'ta': return 'நிலுவையில்';
          default: return 'Pending';
        }
      case MigrationStatus.processing:
        switch (language) {
          case 'si': return 'සැකසෙමින්';
          case 'ta': return 'செயலாக்கப்படுகிறது';
          default: return 'Processing';
        }
      case MigrationStatus.completed:
        switch (language) {
          case 'si': return 'සම්පූර්ණයි';
          case 'ta': return 'முடிந்தது';
          default: return 'Completed';
        }
      case MigrationStatus.failed:
        switch (language) {
          case 'si': return 'අසාර්ථකයි';
          case 'ta': return 'தோல்வி';
          default: return 'Failed';
        }
    }
  }
}

/// Summary of migration queue status
class MigrationQueueSummary {
  final int totalEntries;
  final int pendingEntries;
  final int processingEntries;
  final int completedEntries;
  final int failedEntries;
  final DateTime? lastProcessedAt;
  
  MigrationQueueSummary({
    required this.totalEntries,
    required this.pendingEntries,
    required this.processingEntries,
    required this.completedEntries,
    required this.failedEntries,
    this.lastProcessedAt,
  });

  bool get hasWork => pendingEntries > 0 || failedRetriableEntries > 0;
  bool get isProcessing => processingEntries > 0;
  bool get isComplete => totalEntries > 0 && pendingEntries == 0 && processingEntries == 0 && failedEntries == 0;
  
  int get failedRetriableEntries => failedEntries; // Simplified - in real implementation would check retry count

  double get progress {
    if (totalEntries == 0) return 1.0;
    return completedEntries / totalEntries;
  }

  String getStatusText(String language) {
    if (isComplete) {
      switch (language) {
        case 'si': return 'සමමුහුර්ත කිරීම සම්පූර්ණයි';
        case 'ta': return 'ஒத்திசைவு முடிந்தது';
        default: return 'Sync Complete';
      }
    } else if (isProcessing) {
      switch (language) {
        case 'si': return 'සමමුහුර්ත කරමින්';
        case 'ta': return 'ஒத்திசைக்கிறது';
        default: return 'Syncing';
      }
    } else if (hasWork) {
      switch (language) {
        case 'si': return 'සමමුහුර්ත කිරීම අවශ්‍යයි';
        case 'ta': return 'ஒத்திசைவு தேவை';
        default: return 'Sync Needed';
      }
    } else {
      switch (language) {
        case 'si': return 'යාවත්කාලීනයි';
        case 'ta': return 'புதுப்பித்த நிலையில்';
        default: return 'Up to Date';
      }
    }
  }
}