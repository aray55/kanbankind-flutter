// import 'package:flutter/material.dart';

// class AppTheme {
//   AppTheme._();

//   // Custom Color Palette
//   static const Color _primaryBlue = Color(0xFF2196F3);
//   static const Color _secondaryTeal = Color(0xFF00BCD4);
//   static const Color _accentOrange = Color(0xFFFF9800);
//   static const Color _successGreen = Color(0xFF4CAF50);
//   static const Color _warningAmber = Color(0xFFFFC107);
//   static const Color _errorRed = Color(0xFFF44336);

//   // Light Theme Colors
//   static const Color _lightBackground = Color(0xFFF5F7FA);
//   static const Color _lightSurface = Color(0xFFFFFFFF);
//   static const Color _lightCardBackground = Color(0xFFFFFFFF);
//   static const Color _lightTextPrimary = Color(0xFF1A1A1A);
//   static const Color _lightTextSecondary = Color(0xFF666666);
//   static const Color _lightDivider = Color(0xFFE0E0E0);

//   // Dark Theme Colors
//   static const Color _darkBackground = Color(0xFF121212);
//   static const Color _darkSurface = Color(0xFF1E1E1E);
//   static const Color _darkCardBackground = Color(0xFF2D2D2D);
//   static const Color _darkTextPrimary = Color(0xFFFFFFFF);
//   static const Color _darkTextSecondary = Color(0xFFB3B3B3);
//   static const Color _darkDivider = Color(0xFF404040);

//   // Light Color Scheme
//   static const ColorScheme lightColorScheme = ColorScheme(
//     brightness: Brightness.light,
//     primary: _primaryBlue,
//     onPrimary: Colors.white,
//     secondary: _secondaryTeal,
//     onSecondary: Colors.white,
//     tertiary: _accentOrange,
//     onTertiary: Colors.white,
//     error: _errorRed,
//     onError: Colors.white,
//     surface: _lightBackground,
//     onSurface: _lightTextPrimary,
//     surfaceContainerHighest: Color(0xFFF0F2F5),
//     onSurfaceVariant: _lightTextSecondary,
//     outline: _lightDivider,
//     shadow: Color(0x1A000000),
//   );

//   // Dark Color Scheme
//   static const ColorScheme darkColorScheme = ColorScheme(
//     brightness: Brightness.dark,
//     primary: _primaryBlue,
//     onPrimary: Colors.white,
//     secondary: _secondaryTeal,
//     onSecondary: Colors.white,
//     tertiary: _accentOrange,
//     onTertiary: Colors.white,
//     error: _errorRed,
//     onError: Colors.white,
//     surface: _darkBackground,
//     onSurface: _darkTextPrimary,
//     surfaceContainerHighest: Color(0xFF2A2A2A),
//     onSurfaceVariant: _darkTextSecondary,
//     outline: _darkDivider,
//     shadow: Color(0x40000000),
//   );

//   // Typography
//   static const TextTheme textTheme = TextTheme(
//     displayLarge: TextStyle(
//       fontSize: 32,
//       fontWeight: FontWeight.bold,
//       letterSpacing: -0.5,
//     ),
//     displayMedium: TextStyle(
//       fontSize: 28,
//       fontWeight: FontWeight.bold,
//       letterSpacing: -0.25,
//     ),
//     displaySmall: TextStyle(
//       fontSize: 24,
//       fontWeight: FontWeight.w600,
//       letterSpacing: 0,
//     ),
//     headlineLarge: TextStyle(
//       fontSize: 22,
//       fontWeight: FontWeight.w600,
//       letterSpacing: 0,
//     ),
//     headlineMedium: TextStyle(
//       fontSize: 20,
//       fontWeight: FontWeight.w600,
//       letterSpacing: 0.15,
//     ),
//     headlineSmall: TextStyle(
//       fontSize: 18,
//       fontWeight: FontWeight.w600,
//       letterSpacing: 0.15,
//     ),
//     titleLarge: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       letterSpacing: 0.15,
//     ),
//     titleMedium: TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w500,
//       letterSpacing: 0.1,
//     ),
//     titleSmall: TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.w500,
//       letterSpacing: 0.1,
//     ),
//     bodyLarge: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.normal,
//       letterSpacing: 0.5,
//     ),
//     bodyMedium: TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.normal,
//       letterSpacing: 0.25,
//     ),
//     bodySmall: TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.normal,
//       letterSpacing: 0.4,
//     ),
//     labelLarge: TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w500,
//       letterSpacing: 0.1,
//     ),
//     labelMedium: TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.w500,
//       letterSpacing: 0.5,
//     ),
//     labelSmall: TextStyle(
//       fontSize: 10,
//       fontWeight: FontWeight.w500,
//       letterSpacing: 0.5,
//     ),
//   );

//   // Light Theme
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: lightColorScheme,
//       textTheme: textTheme,
//       scaffoldBackgroundColor: lightColorScheme.background,

//       // App Bar Theme
//       appBarTheme: AppBarTheme(
//         backgroundColor: lightColorScheme.surface,
//         foregroundColor: lightColorScheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: textTheme.headlineMedium?.copyWith(
//           color: lightColorScheme.onSurface,
//           fontWeight: FontWeight.w600,
//         ),
//         iconTheme: IconThemeData(color: lightColorScheme.onSurface),
//       ),

//       // Card Theme
//       cardTheme: CardThemeData(
//         color: _lightCardBackground,
//         elevation: 2,
//         shadowColor: lightColorScheme.shadow,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(8),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: lightColorScheme.primary,
//           foregroundColor: lightColorScheme.onPrimary,
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: lightColorScheme.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: lightColorScheme.primary,
//           side: BorderSide(color: lightColorScheme.primary),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: lightColorScheme.onSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: lightColorScheme.outline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: lightColorScheme.outline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: lightColorScheme.onPrimary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: lightColorScheme.error),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),

//       // Floating Action Button Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: lightColorScheme.primary,
//         foregroundColor: lightColorScheme.onPrimary,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),

//       // Chip Theme
//       chipTheme: ChipThemeData(
//         backgroundColor: lightColorScheme.surfaceContainerHighest,
//         labelStyle: textTheme.bodySmall?.copyWith(
//           color: lightColorScheme.onSurfaceVariant,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: lightColorScheme.outline,
//         thickness: 1,
//         space: 1,
//       ),

//       // Icon Theme
//       iconTheme: IconThemeData(
//         color: lightColorScheme.onSurface,
//         size: 24,
//       ),
//     );
//   }

//   // Dark Theme
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: darkColorScheme,
//       textTheme: textTheme,
//       scaffoldBackgroundColor: darkColorScheme.surface,

//       // App Bar Theme
//       appBarTheme: AppBarTheme(
//         backgroundColor: darkColorScheme.surface,
//         foregroundColor: darkColorScheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: textTheme.headlineMedium?.copyWith(
//           color: darkColorScheme.onSurface,
//           fontWeight: FontWeight.w600,
//         ),
//         iconTheme: IconThemeData(color: darkColorScheme.onSurface),
//       ),

//       // Card Theme
//       cardTheme: CardThemeData(
//         color: _darkCardBackground,
//         elevation: 4,
//         shadowColor: darkColorScheme.shadow,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(8),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: darkColorScheme.primary,
//           foregroundColor: darkColorScheme.onPrimary,
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: darkColorScheme.primary,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: darkColorScheme.primary,
//           side: BorderSide(color: darkColorScheme.primary),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           textStyle: textTheme.labelLarge,
//         ),
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: darkColorScheme.surface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: darkColorScheme.outline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: darkColorScheme.outline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: darkColorScheme.error),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),

//       // Floating Action Button Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: darkColorScheme.primary,
//         foregroundColor: darkColorScheme.onPrimary,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),

//       // Chip Theme
//       chipTheme: ChipThemeData(
//         backgroundColor: darkColorScheme.surfaceVariant,
//         labelStyle: textTheme.bodySmall?.copyWith(
//           color: darkColorScheme.onSurfaceVariant,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: darkColorScheme.outline,
//         thickness: 1,
//         space: 1,
//       ),

//       // Icon Theme
//       iconTheme: IconThemeData(
//         color: darkColorScheme.onSurface,
//         size: 24,
//       ),
//     );
//   }

//   // Custom Colors for Kanban Board
//   static const Map<String, Color> kanbanColors = {
//     'todo': Color(0xFFE3F2FD),
//     'inProgress': Color(0xFFFFF3E0),
//     'done': Color(0xFFE8F5E8),
//     'todoDark': Color(0xFF1565C0),
//     'inProgressDark': Color(0xFFE65100),
//     'doneDark': Color(0xFF2E7D32),
//   };

//   // Status Colors
//   static const Map<String, Color> statusColors = {
//     'success': _successGreen,
//     'warning': _warningAmber,
//     'error': _errorRed,
//     'info': _primaryBlue,
//   };
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/services/font_service.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ------------------- Light Theme -------------------
  static ThemeData get lightTheme {
    final fontService = Get.find<FontService>();
    final typography = AppTypography(
      fontFamily: fontService.currentFont.value,
      scale: fontService.currentScale.value,
    );
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      brightness: Brightness.light,

      background: AppColors.background,
      onBackground: AppColors.text,
      surface: AppColors.surface,
      onSurface: AppColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: typography.textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
      iconTheme: IconThemeData(color: AppColors.onSurface),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: typography.textTheme.bodySmall!.copyWith(
          color: AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        cancelButtonStyle: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.error),
          foregroundColor: WidgetStatePropertyAll(AppColors.white),
        ),
        confirmButtonStyle: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          foregroundColor: WidgetStatePropertyAll(AppColors.white),
        ),
      ),
    );
  }

  // ------------------- Dark Theme -------------------
  static ThemeData get darkTheme {
    final fontService = Get.find<FontService>();
    final typography = AppTypography(
      fontFamily: fontService.currentFont.value,
      scale: fontService.currentScale.value,
    );
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.text,
      surfaceContainerHighest: AppColors.surface,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.divider,
      shadow: Color(0x40000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: typography.textTheme.copyWith(
        bodyLarge: typography.textTheme.bodyLarge?.copyWith(
          color: AppColors.text,
        ),
        bodyMedium: typography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        bodySmall: typography.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.secondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        cancelButtonStyle: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.error),
          foregroundColor: WidgetStatePropertyAll(AppColors.white),
        ),
        confirmButtonStyle: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          foregroundColor: WidgetStatePropertyAll(AppColors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: typography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
      iconTheme: IconThemeData(color: AppColors.onSurface),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: typography.textTheme.bodySmall!.copyWith(
          color: AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
