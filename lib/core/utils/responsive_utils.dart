import 'package:flutter/material.dart';

class ResponsiveUtils {
  // استرجاع عرض الشاشة وارتفاعها
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // النسبة المئوية من العرض
  static double wp(BuildContext context, double percent) =>
      screenWidth(context) * (percent / 100);

  // النسبة المئوية من الارتفاع
  static double hp(BuildContext context, double percent) =>
      screenHeight(context) * (percent / 100);

  // حساب حجم الخط بناءً على نسبة عرض الشاشة أو قيمة افتراضية
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    // مثال: تصميم على 375px width (iPhone X baseline)
    final scale = width / 375.0;
    return baseSize * scale;
  }

  // حجم أي عنصر يعتمد على screen width
  static double scaledSize(BuildContext context, double size) {
    final width = screenWidth(context);
    return size * (width / 375.0);
  }
}
