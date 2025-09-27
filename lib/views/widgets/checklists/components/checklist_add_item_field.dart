import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/checklist_item_controller.dart';
import '../../../../core/localization/local_keys.dart';
import '../../../../models/checklist_model.dart';
import '../../responsive_text.dart';
import '../../checklist_items/add_edit_checklist_item_modal.dart';

class ChecklistAddItemField extends StatelessWidget {
  final ChecklistModel checklist;
  final VoidCallback? onItemAdded;

  const ChecklistAddItemField({
    Key? key,
    required this.checklist,
    this.onItemAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('checklist_add_item_${checklist.id}'),
      onTap: () => _showAddItemModal(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                LocalKeys.addChecklistItem.tr,
                variant: AppTextVariant.body,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemModal(BuildContext context) {
    // Initialize ChecklistItemController if not already registered
    if (!Get.isRegistered<ChecklistItemController>()) {
      Get.put(ChecklistItemController(), permanent: true);
    }

    AddEditChecklistItemModal.show(
      context,
      checklistId: checklist.id!,
    ).then((_) {
      // Refresh items after modal closes
      final checklistItemController = Get.find<ChecklistItemController>();
      checklistItemController.loadActiveItems(checklist.id!);
      onItemAdded?.call();
    });
  }
}
