// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/localization/local_keys.dart';
// import 'package:kanbankit/core/services/dialog_service.dart';
// import 'package:kanbankit/views/widgets/lists/lists_header.dart';
// import 'package:kanbankit/views/widgets/lists/list_tile_widget.dart';
// import 'package:kanbankit/views/widgets/lists/list_column_widget.dart';
// import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
// import '../../controllers/list_controller.dart';
// import '../../controllers/card_controller.dart';
// import '../../models/board_model.dart';
// import '../../models/list_model.dart';
// import '../../core/enums/board_view_mode.dart';
// import '../widgets/responsive_text.dart';
// import '../widgets/boards/view_mode_toggle.dart';
// import '../components/empty_state.dart';
// import '../components/state_widgets.dart';

// class BoardListsScreen extends StatefulWidget {
//   final Board board;

//   const BoardListsScreen({super.key, required this.board});

//   @override
//   State<BoardListsScreen> createState() => _BoardListsScreenState();
// }

// class _BoardListsScreenState extends State<BoardListsScreen> {
//   BoardViewMode _currentMode = BoardViewMode.active;
//   late final ListController _listController;
//   late final DialogService _dialogService;
//   late final CardController _cardController;
//   late final ScrollController _horizontalScrollController;

//   // Auto-scroll variables
//   Timer? _autoScrollTimer;
//   bool _isDragging = false;

//   @override
//   void initState() {
//     super.initState();
//     _listController = Get.find<ListController>();
//     _dialogService = Get.find<DialogService>();
//     _horizontalScrollController = ScrollController();

//     // Ensure CardController is registered as a singleton
//     if (!Get.isRegistered<CardController>()) {
//       Get.put<CardController>(CardController(), permanent: true);
//     }
//     _cardController = Get.find<CardController>();

//     // Set the board ID and load lists
//     _listController.setBoardId(widget.board.id!);

//     // Load all cards for this board
//     _loadCardsForBoard();
//   }

//   @override
//   void dispose() {
//     _horizontalScrollController.dispose();
//     _autoScrollTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadCardsForBoard() async {
//     await _cardController.loadAllCards(showLoading: false);
//   }

//   // Auto-scroll methods
//   void _startAutoScroll(double velocity) {
//     if (_autoScrollTimer == null ||
//         (_autoScrollTimer != null && !_autoScrollTimer!.isActive)) {
//       _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
//         final newOffset = _horizontalScrollController.offset + velocity;
//         if (newOffset >= _horizontalScrollController.position.minScrollExtent &&
//             newOffset <= _horizontalScrollController.position.maxScrollExtent) {
//           _horizontalScrollController.jumpTo(newOffset);
//         } else {
//           _stopAutoScroll();
//         }
//       });
//     }
//   }

//   void _stopAutoScroll() {
//     _autoScrollTimer?.cancel();
//     // Don't set _isDragging = false here, only in handleDragEnd
//   }

//   // Auto-scroll logic based on pointer position (following TaskController pattern)
//   void handlePointerMove(PointerMoveEvent event) {
//     if (!_isDragging) return;

//     const double hotZoneWidth = 100.0;
//     const double scrollSpeed = 10.0;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final position = event.position.dx;

//     // Left hot zone - scroll left
//     if (position < hotZoneWidth) {
//       if (_horizontalScrollController.position.pixels >
//           _horizontalScrollController.position.minScrollExtent) {
//         _startAutoScroll(-scrollSpeed);
//       }
//     }
//     // Right hot zone - scroll right
//     else if (position > screenWidth - hotZoneWidth) {
//       if (_horizontalScrollController.position.pixels <
//           _horizontalScrollController.position.maxScrollExtent) {
//         _startAutoScroll(scrollSpeed);
//       }
//     }
//     // Outside hot zones
//     else {
//       _stopAutoScroll();
//     }
//   }

//   void handleDragStart() {
//     _isDragging = true;
//   }

//   void handleDragEnd() {
//     _isDragging = false;
//     _stopAutoScroll();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: AppText(
//           _currentMode == BoardViewMode.active
//               ? widget.board.title
//               : LocalKeys.archivedBoards.tr,
//           variant: AppTextVariant.h2,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.onSurface,
//         ),
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         elevation: 0,
//         actions: [
//           // Search button (only for active lists)
//           if (_currentMode == BoardViewMode.active)
//             IconButton(
//               onPressed: () => _showSearchDialog(context),
//               icon: Icon(
//                 Icons.search,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//               tooltip: LocalKeys.searchLists.tr,
//             ),
//           // Refresh button
//           IconButton(
//             onPressed: () => _refreshCurrentView(),
//             icon: Icon(
//               Icons.refresh,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             tooltip: LocalKeys.refresh.tr,
//           ),
//           // More options menu
//           PopupMenuButton<String>(
//             icon: Icon(
//               Icons.more_vert,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             onSelected: _handleMenuAction,
//             itemBuilder: (context) => [
//               if (_currentMode == BoardViewMode.active) ...[
//                 PopupMenuItem(
//                   value: 'archive_all',
//                   child: Row(
//                     children: [
//                       const Icon(Icons.archive, size: 18),
//                       const SizedBox(width: 12),
//                       Text(LocalKeys.archiveAllLists.tr),
//                     ],
//                   ),
//                 ),
//               ] else ...[
//                 PopupMenuItem(
//                   value: 'restore_all',
//                   child: Row(
//                     children: [
//                       const Icon(Icons.unarchive, size: 18),
//                       const SizedBox(width: 12),
//                       Text(LocalKeys.restoreAllLists.tr),
//                     ],
//                   ),
//                 ),
//               ],
//               PopupMenuItem(
//                 value: 'board_settings',
//                 child: Row(
//                   children: [
//                     const Icon(Icons.settings, size: 18),
//                     const SizedBox(width: 12),
//                     Text(LocalKeys.boardSettings.tr),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // View mode toggle
//           _buildViewModeToggle(context),

//           // Main content
//           Expanded(
//             child: Obx(() {
//               if (_listController.isLoading) {
//                 return const LoadingView();
//               }

//               if (_currentMode == BoardViewMode.active) {
//                 return _buildActiveLists(context);
//               } else {
//                 return _buildArchivedLists(context);
//               }
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: _currentMode == BoardViewMode.active
//           ? FloatingActionButton.extended(
//               onPressed: () => _showAddListModal(context),
//               icon: const Icon(Icons.add),
//               label: Text(LocalKeys.addList.tr),
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//             )
//           : null,
//     );
//   }

//   Widget _buildViewModeToggle(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ViewModeToggle(
//         currentMode: _currentMode,
//         activeLabel: LocalKeys.yourLists.tr,
//         archivedLabel: LocalKeys.archivedLists.tr,
//         onModeChanged: (mode) {
//           setState(() {
//             _currentMode = mode;
//           });
//           _refreshCurrentView();
//         },
//       ),
//     );
//   }

//   Widget _buildActiveLists(BuildContext context) {
//     return Obx(() {
//       final lists = _listController.filteredLists;
//       final searchQuery = _listController.searchQuery;

//       // For active lists view, show the Kanban board layout
//       return _buildKanbanBoard(context, lists, isArchived: false);
//     });
//   }

//   Widget _buildArchivedLists(BuildContext context) {
//     return Obx(() {
//       final archivedLists = _listController.archivedLists;

//       // For archived lists view, show the list view as before
//       return Column(
//         children: [
//           // Lists header
//           ListsHeader(
//             boardTitle: widget.board.title,
//             totalLists: archivedLists.length,
//             isArchived: true,
//             totalArchivedLists: archivedLists.length,
//           ),

//           // Archived lists content
//           Expanded(
//             child: archivedLists.isEmpty
//                 ? _buildEmptyState(context, isArchived: true)
//                 : _buildListsGrid(context, archivedLists, isArchived: true),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildKanbanBoard(
//     BuildContext context,
//     List<ListModel> lists, {
//     bool isArchived = false,
//   }) {
//     if (lists.isEmpty) {
//       return _buildEmptyState(context, isArchived: false);
//     }

//     // Filter out archived lists and sort by position
//     final activeLists = lists.where((list) => list.isActive).toList()
//       ..sort((a, b) => a.position.compareTo(b.position));

//     return Listener(
//       onPointerMove: handlePointerMove,
//       child: NotificationListener<ScrollNotification>(
//         onNotification: (notification) {
//           // Stop auto-scroll when user manually scrolls
//           if (notification is UserScrollNotification) {
//             _stopAutoScroll();
//           }
//           return false;
//         },
//         child: SingleChildScrollView(
//           controller: _horizontalScrollController,
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Add lists as columns
//               ...activeLists.map((list) {
//                 return ListColumnWidget(
//                   list: list,
//                   onListUpdated: (updatedList) {
//                     _listController.updateList(updatedList);
//                   },
//                   onListDeleted: (list) {
//                     _handleDeleteList(list);
//                   },
//                   onListArchived: (list) {
//                     _handleArchiveList(list);
//                   },
//                   onDragStart: handleDragStart,
//                   onDragEnd: handleDragEnd,
//                 );
//               }).toList(),

//               // Add new list column
//               _buildAddListColumn(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAddListColumn(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       width: 280,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       child: Card(
//         elevation: 2,
//         shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: InkWell(
//           onTap: () => _showAddListModal(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: colorScheme.outline.withValues(alpha: 0.2),
//                 width: 2,
//               ),
//               color: colorScheme.surface,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.add, size: 48, color: colorScheme.primary),
//                 const SizedBox(height: 16),
//                 AppText(
//                   LocalKeys.addList.tr,
//                   variant: AppTextVariant.h2,
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.primary,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildListsGrid(
//     BuildContext context,
//     List<ListModel> lists, {
//     bool isArchived = false,
//   }) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: lists.length,
//       itemBuilder: (context, index) {
//         final list = lists[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: ListTileWidget(
//             list: list,
//             isArchived: isArchived,
//             onTap: () => _handleListTap(list),
//             onEdit: () => _showEditListModal(context, list),
//             onArchive: isArchived ? null : () => _handleArchiveList(list),
//             onUnarchive: isArchived ? () => _handleUnarchiveList(list) : null,
//             onDelete: () => _handleDeleteList(list),
//             onDuplicate: isArchived ? null : () => _handleDuplicateList(list),
//             onMoveToBoard: isArchived ? null : () => _handleMoveToBoard(list),
//             lastUpdated: list.updatedAt,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context, {required bool isArchived}) {
//     if (isArchived) {
//       return EmptyState(
//         title: LocalKeys.noArchivedLists.tr,
//         subtitle: LocalKeys.archivedListsWillAppearHereDescription.tr,
//         icon: Icons.archive_outlined,
//       );
//     }

//     final hasSearchQuery = _listController.searchQuery.isNotEmpty;
//     if (hasSearchQuery) {
//       return EmptyState(
//         title: LocalKeys.noListsFound.tr,
//         subtitle: LocalKeys.noListsMatchSearch.tr,
//         icon: Icons.search_off,
//         actionText: LocalKeys.clearSearch.tr,
//         onActionPressed: () {
//           _listController.clearSearch();
//           _listController.loadListsForBoard(
//             widget.board.id!,
//             showLoading: false,
//           );
//         },
//       );
//     }

//     return EmptyState(
//       title: LocalKeys.noListsYet.tr,
//       subtitle: LocalKeys.createFirstListDescription.tr,
//       icon: Icons.view_column_outlined,
//       actionText: LocalKeys.createList.tr,
//       onActionPressed: () => _showAddListModal(context),
//     );
//   }

//   // Event handlers
//   void _handleListTap(ListModel list) {
//     // TODO: Navigate to list details or tasks view
//     _dialogService.showSnack(
//       title: LocalKeys.listSelected.tr,
//       message: LocalKeys.tappedOnList.trParams({'title': list.title}),
//     );
//   }

//   void _handleArchiveList(ListModel list) async {
//     final confirmed = await _dialogService.confirm(
//       title: LocalKeys.archiveList.tr,
//       message: LocalKeys.confirmArchiveList.trParams({'title': list.title}),
//       confirmText: LocalKeys.archive.tr,
//       cancelText: LocalKeys.cancel.tr,
//     );

//     if (confirmed == true) {
//       await _listController.archiveList(list.id!);
//     }
//   }

//   void _handleUnarchiveList(ListModel list) async {
//     await _listController.unarchiveList(list.id!);
//   }

//   void _handleDeleteList(ListModel list) async {
//     final confirmed = await _dialogService.confirm(
//       title: LocalKeys.deleteList.tr,
//       message: LocalKeys.confirmDeleteList.trParams({'title': list.title}),
//       confirmText: LocalKeys.delete.tr,
//       cancelText: LocalKeys.cancel.tr,
//     );

//     if (confirmed == true) {
//       await _listController.deleteList(list.id!);
//     }
//   }

//   void _handleDuplicateList(ListModel list) async {
//     final result = await _dialogService.promptInput(
//       title: LocalKeys.duplicateList.tr,
//       label: LocalKeys.enterNameForDuplicatedList.tr,
//       initialValue: '${list.title} (Copy)',
//     );

//     if (result != null && result.isNotEmpty) {
//       await _listController.duplicateList(list.id!, result);
//     }
//   }

//   void _handleMoveToBoard(ListModel list) {
//     // TODO: Implement move to board functionality
//     _dialogService.showSnack(
//       title: LocalKeys.moveToBoard.tr,
//       message: LocalKeys.moveToBoardDescription.tr,
//     );
//   }

//   void _handleMenuAction(String action) {
//     switch (action) {
//       case 'archive_all':
//         _handleArchiveAllLists();
//         break;
//       case 'restore_all':
//         _handleRestoreAllLists();
//         break;
//       case 'board_settings':
//         _handleBoardSettings();
//         break;
//     }
//   }

//   void _handleArchiveAllLists() async {
//     final confirmed = await _dialogService.confirm(
//       title: LocalKeys.archiveAllListsDialog.tr,
//       message: LocalKeys.confirmArchiveAllLists.tr,
//       confirmText: LocalKeys.archiveAll.tr,
//       cancelText: LocalKeys.cancel.tr,
//     );

//     if (confirmed == true) {
//       await _listController.archiveAllLists();
//     }
//   }

//   void _handleRestoreAllLists() async {
//     final confirmed = await _dialogService.confirm(
//       title: LocalKeys.restoreAllListsDialog.tr,
//       message: LocalKeys.confirmRestoreAllLists.tr,
//       confirmText: LocalKeys.restoreAll.tr,
//       cancelText: LocalKeys.cancel.tr,
//     );

//     if (confirmed == true) {
//       await _listController.unarchiveAllLists();
//     }
//   }

//   void _handleBoardSettings() {
//     // TODO: Navigate to board settings or show board edit modal
//     _dialogService.showSnack(
//       title: LocalKeys.boardSettingsDialog.tr,
//       message: LocalKeys.boardSettingsDescription.tr,
//     );
//   }

//   // Modal and dialog methods
//   void _showAddListModal(BuildContext context) {
//     AddEditListModal.show(context, boardId: widget.board.id!);
//   }

//   void _showEditListModal(BuildContext context, ListModel list) {
//     AddEditListModal.show(context, list: list, boardId: widget.board.id!);
//   }

//   void _showSearchDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(LocalKeys.searchLists.tr),
//         content: TextField(
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: LocalKeys.enterListName.tr,
//             prefixIcon: Icon(
//               Icons.search,
//               color: Theme.of(
//                 context,
//               ).colorScheme.onSurface.withValues(alpha: 0.6),
//             ),
//           ),
//           onSubmitted: (query) {
//             Navigator.of(context).pop();
//             if (query.trim().isNotEmpty) {
//               _listController.searchListsInBoard(query);
//             } else {
//               _listController.loadListsForBoard(
//                 widget.board.id!,
//                 showLoading: false,
//               );
//             }
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(LocalKeys.cancel.tr),
//           ),
//         ],
//       ),
//     );
//   }

//   void _refreshCurrentView() {
//     if (_currentMode == BoardViewMode.active) {
//       _listController.loadListsForBoard(widget.board.id!);
//       // Also refresh cards when refreshing lists
//       _cardController.loadAllCards(showLoading: false);
//     } else {
//       _listController.loadArchivedLists();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/views/widgets/lists/lists_header.dart';
import 'package:kanbankit/views/widgets/lists/list_tile_widget.dart';
import 'package:kanbankit/views/widgets/lists/list_column_widget.dart';
import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
import '../../controllers/list_controller.dart';
import '../../controllers/card_controller.dart';
import '../../controllers/drag_controller.dart';
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

  @override
  Widget build(BuildContext context) {
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
              ...activeLists.map((list) {
                return ListColumnWidget(
                  list: list,
                  onListUpdated: (updatedList) =>
                      _listController.updateList(updatedList),
                  onListDeleted: (list) => _handleDeleteList(list),
                  onListArchived: (list) => _handleArchiveList(list),
                  onDragStart: _dragController.handleDragStart,
                  onDragEnd: _dragController.handleDragEnd,
                );
              }),
              _buildAddListColumn(context),
            ],
          ),
        ),
      ),
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
