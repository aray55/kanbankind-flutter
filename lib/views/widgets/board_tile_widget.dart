import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/board_model.dart';
import '../../../core/localization/local_keys.dart';
import '../../../core/utils/date_utils.dart';
import 'responsive_text.dart';

class BoardTileWidget extends StatelessWidget {
  final Board board;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const BoardTileWidget({
    super.key,
    required this.board,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boardColor = _getBoardColor(context);

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                boardColor.withValues(alpha: 0.1),
                boardColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with color indicator and menu
              _buildHeader(context, boardColor),

              // Board content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Board title
                      _buildTitle(context),

                      const SizedBox(height: 8),

                      // Board description
                      if (board.description != null &&
                          board.description!.isNotEmpty)
                        _buildDescription(context),

                      const Spacer(),

                      // Board metadata
                      _buildMetadata(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color boardColor) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: boardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          // More options menu with larger touch target
          Padding(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => _buildOptionsMenu(context, boardColor),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8), // Larger touch area
                color: Colors
                    .transparent, // Transparent to not affect visual appearance
                child: Icon(Icons.more_vert, size: 24, color: boardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, Color boardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Menu items
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: AppText(LocalKeys.edit.tr, variant: AppTextVariant.body),
            onTap: () {
              Navigator.of(context).pop();
              onEdit?.call();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.copy,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: AppText(
              LocalKeys.duplicate.tr,
              variant: AppTextVariant.body,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onDuplicate?.call();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.archive,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: AppText(LocalKeys.archive.tr, variant: AppTextVariant.body),
            onTap: () {
              Navigator.of(context).pop();
              onArchive?.call();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: AppText(
              LocalKeys.delete.tr,
              variant: AppTextVariant.body,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return AppText(
      board.title,
      variant: AppTextVariant.h2,
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.bold,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return AppText(
      board.description!,
      variant: AppTextVariant.small,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        // Creation date
        Icon(Icons.access_time, size: 14),
        const SizedBox(width: 4),
        AppText(
          AppDateUtils.formatRelativeTimeLocalized(board.createdAt),
          variant: AppTextVariant.small,
        ),
        const Spacer(),

        // Board status indicator
        if (board.archived)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: AppText(
              LocalKeys.archived.tr,
              variant: AppTextVariant.small,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Color _getBoardColor(BuildContext context) {
    if (board.color != null && board.color!.isNotEmpty) {
      try {
        // Parse hex color
        final colorString = board.color!.replaceFirst('#', '');
        final colorValue = int.parse(colorString, radix: 16);

        if (colorString.length == 6) {
          return Color(0xFF000000 + colorValue);
        } else if (colorString.length == 8) {
          return Color(colorValue);
        } else if (colorString.length == 3) {
          // Convert RGB to RRGGBB
          final r = colorString[0];
          final g = colorString[1];
          final b = colorString[2];
          return Color(0xFF000000 + int.parse('$r$r$g$g$b$b', radix: 16));
        }
      } catch (e) {
        // Fallback to default color if parsing fails
      }
    }

    // Default board color
    return Theme.of(context).colorScheme.primary;
  }

  // Removed the unused _handleMenuSelection method since we're now using a bottom sheet
}
