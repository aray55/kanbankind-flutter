import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/expandable_controller.dart';

class ExpandableWidget extends StatelessWidget {
  final ExpandableController controller;
  final Widget header;
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final void Function(bool isExpanded)? onExpansionChanged;
  final bool showExpandIcon;
  final IconData? expandIcon;
  final IconData? collapseIcon;
  final double? expandIconSize;
  final Color? expandIconColor;

  const ExpandableWidget({
    Key? key,
    required this.controller,
    required this.header,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onExpansionChanged,
    this.showExpandIcon = true,
    this.expandIcon = Icons.expand_more,
    this.collapseIcon = Icons.expand_less,
    this.expandIconSize = 24.0,
    this.expandIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isExpanded = controller.isExpanded.value;

      return AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border:
              border ??
              Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                onTap: () {
                  controller.toggle();
                  onExpansionChanged?.call(isExpanded);
                },
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: header),
                      if (showExpandIcon)
                        AnimatedRotation(
                          duration: animationDuration,
                          turns: isExpanded ? 0.5 : 0.0,
                          child: Icon(
                            isExpanded
                                ? (collapseIcon ?? Icons.keyboard_arrow_up)
                                : (expandIcon ?? Icons.keyboard_arrow_down),
                            size: expandIconSize ?? 24.0,
                            color:
                                expandIconColor ??
                                theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Child
            AnimatedCrossFade(
              duration: animationDuration,
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                padding: padding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: child,
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}
