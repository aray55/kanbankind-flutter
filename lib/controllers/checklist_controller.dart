import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import '../core/themes/app_colors.dart' show AppColors;
import '../models/checklist_item_model.dart';
import '../models/check_list_progress_model.dart';
import '../data/repository/checklist_item_repository.dart';
import '../core/services/task_movement_service.dart';
import '../data/repository/task_repository.dart';

class ChecklistController extends GetxController {
  final ChecklistItemRepository _repository = ChecklistItemRepository();
  final TaskMovementService _taskMovementService = TaskMovementService();
  final TaskRepository _taskRepository = TaskRepository();

  final DialogService _dialogService = Get.find<DialogService>();

  // Observable lists and states
  final RxList<ChecklistItem> _checklistItems = <ChecklistItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentTaskId = 0.obs;
  final Rx<ChecklistProgress> _progress = ChecklistProgress(
    total: 0,
    completed: 0,
    percentage: 0.0,
  ).obs;

  // Getters
  List<ChecklistItem> get checklistItems => _checklistItems.toList();
  List<ChecklistItem> get filteredItems {
    if (_searchQuery.value.isEmpty) {
      return _checklistItems.toList();
    }
    return _checklistItems
        .where(
          (item) => item.title.toLowerCase().contains(
            _searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  String get searchQuery => _searchQuery.value;
  int get currentTaskId => _currentTaskId.value;
  ChecklistProgress get progress => _progress.value;

  // Computed properties
  int get totalItems => _checklistItems.length;
  int get completedItems => _checklistItems.where((item) => item.isDone).length;
  int get remainingItems => totalItems - completedItems;
  double get progressPercentage =>
      totalItems > 0 ? completedItems / totalItems : 0.0;
  bool get hasItems => _checklistItems.isNotEmpty;
  bool get isAllCompleted => totalItems > 0 && completedItems == totalItems;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in checklist items to update progress
    ever(_checklistItems, (_) => _updateProgress());
  }

  // Load checklist items for a specific task
  Future<void> loadChecklistItems(int taskId) async {
    try {
      _isLoading.value = true;
      _currentTaskId.value = taskId;

      final items = await _repository.getChecklistItemsByTaskId(taskId);
      _checklistItems.assignAll(items);

      await _updateProgress();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorLoadingChecklist.tr,
        message: LocalKeys.errorLoadingChecklist.tr,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new checklist item
  Future<void> createChecklistItem({
    required int taskId,
    required String title,
    int? position,
  }) async {
    if (title.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.checklistItemTitleEmpty.tr,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final newItem = await _repository.createChecklistItem(
        taskId: taskId,
        title: title.trim(),
        position: position,
      );

      _checklistItems.add(newItem);
      _sortItemsByPosition();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.checklistItemCreatedSuccessfully.tr,
        backgroundColor: AppColors.primary,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorCreatingItem.tr,
        message: LocalKeys.errorCreatingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Create multiple checklist items
  Future<void> createMultipleItems({
    required int taskId,
    required List<String> titles,
  }) async {
    final validTitles = titles
        .where((title) => title.trim().isNotEmpty)
        .toList();

    if (validTitles.isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.invalidInput.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final newItems = await _repository.createMultipleItems(
        taskId: taskId,
        titles: validTitles,
      );

      _checklistItems.addAll(newItems);
      _sortItemsByPosition();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.created.tr,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorCreatingItems.tr,
        message: LocalKeys.errorCreatingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update checklist item title
  Future<void> updateItemTitle(int itemId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.invalidInput.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isUpdating.value = true;

      final updatedItem = await _repository.updateChecklistItemTitle(
        itemId,
        newTitle.trim(),
      );

      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemUpdatedSuccessfully.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorUpdatingItem.tr,
        message: LocalKeys.errorUpdatingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Toggle checklist item completion
  Future<void> toggleItemCompletion(int itemId) async {
    try {
      final updatedItem = await _repository.toggleChecklistItemDone(itemId);

      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
        }

        // Trigger automatic task movement evaluation
        await _evaluateTaskMovement(updatedItem.taskId);
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorTogglingItem.tr,
        message: LocalKeys.errorTogglingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Mark item as done/undone
  Future<void> markItemDone(int itemId, bool isDone) async {
    try {
      final updatedItem = await _repository.markChecklistItemDone(
        itemId,
        isDone,
      );

      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
        }

        // Trigger automatic task movement evaluation
        await _evaluateTaskMovement(updatedItem.taskId);
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorUpdatingItem.tr,
        message: LocalKeys.errorUpdatingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Delete checklist item
  Future<void> deleteItem(int itemId) async {
    try {
      final success = await _repository.deleteChecklistItem(itemId);

      if (success) {
        _checklistItems.removeWhere((item) => item.id == itemId);

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemDeletedSuccessfully.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorDeletingItem.tr,
        message: LocalKeys.errorDeletingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Delete multiple items
  Future<void> deleteMultipleItems(List<int> itemIds) async {
    if (itemIds.isEmpty) return;

    try {
      final success = await _repository.deleteMultipleItems(itemIds);

      if (success) {
        _checklistItems.removeWhere((item) => itemIds.contains(item.id));

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.deleteItem.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorDeletingItems.tr,
        message: LocalKeys.errorDeletingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Reorder checklist items
  Future<void> reorderItems(List<ChecklistItem> newOrder) async {
    try {
      final reorderedItems = await _repository.reorderChecklistItems(newOrder);
      _checklistItems.assignAll(reorderedItems);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorReorderingItems.tr,
        message: LocalKeys.errorReorderingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload items to restore original order
      if (_currentTaskId.value > 0) {
        await loadChecklistItems(_currentTaskId.value);
      }
    }
  }

  // Move item to new position
  Future<void> moveItem(int itemId, int newPosition) async {
    try {
      final reorderedItems = await _repository.moveChecklistItem(
        itemId,
        newPosition,
      );
      _checklistItems.assignAll(reorderedItems);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorMovingItem.tr,
        message: LocalKeys.errorMovingItem.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload items to restore original order
      if (_currentTaskId.value > 0) {
        await loadChecklistItems(_currentTaskId.value);
      }
    }
  }

  // Clear all completed items
  Future<void> clearCompletedItems() async {
    if (_currentTaskId.value == 0) return;

    try {
      final success = await _repository.clearCompletedItems(
        _currentTaskId.value,
      );

      if (success) {
        _checklistItems.removeWhere((item) => item.isDone);

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.clearCompletedItems.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorClearingItems.tr,
        message: LocalKeys.errorClearingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Mark all items as done/undone
  Future<void> markAllItems(bool isDone) async {
    if (_currentTaskId.value == 0) return;

    try {
      final updatedItems = await _repository.markAllItems(
        _currentTaskId.value,
        isDone,
      );
      _checklistItems.assignAll(updatedItems);

      final action = isDone ? 'completed' : 'uncompleted';
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.markedAllItems.tr,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorUpdatingAllItems.tr,
        message: LocalKeys.errorUpdatingAllItems.tr,
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

  // Search checklist items
  Future<void> searchItems(String query, {int? taskId}) async {
    try {
      _isLoading.value = true;

      final items = await _repository.searchChecklistItems(
        query,
        taskId: taskId ?? _currentTaskId.value,
      );

      _checklistItems.assignAll(items);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorSearchingItems.tr,
        message: LocalKeys.errorSearchingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Duplicate checklist from another task
  Future<void> duplicateFromTask({
    required int fromTaskId,
    required int toTaskId,
    bool copyCompletionStatus = false,
  }) async {
    try {
      _isLoading.value = true;

      final duplicatedItems = await _repository.duplicateChecklistItems(
        fromTaskId: fromTaskId,
        toTaskId: toTaskId,
        copyCompletionStatus: copyCompletionStatus,
      );

      if (toTaskId == _currentTaskId.value) {
        _checklistItems.assignAll(duplicatedItems);
      }

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.duplicatedChecklistItems.tr,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.errorDuplicatingItems.tr,
        message: LocalKeys.errorDuplicatingItems.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get checklist item by ID
  ChecklistItem? getItemById(int itemId) {
    try {
      return _checklistItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Get items by completion status
  List<ChecklistItem> getItemsByStatus(bool isDone) {
    return _checklistItems.where((item) => item.isDone == isDone).toList();
  }

  // Get completed items
  List<ChecklistItem> get completedItemsList => getItemsByStatus(true);

  // Get pending items
  List<ChecklistItem> get pendingItemsList => getItemsByStatus(false);

  // Private helper methods
  void _sortItemsByPosition() {
    _checklistItems.sort((a, b) => a.position.compareTo(b.position));
  }

  Future<void> _updateProgress() async {
    if (_currentTaskId.value == 0) return;

    try {
      final progress = await _repository.getChecklistProgress(
        _currentTaskId.value,
      );
      _progress.value = progress;
    } catch (e) {
      // Silent fail for progress updates
    }
  }

  // Refresh checklist items
  Future<void> refresh() async {
    if (_currentTaskId.value > 0) {
      await loadChecklistItems(_currentTaskId.value);
    }
  }

  // Clear all data (useful when switching tasks)
  void clearData() {
    if (!isClosed) {
      _checklistItems.clear();
      _currentTaskId.value = 0;
      _searchQuery.value = '';
      _progress.value = ChecklistProgress(
        total: 0,
        completed: 0,
        percentage: 0.0,
      );
    }
  }

  /// Evaluates task for automatic movement after checklist changes
  Future<void> _evaluateTaskMovement(int taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null) {
        final movedTask = await _taskMovementService.evaluateAndMoveTask(task);
        if (movedTask != null) {
          _dialogService.showSuccessSnackbar(
            title:" تم نقل المهمة تلقائيًا",
            message: "تم نقل المهمة إلى ${movedTask.status.name}",
          );
        }
      }
    } catch (e) {
      // Silent fail for automatic movement
    }
  }

  @override
  void onClose() {
    // Don't call clearData during disposal to avoid setState errors
    super.onClose();
  }
}
