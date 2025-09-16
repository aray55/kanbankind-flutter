import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart' show AppColors;

enum AppButtonVariant { primary, secondary, success, danger, neutral, link }

class ButtonPalette {
  final Color fg;
  final Color disabledFg;

  const ButtonPalette({required this.fg, required this.disabledFg});
}

ButtonPalette paletteFor(AppButtonVariant v) {
  switch (v) {
    case AppButtonVariant.secondary:
      return const ButtonPalette(fg: AppColors.secondary, disabledFg: AppColors.disabled);
    case AppButtonVariant.success:
      return const ButtonPalette(fg: AppColors.success, disabledFg: AppColors.disabled);
    case AppButtonVariant.danger:
      return const ButtonPalette(fg: AppColors.error, disabledFg: AppColors.disabled);
    case AppButtonVariant.neutral:
      return const ButtonPalette(fg: AppColors.gray700, disabledFg: AppColors.disabled);
    case AppButtonVariant.link:
      return const ButtonPalette(fg: AppColors.link, disabledFg: AppColors.disabled);
    case AppButtonVariant.primary:
    return const ButtonPalette(fg: AppColors.primary, disabledFg: AppColors.disabled);
  }
}
