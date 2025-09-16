import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/checklist_item_model.dart';
import '../../core/themes/app_colors.dart';
import '../../controllers/checklist_controller.dart';

class ChecklistItemWidget extends StatefulWidget {
  final ChecklistItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;
  final bool showActions;

  const ChecklistItemWidget({
    Key? key,
    required this.item,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _textController = TextEditingController(text: widget.item.title);
    _focusNode = FocusNode();
    
    if (widget.item.isDone) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
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
    
    if (oldWidget.item.title != widget.item.title) {
      _textController.text = widget.item.title;
    }
  }

  void _toggleCompletion() {
    if (widget.onToggle != null) {
      widget.onToggle!();
    } else {
      final controller = Get.find<ChecklistController>();
      controller.toggleItemCompletion(widget.item.id!);
    }
  }

  void _startEditing() {
    if (!widget.isEditable) return;
    
    setState(() {
      _isEditing = true;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    });
  }

  void _saveEdit() {
    final newTitle = _textController.text.trim();
    if (newTitle.isEmpty) {
      _textController.text = widget.item.title;
      _cancelEdit();
      return;
    }
    
    if (newTitle != widget.item.title) {
      final controller = Get.find<ChecklistController>();
      controller.updateItemTitle(widget.item.id!, newTitle);
    }
    
    _cancelEdit();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _textController.text = widget.item.title;
  }

  void _deleteItem() {
    if (widget.onDelete != null) {
      widget.onDelete!();
    } else {
      final controller = Get.find<ChecklistController>();
      controller.deleteItem(widget.item.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    ? AppColors.surface.withValues(alpha: 0.5)
                    : AppColors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.item.isDone 
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  if (!widget.item.isDone)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isEditing ? null : _toggleCompletion,
                  onLongPress: widget.isEditable && !_isEditing ? _startEditing : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Checkbox
                        GestureDetector(
                          onTap: _toggleCompletion,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.item.isDone 
                                  ? AppColors.primary 
                                  : Colors.transparent,
                              border: Border.all(
                                color: widget.item.isDone 
                                    ? AppColors.primary 
                                    : AppColors.outline,
                                width: 2,
                              ),
                            ),
                            child: widget.item.isDone
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Title
                        Expanded(
                          child: _isEditing
                              ? TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.onSurface,
                                    decoration: widget.item.isDone 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) => _saveEdit(),
                                  onEditingComplete: _saveEdit,
                                )
                              : Text(
                                  widget.item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: widget.item.isDone 
                                        ? AppColors.onSurface.withOpacity(0.6)
                                        : AppColors.onSurface,
                                    decoration: widget.item.isDone 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                ),
                        ),
                        
                        // Actions
                        if (widget.showActions && !_isEditing) ...[
                          const SizedBox(width: 8),
                          
                          // Edit button
                          if (widget.isEditable)
                            IconButton(
                              onPressed: _startEditing,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.onSurface.withOpacity(0.6),
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          
                          // Delete button
                          IconButton(
                            onPressed: _deleteItem,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                        
                        // Save/Cancel buttons when editing
                        if (_isEditing) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _saveEdit,
                            icon: const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          IconButton(
                            onPressed: _cancelEdit,
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ],
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
}
