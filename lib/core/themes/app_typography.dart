import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/font_service.dart';
import '../utils/responsive_utils.dart';

class AppTypography {
  final String fontFamily;

  AppTypography({String? fontFamily})
    : fontFamily = fontFamily ?? _getDefaultFont();

  // ✅ جلب الخط الافتراضي من FontService أو Cairo
  static String _getDefaultFont() {
    try {
      if (Get.isRegistered<FontService>()) {
        final fontService = Get.find<FontService>();
        return fontService.currentFont.value;
      }
    } catch (_) {}
    return 'Cairo'; // fallback
  }

  // ✅ أنماط نصوص ديناميكية حسب حجم الشاشة
  TextStyle h1(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: ResponsiveUtils.fontSize(context, 20),
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  TextStyle h2(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: ResponsiveUtils.fontSize(context, 16),
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  TextStyle body(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: ResponsiveUtils.fontSize(context, 14),
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  TextStyle small(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: ResponsiveUtils.fontSize(context, 10),
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  TextStyle button(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: ResponsiveUtils.fontSize(context, 12),
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
  );

  // ✅ TextTheme كامل لـ Material 3 مع دوال BuildContext للـ responsive
  TextTheme textTheme(BuildContext context) => TextTheme(
    displayLarge: h1(context),
    displayMedium: h2(context),
    headlineLarge: h1(context),
    headlineMedium: h2(context),
    headlineSmall: h2(
      context,
    ).copyWith(fontSize: ResponsiveUtils.fontSize(context, 18)),
    titleLarge: body(context).copyWith(fontWeight: FontWeight.w600),
    titleMedium: body(context),
    titleSmall: small(context),
    bodyLarge: body(context),
    bodyMedium: small(context),
    bodySmall: small(
      context,
    ).copyWith(fontSize: ResponsiveUtils.fontSize(context, 10)),
    labelLarge: button(context),
    labelMedium: button(
      context,
    ).copyWith(fontSize: ResponsiveUtils.fontSize(context, 14)),
    labelSmall: small(context).copyWith(
      fontSize: ResponsiveUtils.fontSize(context, 12),
      fontWeight: FontWeight.w500,
    ),
  );
}
