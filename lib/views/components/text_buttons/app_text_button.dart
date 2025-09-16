import 'package:flutter/material.dart';
import 'button_size.dart';
import 'button_variant.dart';
import 'button_style.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.uppercase = false,
    this.align = MainAxisAlignment.center,
    this.borderRadius,
    this.tooltip,
    this.maxLines = 1,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;
  final bool uppercase;
  final MainAxisAlignment align;
  final double? borderRadius;
  final String? tooltip;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final ButtonSizeConf s = ButtonSizeConf.forSize(size);
    final ButtonPalette p = paletteFor(variant);

    final ButtonStyle style = ButtonStyle(
      padding: MaterialStateProperty.all(s.padding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? s.radius),
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return p.disabledFg;
        return p.fg;
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return p.fg.withOpacity(0.15);
        }
        if (states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.focused)) {
          return p.fg.withOpacity(0.10);
        }
        return null;
      }),
      minimumSize: MaterialStateProperty.all(Size(0, s.minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: align,
      children: [
        if (isLoading)
          Padding(
            padding: EdgeInsets.only(right: (leadingIcon != null || label.isNotEmpty) ? s.gap : 0),
            child: SizedBox(
              width: s.spinnerSize,
              height: s.spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(p.fg),
              ),
            ),
          ),
        if (!isLoading && leadingIcon != null)
          Padding(
            padding: EdgeInsets.only(right: label.isNotEmpty ? s.gap : 0),
            child: Icon(leadingIcon, size: s.iconSize, color: p.fg),
          ),
        if (label.isNotEmpty)
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: textStyle(context, s, variant),
            ),
          ),
        if (trailingIcon != null)
          Padding(
            padding: EdgeInsets.only(left: label.isNotEmpty ? s.gap : 0),
            child: Icon(trailingIcon, size: s.iconSize, color: p.fg),
          ),
      ],
    );

    Widget button = TextButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: content,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }
    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip ?? label,
      child: button,
    );
  }
}
