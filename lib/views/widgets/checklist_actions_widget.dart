import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/checklist_controller.dart';
import '../../core/themes/app_colors.dart';

class ChecklistActionsWidget extends StatelessWidget {
  final ChecklistController controller;
  final bool isEditable;
  final bool showSearch;
  final bool compact;

  const ChecklistActionsWidget({
    Key? key,
    required this.controller,
    this.isEditable = true,
    this.showSearch = true,
    this.compact = false,
  }) : super(key: key);

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Items'),
        content: Text(
          'Are you sure you want to delete all ${controller.completedItems} completed items? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.clearCompletedItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllDialog(BuildContext context, bool markAsDone) {
    final action = markAsDone ? 'complete' : 'uncomplete';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${markAsDone ? 'Complete' : 'Uncomplete'} All Items'),
        content: Text(
          'Are you sure you want to $action all ${controller.totalItems} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.markAllItems(markAsDone);
            },
            child: Text(markAsDone ? 'Complete All' : 'Uncomplete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasItems) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: compact ? 4 : 8,
          horizontal: compact ? 4 : 8,
        ),
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Search bar
            if (showSearch && !compact)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outline.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search checklist items...',
                    hintStyle: TextStyle(
                      color: AppColors.onSurface.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.onSurface.withOpacity(0.5),
                    ),
                    suffixIcon: controller.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: controller.clearSearch,
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.onSurface.withOpacity(0.5),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

            // Action buttons
            Row(
              children: [
                // Statistics
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: compact ? 16 : 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${controller.completedItems}/${controller.totalItems}',
                          style: TextStyle(
                            fontSize: compact ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 4),
                          Text(
                            'completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (isEditable) ...[
                  const SizedBox(width: 8),

                  // Mark all complete/incomplete
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_all_complete':
                          if (controller.remainingItems > 0) {
                            _showMarkAllDialog(context, true);
                          }
                          break;
                        case 'mark_all_incomplete':
                          if (controller.completedItems > 0) {
                            _showMarkAllDialog(context, false);
                          }
                          break;
                        case 'clear_completed':
                          if (controller.completedItems > 0) {
                            _showClearCompletedDialog(context);
                          }
                          break;
                        case 'refresh':
                          controller.refresh();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (controller.remainingItems > 0)
                        PopupMenuItem(
                          value: 'mark_all_complete',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline),
                              const SizedBox(width: 12),
                              Text('Complete All (${controller.remainingItems})'),
                            ],
                          ),
                        ),
                      
                      if (controller.completedItems > 0)
                        PopupMenuItem(
                          value: 'mark_all_incomplete',
                          child: Row(
                            children: [
                              const Icon(Icons.radio_button_unchecked),
                              const SizedBox(width: 12),
                              Text('Uncomplete All (${controller.completedItems})'),
                            ],
                          ),
                        ),
                      
                      if (controller.completedItems > 0) ...[
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'clear_completed',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: AppColors.error),
                              const SizedBox(width: 12),
                              Text(
                                'Clear Completed (${controller.completedItems})',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 12),
                            Text('Refresh'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Quick action chips (compact mode)
            if (compact && isEditable && (controller.completedItems > 0 || controller.remainingItems > 0))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  children: [
                    if (controller.remainingItems > 0)
                      ActionChip(
                        label: Text(
                          'Complete All',
                          style: TextStyle(fontSize: 11),
                        ),
                        onPressed: () => _showMarkAllDialog(context, true),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                    
                    if (controller.completedItems > 0)
                      ActionChip(
                        label: Text(
                          'Clear Done',
                          style: TextStyle(fontSize: 11),
                        ),
                        onPressed: () => _showClearCompletedDialog(context),
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

// Floating action menu for checklist actions
class ChecklistFloatingActions extends StatelessWidget {
  final ChecklistController controller;
  final int taskId;

  const ChecklistFloatingActions({
    Key? key,
    required this.controller,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasItems) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clear completed
          if (controller.completedItems > 0)
            FloatingActionButton(
              heroTag: "clear_completed",
              mini: true,
              onPressed: () => controller.clearCompletedItems(),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.clear_all, color: AppColors.white),
            ),

          if (controller.completedItems > 0)
            const SizedBox(height: 8),

          // Mark all complete
          if (controller.remainingItems > 0)
            FloatingActionButton(
              heroTag: "mark_all_complete",
              mini: true,
              onPressed: () => controller.markAllItems(true),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.done_all, color: AppColors.white),
            ),

          if (controller.remainingItems > 0)
            const SizedBox(height: 8),

          // Add new item
          FloatingActionButton(
            heroTag: "add_item",
            onPressed: () {
              // This could trigger a bottom sheet or dialog
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Checklist Item',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        // Add your AddChecklistItemWidget here
                        // AddChecklistItemWidget(taskId: taskId, autoFocus: true),
                      ],
                    ),
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        ],
      );
    });
  }
}
