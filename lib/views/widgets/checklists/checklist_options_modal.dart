import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_model.dart';
import '../responsive_text.dart';

class ChecklistOptionsModal extends StatelessWidget {
  final ChecklistModel checklist;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onMove;

  const ChecklistOptionsModal({
    Key? key,
    required this.checklist,
    this.onEdit,
    this.onArchive,
    this.onDelete,
    this.onDuplicate,
    this.onMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    LocalKeys.checklistOptions.tr,
                    variant: AppTextVariant.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 8),
        
            // Checklist Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: AppText(
                  checklist.title,
                  variant: AppTextVariant.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        
            const SizedBox(height: 16),
        
            // Options List
            _buildOptionTile(
              context,
              icon: Icons.edit_outlined,
              title: LocalKeys.rename.tr,
              subtitle: LocalKeys.editChecklistTitle.tr,
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),
        
            _buildOptionTile(
              context,
              icon: Icons.copy_outlined,
              title: LocalKeys.duplicate.tr,
              subtitle: LocalKeys.createCopyOfChecklist.tr,
              onTap: () {
                Navigator.of(context).pop();
                onDuplicate?.call();
              },
            ),
        
            if (!checklist.archived)
              _buildOptionTile(
                context,
                icon: Icons.archive_outlined,
                title: LocalKeys.archive.tr,
                subtitle: LocalKeys.hideChecklistFromView.tr,
                onTap: () {
                  Navigator.of(context).pop();
                  onArchive?.call();
                },
              ),
        
            if (checklist.archived)
              _buildOptionTile(
                context,
                icon: Icons.unarchive_outlined,
                title: LocalKeys.unarchive.tr,
                subtitle: LocalKeys.restoreChecklistToView.tr,
                onTap: () {
                  Navigator.of(context).pop();
                  onArchive?.call(); // Same callback, controller handles the logic
                },
              ),
        
            // Move option (for future implementation)
            if (onMove != null)
              _buildOptionTile(
                context,
                icon: Icons.move_to_inbox_outlined,
                title: LocalKeys.moveToCard.tr,
                subtitle: LocalKeys.moveChecklistToAnotherCard.tr,
                onTap: () {
                  Navigator.of(context).pop();
                  onMove?.call();
                },
              ),
        
            const Divider(height: 32),
        
            // Danger Zone
            _buildOptionTile(
              context,
              icon: Icons.delete_outline,
              title: LocalKeys.delete.tr,
              subtitle: LocalKeys.deleteChecklistPermanently.tr,
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: AppText(
        title,
        variant: AppTextVariant.body,
        color: color,
      ),
      subtitle: AppText(
        subtitle,
        variant: AppTextVariant.small,
        color: color.withValues(alpha: 0.7),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

// Simplified version for quick actions
class QuickChecklistActions extends StatelessWidget {
  final ChecklistModel checklist;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const QuickChecklistActions({
    Key? key,
    required this.checklist,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            tooltip: LocalKeys.edit.tr,
          ),

        if (onArchive != null)
          IconButton(
            icon: Icon(
              checklist.archived 
                  ? Icons.unarchive_outlined 
                  : Icons.archive_outlined,
            ),
            onPressed: onArchive,
            tooltip: checklist.archived 
                ? LocalKeys.unarchive.tr 
                : LocalKeys.archive.tr,
          ),

        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: LocalKeys.delete.tr,
          ),
      ],
    );
  }
}
