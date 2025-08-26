class UserAccount {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String passwordHash;
  final bool isVerified;
  final bool needsSync;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? verifiedAt;
  final DateTime? syncedAt;

  UserAccount({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.passwordHash,
    required this.isVerified,
    required this.needsSync,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.verifiedAt,
    this.syncedAt,
  });

  UserAccount copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? passwordHash,
    bool? isVerified,
    bool? needsSync,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? verifiedAt,
    DateTime? syncedAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      isVerified: isVerified ?? this.isVerified,
      needsSync: needsSync ?? this.needsSync,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'passwordHash': passwordHash,
      'isVerified': isVerified,
      'needsSync': needsSync,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      isVerified: json['isVerified'] ?? false,
      needsSync: json['needsSync'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      syncedAt: json['syncedAt'] != null 
          ? DateTime.parse(json['syncedAt']) 
          : null,
    );
  }

  /// Get display name for UI
  String get displayName => fullName;

  /// Get masked phone number for display
  String get maskedPhoneNumber {
    if (phoneNumber.length < 4) return phoneNumber;
    final start = phoneNumber.substring(0, 3);
    final end = phoneNumber.substring(phoneNumber.length - 2);
    return '$start***$end';
  }

  /// Get account status for display
  String get accountStatus {
    if (isVerified) return 'Verified';
    if (needsSync) return 'Pending Verification';
    return 'Unverified';
  }

  /// Check if account is complete
  bool get isComplete {
    return fullName.isNotEmpty && 
           phoneNumber.isNotEmpty && 
           passwordHash.isNotEmpty;
  }

  @override
  String toString() {
    return 'UserAccount{id: $id, fullName: $fullName, phoneNumber: $phoneNumber, isVerified: $isVerified}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAccount && 
           other.id == id && 
           other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => id.hashCode ^ phoneNumber.hashCode;
}