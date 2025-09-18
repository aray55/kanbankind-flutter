import 'package:flutter/material.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';

/// A reusable widget for displaying labeled information with icons and optional status colors.
///
/// This component is commonly used in detail pages to show structured information
/// in a consistent format with Material 3 design guidelines.
class InfoRow extends StatelessWidget {
  /// The label text displayed above the value
  final String label;

  /// The main value text to display
  final String value;

  /// The icon displayed on the left side
  final IconData icon;

  /// Optional color for status indication - affects text and background styling
  final Color? statusColor;

  /// Optional custom icon color, defaults to grey
  final Color? iconColor;

  /// Optional custom label color
  final Color? labelColor;

  /// Optional padding around the entire component
  final EdgeInsets? padding;

  /// Whether to show the status container background when statusColor is provided
  final bool showStatusContainer;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.statusColor,
    this.iconColor,
    this.labelColor,
    this.padding,
    this.showStatusContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final effectiveLabelColor =
        labelColor ?? theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: effectiveIconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.body,
                  color: effectiveLabelColor,
                ),
                const SizedBox(height: 2),
                _buildValueWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueWidget(BuildContext context) {
    final theme = Theme.of(context);

    if (statusColor != null && showStatusContainer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor!.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor!.withValues(alpha: 0.3)),
        ),
        child: AppText(value, variant: AppTextVariant.body, color: statusColor),
      );
    }

    return AppText(value, variant: AppTextVariant.body, color: statusColor);
  }
}

/// A compact version of InfoRow without vertical padding for tight layouts
class CompactInfoRow extends InfoRow {
  const CompactInfoRow({
    super.key,
    required super.label,
    required super.value,
    required super.icon,
    super.statusColor,
    super.iconColor,
    super.labelColor,
    super.showStatusContainer,
  }) : super(padding: EdgeInsets.zero);
}

/// An info row with enhanced visual hierarchy for important information
class HighlightedInfoRow extends InfoRow {
  const HighlightedInfoRow({
    super.key,
    required super.label,
    required super.value,
    required super.icon,
    super.statusColor,
    super.iconColor,
    super.labelColor,
  }) : super(
         padding: const EdgeInsets.symmetric(vertical: 12),
         showStatusContainer: true,
       );
}
