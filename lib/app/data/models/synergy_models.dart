import 'package:infinity_wellness/app/data/models/user_profile_model.dart';

enum SynergyNudgeType {
  hydrate,
  screenBreak,
  cheer;

  static SynergyNudgeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'screen_break':
      case 'screenbreak':
        return SynergyNudgeType.screenBreak;
      case 'cheer':
        return SynergyNudgeType.cheer;
      case 'hydrate':
      default:
        return SynergyNudgeType.hydrate;
    }
  }

  String get dbValue {
    switch (this) {
      case SynergyNudgeType.screenBreak:
        return 'screen_break';
      case SynergyNudgeType.cheer:
        return 'cheer';
      case SynergyNudgeType.hydrate:
        return 'hydrate';
    }
  }

  String get defaultTitle {
    switch (this) {
      case SynergyNudgeType.hydrate:
        return '💧 Hydration Nudge';
      case SynergyNudgeType.screenBreak:
        return '👀 Screen Break Time';
      case SynergyNudgeType.cheer:
        return '🔥 Streak Boost';
    }
  }
}

class SynergyPairModel {
  const SynergyPairModel({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.status = 'active',
    this.streakCount = 0,
    this.lastSyncedDate,
    this.themeKey = 'love',
    this.createdAt,
    this.partnerProfile,
    this.partnerTodayIntakeMl = 0,
  });

  final String id;
  final String userAId;
  final String userBId;
  final String status;
  final int streakCount;
  final String? lastSyncedDate;
  final String themeKey;
  final DateTime? createdAt;
  final UserProfileModel? partnerProfile;
  final int partnerTodayIntakeMl;

  String getPartnerId(String currentUserId) {
    return currentUserId == userAId ? userBId : userAId;
  }

  bool get isActive => status == 'active';

  factory SynergyPairModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    UserProfileModel? partner;
    if (json['partner_profile'] is Map<String, dynamic>) {
      partner = UserProfileModel.fromJson(json['partner_profile'] as Map<String, dynamic>);
    }

    return SynergyPairModel(
      id: json['id']?.toString() ?? '',
      userAId: json['user_a_id']?.toString() ?? '',
      userBId: json['user_b_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      streakCount: (json['streak_count'] as num?)?.toInt() ?? 0,
      lastSyncedDate: json['last_synced_date']?.toString(),
      themeKey: json['theme_key']?.toString() ?? 'love',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      partnerProfile: partner,
      partnerTodayIntakeMl: (json['partner_today_intake_ml'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'status': status,
      'streak_count': streakCount,
      'last_synced_date': lastSyncedDate,
      'theme_key': themeKey,
    };
  }

  SynergyPairModel copyWith({
    String? id,
    String? userAId,
    String? userBId,
    String? status,
    int? streakCount,
    String? lastSyncedDate,
    String? themeKey,
    DateTime? createdAt,
    UserProfileModel? partnerProfile,
    int? partnerTodayIntakeMl,
  }) {
    return SynergyPairModel(
      id: id ?? this.id,
      userAId: userAId ?? this.userAId,
      userBId: userBId ?? this.userBId,
      status: status ?? this.status,
      streakCount: streakCount ?? this.streakCount,
      lastSyncedDate: lastSyncedDate ?? this.lastSyncedDate,
      themeKey: themeKey ?? this.themeKey,
      createdAt: createdAt ?? this.createdAt,
      partnerProfile: partnerProfile ?? this.partnerProfile,
      partnerTodayIntakeMl: partnerTodayIntakeMl ?? this.partnerTodayIntakeMl,
    );
  }
}

class SynergyNudgeModel {
  const SynergyNudgeModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.nudgeType,
    this.message,
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final SynergyNudgeType nudgeType;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  factory SynergyNudgeModel.fromJson(Map<String, dynamic> json) {
    return SynergyNudgeModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      nudgeType: SynergyNudgeType.fromString(json['nudge_type']?.toString() ?? 'hydrate'),
      message: json['message']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'nudge_type': nudgeType.dbValue,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
