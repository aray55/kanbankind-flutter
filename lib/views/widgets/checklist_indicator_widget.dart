import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../../controllers/checklist_controller.dart';
import '../../core/localization/local_keys.dart';
import '../../core/themes/app_colors.dart';
import 'checklist_progress_widget.dart';

/// Minimal checklist indicator for task cards
class ChecklistIndicatorWidget extends StatelessWidget {
  final int taskId;
  final bool compact;
  final VoidCallback? onTap;

  const ChecklistIndicatorWidget({
    Key? key,
    required this.taskId,
    this.compact = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a unique tag for each task to avoid sharing controller instances
    final controllerTag = 'checklist_indicator_$taskId';

    return GetBuilder<ChecklistController>(
      tag: controllerTag,
      init: ChecklistController(),
      builder: (controller) {
        // Load checklist items if not already loaded
        if (controller.currentTaskId != taskId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.loadChecklistItems(taskId);
          });
        }

        return Obx(() {
          // Don't show anything if no checklist items
          if (!controller.hasItems) {
            return const SizedBox.shrink();
          }

          if (compact) {
            return _buildCompactIndicator(controller);
          } else {
            return _buildFullIndicator(controller);
          }
        });
      },
    );
  }

  Widget _buildCompactIndicator(ChecklistController controller) {
    final isCompleted = controller.isAllCompleted;
    final progressPercentage = controller.progressPercentage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.checklist,

                  size: 14,
                ),
                const SizedBox(width: 6),
                AppText(
                  '${controller.completedItems}/${controller.totalItems}',
                  variant: AppTextVariant.small,
                ),
                const SizedBox(width: 4),
                AppText(
                  '(${(progressPercentage * 100).round()}%)',
                  variant: AppTextVariant.small,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            Container(
              height: 3,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullIndicator(ChecklistController controller) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, size: 16),
                const SizedBox(width: 6),
                AppText(LocalKeys.checklist.tr, variant: AppTextVariant.body),
                const Spacer(),
                AppText(
                  '${controller.completedItems}/${controller.totalItems}',
                  variant: AppTextVariant.small,
                ),
              ],
            ),
            const SizedBox(height: 4),
            MiniChecklistProgressWidget(
              totalItems: controller.totalItems,
              completedItems: controller.completedItems,
              width: 80,
              height: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Even more minimal version - just an icon with badge
class ChecklistBadgeWidget extends StatelessWidget {
  final int taskId;
  final VoidCallback? onTap;

  const ChecklistBadgeWidget({Key? key, required this.taskId, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChecklistController>(
      init: ChecklistController(),
      builder: (controller) {
        if (controller.currentTaskId != taskId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.loadChecklistItems(taskId);
          });
        }

        return Obx(() {
          if (!controller.hasItems) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Icon(
                  controller.isAllCompleted
                      ? Icons.check_circle
                      : Icons.checklist,
                  size: 16,
                  color: controller.isAllCompleted
                      ? AppColors.primary
                      : AppColors.info,
                ),
                if (controller.completedItems > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: AppText(
                        '${controller.completedItems}',
                        variant: AppTextVariant.small,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}
