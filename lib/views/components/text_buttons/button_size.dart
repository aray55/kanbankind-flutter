import 'package:flutter/material.dart';

enum AppButtonSize { small, medium, large }

class ButtonSizeConf {
  final EdgeInsets padding;
  final double iconSize;
  final double spinnerSize;
  final double radius;
  final double minHeight;
  final double gap;

  const ButtonSizeConf({
    required this.padding,
    required this.iconSize,
    required this.spinnerSize,
    required this.radius,
    required this.minHeight,
    required this.gap,
  });

  factory ButtonSizeConf.forSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const ButtonSizeConf(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          iconSize: 18,
          spinnerSize: 16,
          radius: 10,
          minHeight: 36,
          gap: 8,
        );
      case AppButtonSize.large:
        return const ButtonSizeConf(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          iconSize: 22,
          spinnerSize: 20,
          radius: 14,
          minHeight: 48,
          gap: 10,
        );
      case AppButtonSize.medium:
      return const ButtonSizeConf(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          iconSize: 20,
          spinnerSize: 18,
          radius: 12,
          minHeight: 40,
          gap: 8,
        );
    }
  }
}
