import 'package:flutter/material.dart';

class PartnerDayRecord {
  const PartnerDayRecord({
    required this.dayLabel,
    required this.dateStr,
    required this.intakeMl,
    required this.goalMl,
    required this.isReached,
  });

  final String dayLabel;
  final String dateStr;
  final int intakeMl;
  final int goalMl;
  final bool isReached;

  double get progress => (goalMl > 0) ? (intakeMl / goalMl).clamp(0.0, 1.5) : 0.0;
  int get percentage => (progress * 100).toInt();
}

class PartnerReminderLog {
  const PartnerReminderLog({
    required this.id,
    required this.timeStr,
    required this.message,
    required this.icon,
  });

  final String id;
  final String timeStr;
  final String message;
  final IconData icon;
}

class PartnerWaterLog {
  const PartnerWaterLog({
    required this.id,
    required this.timeStr,
    required this.amountMl,
    required this.label,
  });

  final String id;
  final String timeStr;
  final int amountMl;
  final String label;
}

class PartnerThemeOption {
  const PartnerThemeOption({
    required this.key,
    required this.name,
    required this.description,
    required this.gradient,
    required this.accentColor,
    required this.icon,
  });

  final String key;
  final String name;
  final String description;
  final List<Color> gradient;
  final Color accentColor;
  final IconData icon;
}

class PartnerThemes {
  PartnerThemes._();

  static const warm = PartnerThemeOption(
    key: 'warm',
    name: 'Warm',
    description: 'Amber & Sun Glow',
    gradient: [Color(0xFFFFA726), Color(0xFFFF7043)],
    accentColor: Color(0xFFFF9800),
    icon: Icons.wb_sunny_rounded,
  );

  static const love = PartnerThemeOption(
    key: 'love',
    name: 'Love',
    description: 'Rose & Romantic Pink',
    gradient: [Color(0xFFFF4081), Color(0xFFE91E63)],
    accentColor: Color(0xFFE91E63),
    icon: Icons.favorite_rounded,
  );

  static const green = PartnerThemeOption(
    key: 'green',
    name: 'Green',
    description: 'Mint & Emerald Vitality',
    gradient: [Color(0xFF26A69A), Color(0xFF2E7D32)],
    accentColor: Color(0xFF2E7D32),
    icon: Icons.eco_rounded,
  );

  static const energetic = PartnerThemeOption(
    key: 'energetic',
    name: 'Energetic',
    description: 'Electric Cyan & Deep Blue',
    gradient: [Color(0xFF00E5FF), Color(0xFF0091EA)],
    accentColor: Color(0xFF00A3FF),
    icon: Icons.bolt_rounded,
  );

  static const hot = PartnerThemeOption(
    key: 'hot',
    name: 'Hot',
    description: 'Fiery Coral & Red Flame',
    gradient: [Color(0xFFFF5722), Color(0xFFD50000)],
    accentColor: Color(0xFFE53935),
    icon: Icons.local_fire_department_rounded,
  );

  static const List<PartnerThemeOption> all = [
    warm,
    love,
    green,
    energetic,
    hot,
  ];

  static PartnerThemeOption getByKey(String key) {
    return all.firstWhere(
      (t) => t.key.toLowerCase() == key.toLowerCase(),
      orElse: () => love,
    );
  }
}
