import 'package:get/get.dart';
import '../models/checklist_item_model.dart';
import '../data/repository/checklist_item_repository.dart';
import '../core/services/dialog_service.dart';
import '../core/localization/local_keys.dart';

class ChecklistItemController extends GetxController {
  late final ChecklistItemRepository _repository;
  late final DialogService _dialogService;

  @override
  void onInit() {
    super.onInit();
    _repository = ChecklistItemRepository();
    _dialogService = Get.find<DialogService>();
    // Initialize with empty data
    _loadStatistics();
  }

  // Observable lists and states
  final RxList<ChecklistItemModel> _checklistItems = <ChecklistItemModel>[].obs;
  final RxList<ChecklistItemModel> _completedItems = <ChecklistItemModel>[].obs;
  final RxList<ChecklistItemModel> _pendingItems = <ChecklistItemModel>[].obs;
  final RxList<ChecklistItemModel> _archivedItems = <ChecklistItemModel>[].obs;
  final RxList<ChecklistItemModel> _deletedItems = <ChecklistItemModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentChecklistId = 0.obs;
  final RxMap<String, dynamic> _statistics = <String, dynamic>{}.obs;

  // Getters
  List<ChecklistItemModel> get checklistItems => _checklistItems.toList();
  List<ChecklistItemModel> get completedItems => _completedItems.toList();
  List<ChecklistItemModel> get pendingItems => _pendingItems.toList();
  List<ChecklistItemModel> get archivedItems => _archivedItems.toList();
  List<ChecklistItemModel> get deletedItems => _deletedItems.toList();
  
  List<ChecklistItemModel> get filteredChecklistItems {
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
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  int get currentChecklistId => _currentChecklistId.value;
  Map<String, dynamic> get statistics => Map<String, dynamic>.from(_statistics);

  // Computed properties
  int get totalItems => _checklistItems.length;
  int get totalCompletedItems => _completedItems.length;
  int get totalPendingItems => _pendingItems.length;
  int get totalArchivedItems => _archivedItems.length;
  int get totalDeletedItems => _deletedItems.length;
  bool get hasItems => _checklistItems.isNotEmpty;
  bool get hasCompletedItems => _completedItems.isNotEmpty;
  bool get hasPendingItems => _pendingItems.isNotEmpty;
  bool get hasArchivedItems => _archivedItems.isNotEmpty;
  bool get hasDeletedItems => _deletedItems.isNotEmpty;
  
  double get completionProgress {
    if (totalItems == 0) return 0.0;
    return (totalCompletedItems / totalItems) * 100;
  }

  // Load checklist items for a specific checklist
  Future<void> loadChecklistItemsByChecklistId(
    int checklistId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      _isLoading.value = true;
      _currentChecklistId.value = checklistId;

      final items = await _repository.getChecklistItemsByChecklistId(
        checklistId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      // Instead of replacing all items, update items for this specific checklist
      final activeItems = items.where((item) => item.isActive).toList();
      _updateItemsForChecklist(checklistId, activeItems);
      
      if (includeArchived) {
        // Remove existing archived items for this checklist
        _archivedItems.removeWhere((item) => item.checklistId == checklistId);
        // Add new archived items for this checklist
        _archivedItems.addAll(
          items.where((item) => item.archived && !item.isDeleted).toList(),
        );
      }
      
      if (includeDeleted) {
        // Remove existing deleted items for this checklist
        _deletedItems.removeWhere((item) => item.checklistId == checklistId);
        // Add new deleted items for this checklist
        _deletedItems.addAll(
          items.where((item) => item.isDeleted).toList(),
        );
      }

      await _loadStatistics();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load checklist items: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load only active items for a checklist
  Future<void> loadActiveItems(int checklistId) async {
    try {
      _isLoading.value = true;
      _currentChecklistId.value = checklistId;

      final items = await _repository.getActiveChecklistItems(checklistId);
      
      // Instead of replacing all items, add/update items for this checklist
      _updateItemsForChecklist(checklistId, items);

      await _loadStatistics();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load checklist items: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Helper method to update items for a specific checklist without affecting others
  void _updateItemsForChecklist(int checklistId, List<ChecklistItemModel> newItems) {
    // Remove existing items for this checklist
    _checklistItems.removeWhere((item) => item.checklistId == checklistId);
    _completedItems.removeWhere((item) => item.checklistId == checklistId);
    _pendingItems.removeWhere((item) => item.checklistId == checklistId);
    
    // Add new items for this checklist
    _checklistItems.addAll(newItems);
    _completedItems.addAll(newItems.where((item) => item.isDone).toList());
    _pendingItems.addAll(newItems.where((item) => !item.isDone).toList());
    
    // Update the current checklist ID to the last loaded one
    if (newItems.isNotEmpty) {
      _currentChecklistId.value = checklistId;
    }
  }

  // Create a new checklist item
  Future<ChecklistItemModel?> createChecklistItem({
    required int checklistId,
    required String title,
    double? position,
  }) async {
    try {
      _isCreating.value = true;

      final newItem = await _repository.createChecklistItem(
        checklistId: checklistId,
        title: title,
        position: position,
      );

      _checklistItems.add(newItem);
      _pendingItems.add(newItem);
      await _loadStatistics();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.checklistItemCreated.tr,
      );

      return newItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to create checklist item: $e',
      );
      return null;
    } finally {
      _isCreating.value = false;
    }
  }

  // Create multiple checklist items
  Future<List<ChecklistItemModel>> createMultipleItems({
    required int checklistId,
    required List<String> titles,
  }) async {
    try {
      _isCreating.value = true;

      final newItems = await _repository.createMultipleItems(
        checklistId: checklistId,
        titles: titles,
      );

      _checklistItems.addAll(newItems);
      _pendingItems.addAll(newItems);
      await _loadStatistics();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: '${newItems.length} ${LocalKeys.checklistItemsCreated.tr}',
      );

      return newItems;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to create checklist items: $e',
      );
      return [];
    } finally {
      _isCreating.value = false;
    }
  }

  // Update checklist item
  Future<ChecklistItemModel?> updateChecklistItem(ChecklistItemModel item) async {
    try {
      _isUpdating.value = true;

      final updatedItem = await _repository.updateChecklistItem(item);
      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
          _updateItemInLists(updatedItem);
        }
        await _loadStatistics();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemUpdated.tr,
        );
      }

      return updatedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update checklist item: $e',
      );
      return null;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Update checklist item title
  Future<ChecklistItemModel?> updateItemTitle(int id, String newTitle) async {
    try {
      _isUpdating.value = true;

      final updatedItem = await _repository.updateChecklistItemTitle(id, newTitle);
      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((i) => i.id == id);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
          _updateItemInLists(updatedItem);
        }
        await _loadStatistics();
      }

      return updatedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update checklist item title: $e',
      );
      return null;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Toggle checklist item completion status
  Future<ChecklistItemModel?> toggleItemDone(int id) async {
    try {
      final updatedItem = await _repository.toggleChecklistItemDone(id);
      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((i) => i.id == id);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
          _updateItemInLists(updatedItem);
        }
        await _loadStatistics();
      }

      return updatedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to toggle checklist item: $e',
      );
      return null;
    }
  }

  // Mark item as completed
  Future<ChecklistItemModel?> markItemCompleted(int id) async {
    try {
      final updatedItem = await _repository.markChecklistItemCompleted(id);
      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((i) => i.id == id);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
          _updateItemInLists(updatedItem);
        }
        await _loadStatistics();
      }

      return updatedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark item as completed: $e',
      );
      return null;
    }
  }

  // Mark item as pending
  Future<ChecklistItemModel?> markItemPending(int id) async {
    try {
      final updatedItem = await _repository.markChecklistItemPending(id);
      if (updatedItem != null) {
        final index = _checklistItems.indexWhere((i) => i.id == id);
        if (index != -1) {
          _checklistItems[index] = updatedItem;
          _updateItemInLists(updatedItem);
        }
        await _loadStatistics();
      }

      return updatedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark item as pending: $e',
      );
      return null;
    }
  }

  // Delete checklist item (soft delete)
  Future<bool> deleteChecklistItem(int id) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.deleteChecklistItem(id);
      if (success) {
        _checklistItems.removeWhere((item) => item.id == id);
        _completedItems.removeWhere((item) => item.id == id);
        _pendingItems.removeWhere((item) => item.id == id);
        await _loadStatistics();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemDeleted.tr,
        );
      }

      return success;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to delete checklist item: $e',
      );
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Archive checklist item
  Future<ChecklistItemModel?> archiveItem(int id) async {
    try {
      final archivedItem = await _repository.archiveChecklistItem(id);
      if (archivedItem != null) {
        _checklistItems.removeWhere((item) => item.id == id);
        _completedItems.removeWhere((item) => item.id == id);
        _pendingItems.removeWhere((item) => item.id == id);
        _archivedItems.add(archivedItem);
        await _loadStatistics();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemArchived.tr,
        );
      }

      return archivedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive checklist item: $e',
      );
      return null;
    }
  }

  // Unarchive checklist item
  Future<ChecklistItemModel?> unarchiveItem(int id) async {
    try {
      final unarchivedItem = await _repository.unarchiveChecklistItem(id);
      if (unarchivedItem != null) {
        _archivedItems.removeWhere((item) => item.id == id);
        _checklistItems.add(unarchivedItem);
        _updateItemInLists(unarchivedItem);
        await _loadStatistics();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.checklistItemUnarchived.tr,
        );
      }

      return unarchivedItem;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to unarchive checklist item: $e',
      );
      return null;
    }
  }

  // Reorder checklist items
  Future<void> reorderItems(List<ChecklistItemModel> items) async {
    try {
      await _repository.reorderChecklistItems(items);
      _checklistItems.assignAll(items.where((item) => item.isActive).toList());
      _completedItems.assignAll(items.where((item) => item.isCompleted).toList());
      _pendingItems.assignAll(items.where((item) => item.isPending).toList());
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to reorder checklist items: $e',
      );
    }
  }

  // Search checklist items
  Future<void> searchItems(String query) async {
    _searchQuery.value = query;
    if (query.isEmpty) {
      return;
    }

    try {
      // The search results are handled by the filteredChecklistItems getter
      // which filters the current items based on the search query
      update();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to search checklist items: $e',
      );
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
  }

  // Batch operations
  Future<void> batchToggleDone(List<int> ids) async {
    try {
      await _repository.batchToggleDone(ids);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: '${ids.length} items toggled',
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to toggle items: $e',
      );
    }
  }

  Future<void> batchMarkAsCompleted(List<int> ids) async {
    try {
      await _repository.batchMarkAsCompleted(ids);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: '${ids.length} items marked as completed',
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark items as completed: $e',
      );
    }
  }

  Future<void> batchMarkAsPending(List<int> ids) async {
    try {
      await _repository.batchMarkAsPending(ids);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: '${ids.length} items marked as pending',
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark items as pending: $e',
      );
    }
  }

  Future<void> batchDelete(List<int> ids) async {
    try {
      await _repository.batchDelete(ids);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: '${ids.length} items deleted',
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to delete items: $e',
      );
    }
  }

  // Clear completed items
  Future<void> clearCompletedItems() async {
    try {
      final success = await _repository.clearCompletedItems(_currentChecklistId.value);
      if (success) {
        await loadActiveItems(_currentChecklistId.value);
        
        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.completedItemsCleared.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to clear completed items: $e',
      );
    }
  }

  // Mark all items as completed/pending
  Future<void> markAllItemsCompleted() async {
    try {
      await _repository.markAllItemsCompleted(_currentChecklistId.value);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.allItemsMarkedCompleted.tr,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark all items as completed: $e',
      );
    }
  }

  Future<void> markAllItemsPending() async {
    try {
      await _repository.markAllItemsPending(_currentChecklistId.value);
      await loadActiveItems(_currentChecklistId.value);
      
      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.allItemsMarkedPending.tr,
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to mark all items as pending: $e',
      );
    }
  }

  // Private helper methods
  void _updateItemInLists(ChecklistItemModel item) {
    // Remove from all lists first
    _completedItems.removeWhere((i) => i.id == item.id);
    _pendingItems.removeWhere((i) => i.id == item.id);
    
    // Add to appropriate list
    if (item.isDone) {
      _completedItems.add(item);
    } else {
      _pendingItems.add(item);
    }
  }

  Future<void> _loadStatistics() async {
    if (_currentChecklistId.value > 0) {
      try {
        final stats = await _repository.getChecklistProgress(_currentChecklistId.value);
        _statistics.assignAll(stats);
      } catch (e) {
        // Silently fail for statistics
        _statistics.clear();
      }
    }
  }

  // Refresh data
  Future<void> refresh() async {
    if (_currentChecklistId.value > 0) {
      await loadActiveItems(_currentChecklistId.value);
    }
  }

  @override
  void onClose() {
    _checklistItems.close();
    _completedItems.close();
    _pendingItems.close();
    _archivedItems.close();
    _deletedItems.close();
    _isLoading.close();
    _isCreating.close();
    _isUpdating.close();
    _isDeleting.close();
    _searchQuery.close();
    _currentChecklistId.close();
    _statistics.close();
    super.onClose();
  }
}
