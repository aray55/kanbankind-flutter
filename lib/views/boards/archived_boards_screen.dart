import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../../controllers/board_controller.dart';
import '../../core/utils/date_utils.dart';
import '../widgets/responsive_text.dart';
import '../components/empty_state.dart';
import '../components/state_widgets.dart';

class ArchivedBoardsScreen extends StatelessWidget {
  const ArchivedBoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boardController = Get.find<BoardController>();

    // Load archived boards when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardController.loadArchivedBoards();
    });

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          LocalKeys.archivedBoards.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => boardController.loadArchivedBoards(),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.refresh.tr,
          ),
        ],
      ),
      body: Obx(() {
        if (boardController.isLoading) {
          return const LoadingView();
        }

        if (!boardController.hasArchivedBoards) {
          return EmptyState(
            icon: Icons.archive_outlined,
            title: LocalKeys.noArchivedBoards.tr,
            subtitle: LocalKeys.archivedBoardsWillAppearHere.tr,
            actionText: LocalKeys.goBack.tr,
            onActionPressed: () => Navigator.of(context).pop(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => boardController.loadArchivedBoards(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Archived boards header
                _buildArchivedBoardsHeader(context, boardController),

                const SizedBox(height: 16),

                // Archived boards grid
                Expanded(
                  child: _buildArchivedBoardsGrid(context, boardController),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildArchivedBoardsHeader(
    BuildContext context,
    BoardController controller,
  ) {
    return Row(
      children: [
        Icon(
          Icons.archive,
          color: Theme.of(context).colorScheme.secondary,
          size: 24,
        ),
        const SizedBox(width: 8),
        AppText(
          LocalKeys.archivedBoards.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppText(
            controller.totalArchivedBoards.toString(),
            variant: AppTextVariant.small,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildArchivedBoardsGrid(
    BuildContext context,
    BoardController controller,
  ) {
    final archivedBoards = controller.archivedBoards;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: archivedBoards.length,
      itemBuilder: (context, index) {
        final board = archivedBoards[index];
        return ArchivedBoardTileWidget(
          board: board,
          onRestore: () => _showRestoreConfirmation(context, board),
          onPermanentDelete: () =>
              _showPermanentDeleteConfirmation(context, board),
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _showRestoreConfirmation(BuildContext context, board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.restoreBoard.tr, variant: AppTextVariant.h2),
        content: AppText(
          '${LocalKeys.areYouSureRestore.tr} "${board.title}"?',
          variant: AppTextVariant.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.find<BoardController>().unarchiveBoard(board.id!);
            },
            child: AppText(
              LocalKeys.restore.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(BuildContext context, board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          LocalKeys.permanentlyDeleteBoard.tr,
          variant: AppTextVariant.h2,
        ),
        content: AppText(
          '${LocalKeys.permanentlyDeleteWarning.tr} "${board.title}"? ${LocalKeys.cannotBeUndone.tr}.',
          variant: AppTextVariant.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Note: We need to add permanent delete functionality to the controller
              _permanentlyDeleteBoard(board.id!);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: AppText(
              LocalKeys.permanentlyDelete.tr,
              variant: AppTextVariant.button,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  void _permanentlyDeleteBoard(int boardId) {
    // This will need to be implemented in the BoardController
    Get.find<BoardController>().permanentlyDeleteBoard(boardId);
  }
}

// Custom widget for archived board tiles with different actions
class ArchivedBoardTileWidget extends StatelessWidget {
  final board;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentDelete;

  const ArchivedBoardTileWidget({
    super.key,
    required this.board,
    this.onRestore,
    this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boardColor = _getBoardColor(context);

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              boardColor.withOpacity(0.05),
              boardColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with archived indicator and menu
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
    );
  }

  Widget _buildHeader(BuildContext context, Color boardColor) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: boardColor.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          // Archive actions menu
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert, size: 16, color: boardColor),
              ),
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(
                        Icons.restore,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        LocalKeys.restore.tr,
                        variant: AppTextVariant.body,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'permanent_delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        LocalKeys.permanentlyDelete.tr,
                        variant: AppTextVariant.body,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return AppText(
      board.title,
      variant: AppTextVariant.h2,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      fontWeight: FontWeight.bold,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return AppText(
      board.description!,
      variant: AppTextVariant.small,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        // Archive date
        Icon(
          Icons.archive,
          size: 14,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        AppText(
          LocalKeys.archived.tr,
          variant: AppTextVariant.small,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
        const Spacer(),
        // Creation date
        Icon(
          Icons.access_time,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        AppText(
          AppDateUtils.formatRelativeTimeLocalized(board.createdAt),
          variant: AppTextVariant.small,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

    // Default board color (more muted for archived items)
    return Theme.of(context).colorScheme.secondary;
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'restore':
        onRestore?.call();
        break;
      case 'permanent_delete':
        onPermanentDelete?.call();
        break;
    }
  }
}
