import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/views/widgets/lists/lists_header.dart';
import 'package:kanbankit/views/widgets/lists/list_tile_widget.dart';
import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
import '../../controllers/list_controller.dart';
import '../../models/board_model.dart';
import '../../models/list_model.dart';
import '../../core/enums/board_view_mode.dart';
import '../widgets/responsive_text.dart';
import '../widgets/boards/view_mode_toggle.dart';
import '../components/empty_state.dart';
import '../components/state_widgets.dart';

class BoardListsScreen extends StatefulWidget {
  final Board board;

  const BoardListsScreen({
    super.key,
    required this.board,
  });

  @override
  State<BoardListsScreen> createState() => _BoardListsScreenState();
}

class _BoardListsScreenState extends State<BoardListsScreen> {
  BoardViewMode _currentMode = BoardViewMode.active;
  late final ListController _listController;
  late final DialogService _dialogService;

  @override
  void initState() {
    super.initState();
    _listController = Get.find<ListController>();
    _dialogService = Get.find<DialogService>();
    
    // Set the board ID and load lists
    _listController.setBoardId(widget.board.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          _currentMode == BoardViewMode.active
              ? widget.board.title
              : LocalKeys.archivedBoards.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // Search button (only for active lists)
          if (_currentMode == BoardViewMode.active)
            IconButton(
              onPressed: () => _showSearchDialog(context),
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Search Lists',
            ),
          // Refresh button
          IconButton(
            onPressed: () => _refreshCurrentView(),
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LocalKeys.refresh.tr,
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (_currentMode == BoardViewMode.active) ...[
                PopupMenuItem(
                  value: 'archive_all',
                  child: Row(
                    children: [
                      const Icon(Icons.archive, size: 18),
                      const SizedBox(width: 12),
                      const Text('Archive All Lists'),
                    ],
                  ),
                ),
              ] else ...[
                PopupMenuItem(
                  value: 'restore_all',
                  child: Row(
                    children: [
                      const Icon(Icons.unarchive, size: 18),
                      const SizedBox(width: 12),
                      const Text('Restore All Lists'),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'board_settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 18),
                    const SizedBox(width: 12),
                    const Text('Board Settings'),
                  ],
                ),
              ),
            ],
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
              if (_listController.isLoading) {
                return const LoadingView();
              }

              if (_currentMode == BoardViewMode.active) {
                return _buildActiveLists(context);
              } else {
                return _buildArchivedLists(context);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: _currentMode == BoardViewMode.active
          ? FloatingActionButton.extended(
              onPressed: () => _showAddListModal(context),
              icon: const Icon(Icons.add),
              label: Text('Add List'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ViewModeToggle(
        currentMode: _currentMode,
        onModeChanged: (mode) {
          setState(() {
            _currentMode = mode;
          });
          _refreshCurrentView();
        },
      ),
    );
  }

  Widget _buildActiveLists(BuildContext context) {
    return Obx(() {
      final lists = _listController.filteredLists;
      final searchQuery = _listController.searchQuery;

      return Column(
        children: [
          // Lists header
          ListsHeader(
            boardTitle: widget.board.title,
            totalLists: lists.length,
            searchQuery: searchQuery.isEmpty ? null : searchQuery,
            onClearSearch: searchQuery.isEmpty ? null : () {
              _listController.clearSearch();
              _listController.loadListsForBoard(widget.board.id!, showLoading: false);
            },
          ),

          // Lists content
          Expanded(
            child: lists.isEmpty
                ? _buildEmptyState(context, isArchived: false)
                : _buildListsGrid(context, lists),
          ),
        ],
      );
    });
  }

  Widget _buildArchivedLists(BuildContext context) {
    return Obx(() {
      final archivedLists = _listController.archivedLists;

      return Column(
        children: [
          // Lists header
          ListsHeader(
            boardTitle: widget.board.title,
            totalLists: archivedLists.length,
            isArchived: true,
            totalArchivedLists: archivedLists.length,
          ),

          // Archived lists content
          Expanded(
            child: archivedLists.isEmpty
                ? _buildEmptyState(context, isArchived: true)
                : _buildListsGrid(context, archivedLists, isArchived: true),
          ),
        ],
      );
    });
  }

  Widget _buildListsGrid(BuildContext context, List<ListModel> lists, {bool isArchived = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTileWidget(
            list: list,
            isArchived: isArchived,
            onTap: () => _handleListTap(list),
            onEdit: () => _showEditListModal(context, list),
            onArchive: isArchived ? null : () => _handleArchiveList(list),
            onUnarchive: isArchived ? () => _handleUnarchiveList(list) : null,
            onDelete: () => _handleDeleteList(list),
            onDuplicate: isArchived ? null : () => _handleDuplicateList(list),
            onMoveToBoard: isArchived ? null : () => _handleMoveToBoard(list),
            // TODO: Add task count when task integration is ready
            // taskCount: _getTaskCountForList(list.id!),
            lastUpdated: list.updatedAt,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isArchived}) {
    if (isArchived) {
      return EmptyState(
        title: 'No Archived Lists',
        subtitle: 'Archived lists will appear here when you archive them.',
        icon: Icons.archive_outlined,
      );
    }

    final hasSearchQuery = _listController.searchQuery.isNotEmpty;
    if (hasSearchQuery) {
      return EmptyState(
        title: 'No Lists Found',
        subtitle: 'No lists match your search criteria. Try a different search term.',
        icon: Icons.search_off,
        actionText: 'Clear Search',
        onActionPressed: () {
          _listController.clearSearch();
          _listController.loadListsForBoard(widget.board.id!, showLoading: false);
        },
      );
    }

    return EmptyState(
      title: 'No Lists Yet',
      subtitle: 'Create your first list to organize tasks in this board.',
      icon: Icons.view_column_outlined,
      actionText: 'Create List',
      onActionPressed: () => _showAddListModal(context),
    );
  }

  // Event handlers
  void _handleListTap(ListModel list) {
    // TODO: Navigate to list details or tasks view
    _dialogService.showSnack(
      title: 'List Selected',
      message: 'Tapped on list: ${list.title}',
    );
  }

  void _handleArchiveList(ListModel list) async {
    final confirmed = await _dialogService.confirm(
      title: 'Archive List',
      message: 'Are you sure you want to archive "${list.title}"?',
      confirmText: LocalKeys.archive.tr,
      cancelText: LocalKeys.cancel.tr,
    );

    if (confirmed == true) {
      await _listController.archiveList(list.id!);
    }
  }

  void _handleUnarchiveList(ListModel list) async {
    await _listController.unarchiveList(list.id!);
  }

  void _handleDeleteList(ListModel list) async {
    final confirmed = await _dialogService.confirm(
      title: 'Delete List',
      message: 'Are you sure you want to permanently delete "${list.title}"? This action cannot be undone.',
      confirmText: LocalKeys.delete.tr,
      cancelText: LocalKeys.cancel.tr,
    );

    if (confirmed == true) {
      await _listController.deleteList(list.id!);
    }
  }

  void _handleDuplicateList(ListModel list) async {
    final result = await _dialogService.promptInput(
      title: 'Duplicate List',
      label: 'Enter a name for the duplicated list:',
      initialValue: '${list.title} (Copy)',
    );

    if (result != null && result.isNotEmpty) {
      await _listController.duplicateList(list.id!, result);
    }
  }

  void _handleMoveToBoard(ListModel list) {
    // TODO: Implement move to board functionality
    _dialogService.showSnack(
      title: 'Move to Board',
      message: 'Move to board functionality will be implemented soon.',
    );
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
      title: 'Archive All Lists',
      message: 'Are you sure you want to archive all lists in this board?',
      confirmText: 'Archive All',
      cancelText: LocalKeys.cancel.tr,
    );

    if (confirmed == true) {
      await _listController.archiveAllLists();
    }
  }

  void _handleRestoreAllLists() async {
    final confirmed = await _dialogService.confirm(
      title: 'Restore All Lists',
      message: 'Are you sure you want to restore all archived lists?',
      confirmText: 'Restore All',
      cancelText: LocalKeys.cancel.tr,
    );

    if (confirmed == true) {
      await _listController.unarchiveAllLists();
    }
  }

  void _handleBoardSettings() {
    // TODO: Navigate to board settings or show board edit modal
    _dialogService.showSnack(
      title: 'Board Settings',
      message: 'Board settings functionality will be implemented soon.',
    );
  }

  // Modal and dialog methods
  void _showAddListModal(BuildContext context) {
    AddEditListModal.show(
      context,
      boardId: widget.board.id!,
    );
  }

  void _showEditListModal(BuildContext context, ListModel list) {
    AddEditListModal.show(
      context,
      list: list,
      boardId: widget.board.id!,
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Lists'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter list name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.of(context).pop();
            if (query.trim().isNotEmpty) {
              _listController.searchListsInBoard(query);
            } else {
              _listController.loadListsForBoard(widget.board.id!, showLoading: false);
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
    if (_currentMode == BoardViewMode.active) {
      _listController.loadListsForBoard(widget.board.id!);
    } else {
      _listController.loadArchivedLists();
    }
  }
}
