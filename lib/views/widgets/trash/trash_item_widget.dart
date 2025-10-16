import 'package:flutter/material.dart';
import '../../../models/trash_item_model.dart';
import '../../../core/utils/color_utils.dart';
import '../responsive_text.dart';

/// Trash Item Widget
/// Purpose: Display a single deleted item in the trash screen
/// Features: Show item info, restore and delete actions

class TrashItemWidget extends StatelessWidget {
  final TrashItemModel item;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentDelete;
  final VoidCallback? onTap;

  const TrashItemWidget({
    Key? key,
    required this.item,
    this.onRestore,
    this.onPermanentDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('trash_item_${item.type}_${item.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ColorUtils.parseColor(item.typeColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and actions
              Row(
                children: [
                  // Type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorUtils.parseColor(item.typeColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ColorUtils.parseColor(item.typeColor).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.typeIcon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          item.typeDisplayName,
                          variant: AppTextVariant.small,
                          fontWeight: FontWeight.w500,
                          color: ColorUtils.parseColor(item.typeColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Actions menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'restore':
                          onRestore?.call();
                          break;
                        case 'delete':
                          onPermanentDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(
                              Icons.restore,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('استعادة'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('حذف نهائي'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              AppText(
                item.title,
                variant: AppTextVariant.h2,
                fontWeight: FontWeight.w600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description (if available)
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                AppText(
                  item.description!,
                  variant: AppTextVariant.body2,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (item.parentInfo != null && item.parentInfo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(
                        item.parentInfo!,
                        variant: AppTextVariant.small,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer with deletion time and quick actions
              Row(
                children: [
                  // Deletion time
                  Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        item.formattedDeletedAt,
                        variant: AppTextVariant.small,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Quick action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Restore button
                      TextButton.icon(
                        onPressed: onRestore,
                        icon: Icon(
                          Icons.restore,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: AppText(
                          'استعادة',
                          variant: AppTextVariant.small,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Delete button
                      TextButton.icon(
                        onPressed: onPermanentDelete,
                        icon: Icon(
                          Icons.delete_forever,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: AppText(
                          'حذف',
                          variant: AppTextVariant.small,
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version of trash item widget for lists
class TrashItemCompactWidget extends StatelessWidget {
  final TrashItemModel item;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentDelete;
  final VoidCallback? onTap;

  const TrashItemCompactWidget({
    Key? key,
    required this.item,
    this.onRestore,
    this.onPermanentDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('trash_item_compact_${item.type}_${item.id}'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorUtils.parseColor(item.typeColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorUtils.parseColor(item.typeColor).withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            item.typeIcon,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: AppText(
        item.title,
        variant: AppTextVariant.body,
        fontWeight: FontWeight.w500,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            item.typeDisplayName,
            variant: AppTextVariant.small,
            color: ColorUtils.parseColor(item.typeColor),
            fontWeight: FontWeight.w500,
          ),
          if (item.parentInfo != null && item.parentInfo!.isNotEmpty)
            AppText(
              item.parentInfo!,
              variant: AppTextVariant.small,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          AppText(
            item.formattedDeletedAt,
            variant: AppTextVariant.small,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onSelected: (value) {
          switch (value) {
            case 'restore':
              onRestore?.call();
              break;
            case 'delete':
              onPermanentDelete?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'restore',
            child: Row(
              children: [
                Icon(
                  Icons.restore,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('استعادة'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('حذف نهائي'),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
