import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../../models/task_model.dart';
import '../../controllers/checklist_controller.dart';
import '../../core/localization/local_keys.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/helper_functions_utils.dart';
import '../../core/enums/task_status.dart';
import 'info_row.dart';

class TaskDetailsTab extends StatelessWidget {
  final Task task;
  final ChecklistController checklistController;

  const TaskDetailsTab({
    super.key,
    required this.task,
    required this.checklistController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    LocalKeys.taskInformation.tr,
                    variant: AppTextVariant.h2,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  InfoRow(
                    label: LocalKeys.taskTitle.tr,
                    value: task.title,
                    icon: Icons.title,
                  ),
                  const Divider(),

                  // Description
                  InfoRow(
                    label: LocalKeys.taskDescription.tr,
                    value: task.description.isEmpty
                        ? LocalKeys.noDescription.tr
                        : task.description,
                    icon: Icons.description,
                  ),
                  const Divider(),

                  // Status
                  InfoRow(
                    label: LocalKeys.taskStatus.tr,
                    value: HelperFunctionsUtils.getStatusDisplayName(task.status),
                    icon: Icons.info,
                    statusColor: HelperFunctionsUtils.getStatusColor(task.status),
                  ),
                  const Divider(),

                  // Priority
                  InfoRow(
                    label: LocalKeys.priority.tr,
                    value: HelperFunctionsUtils.getPriorityDisplayName(task.priority),
                    icon: Icons.flag,
                    statusColor: HelperFunctionsUtils.getPriorityColor(task.priority),
                  ),
                  const Divider(),

                  // Due Date
                  InfoRow(
                    label: LocalKeys.dueDate.tr,
                    value: task.dueDate != null
                        ? AppDateUtils.formatDateTime(task.dueDate!)
                        : LocalKeys.noDueDate.tr,
                    icon: Icons.schedule,
                    statusColor: task.dueDate != null
                        ? HelperFunctionsUtils.getDueDateColor(task.dueDate!)
                        : null,
                  ),
                  const Divider(),

                  // Created Date
                  InfoRow(
                    label: LocalKeys.created.tr,
                    value: AppDateUtils.formatDateTime(task.createdAt),
                    icon: Icons.calendar_today,
                  ),

                  if (task.updatedAt != null) ...[
                    const Divider(),
                    InfoRow(
                      label: LocalKeys.lastUpdated.tr,
                      value: AppDateUtils.formatDateTime(task.updatedAt!),
                      icon: Icons.update,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress Card (if has checklist)
          Obx(() {
            if (checklistController.hasItems) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        LocalKeys.taskProgress.tr,
                        variant: AppTextVariant.h2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            '${checklistController.completedItems} ${LocalKeys.of.tr} ${checklistController.totalItems} ${LocalKeys.completed.tr}',
                            variant: AppTextVariant.body,
                          ),
                          AppText(
                            '${(checklistController.progressPercentage * 100).toInt()}%',
                            variant: AppTextVariant.body,
                            fontWeight: FontWeight.bold,
                            color: checklistController.isAllCompleted
                                ? Colors.green
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: checklistController.progressPercentage,
                        backgroundColor: HelperFunctionsUtils.getStatusColor(task.status).withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          checklistController.isAllCompleted
                              ? Colors.green
                              : HelperFunctionsUtils.getStatusColor(task.status),
                        ),
                      ),
                      if (checklistController.isAllCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              LocalKeys.allTasksCompleted.tr,
                              variant: AppTextVariant.body,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

}
