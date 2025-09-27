import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/checklist_item_controller.dart';
import '../../../../core/localization/local_keys.dart';
import '../../../../models/checklist_model.dart';
import '../../responsive_text.dart';

class ChecklistProgressBar extends StatelessWidget {
  final ChecklistModel checklist;

  const ChecklistProgressBar({
    Key? key,
    required this.checklist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Initialize ChecklistItemController if not already registered
      if (!Get.isRegistered<ChecklistItemController>()) {
        Get.put(ChecklistItemController(), permanent: true);
      }

      final checklistItemController = Get.find<ChecklistItemController>();
      final allItems = checklistItemController.checklistItems;
      final items = allItems
          .where((item) => item.checklistId == checklist.id)
          .toList();

      final totalItems = items.length;
      final completedItems = items.where((item) => item.isDone).length;
      final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

      return Container(
        key: ValueKey('checklist_progress_${checklist.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  '${LocalKeys.progress.tr}: $completedItems/$totalItems',
                  variant: AppTextVariant.small,
                ),
                AppText(
                  '${(progress * 100).toInt()}%',
                  variant: AppTextVariant.small,
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    });
  }
}
