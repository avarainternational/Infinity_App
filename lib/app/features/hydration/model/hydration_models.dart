import 'package:flutter/material.dart';

class PersonalIntakeLog {
  const PersonalIntakeLog({
    required this.id,
    required this.timeStr,
    required this.amountMl,
    required this.beverageType,
    required this.icon,
    this.iconColor,
  });

  final String id;
  final String timeStr;
  final int amountMl;
  final String beverageType;
  final IconData icon;
  final Color? iconColor;
}

class DayIntakeRecord {
  const DayIntakeRecord({
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

class BeverageTypeOption {
  const BeverageTypeOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.hydrationFactor,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double hydrationFactor;
}

class BeverageTypes {
  BeverageTypes._();

  static const pureWater = BeverageTypeOption(
    id: 'pure_water',
    name: 'Pure Water',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF00A3FF),
    hydrationFactor: 1.0,
  );

  static const electrolytes = BeverageTypeOption(
    id: 'electrolytes',
    name: 'Electrolytes',
    icon: Icons.bolt_rounded,
    color: Color(0xFF10B981),
    hydrationFactor: 1.15,
  );

  static const herbalTea = BeverageTypeOption(
    id: 'herbal_tea',
    name: 'Herbal Tea',
    icon: Icons.emoji_food_beverage_rounded,
    color: Color(0xFF8B5CF6),
    hydrationFactor: 0.95,
  );

  static const mineralWater = BeverageTypeOption(
    id: 'mineral_water',
    name: 'Mineral Water',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF06B6D4),
    hydrationFactor: 1.05,
  );

  static const coconutWater = BeverageTypeOption(
    id: 'coconut_water',
    name: 'Coconut Water',
    icon: Icons.eco_rounded,
    color: Color(0xFFF59E0B),
    hydrationFactor: 1.1,
  );

  static const List<BeverageTypeOption> all = [
    pureWater,
    electrolytes,
    mineralWater,
    herbalTea,
    coconutWater,
  ];
}
