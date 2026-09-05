import 'package:flutter/material.dart';

/// Spacing scale for the Shadcn Wallet Design System (4px, 8px, 12px, 16px, 24px, 32px).
class WalletSpacing {
  WalletSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Border radius tokens for the Shadcn Wallet Design System (8px, 12px, 16px, 20px, 24px, 99px).
class WalletRadius {
  WalletRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 99.0;
}

/// Color system tokens matching Option 1 — Shadcn Wallet Design System.
class WalletColors {
  WalletColors._();

  // Core Brand Colors (Shadcn Professional Blue Palette)
  static const Color primary = Color(0xFF2563EB); // Royal Blue #2563EB
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Clean neutral slate-50
  static const Color surface = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate-100
  static const Color tabBg = Color(0xFFF1F5F9); // Segmented tab container

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate-200 crisp border
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1); // Slate-300
  static const Color divider = Color(0xFFF1F5F9);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900 / High-contrast
  static const Color textSecondary = Color(0xFF334155); // Slate-700
  static const Color textMuted = Color(0xFF64748B); // Slate-500
  static const Color textLight = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Feedback Colors
  static const Color success = Color(0xFF16A34A); // Emerald green
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);

  static const Color info = Color(0xFF2563EB); // Blue
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);

  // Rewards Shop Tinted Card
  static const Color shopBg = Color(0xFFF0F9FF); // Soft cyan/sky-50
  static const Color shopBorder = Color(0xFFBAE6FD); // Sky-200
  static const Color shopIcon = Color(0xFF0284C7); // Sky-600
  static const Color shopText = Color(0xFF0284C7);
}

/// Elevation tokens with borders and soft shadows (Levels 0–3).
class WalletShadows {
  WalletShadows._();

  static const List<BoxShadow> level0 = [];

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x0E0F172A),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];
}

/// Reusable Typography Styles matching Plus Jakarta Sans & Inter hierarchy.
class WalletTextStyles {
  WalletTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: WalletColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: WalletColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    color: WalletColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: WalletColors.textPrimary,
  );

  static const TextStyle balanceDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: WalletColors.primary,
    letterSpacing: -0.6,
  );

  static const TextStyle balanceUnit = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: WalletColors.primary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WalletColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: WalletColors.textMuted,
    height: 1.35,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: WalletColors.textMuted,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: WalletColors.textPrimary,
  );
}
