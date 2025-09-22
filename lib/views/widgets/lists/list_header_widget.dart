import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/models/list_model.dart';
import '../responsive_text.dart';

class ListHeaderWidget extends StatelessWidget {
  final ListModel list;
  final Color color;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeColor;

  const ListHeaderWidget({
    super.key,
    required this.list,
    required this.color,
    this.onEdit,
    this.onArchive,
    this.onDelete,
    this.onChangeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: AppText(
              list.title,
              variant: AppTextVariant.h2,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Menu icon for List actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.edit.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_color',
                child: Row(
                  children: [
                    const Icon(Icons.color_lens, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.boardColor.tr),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    const Icon(Icons.archive, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.archive.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text(
                      LocalKeys.delete.tr,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'change_color':
        onChangeColor?.call();
        break;
      case 'archive':
        onArchive?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
