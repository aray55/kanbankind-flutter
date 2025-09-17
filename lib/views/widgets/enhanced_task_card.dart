import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/themes/app_colors.dart';
import 'package:kanbankit/core/utils/helper_functions_utils.dart';
import 'package:kanbankit/views/components/text_buttons/app_text_button.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../../models/task_model.dart';
import '../../core/utils/date_utils.dart';
import 'enhanced_task_editor.dart';
import 'checklist_indicator_widget.dart';

class EnhancedTaskCard extends StatelessWidget {
  final Task task;
  final Function(int) onDeleted;
  final Function(Task) onUpdated;

  const EnhancedTaskCard({
    super.key,
    required this.task,
    required this.onDeleted,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2.0,
      child: InkWell(
        onTap: () => _showTaskEditor(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      task.title,
                      maxLines: 2,
                      variant: AppTextVariant.h2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPriorityIndicator(),
                      PopupMenuButton<String>(
                     
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(context);
                          } else if (value == 'edit') {
                            _showTaskEditor(context);
                          } else if (value == 'checklist') {
                            _showTaskEditor(context, initialTab: 1);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 8),
                                AppText(LocalKeys.editTask.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'checklist',
                            child: Row(
                              children: [
                                const Icon(Icons.checklist, size: 16),
                                const SizedBox(width: 8),
                                AppText(LocalKeys.checklist.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 16),
                                const SizedBox(width: 8),
                                AppText(LocalKeys.delete.tr),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                AppText(
                  task.description,
                  maxLines: 3,
                  variant: AppTextVariant.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Checklist indicator (only show if task has an ID)
              if (task.id != null) ...[
                const SizedBox(height: 8),
                ChecklistIndicatorWidget(
                  taskId: task.id!,
                  compact: true,
                  onTap: () => _showTaskEditor(context, initialTab: 1),
                ),
              ],

              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final createdDateWidget = AppText(
                    '${LocalKeys.created.tr}: ${AppDateUtils.formatDate(task.createdAt)}',
                    variant: AppTextVariant.body,
                  );

                  final dueDateWidget = task.dueDate != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HelperFunctionsUtils.getDueDateColor(
                              task.dueDate!,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            '${LocalKeys.dueDate.tr}: ${AppDateUtils.formatDate(task.dueDate!)}',
                            variant: AppTextVariant.body,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null;

                  if (constraints.maxWidth > 200) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: createdDateWidget),
                        if (dueDateWidget != null) dueDateWidget,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: createdDateWidget,
                        ),
                        if (dueDateWidget != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: dueDateWidget,
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    IconData icon;

    switch (task.priority) {
      case 1: // High
        color = Colors.red;
        icon = Icons.keyboard_arrow_up;
        break;
      case 2: // Medium
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case 3: // Low
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      default:
        color = Colors.grey;
        icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: Colors.white),
    );
  }

  void _showTaskEditor(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          EnhancedTaskEditor(task: task, onTaskSaved: onUpdated),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.deleteTask.tr),
        content: AppText('${LocalKeys.areYouSureDelete.tr} "${task.title}"?'),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.of(context).pop(),
            label: LocalKeys.cancel.tr,
          ),
          AppTextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleted(task.id!);
            },
            label: LocalKeys.delete.tr,
          ),
        ],
      ),
    );
  }
}
