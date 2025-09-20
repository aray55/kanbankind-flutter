import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/themes/app_typography.dart';

import '../../core/localization/local_keys.dart' show LocalKeys;
import '../../core/services/font_service.dart';

enum AppTextVariant { h1, h2, body, small, button, body2 }

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    Key? key,
    this.variant = AppTextVariant.body,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use FontService if available
    final fontService = Get.isRegistered<FontService>()
        ? Get.find<FontService>()
        : null;

    // If fontService is available, use Obx for reactive updates
    if (fontService != null) {
      return Obx(() {
        final family = fontService.currentFont.value;
        final typography = AppTypography(fontFamily: family);
        final style = _getStyleFromVariant(typography, context);

        return Text(
          text,
          style: style.copyWith(
            fontWeight: fontWeight ?? style.fontWeight,
            color: color ?? style.color,
          ),
          textAlign: textAlign ?? TextAlign.start,
          maxLines: maxLines,
          overflow: overflow,
        );
      });
    }

    // Fallback when FontService is not available
    final typography = AppTypography(fontFamily: 'Cairo');
    final style = _getStyleFromVariant(typography, context);

    return Text(
      text,
      style: style.copyWith(
        fontWeight: fontWeight ?? style.fontWeight,
        color: color ?? style.color,
      ),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getStyleFromVariant(
    AppTypography typography,
    BuildContext context,
  ) {
    switch (variant) {
      case AppTextVariant.h1:
        return typography.h1(context);
      case AppTextVariant.h2:
        return typography.h2(context);
      case AppTextVariant.small:
        return typography.small(context);
      case AppTextVariant.button:
        return typography.button(context);
      case AppTextVariant.body:
        return typography.body(context);
      case AppTextVariant.body2:
        return typography.body2(context);
    }
  }
}

class KanbanColumnTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  final FontWeight? fontWeight;

  const KanbanColumnTitle({
    super.key,
    required this.title,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        String displayText = title;
        AppTextVariant variant = AppTextVariant.h2;

        // Determine appropriate text and variant based on width
        if (availableWidth < 60) {
          displayText = _getInitials(title);
          variant = AppTextVariant.small;
        } else if (availableWidth < 100) {
          displayText = _getAbbreviation(title);
          variant = AppTextVariant.body;
        } else {
          variant = AppTextVariant.h2;
        }

        return AppText(
          displayText,
          variant: variant,
          color: textColor,
          fontWeight: fontWeight,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
    );
  }

  String _getInitials(String text) {
    final words = text.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (text.length >= 2) {
      return text.substring(0, 2).toUpperCase();
    }
    return text.toUpperCase();
  }

  String _getAbbreviation(String text) {
    switch (text.toLowerCase()) {
      case 'to do':
        return LocalKeys.todo.tr;
      case 'in progress':
        return LocalKeys.inProgress.tr;
      case 'done':
        return LocalKeys.done.tr;
      default:
        final words = text.split(' ');
        if (words.length > 1) return words.first;
        return text.length > 8 ? '${text.substring(0, 6)}...' : text;
    }
  }
}
