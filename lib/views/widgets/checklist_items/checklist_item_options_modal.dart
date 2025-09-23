import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_item_model.dart';
import '../../../controllers/checklist_item_controller.dart';

import '../responsive_text.dart';
import 'add_edit_checklist_item_modal.dart';

class ChecklistItemOptionsModal extends StatelessWidget {
  final ChecklistItemModel item;

  const ChecklistItemOptionsModal({
    Key? key,
    required this.item,
  }) : super(key: key);

  // Static method to show the modal
  static Future<void> show(
    BuildContext context, {
    required ChecklistItemModel item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChecklistItemOptionsModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Options
            _buildOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.more_vert,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                LocalKeys.itemOptions.tr,
                variant: AppTextVariant.h2,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              AppText(
                item.title,
                variant: AppTextVariant.body,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Edit option
        _buildOptionTile(
          context: context,
          icon: Icons.edit_outlined,
          title: LocalKeys.editItem.tr,
          subtitle: LocalKeys.editItemDescription.tr,
          onTap: () {
            Navigator.of(context).pop();
            AddEditChecklistItemModal.show(
              context,
              checklistId: item.checklistId,
              item: item,
            );
          },
        ),

        const SizedBox(height: 8),

        // Toggle completion option
        _buildOptionTile(
          context: context,
          icon: item.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          title: item.isDone 
              ? LocalKeys.markAsPending.tr 
              : LocalKeys.markAsCompleted.tr,
          subtitle: item.isDone
              ? LocalKeys.markAsPendingDescription.tr
              : LocalKeys.markAsCompletedDescription.tr,
          onTap: () {
            Navigator.of(context).pop();
            final controller = Get.put(ChecklistItemController(), permanent: false);
            controller.toggleItemDone(item.id!);
          },
        ),

        const SizedBox(height: 8),

        // Archive/Unarchive option
        _buildOptionTile(
          context: context,
          icon: item.archived ? Icons.unarchive : Icons.archive,
          title: item.archived 
              ? LocalKeys.unarchive.tr 
              : LocalKeys.archive.tr,
          subtitle: item.archived
              ? LocalKeys.unarchiveItemDescription.tr
              : LocalKeys.archiveItemDescription.tr,
          onTap: () {
            Navigator.of(context).pop();
            final controller = Get.put(ChecklistItemController(), permanent: false);
            if (item.archived) {
              controller.unarchiveItem(item.id!);
            } else {
              controller.archiveItem(item.id!);
            }
          },
        ),

        const SizedBox(height: 16),

        // Divider
        Divider(
          color: colorScheme.outline.withOpacity(0.2),
          thickness: 1,
        ),

        const SizedBox(height: 16),

        // Delete option
        _buildOptionTile(
          context: context,
          icon: Icons.delete_outline,
          title: LocalKeys.deleteItem.tr,
          subtitle: LocalKeys.deleteItemDescription.tr,
          isDestructive: true,
          onTap: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isDestructive 
        ? colorScheme.error 
        : colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.body,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? colorScheme.error : null,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      subtitle,
                      variant: AppTextVariant.small,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Navigator.of(context).pop(); // Close options modal first

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          LocalKeys.deleteItem.tr,
          variant: AppTextVariant.h2,
        ),
        content: AppText(
          LocalKeys.deleteItemConfirmation.tr,
          variant: AppTextVariant.body,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(
              LocalKeys.cancel.tr,
              variant: AppTextVariant.button,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              final controller = Get.put(ChecklistItemController(), permanent: false);
              controller.deleteChecklistItem(item.id!);
            },
            child: AppText(
              LocalKeys.delete.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ],
      ),
    );
  }
}
