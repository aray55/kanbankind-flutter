// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/services/dialog_service.dart' show DialogService;
// import '../models/checklist_item_model.dart';
// import '../models/check_list_progress_model.dart';
// import '../data/repository/checklist_item_repository.dart';

// class ChecklistController extends GetxController {
//   final ChecklistItemRepository _repository = ChecklistItemRepository();

//   // Observable lists and states
//   final RxList<ChecklistItem> _checklistItems = <ChecklistItem>[].obs;
//   final RxBool _isLoading = false.obs;
//   final RxBool _isCreating = false.obs;
//   final RxBool _isUpdating = false.obs;
//   final RxString _searchQuery = ''.obs;
//   final RxInt _currentTaskId = 0.obs;
//   final Rx<ChecklistProgress> _progress = ChecklistProgress(
//     total: 0,
//     completed: 0,
//     percentage: 0.0,
//   ).obs;
//   late DialogService dialogService;

//   // Helper methods for showing messages
  

//   // Getters
//   List<ChecklistItem> get checklistItems => _checklistItems.toList();
//   List<ChecklistItem> get filteredItems {
//     if (_searchQuery.value.isEmpty) {
//       return _checklistItems.toList();
//     }
//     return _checklistItems
//         .where((item) => item.title.toLowerCase().contains(_searchQuery.value.toLowerCase()))
//         .toList();
//   }
  
//   bool get isLoading => _isLoading.value;
//   bool get isCreating => _isCreating.value;
//   bool get isUpdating => _isUpdating.value;
//   String get searchQuery => _searchQuery.value;
//   int get currentTaskId => _currentTaskId.value;
//   ChecklistProgress get progress => _progress.value;
  
//   // Computed properties
//   int get totalItems => _checklistItems.length;
//   int get completedItems => _checklistItems.where((item) => item.isDone).length;
//   int get remainingItems => totalItems - completedItems;
//   double get progressPercentage => totalItems > 0 ? completedItems / totalItems : 0.0;
//   bool get hasItems => _checklistItems.isNotEmpty;
//   bool get isAllCompleted => totalItems > 0 && completedItems == totalItems;

//   @override
//   void onInit() {
//     super.onInit();
//     // Listen to changes in checklist items to update progress
//     ever(_checklistItems, (_) => _updateProgress());
//   }

//   // Load checklist items for a specific task
//   Future<void> loadChecklistItems(int taskId) async {
//     try {
//       _isLoading.value = true;
//       _currentTaskId.value = taskId;
      
//       final items = await _repository.getChecklistItemsByTaskId(taskId);
//       _checklistItems.assignAll(items);
      
//       await _updateProgress();
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Loading Checklist',
//         message: 'Failed to load checklist items: ${e.toString()}',
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   // Create a new checklist item
//   Future<void> createChecklistItem({
//     required int taskId,
//     required String title,
//     int? position,
//   }) async {
//     if (title.trim().isEmpty) {
//       dialogService.showErrorSnackbar(
//         title: 'Invalid Input',
//         message: 'Checklist item title cannot be empty',
//       );
//       return;
//     }

//     try {
//       _isCreating.value = true;
      
//       final newItem = await _repository.createChecklistItem(
//         taskId: taskId,
//         title: title.trim(),
//         position: position,
//       );
      
//       _checklistItems.add(newItem);
//       _sortItemsByPosition();
      
//       dialogService.showSuccessSnackbar(
//         title: 'Success',
//         message: 'Checklist item created successfully',
//       );
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Creating Item',
//         message: 'Failed to create checklist item: ${e.toString()}',
//       );
//     } finally {
//       _isCreating.value = false;
//     }
//   }

//   // Create multiple checklist items
//   Future<void> createMultipleItems({
//     required int taskId,
//     required List<String> titles,
//   }) async {
//     final validTitles = titles.where((title) => title.trim().isNotEmpty).toList();
    
//     if (validTitles.isEmpty) {
//       dialogService.showErrorSnackbar(
//         title: 'Invalid Input',
//         message: 'No valid checklist items to create',
//       );
//       return;
//     }

//     try {
//       _isCreating.value = true;
      
//       final newItems = await _repository.createMultipleItems(
//         taskId: taskId,
//         titles: validTitles,
//       );
      
//       _checklistItems.addAll(newItems);
//       _sortItemsByPosition();
      
//       dialogService.showSuccessSnackbar(
//         title: 'Success',
//         message: 'Created ${newItems.length} checklist items',
//       );
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Creating Items',
//         message: 'Failed to create checklist items: ${e.toString()}',
//       );
//     } finally {
//       _isCreating.value = false;
//     }
//   }

//   // Update checklist item title
//   Future<void> updateItemTitle(int itemId, String newTitle) async {
//     if (newTitle.trim().isEmpty) {
//       dialogService.showErrorSnackbar(
//         title: 'Invalid Input',
//         message: 'Checklist item title cannot be empty',
//       );
//       return;
//     }

//     try {
//       _isUpdating.value = true;
      
//       final updatedItem = await _repository.updateChecklistItemTitle(itemId, newTitle.trim());
      
//       if (updatedItem != null) {
//         final index = _checklistItems.indexWhere((item) => item.id == itemId);
//         if (index != -1) {
//           _checklistItems[index] = updatedItem;
//         }
        
//         dialogService.showSuccessSnackbar(
//           title: 'Success',
//           message: 'Checklist item updated successfully',
//         );
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Updating Item',
//         message: 'Failed to update checklist item: ${e.toString()}',
//       );
//     } finally {
//       _isUpdating.value = false;
//     }
//   }

//   // Toggle checklist item completion
//   Future<void> toggleItemCompletion(int itemId) async {
//     try {
//       final updatedItem = await _repository.toggleChecklistItemDone(itemId);
      
//       if (updatedItem != null) {
//         final index = _checklistItems.indexWhere((item) => item.id == itemId);
//         if (index != -1) {
//           _checklistItems[index] = updatedItem;
//         }
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Toggling Item',
//         message: 'Failed to toggle checklist item: ${e.toString()}',
//       );
//     }
//   }

//   // Mark item as done/undone
//   Future<void> markItemDone(int itemId, bool isDone) async {
//     try {
//       final updatedItem = await _repository.markChecklistItemDone(itemId, isDone);
      
//       if (updatedItem != null) {
//         final index = _checklistItems.indexWhere((item) => item.id == itemId);
//         if (index != -1) {
//           _checklistItems[index] = updatedItem;
//         }
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Updating Item',
//         message: 'Failed to update checklist item: ${e.toString()}',
//       );
//     }
//   }

//   // Delete checklist item
//   Future<void> deleteItem(int itemId) async {
//     try {
//       final success = await _repository.deleteChecklistItem(itemId);
      
//       if (success) {
//         _checklistItems.removeWhere((item) => item.id == itemId);
        
//         dialogService.showSuccessSnackbar(
//           title: 'Success',
//           message: 'Checklist item deleted successfully',
//         );
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Deleting Item',
//         message: 'Failed to delete checklist item: ${e.toString()}',
//       );
//     }
//   }

//   // Delete multiple items
//   Future<void> deleteMultipleItems(List<int> itemIds) async {
//     if (itemIds.isEmpty) return;

//     try {
//       final success = await _repository.deleteMultipleItems(itemIds);
      
//       if (success) {
//         _checklistItems.removeWhere((item) => itemIds.contains(item.id));
        
//         dialogService.showSuccessSnackbar(
//           title: 'Success',
//           message: 'Deleted ${itemIds.length} checklist items',
//         );
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Deleting Items',
//         message: 'Failed to delete checklist items: ${e.toString()}',
//       );
//     }
//   }

//   // Reorder checklist items
//   Future<void> reorderItems(List<ChecklistItem> newOrder) async {
//     try {
//       final reorderedItems = await _repository.reorderChecklistItems(newOrder);
//       _checklistItems.assignAll(reorderedItems);
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Reordering Items',
//         message: 'Failed to reorder checklist items: ${e.toString()}',
//       );
//       // Reload items to restore original order
//       if (_currentTaskId.value > 0) {
//         await loadChecklistItems(_currentTaskId.value);
//       }
//     }
//   }

//   // Move item to new position
//   Future<void> moveItem(int itemId, int newPosition) async {
//     try {
//       final reorderedItems = await _repository.moveChecklistItem(itemId, newPosition);
//       _checklistItems.assignAll(reorderedItems);
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Moving Item',
//         message: 'Failed to move checklist item: ${e.toString()}',
//       );
//       // Reload items to restore original order
//       if (_currentTaskId.value > 0) {
//         await loadChecklistItems(_currentTaskId.value);
//       }
//     }
//   }

//   // Clear all completed items
//   Future<void> clearCompletedItems() async {
//     if (_currentTaskId.value == 0) return;

//     try {
//       final success = await _repository.clearCompletedItems(_currentTaskId.value);
      
//       if (success) {
//         _checklistItems.removeWhere((item) => item.isDone);
        
//         dialogService.showSuccessSnackbar(
//           title: 'Success',
//           message: 'Cleared all completed items',
//         );
//       }
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Clearing Items',
//         message: 'Failed to clear completed items: ${e.toString()}',
//       );
//     }
//   }

//   // Mark all items as done/undone
//   Future<void> markAllItems(bool isDone) async {
//     if (_currentTaskId.value == 0) return;

//     try {
//       final updatedItems = await _repository.markAllItems(_currentTaskId.value, isDone);
//       _checklistItems.assignAll(updatedItems);
      
//       final action = isDone ? 'completed' : 'uncompleted';
//       dialogService.showSuccessSnackbar(
//         title: 'Success',
//         message: 'Marked all items as $action',
//       );
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Updating Items',
//         message: 'Failed to update all items: ${e.toString()}',
//       );
//     }
//   }

//   // Search functionality
//   void updateSearchQuery(String query) {
//     _searchQuery.value = query.trim();
//   }

//   void clearSearch() {
//     _searchQuery.value = '';
//   }

//   // Search checklist items
//   Future<void> searchItems(String query, {int? taskId}) async {
//     try {
//       _isLoading.value = true;
      
//       final items = await _repository.searchChecklistItems(
//         query,
//         taskId: taskId ?? _currentTaskId.value,
//       );
      
//       _checklistItems.assignAll(items);
//     } catch (e) {
//       dialogService.showErrorSnackbar(
//         title: 'Error Searching',
//         message: 'Failed to search checklist items: ${e.toString()}',
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   // Get checklist item by ID
//   ChecklistItem? getItemById(int itemId) {
//     try {
//       return _checklistItems.firstWhere((item) => item.id == itemId);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Get items by completion status
//   List<ChecklistItem> getItemsByStatus(bool isDone) {
//     return _checklistItems.where((item) => item.isDone == isDone).toList();
//   }

//   // Get completed items
//   List<ChecklistItem> get completedItemsList => getItemsByStatus(true);

//   // Get pending items
//   List<ChecklistItem> get pendingItemsList => getItemsByStatus(false);

//   // Private helper methods
//   void _sortItemsByPosition() {
//     _checklistItems.sort((a, b) => a.position.compareTo(b.position));
//   }

//   Future<void> _updateProgress() async {
//     if (_currentTaskId.value == 0) return;

//     try {
//       final progress = await _repository.getChecklistProgress(_currentTaskId.value);
//       _progress.value = progress;
//     } catch (e) {
//       // Silent fail for progress updates
//     }
//   }

//   // Refresh checklist items
//   Future<void> refresh() async {
//     if (_currentTaskId.value > 0) {
//       await loadChecklistItems(_currentTaskId.value);
//     }
//   }

//   // Clear all data (useful when switching tasks)
//   void clearData() {
//     _checklistItems.clear();
//     _currentTaskId.value = 0;
//     _searchQuery.value = '';
//     _progress.value = ChecklistProgress(
//       total: 0,
//       completed: 0,
//       percentage: 0.0,
//     );
//   }

//   @override
//   void onClose() {
//     clearData();
//     super.onClose();
//   }
// }
