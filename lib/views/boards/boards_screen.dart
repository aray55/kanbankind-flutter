import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../../controllers/board_controller.dart';
import '../widgets/board_tile_widget.dart';
import '../widgets/add_edit_board_modal.dart';
import '../widgets/responsive_text.dart';
import '../widgets/language_switcher.dart';
import '../components/theme_switcher.dart';
import '../components/empty_state.dart';
import '../components/state_widgets.dart';
import 'archived_boards_screen.dart';

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boardController = Get.find<BoardController>();

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          LocalKeys.appName.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // Language switcher
          IconButton(
            onPressed: () => LanguageSwitcherBottomSheet.show(),
            icon: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.changeLanguage.tr,
          ),
          // Theme switcher
          IconButton(
            onPressed: () => ThemeSwitcherBottomSheet.show(),
            icon: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.chooseTheme.tr,
          ),
          // Search button
          IconButton(
            onPressed: () => _showSearchDialog(context, boardController),
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.searchBoards.tr,
          ),
          // More options menu
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value, boardController),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    AppText(LocalKeys.refresh.tr, variant: AppTextVariant.body),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archived',
                child: Row(
                  children: [
                    Icon(
                      Icons.archive,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      LocalKeys.archivedBoards.tr,
                      variant: AppTextVariant.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (boardController.isLoading) {
          return const LoadingView();
        }

        if (!boardController.hasBoards) {
          return EmptyState(
            icon: Icons.dashboard_outlined,
            title: LocalKeys.noBoardsYet.tr,
            subtitle: LocalKeys.createFirstBoard.tr,
            actionText: LocalKeys.create.tr,
            onActionPressed: () => _showAddBoardModal(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => boardController.refresh(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar (if searching)
                if (boardController.searchQuery.isNotEmpty)
                  _buildSearchHeader(context, boardController),

                // Boards count
                _buildBoardsHeader(context, boardController),

                const SizedBox(height: 16),

                // Boards grid
                Expanded(child: _buildBoardsGrid(context, boardController)),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBoardModal(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: AppText(LocalKeys.addBoard.tr, variant: AppTextVariant.button),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, BoardController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              '${LocalKeys.searchingFor.tr} "${controller.searchQuery}"',
              variant: AppTextVariant.body,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: () {
              controller.clearSearch();
              controller.loadBoards();
            },
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardsHeader(BuildContext context, BoardController controller) {
    final totalBoards = controller.searchQuery.isEmpty
        ? controller.totalBoards
        : controller.filteredBoards.length;

    return Row(
      children: [
        AppText(
          controller.searchQuery.isEmpty
              ? LocalKeys.yourBoards.tr
              : LocalKeys.searchResults.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppText(
            totalBoards.toString(),
            variant: AppTextVariant.small,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardsGrid(BuildContext context, BoardController controller) {
    final boards = controller.searchQuery.isEmpty
        ? controller.boards
        : controller.filteredBoards;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return BoardTileWidget(
          board: board,
          onTap: () => _navigateToBoardDetail(context, board),
          onEdit: () => _showEditBoardModal(context, board),
          onArchive: () => _showArchiveConfirmation(context, board),
          onDelete: () => _showDeleteConfirmation(context, board),
          onDuplicate: () => _showDuplicateBoardDialog(context, board),
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

  void _showAddBoardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditBoardModal(),
    );
  }

  void _showEditBoardModal(BuildContext context, board) {
    final boardController = Get.find<BoardController>();
    boardController.selectBoard(board);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditBoardModal(board: board),
    );
  }

  void _showSearchDialog(BuildContext context, BoardController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.searchBoards.tr, variant: AppTextVariant.h2),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocalKeys.enterBoardName.tr,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            Navigator.of(context).pop();
            if (query.trim().isNotEmpty) {
              controller.updateSearchQuery(query);
              controller.searchBoards(query);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.archiveBoard.tr, variant: AppTextVariant.h2),
        content: AppText(
          '${LocalKeys.areYouSureArchive.tr} "${board.title}"?',
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
              Get.find<BoardController>().archiveBoard(board.id!);
            },
            child: AppText(
              LocalKeys.archive.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.deleteBoard.tr, variant: AppTextVariant.h2),
        content: AppText(
          '${LocalKeys.areYouSureDelete.tr} "${board.title}"? ${LocalKeys.cannotBeUndone.tr}.',
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
              Get.find<BoardController>().deleteBoard(board.id!);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: AppText(
              LocalKeys.delete.tr,
              variant: AppTextVariant.button,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateBoardDialog(BuildContext context, board) {
    final textController = TextEditingController(text: '${board.title} (Copy)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.duplicateBoard.tr, variant: AppTextVariant.h2),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: LocalKeys.newBoardName.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.find<BoardController>().duplicateBoard(
                board.id!,
                textController.text,
              );
            },
            child: AppText(
              LocalKeys.duplicate.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, BoardController controller) {
    switch (value) {
      case 'refresh':
        controller.refresh();
        break;
      case 'archived':
        Navigator.of(Get.context!).push(
          MaterialPageRoute(builder: (context) => const ArchivedBoardsScreen()),
        );
        break;
    }
  }

  void _navigateToBoardDetail(BuildContext context, board) {
    // Navigate to board detail screen
    // Get.toNamed('/board-detail', arguments: board);
  }
}
