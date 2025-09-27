import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/label_model.dart';
import '../../../core/localization/local_keys.dart';
import '../../../core/utils/color_utils.dart';

/// Single Label Widget
/// Purpose: Displays an individual label
/// Responsibilities:
/// - Shows the label's title and color
/// - Handles user interactions: edit, delete, select/unselect
class LabelItemWidget extends StatefulWidget {
  final LabelModel label;
  final bool isCompact;
  final bool isSelected;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  const LabelItemWidget({
    Key? key,
    required this.label,
    this.isCompact = false,
    this.isSelected = false,
    this.showActions = true,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  }) : super(key: key);

  @override
  State<LabelItemWidget> createState() => _LabelItemWidgetState();
}

class _LabelItemWidgetState extends State<LabelItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final labelColor = ColorUtils.parseColor(widget.label.color);
    final isLightColor = ColorUtils.isLightColor(labelColor);
    final textColor = isLightColor ? Colors.black87 : Colors.white;

    if (widget.isCompact) {
      return _buildCompactLabel(labelColor, textColor);
    }

    return _buildFullLabel(labelColor, textColor);
  }

  Widget _buildCompactLabel(Color labelColor, Color textColor) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? labelColor 
                : labelColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected 
                ? Border.all(color: textColor.withOpacity(0.3), width: 1)
                : null,
            boxShadow: _isHovered ? [
              BoxShadow(
                color: labelColor.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: textColor,
                  ),
                ),
              Flexible(
                child: Text(
                  widget.label.name,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullLabel(Color labelColor, Color textColor) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected 
                ? labelColor 
                : Get.theme.colorScheme.outline.withOpacity(0.3),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: labelColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.colorScheme.outline.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Label name
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap ?? widget.onToggle,
                child: Text(
                  widget.label.name,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Selection indicator
            if (widget.isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: labelColor,
                ),
              ),

            // Action buttons (show on hover or always if specified)
            if (widget.showActions && (_isHovered || widget.isCompact)) ...[
              const SizedBox(width: 8),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onEdit != null)
          IconButton(
            onPressed: widget.onEdit,
            icon: const Icon(Icons.edit_outlined),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
            tooltip: LocalKeys.editLabel.tr,
          ),
        if (widget.onDelete != null)
          IconButton(
            onPressed: () => _showDeleteConfirmation(),
            icon: const Icon(Icons.delete_outline),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
            tooltip: LocalKeys.deleteLabel.tr,
          ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(LocalKeys.deleteLabel.tr),
        content: Text(
          '${LocalKeys.areYouSureDelete.tr} "${widget.label.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: Text(LocalKeys.delete.tr),
          ),
        ],
      ),
    );
  }
}
