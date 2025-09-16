import 'package:flutter/material.dart';
import 'icon_button_variant.dart';
enum AppIconButtonStyle { plain, filled, tonal }

Color backgroundColor(AppIconButtonStyle style, IconButtonPalette p, bool selected, bool enabled) {
  switch (style) {
    case AppIconButtonStyle.plain:
      return Colors.transparent;
    case AppIconButtonStyle.filled:
      if (!enabled) return p.disabledBg;
      return p.base;
    case AppIconButtonStyle.tonal:
      if (!enabled) return p.disabledBg;
      return p.container;
  }
}

Color iconColor(AppIconButtonStyle style, IconButtonPalette p, bool selected, bool enabled) {
  switch (style) {
    case AppIconButtonStyle.plain:
      return enabled ? p.base : p.disabledFg;
    case AppIconButtonStyle.filled:
      return enabled ? p.onBase : p.disabledFgOnBase;
    case AppIconButtonStyle.tonal:
      return enabled ? (selected ? p.onContainer : p.base) : p.disabledFg;
  }
}
