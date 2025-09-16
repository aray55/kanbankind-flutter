import '../../models/check_list_progress_model.dart' show ChecklistProgress;
import '../../models/checklist_item_model.dart';
import '../database/checklist_item_dao.dart';

class ChecklistItemRepository {
  final ChecklistItemDao _dao = ChecklistItemDao();

  // Create a new checklist item
  Future<ChecklistItem> createChecklistItem({
    required int taskId,
    required String title,
    int? position,
  }) async {
    // If no position is provided, set it to the end of the list
    if (position == null) {
      final existingItems = await _dao.getByTaskId(taskId);
      position = existingItems.length;
    }

    final item = ChecklistItem(
      taskId: taskId,
      title: title.trim(),
      position: position,
    );

    final id = await _dao.insert(item);
    return item.copyWith(id: id);
  }

  // Create multiple checklist items
  Future<List<ChecklistItem>> createMultipleItems({
    required int taskId,
    required List<String> titles,
  }) async {
    final existingItems = await _dao.getByTaskId(taskId);
    int startPosition = existingItems.length;

    final items = titles.asMap().entries.map((entry) {
      return ChecklistItem(
        taskId: taskId,
        title: entry.value.trim(),
        position: startPosition + entry.key,
      );
    }).toList();

    final ids = await _dao.insertBatch(items);
    
    return items.asMap().entries.map((entry) {
      return entry.value.copyWith(id: ids[entry.key]);
    }).toList();
  }

  // Get all checklist items for a task
  Future<List<ChecklistItem>> getChecklistItemsByTaskId(int taskId) async {
    return await _dao.getByTaskId(taskId);
  }

  // Get a specific checklist item
  Future<ChecklistItem?> getChecklistItemById(int id) async {
    return await _dao.getById(id);
  }

  // Update checklist item
  Future<ChecklistItem?> updateChecklistItem(ChecklistItem item) async {
    final updatedRows = await _dao.update(item);
    if (updatedRows > 0) {
      return item;
    }
    return null;
  }

  // Update checklist item title
  Future<ChecklistItem?> updateChecklistItemTitle(int id, String newTitle) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    final updatedItem = item.copyWith(title: newTitle.trim());
    final updatedRows = await _dao.update(updatedItem);
    
    if (updatedRows > 0) {
      return updatedItem;
    }
    return null;
  }

  // Toggle checklist item completion status
  Future<ChecklistItem?> toggleChecklistItemDone(int id) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    await _dao.toggleDone(id);
    return item.copyWith(isDone: !item.isDone);
  }

  // Mark checklist item as done
  Future<ChecklistItem?> markChecklistItemDone(int id, bool isDone) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    final updatedItem = item.copyWith(isDone: isDone);
    final updatedRows = await _dao.update(updatedItem);
    
    if (updatedRows > 0) {
      return updatedItem;
    }
    return null;
  }

  // Reorder checklist items
  Future<List<ChecklistItem>> reorderChecklistItems(List<ChecklistItem> items) async {
    // Update positions based on the new order
    final reorderedItems = items.asMap().entries.map((entry) {
      return entry.value.copyWith(position: entry.key);
    }).toList();

    await _dao.updatePositions(reorderedItems);
    return reorderedItems;
  }

  // Move checklist item to a new position
  Future<List<ChecklistItem>> moveChecklistItem(int itemId, int newPosition) async {
    final item = await _dao.getById(itemId);
    if (item == null) return [];

    final allItems = await _dao.getByTaskId(item.taskId);
    
    // Remove the item from its current position
    allItems.removeWhere((i) => i.id == itemId);
    
    // Insert it at the new position
    allItems.insert(newPosition, item);
    
    // Update all positions
    return await reorderChecklistItems(allItems);
  }

  // Delete checklist item
  Future<bool> deleteChecklistItem(int id) async {
    final deletedRows = await _dao.delete(id);
    return deletedRows > 0;
  }

  // Delete multiple checklist items
  Future<bool> deleteMultipleItems(List<int> ids) async {
    if (ids.isEmpty) return true;
    
    await _dao.deleteBatch(ids);
    return true;
  }

  // Delete all checklist items for a task
  Future<bool> deleteAllItemsForTask(int taskId) async {
    final deletedRows = await _dao.deleteByTaskId(taskId);
    return deletedRows >= 0;
  }

  // Get checklist progress for a task
  Future<ChecklistProgress> getChecklistProgress(int taskId) async {
    final total = await _dao.getCountByTaskId(taskId);
    final completed = await _dao.getCompletedCountByTaskId(taskId);
    final percentage = await _dao.getProgressByTaskId(taskId);

    return ChecklistProgress(
      total: total,
      completed: completed,
      percentage: percentage,
    );
  }

  // Search checklist items
  Future<List<ChecklistItem>> searchChecklistItems(String query, {int? taskId}) async {
    if (query.trim().isEmpty) {
      if (taskId != null) {
        return await _dao.getByTaskId(taskId);
      }
      return await _dao.getAll();
    }
    
    return await _dao.searchByTitle(query.trim(), taskId: taskId);
  }

  // Duplicate checklist items from one task to another
  Future<List<ChecklistItem>> duplicateChecklistItems({
    required int fromTaskId,
    required int toTaskId,
    bool copyCompletionStatus = false,
  }) async {
    final sourceItems = await _dao.getByTaskId(fromTaskId);
    
    if (sourceItems.isEmpty) return [];

    final newItems = sourceItems.map((item) {
      return ChecklistItem(
        taskId: toTaskId,
        title: item.title,
        isDone: copyCompletionStatus ? item.isDone : false,
        position: item.position,
      );
    }).toList();

    final ids = await _dao.insertBatch(newItems);
    
    return newItems.asMap().entries.map((entry) {
      return entry.value.copyWith(id: ids[entry.key]);
    }).toList();
  }

  // Get statistics for all tasks
  Future<Map<int, ChecklistProgress>> getAllTasksProgress() async {
    final allItems = await _dao.getAll();
    final Map<int, ChecklistProgress> progressMap = {};

    // Group items by task ID
    final Map<int, List<ChecklistItem>> itemsByTask = {};
    for (final item in allItems) {
      itemsByTask.putIfAbsent(item.taskId, () => []).add(item);
    }

    // Calculate progress for each task
    for (final entry in itemsByTask.entries) {
      final taskId = entry.key;
      final items = entry.value;
      final completed = items.where((item) => item.isDone).length;
      final total = items.length;
      final percentage = total > 0 ? completed / total : 0.0;

      progressMap[taskId] = ChecklistProgress(
        total: total,
        completed: completed,
        percentage: percentage,
      );
    }

    return progressMap;
  }

  // Clear all completed items for a task
  Future<bool> clearCompletedItems(int taskId) async {
    final items = await _dao.getByTaskId(taskId);
    final completedIds = items.where((item) => item.isDone).map((item) => item.id!).toList();
    
    if (completedIds.isEmpty) return true;
    
    await _dao.deleteBatch(completedIds);
    return true;
  }

  // Mark all items as done/undone for a task
  Future<List<ChecklistItem>> markAllItems(int taskId, bool isDone) async {
    final items = await _dao.getByTaskId(taskId);
    
    if (items.isEmpty) return [];

    final updatedItems = items.map((item) => item.copyWith(isDone: isDone)).toList();
    await _dao.updateBatch(updatedItems);
    
    return updatedItems;
  }
}


