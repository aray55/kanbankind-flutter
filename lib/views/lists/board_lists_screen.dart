
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/views/widgets/lists/lists_header.dart';
import 'package:kanbankit/views/widgets/lists/list_tile_widget.dart';
import 'package:kanbankit/views/widgets/lists/draggable_list_column.dart';
import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
import '../../controllers/list_controller.dart';
import '../../controllers/card_controller.dart';
import '../../controllers/drag_controller.dart';
import '../../controllers/comment_controller.dart';
import '../../controllers/attachment_controller.dart';
import '../../controllers/activity_log_controller.dart';
import '../../controllers/checklists_controller.dart';
import '../../models/board_model.dart';
import '../../models/list_model.dart';
import '../../core/enums/board_view_mode.dart';
import '../widgets/responsive_text.dart';
import '../widgets/boards/view_mode_toggle.dart';
import '../components/empty_state.dart';
import '../components/state_widgets.dart';

class BoardListsScreen extends StatelessWidget {
  final Board board;
  final Rx<BoardViewMode> _currentMode = BoardViewMode.active.obs;

  BoardListsScreen({super.key, required this.board});

  final ListController _listController = Get.find<ListController>();
  final DialogService _dialogService = Get.find<DialogService>();
  final CardController _cardController = Get.put<CardController>(
    CardController(),
    permanent: true,
  );
  final DragController _dragController = Get.put<DragController>(
    DragController(scrollController: ScrollController()),
  );
  
  // Initialize controllers for card details features
  void _initializeCardControllers() {
    if (!Get.isRegistered<CommentController>()) {
      Get.lazyPut<CommentController>(() => CommentController());
    }
    if (!Get.isRegistered<AttachmentController>()) {
      Get.lazyPut<AttachmentController>(() => AttachmentController());
    }
    if (!Get.isRegistered<ActivityLogController>()) {
      Get.lazyPut<ActivityLogController>(() => ActivityLogController());
    }
    if (!Get.isRegistered<ChecklistsController>()) {
      Get.lazyPut<ChecklistsController>(() => ChecklistsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize card-related controllers
    _initializeCardControllers();
    
    // Load board data once
    _listController.setBoardId(board.id!);
    _cardController.loadAllCards(showLoading: false);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => AppText(
            _currentMode.value == BoardViewMode.active
                ? board.title
                : LocalKeys.archivedBoards.tr,
            variant: AppTextVariant.h2,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Obx(
            () => _currentMode.value == BoardViewMode.active
                ? IconButton(
                    onPressed: () => _showSearchDialog(context),
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: LocalKeys.searchLists.tr,
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () => _refreshCurrentView(),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.refresh.tr,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (_currentMode.value == BoardViewMode.active)
                PopupMenuItem(
                  value: 'archive_all',
                  child: Row(
                    children: [
                      const Icon(Icons.archive, size: 18),
                      const SizedBox(width: 12),
                      Text(LocalKeys.archiveAllLists.tr),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'restore_all',
                  child: Row(
                    children: [
                      const Icon(Icons.unarchive, size: 18),
                      const SizedBox(width: 12),
                      Text(LocalKeys.restoreAllLists.tr),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'board_settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.boardSettings.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildViewModeToggle(context),
          Expanded(
            child: Obx(() {
              if (_listController.isLoading) {
                return const LoadingView();
              }

              return _currentMode.value == BoardViewMode.active
                  ? _buildActiveLists(context)
                  : _buildArchivedLists(context);
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => _currentMode.value == BoardViewMode.active
            ? FloatingActionButton.extended(
                onPressed: () => _showAddListModal(context),
                icon: const FaIcon(FontAwesomeIcons.plus),
                label: AppText(
                  LocalKeys.addList.tr,
                  variant: AppTextVariant.button,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => ViewModeToggle(
          currentMode: _currentMode.value,
          activeLabel: LocalKeys.yourLists.tr,
          archivedLabel: LocalKeys.archivedLists.tr,
          onModeChanged: (mode) {
            _currentMode.value = mode;
            _refreshCurrentView();
          },
        ),
      ),
    );
  }

  Widget _buildActiveLists(BuildContext context) {
    return Obx(() {
      final lists = _listController.filteredLists;
      return _buildKanbanBoard(context, lists, isArchived: false);
    });
  }

  Widget _buildArchivedLists(BuildContext context) {
    return Obx(() {
      final archivedLists = _listController.archivedLists;

      return Column(
        children: [
          ListsHeader(
            boardTitle: board.title,
            totalLists: archivedLists.length,
            isArchived: true,
            totalArchivedLists: archivedLists.length,
          ),
          Expanded(
            child: archivedLists.isEmpty
                ? _buildEmptyState(context, isArchived: true)
                : _buildListsGrid(context, archivedLists, isArchived: true),
          ),
        ],
      );
    });
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    List<ListModel> lists, {
    bool isArchived = false,
  }) {
    if (lists.isEmpty) {
      return _buildEmptyState(context, isArchived: false);
    }

    final activeLists = lists.where((l) => l.isActive).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return Listener(
      onPointerMove: (event) =>
          _dragController.handlePointerMove(event, context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification) {
            _dragController.handleDragEnd();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _dragController.scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...activeLists.asMap().entries.map((entry) {
                final index = entry.key;
                final list = entry.value;
                
                return _buildDraggableListColumn(list, index, activeLists);
              }),
              _buildAddListColumn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableListColumn(ListModel list, int index, List<ListModel> allLists) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drop zone before the column (for inserting at this position)
        if (index == 0) _buildDropZone(0, allLists),
        
        // The draggable column
        DraggableListColumn(
          list: list,
          onListUpdated: (updatedList) =>
              _listController.updateList(updatedList),
          onListDeleted: (list) => _handleDeleteList(list),
          onListArchived: (list) => _handleArchiveList(list),
          onDragStart: _dragController.handleDragStart,
          onDragEnd: _dragController.handleDragEnd,
          onListReordered: _handleListReordered,
        ),
        
        // Drop zone after the column (for inserting after this position)
        _buildDropZone(index + 1, allLists),
      ],
    );
  }

  Widget _buildDropZone(int targetIndex, List<ListModel> allLists) {
    return DragTarget<ListModel>(
      onAcceptWithDetails: (details) {
        _handleListReordered(details.data, targetIndex);
      },
      onWillAcceptWithDetails: (details) {
        // Accept any list that's not already at this position
        final currentIndex = allLists.indexWhere((l) => l.id == details.data.id);
        return currentIndex != targetIndex && currentIndex != targetIndex - 1;
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        final colorScheme = Theme.of(context).colorScheme;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 20 : 6,
          height: isActive ? 300 : 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive 
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: isActive 
                ? Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: isActive
              ? Center(
                  child: Icon(
                    Icons.add_circle,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildAddListColumn(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showAddListModal(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 2,
              ),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 48, color: colorScheme.primary),
                const SizedBox(height: 16),
                AppText(
                  LocalKeys.addList.tr,
                  variant: AppTextVariant.h2,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListsGrid(
    BuildContext context,
    List<ListModel> lists, {
    bool isArchived = false,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTileWidget(
            isDraggable: true,
            list: list,
            isArchived: isArchived,
            onTap: () => _handleListTap(list),
            onEdit: () => _showEditListModal(context, list),
            onArchive: isArchived ? null : () => _handleArchiveList(list),
            onUnarchive: isArchived ? () => _handleUnarchiveList(list) : null,
            onDelete: () => _handleDeleteList(list),
            onDuplicate: isArchived ? null : () => _handleDuplicateList(list),
            onMoveToBoard: isArchived ? null : () => _handleMoveToBoard(list),
            lastUpdated: list.updatedAt,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isArchived}) {
    if (isArchived) {
      return EmptyState(
        title: LocalKeys.noArchivedLists.tr,
        subtitle: LocalKeys.archivedListsWillAppearHereDescription.tr,
        icon: Icons.archive_outlined,
      );
    }

    final hasSearchQuery = _listController.searchQuery.isNotEmpty;
    if (hasSearchQuery) {
      return EmptyState(
        title: LocalKeys.noListsFound.tr,
        subtitle: LocalKeys.noListsMatchSearch.tr,
        icon: Icons.search_off,
        actionText: LocalKeys.clearSearch.tr,
        onActionPressed: () {
          _listController.clearSearch();
          _listController.loadListsForBoard(board.id!, showLoading: false);
        },
      );
    }

    return EmptyState(
      title: LocalKeys.noListsYet.tr,
      subtitle: LocalKeys.createFirstListDescription.tr,
      icon: Icons.view_column_outlined,
      actionText: LocalKeys.createList.tr,
      onActionPressed: () => _showAddListModal(context),
    );
  }

  // --- Event handlers (نفس اللي عندك بدون تغيير كبير) ---
  void _handleListTap(ListModel list) {
    _dialogService.showSnack(
      title: LocalKeys.listSelected.tr,
      message: LocalKeys.tappedOnList.trParams({'title': list.title}),
    );
  }

  void _handleArchiveList(ListModel list) async {
    final confirmed = await _dialogService.confirm(
      title: LocalKeys.archiveList.tr,
      message: LocalKeys.confirmArchiveList.trParams({'title': list.title}),
      confirmText: LocalKeys.archive.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    if (confirmed == true) await _listController.archiveList(list.id!);
  }

  void _handleUnarchiveList(ListModel list) async {
    await _listController.unarchiveList(list.id!);
  }

  void _handleDeleteList(ListModel list) async {
    final confirmed = await _dialogService.confirm(
      title: LocalKeys.deleteList.tr,
      message: LocalKeys.confirmDeleteList.trParams({'title': list.title}),
      confirmText: LocalKeys.delete.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    if (confirmed == true) await _listController.deleteList(list.id!);
  }

  void _handleDuplicateList(ListModel list) async {
    final result = await _dialogService.promptInput(
      title: LocalKeys.duplicateList.tr,
      label: LocalKeys.enterNameForDuplicatedList.tr,
      initialValue: '${list.title} (Copy)',
    );
    if (result != null && result.isNotEmpty) {
      await _listController.duplicateList(list.id!, result);
    }
  }

  void _handleMoveToBoard(ListModel list) {
    _dialogService.showSnack(
      title: LocalKeys.moveToBoard.tr,
      message: LocalKeys.moveToBoardDescription.tr,
    );
  }

  void _handleListReordered(ListModel draggedList, int newIndex) async {
    try {
      // Get current active lists sorted by position
      final currentLists = _listController.lists
          .where((l) => l.isActive)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));

      // Remove the dragged list from its current position
      final oldIndex = currentLists.indexWhere((l) => l.id == draggedList.id);
      if (oldIndex == -1) return;

      // Create a new list with updated positions
      final reorderedLists = List<ListModel>.from(currentLists);
      reorderedLists.removeAt(oldIndex);
      
      // Insert at new position (clamp to valid range)
      final insertIndex = newIndex.clamp(0, reorderedLists.length);
      reorderedLists.insert(insertIndex, draggedList);

      // Update positions for all lists
      for (int i = 0; i < reorderedLists.length; i++) {
        reorderedLists[i] = reorderedLists[i].copyWith(position: i.toDouble());
      }

      // Save the new order
      await _listController.reorderLists(reorderedLists);
      
      _dialogService.showSnack(
        title: LocalKeys.success.tr,
        message: 'تم إعادة ترتيب القائمة بنجاح',
      );
    } catch (e) {
      _dialogService.showSnack(
        title: 'خطأ',
        message: 'حدث خطأ أثناء إعادة ترتيب القائمة: $e',
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'archive_all':
        _handleArchiveAllLists();
        break;
      case 'restore_all':
        _handleRestoreAllLists();
        break;
      case 'board_settings':
        _handleBoardSettings();
        break;
    }
  }

  void _handleArchiveAllLists() async {
    final confirmed = await _dialogService.confirm(
      title: LocalKeys.archiveAllListsDialog.tr,
      message: LocalKeys.confirmArchiveAllLists.tr,
      confirmText: LocalKeys.archiveAll.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    if (confirmed == true) await _listController.archiveAllLists();
  }

  void _handleRestoreAllLists() async {
    final confirmed = await _dialogService.confirm(
      title: LocalKeys.restoreAllListsDialog.tr,
      message: LocalKeys.confirmRestoreAllLists.tr,
      confirmText: LocalKeys.restoreAll.tr,
      cancelText: LocalKeys.cancel.tr,
    );
    if (confirmed == true) await _listController.unarchiveAllLists();
  }

  void _handleBoardSettings() {
    _dialogService.showSnack(
      title: LocalKeys.boardSettingsDialog.tr,
      message: LocalKeys.boardSettingsDescription.tr,
    );
  }

  void _showAddListModal(BuildContext context) {
    AddEditListModal.show(context, boardId: board.id!);
  }

  void _showEditListModal(BuildContext context, ListModel list) {
    AddEditListModal.show(context, list: list, boardId: board.id!);
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.searchLists.tr),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocalKeys.enterListName.tr,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          onSubmitted: (query) {
            Navigator.of(context).pop();
            if (query.trim().isNotEmpty) {
              _listController.searchListsInBoard(query);
            } else {
              _listController.loadListsForBoard(board.id!, showLoading: false);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalKeys.cancel.tr),
          ),
        ],
      ),
    );
  }

  void _refreshCurrentView() {
    if (_currentMode.value == BoardViewMode.active) {
      _listController.loadListsForBoard(board.id!);
      _cardController.loadAllCards(showLoading: false);
    } else {
      _listController.loadArchivedLists();
    }
  }
}
