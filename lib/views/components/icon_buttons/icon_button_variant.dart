import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart' show AppColors;

enum AppIconButtonVariant { primary, secondary, success, danger, neutral }

class IconButtonPalette {
  final Color base;
  final Color onBase;
  final Color container;
  final Color onContainer;
  final Color disabledFg;
  final Color disabledFgOnBase;
  final Color disabledBg;

  const IconButtonPalette({
    required this.base,
    required this.onBase,
    required this.container,
    required this.onContainer,
    required this.disabledFg,
    required this.disabledFgOnBase,
    required this.disabledBg,
  });
}

// نفس اللي عندك في الكود الحالي بس ننقله هنا
IconButtonPalette paletteFor(AppIconButtonVariant v) {
  switch (v) {
    case AppIconButtonVariant.secondary:
      return IconButtonPalette(
        base: AppColors.secondary,
        onBase: AppColors.onSecondary,
        container: AppColors.secondaryContainer,
        onContainer: AppColors.onSecondaryContainer,
        disabledFg: AppColors.disabled,
        disabledFgOnBase: AppColors.overlayWhite70,
        disabledBg: AppColors.disabledBg,
      );
    // ... باقي الحالات
    default:
      return IconButtonPalette(
        base: AppColors.primary,
        onBase: AppColors.onPrimary,
        container: AppColors.primaryContainer,
        onContainer: AppColors.onPrimaryContainer,
        disabledFg: AppColors.disabled,
        disabledFgOnBase: AppColors.overlayWhite70,
        disabledBg: AppColors.disabledBg,
      );
  }
}
