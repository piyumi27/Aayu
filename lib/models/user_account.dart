/// Authentication methods supported by the app
enum AuthMethod {
  email,
  phone;

  String getDisplayText(String language) {
    switch (this) {
      case AuthMethod.email:
        switch (language) {
          case 'si':
            return 'ඊමේල්';
          case 'ta':
            return 'மின்னஞ்சல்';
          default:
            return 'Email';
        }
      case AuthMethod.phone:
        switch (language) {
          case 'si':
            return 'දුරකථන';
          case 'ta':
            return 'தொலைபேசி';
          default:
            return 'Phone';
        }
    }
  }
}

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
  final String? photoUrl; // User profile picture path

  // Enhanced verification tracking
  final AuthMethod authMethod;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? verificationId; // For phone OTP
  final DateTime? lastOtpSentAt;

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
    this.photoUrl,
    this.authMethod = AuthMethod.email,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.verificationId,
    this.lastOtpSentAt,
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
    String? photoUrl,
    AuthMethod? authMethod,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? verificationId,
    DateTime? lastOtpSentAt,
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
      photoUrl: photoUrl ?? this.photoUrl,
      authMethod: authMethod ?? this.authMethod,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      verificationId: verificationId ?? this.verificationId,
      lastOtpSentAt: lastOtpSentAt ?? this.lastOtpSentAt,
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
      'photoUrl': photoUrl,
      'authMethod': authMethod.name,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'verificationId': verificationId,
      'lastOtpSentAt': lastOtpSentAt?.toIso8601String(),
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
      syncedAt:
          json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      photoUrl: json['photoUrl'],
      authMethod: AuthMethod.values.firstWhere(
        (method) => method.name == json['authMethod'],
        orElse: () => AuthMethod.email,
      ),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      verificationId: json['verificationId'],
      lastOtpSentAt: json['lastOtpSentAt'] != null
          ? DateTime.parse(json['lastOtpSentAt'])
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

  /// Check if sync gate is open (verified through any method)
  bool get isSyncGateOpen {
    return isEmailVerified || isPhoneVerified;
  }

  /// Check if verification is pending
  bool get isVerificationPending {
    return !isSyncGateOpen && (email != null || phoneNumber.isNotEmpty);
  }

  /// Get primary verification method for display
  AuthMethod get primaryVerificationMethod {
    return authMethod;
  }

  /// Check if OTP can be resent (30 second cooldown)
  bool get canResendOtp {
    if (lastOtpSentAt == null) return true;
    final timeSinceLastOtp = DateTime.now().difference(lastOtpSentAt!);
    return timeSinceLastOtp.inSeconds >= 30;
  }

  /// Get seconds remaining for OTP resend
  int get otpResendCountdown {
    if (lastOtpSentAt == null) return 0;
    final timeSinceLastOtp = DateTime.now().difference(lastOtpSentAt!);
    final remainingSeconds = 30 - timeSinceLastOtp.inSeconds;
    return remainingSeconds > 0 ? remainingSeconds : 0;
  }

  /// Get verification status for UI display
  VerificationStatus get verificationStatus {
    if (isSyncGateOpen) return VerificationStatus.verified;
    if (isVerificationPending) return VerificationStatus.pendingSync;
    return VerificationStatus.unverified;
  }

  /// Get localized verification prompt message
  String getVerificationPrompt(String language) {
    switch (language) {
      case 'si':
        return 'ක්ලවුඩ් විශේෂාංග අගුළු ඇරීමට ඔබේ ගිණුම සත්‍යාපනය කරන්න';
      case 'ta':
        return 'கிளவுட் அம்சங்களைத் திறக்க உங்கள் கணக்கைச் சரிபார்க்கவும்';
      default:
        return 'Please verify your account to unlock cloud features';
    }
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

/// Verification status enum
enum VerificationStatus {
  notLoggedIn,
  pendingSync,
  unverified,
  verified,
}

extension VerificationStatusExtension on VerificationStatus {
  String get displayText {
    switch (this) {
      case VerificationStatus.notLoggedIn:
        return 'Not Logged In';
      case VerificationStatus.pendingSync:
        return 'Pending Sync';
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.verified:
        return 'Verified';
    }
  }

  String get displayTextSinhala {
    switch (this) {
      case VerificationStatus.notLoggedIn:
        return 'ඇතුල් වී නැත';
      case VerificationStatus.pendingSync:
        return 'සමමුහුර්ත කිරීම බලාපොරොත්තුවෙන්';
      case VerificationStatus.unverified:
        return 'සත්‍යාපනය වී නැත';
      case VerificationStatus.verified:
        return 'සත්‍යාපිතයි';
    }
  }

  String get displayTextTamil {
    switch (this) {
      case VerificationStatus.notLoggedIn:
        return 'உள்நுழையவில்லை';
      case VerificationStatus.pendingSync:
        return 'ஒத்திசைவு நிலுவையில்';
      case VerificationStatus.unverified:
        return 'சரிபார்க்கப்படவில்லை';
      case VerificationStatus.verified:
        return 'சரிபார்க்கப்பட்டது';
    }
  }
}
