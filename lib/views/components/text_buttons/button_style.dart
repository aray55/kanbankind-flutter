import 'package:flutter/material.dart';
import 'button_size.dart';
import 'button_variant.dart';

TextStyle textStyle(BuildContext context, ButtonSizeConf s, AppButtonVariant v) {
  final base = Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 14);
  final sizeAdjusted = base.copyWith(
    fontSize: s.minHeight == 48 ? (base.fontSize ?? 14) + 2 : // large
              s.minHeight == 36 ? (base.fontSize ?? 14) - 1 : // small
              base.fontSize,
    fontWeight: FontWeight.w600,
    decoration: v == AppButtonVariant.link ? TextDecoration.underline : TextDecoration.none,
  );
  return sizeAdjusted;
}
