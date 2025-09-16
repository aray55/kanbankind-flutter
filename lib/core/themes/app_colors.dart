import 'package:flutter/material.dart';

class AppColors {
  // Brand (primary/secondary/tertiary)
  static const Color primary = Color(0xFF3A7AFE);
  static const Color primaryDark = Color(0xFF1E5AE2);
  static const Color primaryLight = Color(0xFF6CA0FF);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFD6E2FF);
  static const Color onPrimaryContainer = Color(0xFF001A43);

  static const Color secondary = Color(0xFF00C48C);
  static const Color secondaryDark = Color(0xFF009B6E);
  static const Color secondaryLight = Color(0xFF3BE1AC);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFCFF6EA);
  static const Color onSecondaryContainer = Color(0xFF002116);

  static const Color tertiary = Color(0xFF8B5CF6);
  static const Color tertiaryDark = Color(0xFF6D28D9);
  static const Color tertiaryLight = Color(0xFFB69CFF);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFEDE7FF);
  static const Color onTertiaryContainer = Color(0xFF2B1159);

  // Semantic statuses
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF15803D);
  static const Color successLight = Color(0xFF86EFAC);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF052E12);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color onWarning = Color(0xFF1F1600);
  static const Color warningContainer = Color(0xFFFFF7E6);
  static const Color onWarningContainer = Color(0xFF221A00);

  static const Color error = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFB0201C);
  static const Color errorLight = Color(0xFFFF6B66);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFDE7E7);
  static const Color onErrorContainer = Color(0xFF400000);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF0369A1);
  static const Color infoLight = Color(0xFF7DD3FC);
  static const Color onInfo = Colors.white;
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF001F2A);

  // Neutral gray scale (Tailwind-like)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Backgrounds and Surfaces
  // Keep these to match existing theme usage
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF2F4F7);
  static const Color surfaceInverse = Color(0xFF121212);
  static const Color onBackground = gray800;
  static const Color onSurface = gray800;
  static const Color onSurfaceVariant = gray600;
  static const Color surfaceTint = primary; // Material3 surface tint

  // Text
  static const Color text = gray800; // used previously
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;
  static const Color textInverse = Colors.white;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  static const Color textOnTertiary = Colors.white;
  static const Color hint = gray400; // used previously
  static const Color link = Color(0xFF2563EB);

  // Borders / Dividers / Focus
  static const Color border = gray200;
  static const Color divider = gray200;
  static const Color outline = gray300;
  static const Color focus = Color(0xFF2563EB);

  // States (generic)
  static const Color hover = Color(0x143A7AFE);   // 8% primary
  static const Color pressed = Color(0x263A7AFE); // 15% primary
  static const Color selected = Color(0x1A3A7AFE); // 10% primary
  static const Color disabled = Color(0x609CA3AF); // 38% of gray400
  static const Color disabledBg = Color(0x14D1D5DB); // 8% of gray300

  // Overlays (alpha variants)
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  static const Color overlayBlack05 = Color(0x0D000000); // ~5%
  static const Color overlayBlack12 = Color(0x1F000000); // ~12%
  static const Color overlayBlack20 = Color(0x33000000); // 20%
  static const Color overlayBlack30 = Color(0x4D000000); // 30%
  static const Color overlayBlack54 = Color(0x8A000000); // 54%
  static const Color overlayBlack70 = Color(0xB3000000); // 70%

  static const Color overlayWhite20 = Color(0x33FFFFFF);
  static const Color overlayWhite40 = Color(0x66FFFFFF);
  static const Color overlayWhite70 = Color(0xB3FFFFFF);

  // Elevation colors (optional hints for shadow color usage)
  static const Color shadowColor = black;
  static const Color shadowSoft = overlayBlack12;
  static const Color shadowMedium = overlayBlack20;
  static const Color shadowStrong = overlayBlack30;

  // Utility palettes
  static const List<Color> chartPalette = <Color>[
    primary,
    secondary,
    warning,
    error,
    tertiary,
    info,
    success,
    Color(0xFF14B8A6), // teal
    Color(0xFFEF4444), // red
    Color(0xFF10B981), // emerald
  ];

  static const List<Color> primaryGradient = <Color>[
    primary,
    primaryDark,
  ];

  static const List<Color> successGradient = <Color>[
    success,
    successDark,
  ];

  static const List<Color> dangerGradient = <Color>[
    error,
    errorDark,
  ];

  static const List<Color> infoGradient = <Color>[
    info,
    infoDark,
  ];

  // Optional semantic aliases (handy for components)
  static const Color chipBg = Color(0xFFF3F4F6);
  static const Color chipText = gray700;
  static const Color inputBg = Colors.white;
  static const Color inputBorder = gray200;
  static const Color inputFocusedBorder = primary;
  static const Color cardBg = Colors.white;
  static const Color listTileHover = Color(0x0A000000); // 4% black
}