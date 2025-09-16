import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/font_service.dart';

class AppTypography {
  final String fontFamily;
  final double scale;

  AppTypography({String? fontFamily, this.scale = 1.0})
      : fontFamily = fontFamily ?? _getDefaultFont();

  // Get default font from FontService or fallback to system font
  static String _getDefaultFont() {
    try {
      if (Get.isRegistered<FontService>()) {
        final fontService = Get.find<FontService>();
        return fontService.currentFont.value;
      }
    } catch (e) {
      // Ignore error and use fallback
    }
    // Fallback to system font if FontService is not available
    return 'Cairo'; // Default font
  }

  TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24 * scale,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20 * scale,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  TextStyle get body => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * scale,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  TextStyle get small => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * scale,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: Colors.grey,
      );

  TextStyle get button => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      );

  // 👇 New: Return a full TextTheme for Material 3
  TextTheme get textTheme => TextTheme(
        displayLarge: h1,           // Largest heading
        displayMedium: h2,          // Medium heading
        headlineLarge: h1,          // App bar title, etc.
        headlineMedium: h2,
        headlineSmall: h2.copyWith(fontSize: 18 * scale), // Optional
        titleLarge: body.copyWith(fontWeight: FontWeight.w600), // Section titles
        titleMedium: body,
        titleSmall: small,
        bodyLarge: body,
        bodyMedium: small,          // Smaller body text
        bodySmall: small.copyWith(fontSize: 12 * scale), // Captions, hints
        labelLarge: button,         // Buttons, large labels
        labelMedium: button.copyWith(fontSize: 14 * scale),
        labelSmall: small.copyWith(fontSize: 12 * scale, fontWeight: FontWeight.w500),
      );
}