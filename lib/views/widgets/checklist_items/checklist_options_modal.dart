import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_model.dart';
import '../../../controllers/checklists_controller.dart';
import '../responsive_text.dart';

class ChecklistOptionsModal extends StatelessWidget {
  final ChecklistModel checklist;

  const ChecklistOptionsModal({
    Key? key,
    required this.checklist,
  }) : super(key: key);

  // Static method to show the modal
  static Future<void> show(
    BuildContext context, {
    required ChecklistModel checklist,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChecklistOptionsModal(checklist: checklist),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<ChecklistsController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed handle bar
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // Options
                  _buildOptions(context,controller),
                ],
              ),
            ),
          ),
        ],
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
            color: colorScheme.primary.withValues(alpha: 0.1),
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
                LocalKeys.checklistOptions.tr,
                variant: AppTextVariant.h2,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              AppText(
                checklist.title,
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

  Widget _buildOptions(BuildContext context,ChecklistsController controller) {
    return Column(
      children: [
        // Rename option
        _buildOptionTile(
          context: context,
          icon: Icons.edit_outlined,
          title: LocalKeys.renameChecklist.tr,
          subtitle: LocalKeys.renameChecklistDescription.tr,
          onTap: () => _showRenameDialog(context,controller),
        ),

        const SizedBox(height: 8),

        // Archive/Unarchive option
        _buildOptionTile(
          context: context,
          icon: checklist.archived ? Icons.unarchive : Icons.archive,
          title: checklist.archived 
              ? LocalKeys.unarchive.tr 
              : LocalKeys.archive.tr,
          subtitle: checklist.archived
              ? LocalKeys.unarchiveChecklistDescription.tr
              : LocalKeys.archiveChecklistDescription.tr,
          onTap: () {
            Navigator.of(context).pop();
            final controller = Get.put(ChecklistsController(), permanent: false);
            if (checklist.archived) {
              controller.unarchiveChecklist(checklist.id!);
            } else {
              controller.archiveChecklist(checklist.id!);
            }
          },
        ),

        const SizedBox(height: 8),

        // Duplicate option
        _buildOptionTile(
          context: context,
          icon: Icons.copy_outlined,
          title: LocalKeys.duplicateChecklist.tr,
          subtitle: LocalKeys.duplicateChecklistDescription.tr,
          onTap: () {
            Navigator.of(context).pop();
            final controller = Get.put(ChecklistsController(), permanent: false);
            controller.duplicateChecklist(checklist.id!, checklist.title);
          },
        ),

        const SizedBox(height: 16),

        // Divider
        Divider(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          thickness: 1,
        ),

        const SizedBox(height: 16),

        // Delete option
        _buildOptionTile(
          context: context,
          icon: Icons.delete_outline,
          title: LocalKeys.deleteChecklist.tr,
          subtitle: LocalKeys.deleteChecklistDescription.tr,
          isDestructive: true,
          onTap: () => _showDeleteConfirmation(context,controller),
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

  void _showRenameDialog(BuildContext context,ChecklistsController controller) {
    Navigator.of(context).pop(); // Close options modal first

    final titleController = TextEditingController(text: checklist.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          LocalKeys.renameChecklist.tr,
          variant: AppTextVariant.h2,
        ),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: LocalKeys.checklistTitle.tr,
            border: const OutlineInputBorder(),
          ),
          maxLength: 255,
          autofocus: true,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty && newTitle != checklist.title) {
                Navigator.of(context).pop();
                final controller = Get.put(ChecklistsController(), permanent: false);
                final updatedChecklist = checklist.copyWith(title: newTitle);
                controller.updateChecklist(updatedChecklist);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: AppText(
              LocalKeys.rename.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context,ChecklistsController controller) {
    Navigator.of(context).pop(); // Close options modal first

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          LocalKeys.deleteChecklist.tr,
          variant: AppTextVariant.h2,
        ),
        content: AppText(
          LocalKeys.deleteChecklistConfirmation.tr,
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
              final controller = Get.put(ChecklistsController(), permanent: false);
              controller.deleteChecklist(checklist.id!);
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
