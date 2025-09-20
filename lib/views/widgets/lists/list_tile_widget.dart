import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/utils/date_utils.dart';
import '../../../models/list_model.dart';
import '../responsive_text.dart';

class ListTileWidget extends StatelessWidget {
  final ListModel list;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onMoveToBoard;
  final int? taskCount;
  final DateTime? lastUpdated;
  final bool showActions;
  final bool isArchived;
  final bool isDraggable;

  const ListTileWidget({
    super.key,
    required this.list,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.onUnarchive,
    this.onDelete,
    this.onDuplicate,
    this.onMoveToBoard,
    this.taskCount,
    this.lastUpdated,
    this.showActions = true,
    this.isArchived = false,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listColor = _getListColor(context);

    Widget child = Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                listColor.withValues(alpha: 0.1),
                listColor.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: listColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and actions
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: listColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: AppText(
                      list.title,
                      variant: AppTextVariant.body2,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Actions menu
                  if (showActions)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => _buildMenuItems(context),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  // Task count
                  if (taskCount != null) ...[
                    Icon(
                      Icons.task_alt,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      taskCount == 1 ? '1 task' : '$taskCount tasks',
                      variant: AppTextVariant.body2,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Archive indicator
                  if (isArchived) ...[
                    Icon(Icons.archive, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    AppText(
                      LocalKeys.archived.tr,
                      variant: AppTextVariant.body2,
                      color: colorScheme.secondary,
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),

                  // Last updated
                  if (lastUpdated != null)
                    AppText(
                      AppDateUtils.formatRelativeTimeLocalized(lastUpdated!),
                      variant: AppTextVariant.body2,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                ],
              ),

              // Position indicator (for debugging/admin)
              if (list.position != 1024.0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(
                    'Position: ${list.position.toStringAsFixed(0)}',
                    variant: AppTextVariant.body2,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap with draggable if needed
    if (isDraggable) {
      child = Draggable<ListModel>(
        data: list,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 280,
            child: Opacity(opacity: 0.8, child: child),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: child),
        child: child,
      );
    }

    return child;
  }

  Color _getListColor(BuildContext context) {
    if (list.color != null && list.color!.isNotEmpty) {
      try {
        return Color(int.parse(list.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback to default color if parsing fails
      }
    }
    return Theme.of(context).colorScheme.primary;
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];

    if (!isArchived) {
      // Active list actions
      if (onEdit != null) {
        items.add(
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 18),
                const SizedBox(width: 12),
                Text(LocalKeys.edit.tr),
              ],
            ),
          ),
        );
      }

      if (onDuplicate != null) {
        items.add(
          PopupMenuItem(
            value: 'duplicate',
            child: Row(
              children: [
                const Icon(Icons.copy, size: 18),
                const SizedBox(width: 12),
                Text(LocalKeys.duplicate.tr),
              ],
            ),
          ),
        );
      }

      if (onMoveToBoard != null) {
        items.add(
          PopupMenuItem(
            value: 'move',
            child: Row(
              children: [
                const Icon(Icons.move_to_inbox, size: 18),
                const SizedBox(width: 12),
                Text('Move to Board'),
              ],
            ),
          ),
        );
      }

      if (items.isNotEmpty) {
        items.add(const PopupMenuDivider());
      }

      if (onArchive != null) {
        items.add(
          PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                const Icon(Icons.archive, size: 18),
                const SizedBox(width: 12),
                Text(LocalKeys.archive.tr),
              ],
            ),
          ),
        );
      }
    } else {
      // Archived list actions
      if (onUnarchive != null) {
        items.add(
          PopupMenuItem(
            value: 'unarchive',
            child: Row(
              children: [
                const Icon(Icons.unarchive, size: 18),
                const SizedBox(width: 12),
                Text(LocalKeys.restore.tr),
              ],
            ),
          ),
        );
      }
    }

    if (onDelete != null) {
      if (items.isNotEmpty) {
        items.add(const PopupMenuDivider());
      }
      items.add(
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                LocalKeys.delete.tr,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'duplicate':
        onDuplicate?.call();
        break;
      case 'move':
        onMoveToBoard?.call();
        break;
      case 'archive':
        onArchive?.call();
        break;
      case 'unarchive':
        onUnarchive?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
