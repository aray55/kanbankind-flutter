import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/helpers/board_dialog_helper.dart';
import 'package:kanbankit/views/widgets/boards/boards_grid.dart';
import 'package:kanbankit/views/widgets/boards/boards_header.dart';
import 'package:kanbankit/views/widgets/boards/view_mode_toggle.dart';
import '../../controllers/board_controller.dart';
import '../../core/enums/board_view_mode.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/responsive_text.dart';
import '../widgets/language_switcher.dart';
import '../components/theme_switcher.dart';
import '../components/empty_state.dart';
import '../components/state_widgets.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  BoardViewMode _currentMode = BoardViewMode.active;

  @override
  Widget build(BuildContext context) {
    final boardController = Get.find<BoardController>();
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          _currentMode == BoardViewMode.active
              ? LocalKeys.appName.tr
              : LocalKeys.archivedBoards.tr,
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
          // Search button (only for active boards)
          if (_currentMode == BoardViewMode.active)
            IconButton(
              onPressed: () =>
                  BoardDialogHelper.showSearchDialog(context, boardController),
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: LocalKeys.searchBoards.tr,
            ),
          // Trash button
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.trash),
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.trashBin.tr,
          ),
          // Refresh button
          IconButton(
            onPressed: () => _refreshCurrentView(boardController),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.refresh.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          // View mode toggle
          _buildViewModeToggle(context),

          // Main content
          Expanded(
            child: Obx(() {
              if (boardController.isLoading) {
                return const LoadingView();
              }

              if (_currentMode == BoardViewMode.active) {
                return _buildActiveBoards(context, boardController);
              } else {
                return _buildArchivedBoards(context, boardController);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: _currentMode == BoardViewMode.active
          ? FloatingActionButton.extended(
              onPressed: () => BoardDialogHelper.showAddBoardModal(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: AppText(
                LocalKeys.addBoard.tr,
                variant: AppTextVariant.button,
              ),
            )
          : null,
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return ViewModeToggle(
      activeLabel: LocalKeys.yourLists.tr,
      archivedLabel: LocalKeys.archivedLists.tr,
      currentMode: _currentMode,
      onModeChanged: _switchToMode,
    );
  }

  void _switchToMode(BoardViewMode mode) {
    if (_currentMode != mode) {
      setState(() {
        _currentMode = mode;
      });

      final boardController = Get.find<BoardController>();
      if (mode == BoardViewMode.archived) {
        boardController.loadArchivedBoards();
      } else {
        boardController.loadBoards();
      }
    }
  }

  void _refreshCurrentView(BoardController controller) {
    if (_currentMode == BoardViewMode.active) {
      controller.refresh();
    } else {
      controller.loadArchivedBoards();
    }
  }

  Widget _buildActiveBoards(BuildContext context, BoardController controller) {
    if (!controller.hasBoards) {
      return EmptyState(
        icon: Icons.dashboard_outlined,
        title: LocalKeys.noBoardsYet.tr,
        subtitle: LocalKeys.createFirstBoard.tr,
        actionText: LocalKeys.create.tr,
        onActionPressed: () => BoardDialogHelper.showAddBoardModal(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar (if searching)
            if (controller.searchQuery.isNotEmpty)
              _buildSearchHeader(context, controller),

            // Boards count
            BoardsHeader(controller: controller),

            const SizedBox(height: 16),

            // Boards grid
            Expanded(
              child: BoardsGrid(
                controller: controller,
                onTap: (board) => controller.navigateToLists(board.id!),
                onEdit: (board) =>
                    BoardDialogHelper.showEditBoardModal(context, board),
                onArchive: (board) =>
                    BoardDialogHelper.showArchiveConfirmation(context, board),
                onDelete: (board) =>
                    BoardDialogHelper.showDeleteConfirmation(context, board),
                onDuplicate: (board) =>
                    BoardDialogHelper.showDuplicateBoardDialog(context, board),
                onRestore: (board) =>
                    BoardDialogHelper.showRestoreConfirmation(context, board),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedBoards(
    BuildContext context,
    BoardController controller,
  ) {
    if (!controller.hasArchivedBoards) {
      return EmptyState(
        icon: Icons.archive_outlined,
        title: LocalKeys.noArchivedBoards.tr,
        subtitle: LocalKeys.archivedBoardsWillAppearHere.tr,
        actionText: LocalKeys.goBack.tr,
        onActionPressed: () => _switchToMode(BoardViewMode.active),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadArchivedBoards(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Archived boards header
            BoardsHeader(controller: controller, isArchived: true),

            const SizedBox(height: 16),

            // Archived boards grid
            Expanded(
              child: BoardsGrid(
                controller: controller,
                onRestore: (board) =>
                    BoardDialogHelper.showRestoreConfirmation(context, board),
                onDelete: (board) =>
                    BoardDialogHelper.showPermanentDeleteConfirmation(
                      context,
                      board,
                    ),
                isArchived: true,
              ),
            ),
          ],
        ),
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
}
