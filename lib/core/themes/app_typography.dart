// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../services/font_service.dart';

// class AppTypography {
//   final String fontFamily;
//   final double scale;

//   AppTypography({String? fontFamily, this.scale = 1.0})
//       : fontFamily = fontFamily ?? _getDefaultFont();

//   // Get default font from FontService or fallback to system font
//   static String _getDefaultFont() {
//     try {
//       if (Get.isRegistered<FontService>()) {
//         final fontService = Get.find<FontService>();
//         return fontService.currentFont.value;
//       }
//     } catch (e) {
//       // Ignore error and use fallback
//     }
//     // Fallback to system font if FontService is not available
//     return 'Cairo'; // Default font
//   }

//   TextStyle get h1 => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: 24 * scale,
//         fontWeight: FontWeight.bold,
//         height: 1.3,
//       );

//   TextStyle get h2 => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: 20 * scale,
//         fontWeight: FontWeight.w600,
//         height: 1.3,
//       );

//   TextStyle get body => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: 16 * scale,
//         fontWeight: FontWeight.normal,
//         height: 1.5,
//       );

//   TextStyle get small => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: 14 * scale,
//         fontWeight: FontWeight.normal,
//         height: 1.4,
//         color: Colors.grey,
//       );

//   TextStyle get button => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: 16 * scale,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 1.1,
//       );

//   // 👇 New: Return a full TextTheme for Material 3
//   TextTheme get textTheme => TextTheme(
//         displayLarge: h1,           // Largest heading
//         displayMedium: h2,          // Medium heading
//         headlineLarge: h1,          // App bar title, etc.
//         headlineMedium: h2,
//         headlineSmall: h2.copyWith(fontSize: 18 * scale), // Optional
//         titleLarge: body.copyWith(fontWeight: FontWeight.w600), // Section titles
//         titleMedium: body,
//         titleSmall: small,
//         bodyLarge: body,
//         bodyMedium: small,          // Smaller body text
//         bodySmall: small.copyWith(fontSize: 12 * scale), // Captions, hints
//         labelLarge: button,         // Buttons, large labels
//         labelMedium: button.copyWith(fontSize: 14 * scale),
//         labelSmall: small.copyWith(fontSize: 12 * scale, fontWeight: FontWeight.w500),
//       );
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../services/font_service.dart';
// import '../utils/responsive_utils.dart';

// class AppTypography {
//   final String fontFamily;
//   final BuildContext context;

//   AppTypography(this.context, {String? fontFamily})
//       : fontFamily = fontFamily ?? _getDefaultFont();

//   // ✅ جلب الخط الافتراضي من FontService أو Cairo
//   static String _getDefaultFont() {
//     try {
//       if (Get.isRegistered<FontService>()) {
//         final fontService = Get.find<FontService>();
//         return fontService.currentFont.value;
//       }
//     } catch (_) {}
//     return 'Cairo'; // fallback
//   }

//   // ✅ أنماط النصوص (Responsive)
//   TextStyle get h1 => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: ResponsiveUtils.fontSize(context, 24),
//         fontWeight: FontWeight.bold,
//         height: 1.3,
//       );

//   TextStyle get h2 => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: ResponsiveUtils.fontSize(context, 20),
//         fontWeight: FontWeight.w600,
//         height: 1.3,
//       );

//   TextStyle get body => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: ResponsiveUtils.fontSize(context, 16),
//         fontWeight: FontWeight.normal,
//         height: 1.5,
//       );

//   TextStyle get small => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: ResponsiveUtils.fontSize(context, 14),
//         fontWeight: FontWeight.normal,
//         height: 1.4,
//         color: Colors.grey,
//       );

//   TextStyle get button => TextStyle(
//         fontFamily: fontFamily,
//         fontSize: ResponsiveUtils.fontSize(context, 16),
//         fontWeight: FontWeight.w600,
//         letterSpacing: 1.1,
//       );

//   // ✅ TextTheme كامل متوافق مع Material 3
//   TextTheme get textTheme => TextTheme(
//         displayLarge: h1, // عناوين كبيرة
//         displayMedium: h2,
//         headlineLarge: h1, // AppBar
//         headlineMedium: h2,
//         headlineSmall: h2.copyWith(
//           fontSize: ResponsiveUtils.fontSize(context, 18),
//         ),
//         titleLarge: body.copyWith(fontWeight: FontWeight.w600),
//         titleMedium: body,
//         titleSmall: small,
//         bodyLarge: body,
//         bodyMedium: small,
//         bodySmall: small.copyWith(
//           fontSize: ResponsiveUtils.fontSize(context, 12),
//         ),
//         labelLarge: button,
//         labelMedium: button.copyWith(
//           fontSize: ResponsiveUtils.fontSize(context, 14),
//         ),
//         labelSmall: small.copyWith(
//           fontSize: ResponsiveUtils.fontSize(context, 12),
//           fontWeight: FontWeight.w500,
//         ),
//       );
// }
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
        fontSize: ResponsiveUtils.fontSize(context, 24),
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  TextStyle h2(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: ResponsiveUtils.fontSize(context, 20),
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  TextStyle body(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: ResponsiveUtils.fontSize(context, 16),
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  TextStyle small(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: ResponsiveUtils.fontSize(context, 14),
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: Colors.grey,
      );

  TextStyle button(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: ResponsiveUtils.fontSize(context, 16),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      );

  // ✅ TextTheme كامل لـ Material 3 مع دوال BuildContext للـ responsive
  TextTheme textTheme(BuildContext context) => TextTheme(
        displayLarge: h1(context),
        displayMedium: h2(context),
        headlineLarge: h1(context),
        headlineMedium: h2(context),
        headlineSmall: h2(context).copyWith(
          fontSize: ResponsiveUtils.fontSize(context, 18),
        ),
        titleLarge: body(context).copyWith(fontWeight: FontWeight.w600),
        titleMedium: body(context),
        titleSmall: small(context),
        bodyLarge: body(context),
        bodyMedium: small(context),
        bodySmall: small(context).copyWith(
          fontSize: ResponsiveUtils.fontSize(context, 12),
        ),
        labelLarge: button(context),
        labelMedium: button(context).copyWith(
          fontSize: ResponsiveUtils.fontSize(context, 14),
        ),
        labelSmall: small(context).copyWith(
          fontSize: ResponsiveUtils.fontSize(context, 12),
          fontWeight: FontWeight.w500,
        ),
      );
}
