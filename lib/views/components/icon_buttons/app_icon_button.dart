import 'package:flutter/material.dart';
import 'icon_button_variant.dart';
import 'icon_button_size.dart';
import 'icon_button_style.dart';

class AppIconButton extends StatelessWidget {
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final AppIconButtonStyle style;
  final bool selected;
  final bool disabled;
  final bool loading;
  final VoidCallback? onPressed;
  final Widget child;

  const AppIconButton({
    super.key,
    this.variant = AppIconButtonVariant.primary,
    this.size = AppIconButtonSize.medium,
    this.style = AppIconButtonStyle.filled,
    this.selected = false,
    this.disabled = false,
    this.loading = false,
    required this.onPressed,
    required this.child,
  });

  Color _backgroundColor(BuildContext context) {
    final palette = paletteFor(variant);
    switch (style) {
      case AppIconButtonStyle.plain:
        return Colors.transparent;
      case AppIconButtonStyle.filled:
        return disabled ? palette.disabledBg : palette.base;
      case AppIconButtonStyle.tonal:
        return disabled ? palette.disabledBg : palette.container;
    }
  }

  Color _iconColor(BuildContext context) {
    final palette = paletteFor(variant);
    switch (style) {
      case AppIconButtonStyle.plain:
        return disabled ? palette.disabledFg : palette.base;
      case AppIconButtonStyle.filled:
        return disabled ? palette.disabledFgOnBase : palette.onBase;
      case AppIconButtonStyle.tonal:
        if (disabled) return palette.disabledFg;
        return selected ? palette.onContainer : palette.base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeConf = IconButtonSizeConf.forSize(size);
    final bgColor = _backgroundColor(context);
    final iconClr = _iconColor(context);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashFactory: InkRipple.splashFactory,
        onTap: (disabled || loading) ? null : onPressed,
        child: SizedBox(
          width: sizeConf.dimension,
          height: sizeConf.dimension,
          child: Center(
            child: loading
                ? SizedBox(
                    width: sizeConf.spinnerSize,
                    height: sizeConf.spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconClr),
                    ),
                  )
                : IconTheme(
                    data: IconThemeData(
                      size: sizeConf.iconSize,
                      color: iconClr,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
