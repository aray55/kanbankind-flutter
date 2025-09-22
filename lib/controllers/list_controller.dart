import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import '../core/themes/app_colors.dart' show AppColors;
import '../models/list_model.dart';
import '../data/repository/list_repository.dart';

class ListController extends GetxController {
  final ListRepository _repository = ListRepository();
  final DialogService _dialogService = Get.find<DialogService>();

  // Observable lists and states
  final RxList<ListModel> _lists = <ListModel>[].obs;
  final RxList<ListModel> _archivedLists = <ListModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<ListModel?> _selectedList = Rx<ListModel?>(null);
  final RxInt _currentBoardId = 0.obs;

  // Form controllers for list creation/editing
  final TextEditingController titleController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final RxString _selectedColor = '#2196F3'.obs;

  // Getters
  List<ListModel> get lists => _lists.toList();
  List<ListModel> get archivedLists => _archivedLists.toList();
  List<ListModel> get filteredLists {
    if (_searchQuery.value.isEmpty) {
      return _lists.toList();
    }
    return _lists
        .where(
          (list) => list.title.toLowerCase().contains(
            _searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  ListModel? get selectedList => _selectedList.value;
  String get selectedColor => _selectedColor.value;
  int get currentBoardId => _currentBoardId.value;

  // Computed properties
  int get totalLists => _lists.length;
  int get totalArchivedLists => _archivedLists.length;
  bool get hasLists => _lists.isNotEmpty;
  bool get hasArchivedLists => _archivedLists.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // Lists will be loaded when a board is selected
  }

  @override
  void onClose() {
    titleController.dispose();
    colorController.dispose();
    super.onClose();
  }

  // Set current board and load its lists
  Future<void> setBoardId(int boardId, {bool showLoading = true}) async {
    _currentBoardId.value = boardId;
    await loadListsForBoard(boardId, showLoading: showLoading);
  }

  // Load lists for a specific board
  Future<void> loadListsForBoard(int boardId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final lists = await _repository.getListsByBoardId(boardId);
      _lists.assignAll(lists);
      _currentBoardId.value = boardId;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load all lists across all boards
  Future<void> loadAllLists({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final lists = await _repository.getAllLists();
      _lists.assignAll(lists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load all lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load archived lists for current board
  Future<void> loadArchivedLists() async {
    if (_currentBoardId.value == 0) return;

    try {
      _isLoading.value = true;
      final archivedLists = await _repository.getArchivedListsByBoardId(
        _currentBoardId.value,
      );
      _archivedLists.assignAll(archivedLists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load archived lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new list
  Future<void> createList({
    required int boardId,
    required String title,
    String? color,
    double? position,
  }) async {
    if (title.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final list = await _repository.createList(
        boardId: boardId,
        title: title.trim(),
        color: color,
        position: position,
      );

      // Add to lists if it belongs to current board
      if (boardId == _currentBoardId.value) {
        _lists.add(list);
        _sortListsByPosition();
      }

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: 'List created successfully',
        backgroundColor: AppColors.primary,
        icon: Icons.check_circle_outline,
      );

      clearForm();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to create list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update list
  Future<void> updateList(ListModel list) async {
    try {
      _isUpdating.value = true;

      final updatedList = await _repository.updateList(list);
      if (updatedList != null) {
        final index = _lists.indexWhere((l) => l.id == list.id);
        if (index != -1) {
          _lists[index] = updatedList;
        }

        // Update selected list if it's the one being updated
        if (_selectedList.value?.id == list.id) {
          _selectedList.value = updatedList;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Update list title
  Future<void> updateListTitle(int listId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      final updatedList = await _repository.updateListTitle(
        listId,
        newTitle.trim(),
      );
      if (updatedList != null) {
        final index = _lists.indexWhere((l) => l.id == listId);
        if (index != -1) {
          _lists[index] = updatedList;
        }

        if (_selectedList.value?.id == listId) {
          _selectedList.value = updatedList;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List title updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update list title: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Update list color
  Future<void> updateListColor(int listId, String? newColor) async {
    try {
      final updatedList = await _repository.updateListColor(listId, newColor);
      if (updatedList != null) {
        final index = _lists.indexWhere((l) => l.id == listId);
        if (index != -1) {
          _lists[index] = updatedList;
        }

        if (_selectedList.value?.id == listId) {
          _selectedList.value = updatedList;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List color updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update list color: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Archive list
  Future<void> archiveList(int listId) async {
    try {
      final success = await _repository.archiveList(listId);
      if (success) {
        _lists.removeWhere((list) => list.id == listId);
        await loadArchivedLists(); // Refresh archived lists

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List archived successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.archive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Unarchive list
  Future<void> unarchiveList(int listId) async {
    try {
      final success = await _repository.unarchiveList(listId);
      if (success) {
        _archivedLists.removeWhere((list) => list.id == listId);
        await loadListsForBoard(
          _currentBoardId.value,
          showLoading: false,
        ); // Refresh active lists

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List restored successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.unarchive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to restore list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Delete list
  Future<void> deleteList(int listId) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.deleteList(listId);
      if (success) {
        _lists.removeWhere((list) => list.id == listId);
        _archivedLists.removeWhere((list) => list.id == listId);

        // Clear selected list if it was deleted
        if (_selectedList.value?.id == listId) {
          _selectedList.value = null;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List deleted successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.delete_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to delete list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Duplicate list
  Future<void> duplicateList(int listId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final duplicatedList = await _repository.duplicateList(
        listId,
        newTitle.trim(),
      );

      if (duplicatedList != null) {
        // Add to lists if it belongs to current board
        if (duplicatedList.boardId == _currentBoardId.value) {
          _lists.add(duplicatedList);
          _sortListsByPosition();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List duplicated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.copy_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to duplicate list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Reorder lists
  Future<void> reorderLists(List<ListModel> newOrder) async {
    try {
      final reorderedLists = await _repository.reorderLists(newOrder);
      _lists.assignAll(reorderedLists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to reorder lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload lists to restore original order
      await loadListsForBoard(_currentBoardId.value, showLoading: false);
    }
  }

  // Move list to new position
  Future<void> moveListToPosition(int listId, int newPosition) async {
    try {
      final reorderedLists = await _repository.moveListToPosition(
        listId,
        newPosition,
      );
      _lists.assignAll(reorderedLists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to move list: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload lists to restore original order
      await loadListsForBoard(_currentBoardId.value, showLoading: false);
    }
  }

  // Move list to another board
  Future<void> moveListToBoard(int listId, int newBoardId) async {
    try {
      final movedList = await _repository.moveListToBoard(listId, newBoardId);
      if (movedList != null) {
        // Remove from current lists if it was in current board
        _lists.removeWhere((list) => list.id == listId);

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'List moved to board successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.move_to_inbox_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to move list to board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  // Search lists in current board
  Future<void> searchListsInBoard(String query) async {
    if (_currentBoardId.value == 0) return;

    try {
      _isLoading.value = true;

      final lists = await _repository.searchListsInBoard(
        _currentBoardId.value,
        query.trim(),
      );
      _lists.assignAll(lists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to search lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Search lists across all boards
  Future<void> searchAllLists(String query) async {
    try {
      _isLoading.value = true;

      final lists = await _repository.searchLists(query.trim());
      _lists.assignAll(lists);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to search lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Select list
  void selectList(ListModel? list) {
    _selectedList.value = list;
    if (list != null) {
      populateFormFromList(list);
    }
  }

  // Get list by ID
  ListModel? getListById(int id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get lists statistics for current board
  Future<Map<String, int>> getListsStatistics() async {
    if (_currentBoardId.value == 0) return {'active': 0, 'archived': 0};

    try {
      return await _repository.getListsStatisticsByBoard(_currentBoardId.value);
    } catch (e) {
      return {'active': 0, 'archived': 0};
    }
  }

  // Form management
  void clearForm() {
    titleController.clear();
    colorController.clear();
    _selectedColor.value = '#2196F3';
    _selectedList.value = null;
  }

  void populateFormFromList(ListModel list) {
    titleController.text = list.title;
    colorController.text = list.color ?? '';
    _selectedColor.value = list.color ?? '#2196F3';
  }

  void setSelectedColor(String color) {
    _selectedColor.value = color;
    colorController.text = color;
  }

  // Validation
  bool validateListForm() {
    final title = titleController.text.trim();
    if (title.isEmpty || title.length > 255) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: 'List title must be between 1 and 255 characters',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return false;
    }

    final color = colorController.text.trim();
    if (color.isNotEmpty &&
        !_repository.validateListData(title: title, color: color)) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message:
            'Invalid color format. Use hex format like #FFF, #RRGGBB, or #RRGGBBAA',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return false;
    }

    return true;
  }

  // Create list from form
  Future<void> createListFromForm(int boardId) async {
    if (!validateListForm()) return;

    await createList(
      boardId: boardId,
      title: titleController.text.trim(),
      color: colorController.text.trim().isEmpty
          ? null
          : colorController.text.trim(),
    );
  }

  // Update list from form
  Future<void> updateListFromForm() async {
    if (_selectedList.value == null) return;
    if (!validateListForm()) return;

    final updatedList = _selectedList.value!.copyWith(
      title: titleController.text.trim(),
      color: colorController.text.trim().isEmpty
          ? null
          : colorController.text.trim(),
    );

    await updateList(updatedList);
  }

  // Private helper methods
  void _sortListsByPosition() {
    _lists.sort((a, b) => a.position.compareTo(b.position));
  }

  // Refresh data for current board
  Future<void> refresh() async {
    if (_currentBoardId.value != 0) {
      await loadListsForBoard(_currentBoardId.value);
      if (_archivedLists.isNotEmpty) {
        await loadArchivedLists();
      }
    }
  }

  // Refresh lists and their cards after card movement
  Future<void> refreshAfterCardMovement() async {
    if (_currentBoardId.value != 0) {
      await loadListsForBoard(_currentBoardId.value, showLoading: false);
    }
  }

  // Get recent lists for current board
  Future<List<ListModel>> getRecentLists({int limit = 5}) async {
    try {
      return await _repository.getRecentlyCreatedLists(
        limit: limit,
        boardId: _currentBoardId.value != 0 ? _currentBoardId.value : null,
      );
    } catch (e) {
      return [];
    }
  }

  // Check if list title exists in current board
  Future<bool> listTitleExists(String title, {int? excludeListId}) async {
    if (_currentBoardId.value == 0) return false;

    try {
      return await _repository.listTitleExistsInBoard(
        _currentBoardId.value,
        title,
        excludeListId: excludeListId,
      );
    } catch (e) {
      return false;
    }
  }

  // Get lists by color in current board
  Future<List<ListModel>> getListsByColor(String color) async {
    try {
      return await _repository.getListsByColor(
        color,
        boardId: _currentBoardId.value != 0 ? _currentBoardId.value : null,
      );
    } catch (e) {
      return [];
    }
  }

  // Get total lists count for current board
  Future<int> getTotalListsCount() async {
    if (_currentBoardId.value == 0) return 0;

    try {
      return await _repository.getTotalListsCountByBoard(_currentBoardId.value);
    } catch (e) {
      return 0;
    }
  }

  // Archive all lists in current board
  Future<void> archiveAllLists() async {
    if (_currentBoardId.value == 0) return;

    try {
      final success = await _repository.archiveListsByBoardId(
        _currentBoardId.value,
      );
      if (success) {
        await loadListsForBoard(_currentBoardId.value, showLoading: false);
        await loadArchivedLists();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'All lists archived successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.archive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive all lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Unarchive all lists in current board
  Future<void> unarchiveAllLists() async {
    if (_currentBoardId.value == 0) return;

    try {
      final success = await _repository.unarchiveListsByBoardId(
        _currentBoardId.value,
      );
      if (success) {
        await loadListsForBoard(_currentBoardId.value, showLoading: false);
        await loadArchivedLists();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'All lists restored successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.unarchive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to restore all lists: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }
}
