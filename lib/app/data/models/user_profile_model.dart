class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    this.weightKg = 68.0,
    this.heightCm = 175.0,
    this.activityLevel = 'Moderate Active',
    this.dailyWaterGoalMl = 2600,
    this.wellnessPointsBalance = 100,
    this.inviteCode = '',
    this.currentStreak = 0,
    this.gender = 'Prefer not to say',
    this.age = 22,
    this.isOnboarded = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final int dailyWaterGoalMl;
  final int wellnessPointsBalance;
  final String inviteCode;
  final int currentStreak;
  final String gender;
  final int age;
  final bool isOnboarded;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Smart dynamic water goal calculation helper
  static int computeRecommendedGoal({
    required double weightKg,
    required String activityLevel,
    bool isHotWeather = false,
  }) {
    // Formula: Weight (kg) * 35 ml + activity boost + weather boost
    int base = (weightKg * 35).round();
    if (activityLevel.contains('Moderate') || activityLevel.contains('+300')) {
      base += 300;
    } else if (activityLevel.contains('Very') || activityLevel.contains('+600') || activityLevel.contains('Athletic')) {
      base += 600;
    } else if (activityLevel.contains('Light') || activityLevel.contains('+150')) {
      base += 150;
    }
    if (isHotWeather) {
      base += 250;
    }
    // Round to nearest 50 ml
    return ((base + 25) ~/ 50) * 50;
  }

  /// Generates a clean 6-character alphanumeric invite code
  static String generateInviteCode([String? name]) {
    final prefix = (name != null && name.trim().isNotEmpty)
        ? name.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase()
        : 'INF';
    final safePrefix = prefix.length >= 3 ? prefix.substring(0, 3) : prefix.padRight(3, 'X');
    final randomSuffix = (100 + (DateTime.now().millisecondsSinceEpoch % 900)).toString();
    return '$safePrefix$randomSuffix';
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'Infinity Member',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 68.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 175.0,
      activityLevel: json['activity_level']?.toString() ?? 'Moderate Active',
      dailyWaterGoalMl: (json['daily_water_goal_ml'] as num?)?.toInt() ?? 2600,
      wellnessPointsBalance: (json['wellness_points_balance'] as num?)?.toInt() ?? 100,
      inviteCode: json['invite_code']?.toString() ?? '',
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      gender: json['gender']?.toString() ?? 'Prefer not to say',
      age: (json['age'] as num?)?.toInt() ?? 22,
      isOnboarded: json['is_onboarded'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel,
      'daily_water_goal_ml': dailyWaterGoalMl,
      'wellness_points_balance': wellnessPointsBalance,
      'invite_code': inviteCode,
      'current_streak': currentStreak,
      'gender': gender,
      'age': age,
      'is_onboarded': isOnboarded,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    int? dailyWaterGoalMl,
    int? wellnessPointsBalance,
    String? inviteCode,
    int? currentStreak,
    String? gender,
    int? age,
    bool? isOnboarded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      wellnessPointsBalance: wellnessPointsBalance ?? this.wellnessPointsBalance,
      inviteCode: inviteCode ?? this.inviteCode,
      currentStreak: currentStreak ?? this.currentStreak,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
