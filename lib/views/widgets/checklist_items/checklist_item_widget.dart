import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/checklist_item_model.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../../components/icon_buttons/app_icon_button.dart';
import '../../components/icon_buttons/icon_button_style.dart';
import '../responsive_text.dart';
import 'add_edit_checklist_item_modal.dart';
import 'checklist_item_options_modal.dart';

class ChecklistItemWidget extends StatefulWidget {
  final ChecklistItemModel item;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReorder;
  final bool isEditable;
  final bool showActions;
  final bool showDragHandle;

  const ChecklistItemWidget({
    Key? key,
    required this.item,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onReorder,
    this.isEditable = true,
    this.showActions = true,
    this.showDragHandle = true,
  }) : super(key: key);

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.item.isDone) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChecklistItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isDone != widget.item.isDone) {
      if (widget.item.isDone) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _toggleCompletion() {
    HapticFeedback.selectionClick();
    
    if (widget.onToggle != null) {
      widget.onToggle!();
    } else {
      final controller = Get.find<ChecklistItemController>();
      controller.toggleItemDone(widget.item.id!);
    }
  }

  void _showEditModal() {
    AddEditChecklistItemModal.show(
      context,
      checklistId: widget.item.checklistId,
      item: widget.item,
    );
  }

  void _showOptionsModal() {
    ChecklistItemOptionsModal.show(context, item: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.item.isDone
                    ? colorScheme.primary.withValues(alpha: 0.05)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.item.isDone
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  if (!widget.item.isDone)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _toggleCompletion,
                    onLongPress: widget.isEditable ? _showEditModal : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Drag Handle
                          if (widget.showDragHandle) ...[
                            ReorderableDragStartListener(
                              index: 0, // This will be set by parent
                              child: Icon(
                                Icons.drag_handle,
                                size: 18,
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Checkbox
                          _buildCheckbox(),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: _buildTitle(),
                          ),

                          // Action buttons
                          if (widget.showActions && _isHovered) ...[
                            const SizedBox(width: 8),
                            _buildActionButtons(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: _toggleCompletion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.item.isDone
              ? colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: widget.item.isDone
                ? colorScheme.primary
                : colorScheme.outline,
            width: 2,
          ),
        ),
        child: widget.item.isDone
            ? Icon(
                Icons.check,
                color: colorScheme.onPrimary,
                size: 14,
              )
            : null,
      ),
    );
  }

  Widget _buildTitle() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppText(
      widget.item.title,
      variant: AppTextVariant.body,
      fontWeight: widget.item.isDone ? FontWeight.w400 : FontWeight.w500,
      color: widget.item.isDone
          ? colorScheme.onSurface.withValues(alpha: 0.6)
          : colorScheme.onSurface,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        if (widget.isEditable)
          AppIconButton(
            style: AppIconButtonStyle.plain,
            onPressed: _showEditModal,
            child: Icon(
              Icons.edit_outlined,
              size: 16,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),

        const SizedBox(width: 4),

        // Options button
        AppIconButton(
          style: AppIconButtonStyle.plain,
          onPressed: _showOptionsModal,
          child: Icon(
            Icons.more_vert,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
