import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_editor_controller.dart';
import '../../controllers/checklist_controller.dart';
import '../../core/localization/local_keys.dart';
import '../../core/themes/app_typography.dart' show AppTypography;
import '../../core/themes/app_colors.dart';
import 'checklist_item_widget.dart';
import 'checklist_widget.dart';

class ChecklistTab extends StatelessWidget {
  final TaskEditorController? controller;

  const ChecklistTab({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? Get.find<TaskEditorController>();
    final isNewTask = controller.editingTask?.id == null;

    if (isNewTask) {
      // For new tasks, show temporary checklist items
      return _buildNewTaskChecklist(controller);
    } else {
      // For existing tasks, show real checklist items
      return _buildExistingTaskChecklist(controller);
    }
  }

  Widget _buildNewTaskChecklist(TaskEditorController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.checklist_rtl, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Checklist',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Add checklist items for this new task',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Add checklist item input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Obx(
              () => Column(
                children: [
                  TextField(
                    controller: controller.checklistItemController,
                    decoration: InputDecoration(
                      hintText: 'Add checklist item...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.add, color: AppColors.primary),
                      suffixIcon: IconButton(
                        onPressed: () {
                          final text = controller.checklistItemController.text
                              .trim();
                          if (text.isNotEmpty) {
                            controller.addTempChecklistItem(text);
                            controller.checklistItemController.clear();
                          }
                        },
                        icon: Icon(Icons.send, color: AppColors.primary),
                      ),
                    ),
                    onSubmitted: (value) {
                      final text = value.trim();
                      if (text.isNotEmpty) {
                        controller.addTempChecklistItem(text);
                        controller.checklistItemController.clear();
                      }
                    },
                  ),
                  if (controller.tempChecklistItems.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      '${LocalKeys.itemsToAdd.tr} (${controller.tempChecklistItems.length}):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Temporary checklist items
          Expanded(
            child: Obx(() {
              if (controller.tempChecklistItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist_outlined,
                        size: 48,
                        color: AppColors.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalKeys.noChecklistItems.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalKeys.addItemsAboveToCreateChecklist,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.tempChecklistItems.length,
                itemBuilder: (context, index) {
                  final item = controller.tempChecklistItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              controller.removeTempChecklistItem(index),
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.error.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingTaskChecklist(TaskEditorController taskController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Use the old ChecklistWidget approach
          GetBuilder<ChecklistController>(
            init: ChecklistController(),
            builder: (checklistController) {
              // Load checklist items if not already loaded
              if (checklistController.currentTaskId !=
                  taskController.editingTask!.id!) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  checklistController.loadChecklistItems(
                    taskController.editingTask!.id!,
                  );
                });
              }

              return ChecklistWidget(
                taskId: taskController.editingTask!.id!,
                showProgress: true,
                showActions: true,
                isEditable: true,
                header: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.checklist_rtl, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalKeys.taskChecklist.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              LocalKeys.breakDownTaskIntoSmallerSteps.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Show temporary items that will be added when saving
          Obx(() {
            final tempItems = taskController.tempChecklistItems;
            if (tempItems.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${LocalKeys.newItemsToAdd.tr} (${tempItems.length}):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tempItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => taskController
                                    .removeTempChecklistItem(index),
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.error.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
