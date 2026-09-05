class HydrationLogModel {
  const HydrationLogModel({
    required this.id,
    required this.userId,
    required this.amountMl,
    this.beverageType = 'Pure Water',
    this.logDate,
    required this.loggedAt,
  });

  final String id;
  final String userId;
  final int amountMl;
  final String beverageType;
  final String? logDate;
  final DateTime loggedAt;

  factory HydrationLogModel.fromJson(Map<String, dynamic> json) {
    return HydrationLogModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      amountMl: (json['amount_ml'] as num?)?.toInt() ?? 0,
      beverageType: json['beverage_type']?.toString() ?? 'Pure Water',
      logDate: json['log_date']?.toString(),
      loggedAt: json['logged_at'] != null
          ? DateTime.tryParse(json['logged_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount_ml': amountMl,
      'beverage_type': beverageType,
      if (logDate != null) 'log_date': logDate,
      'logged_at': loggedAt.toIso8601String(),
    };
  }
}
