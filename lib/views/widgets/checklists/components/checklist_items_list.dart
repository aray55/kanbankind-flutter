import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/checklist_item_controller.dart';
import '../../../../models/checklist_model.dart';
import '../../checklist_items/add_edit_checklist_item_modal.dart';
import '../../checklist_items/checklist_item_widget.dart';

class ChecklistItemsList extends StatelessWidget {
  final ChecklistModel checklist;
  final bool isEditable;
  final VoidCallback? onItemsChanged;

  const ChecklistItemsList({
    Key? key,
    required this.checklist,
    this.isEditable = true,
    this.onItemsChanged,
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

      if (items.isEmpty) {
        return const SizedBox.shrink(); // Don't show anything if no items
      }

      return Container(
        key: ValueKey('checklist_items_${checklist.id}'),
        child: Column(
          children: [
            // Load checklist items when widget is first built
            ...items.map((item) {
              return ChecklistItemWidget(
                key: ValueKey(item.id),
                item: item,
                isEditable: isEditable,
                showActions: isEditable,
                showDragHandle: false, // Disable drag handle for now
                onToggle: () {
                  checklistItemController.toggleItemDone(item.id!);
                  onItemsChanged?.call();
                },
                onEdit: () {
                  _showEditItemModal(context, item);
                },
                onDelete: () {
                  checklistItemController.deleteChecklistItem(item.id!);
                  onItemsChanged?.call();
                },
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  void _showEditItemModal(BuildContext context, item) {
    AddEditChecklistItemModal.show(
      context,
      checklistId: checklist.id!,
      item: item,
    ).then((_) {
      // Refresh items after modal closes
      if (!Get.isRegistered<ChecklistItemController>()) {
        Get.put(ChecklistItemController(), permanent: true);
      }
      final checklistItemController = Get.find<ChecklistItemController>();
      checklistItemController.loadActiveItems(checklist.id!);
      onItemsChanged?.call();
    });
  }
}
