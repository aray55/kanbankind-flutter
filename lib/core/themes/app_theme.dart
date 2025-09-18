import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/services/font_service.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();
  static final typography = AppTypography();
  // ------------------- Light Theme -------------------
  static ThemeData lightTheme(BuildContext context) {
    Get.find<FontService>();
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
      textTheme: typography
          .textTheme(context)
          .copyWith(
            bodyLarge: typography
                .textTheme(context)
                .bodyLarge
                ?.copyWith(color: AppColors.text),
            bodyMedium: typography
                .textTheme(context)
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            bodySmall: typography
                .textTheme(context)
                .bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography
            .textTheme(context)
            .headlineMedium
            ?.copyWith(
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
          textStyle: typography.textTheme(context).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme(context).labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: typography.textTheme(context).labelLarge,
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
        labelStyle: typography
            .textTheme(context)
            .bodySmall!
            .copyWith(color: AppColors.onSurface),
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
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        iconColor: AppColors.onSurface,
        textStyle: typography
            .textTheme(context)
            .bodyLarge
            ?.copyWith(color: AppColors.onSurface),
      ),
    );
  }

  // ------------------- Dark Theme -------------------
  static ThemeData darkTheme(BuildContext context) {
    Get.find<FontService>();
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.gray800,
      onSurface: AppColors.gray100,
      surfaceContainerHighest: AppColors.gray700,
      onSurfaceVariant: AppColors.gray300,
      outline: AppColors.gray600,
      shadow: Color(0x60000000),
      // Enhanced colors for better dark mode support
      surfaceVariant: AppColors.gray700,
      inverseSurface: AppColors.gray100,
      onInverseSurface: AppColors.gray900,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.gray50,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.gray50,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: typography
          .textTheme(context)
          .copyWith(
            bodyLarge: typography
                .textTheme(context)
                .bodyLarge
                ?.copyWith(color: AppColors.textInverse),
            bodyMedium: typography
                .textTheme(context)
                .bodyMedium
                ?.copyWith(color: AppColors.textInverse),
            bodySmall: typography
                .textTheme(context)
                .bodySmall
                ?.copyWith(color: AppColors.textInverse),
          ),
      scaffoldBackgroundColor: AppColors.gray900,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gray800,
        foregroundColor: AppColors.gray100,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: typography
            .textTheme(context)
            .headlineMedium
            ?.copyWith(color: AppColors.gray100, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: AppColors.gray100),
      ),
      cardTheme: CardThemeData(
        color: AppColors.gray800,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: typography.textTheme(context).labelLarge,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.gray800,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.white,
        dayStyle: TextStyle(color: AppColors.gray100),
        weekdayStyle: TextStyle(color: AppColors.gray300),
        yearStyle: TextStyle(color: AppColors.gray100),
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
          textStyle: typography.textTheme(context).labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: typography.textTheme(context).labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: typography
            .textTheme(context)
            .bodyLarge
            ?.copyWith(color: AppColors.gray300),
        filled: true,
        fillColor: AppColors.gray700,
        hintStyle: typography
            .textTheme(context)
            .bodyLarge
            ?.copyWith(color: AppColors.gray400),
        // Enhanced text style for dark mode input text
        suffixIconColor: AppColors.gray300,
        prefixIconColor: AppColors.gray300,
        iconColor: AppColors.gray300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gray600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gray600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gray700),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.gray800,
        modalBackgroundColor: AppColors.gray800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.gray600, thickness: 1),
      iconTheme: IconThemeData(color: AppColors.gray200),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray700,
        labelStyle: typography
            .textTheme(context)
            .bodySmall!
            .copyWith(color: AppColors.gray200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: typography
            .textTheme(context)
            .bodyLarge
            ?.copyWith(color: AppColors.gray200),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.gray800),
          shadowColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.5),
          ),
          elevation: WidgetStatePropertyAll(8.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        textStyle: typography
            .textTheme(context)
            .bodyLarge
            ?.copyWith(color: AppColors.gray200),
        color: AppColors.gray800,
        iconColor: AppColors.gray300,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Enhanced Material state colors for dark mode
      hoverColor: AppColors.primary.withValues(alpha: 0.08),
      focusColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.12),
      splashColor: AppColors.primary.withValues(alpha: 0.16),
    );
  }
}
