import 'package:flutter/material.dart';
import 'package:kanbankit/models/list_model.dart';
import 'package:kanbankit/views/widgets/lists/list_column_widget.dart';

/// Wrapper widget that makes ListColumnWidget draggable for reordering
class DraggableListColumn extends StatelessWidget {
  final ListModel list;
  final Function(ListModel) onListUpdated;
  final Function(ListModel) onListDeleted;
  final Function(ListModel) onListArchived;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Function(ListModel, int)? onListReordered;

  const DraggableListColumn({
    super.key,
    required this.list,
    required this.onListUpdated,
    required this.onListDeleted,
    required this.onListArchived,
    this.onDragStart,
    this.onDragEnd,
    this.onListReordered,
  });

  @override
  Widget build(BuildContext context) {
    final listColor = _getListColor(context);
    
    return LongPressDraggable<ListModel>(
      data: list,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          height: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: listColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: listColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: listColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 32,
                      decoration: BoxDecoration(
                        color: listColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        list.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.drag_indicator,
                      color: listColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.open_with,
                        size: 48,
                        color: listColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'جاري النقل...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: listColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: ListColumnWidget(
          list: list,
          onListUpdated: onListUpdated,
          onListDeleted: onListDeleted,
          onListArchived: onListArchived,
          onDragStart: onDragStart,
          onDragEnd: onDragEnd,
        ),
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        onDragStart?.call();
      },
      onDragCompleted: () {
        onDragEnd?.call();
      },
      onDraggableCanceled: (velocity, offset) {
        onDragEnd?.call();
      },
      child: ListColumnWidget(
        list: list,
        onListUpdated: onListUpdated,
        onListDeleted: onListDeleted,
        onListArchived: onListArchived,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      ),
    );
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
}
