import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/utils/helper_functions_utils.dart';
import 'package:kanbankit/views/components/responsive_text.dart';
import 'package:kanbankit/views/components/text_buttons/app_text_button.dart';
import 'package:kanbankit/views/widgets/enhanced_task_editor.dart';
import '../../models/task_model.dart';
import '../../core/utils/date_utils.dart';
import 'task_editor.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(int) onDeleted;
  final Function(Task) onUpdated;

  const TaskCard({
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
                    child: ResponsiveText(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
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
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 8),
                                Text(LocalKeys.editTask.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  LocalKeys.delete.tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
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
                ResponsiveText(
                  task.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final createdDateWidget = ResponsiveText(
                    'Created: ${AppDateUtils.formatDate(task.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  );

                  final dueDateWidget = task.dueDate != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HelperFunctionsUtils.getDueDateColor(task.dueDate!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ResponsiveText(
                            'Due: ${AppDateUtils.formatDate(task.dueDate!)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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

  void _showTaskEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EnhancedTaskEditor(task: task, onTaskSaved: onUpdated),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.deleteTask.tr),
        content: Text('${LocalKeys.areYouSureDelete.tr} "${task.title}"?'),
        actions: [
          AppTextButton(
            label: LocalKeys.cancel.tr,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppTextButton(
            label: LocalKeys.delete.tr,
            onPressed: () {
              Navigator.of(context).pop();
              onDeleted(task.id!);
            },
          ),
        ],
      ),
    );
  }
}
