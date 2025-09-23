import '../../models/checklist_item_model.dart';
import '../database/checklist_item_dao.dart';

class ChecklistItemRepository {
  final ChecklistItemDao _dao = ChecklistItemDao();

  // Create a new checklist item
  Future<ChecklistItemModel> createChecklistItem({
    required int checklistId,
    required String title,
    double? position,
  }) async {
    // Validate title
    if (title.trim().isEmpty || title.length > 255) {
      throw ArgumentError('Title must be between 1 and 255 characters');
    }

    // If no position is provided, set it to the end of the list
    if (position == null) {
      final existingItems = await _dao.getByChecklistId(checklistId);
      position = (existingItems.length + 1) * 1024.0;
    }

    final item = ChecklistItemModel(
      checklistId: checklistId,
      title: title.trim(),
      position: position,
    );

    final id = await _dao.insert(item);
    return item.copyWith(id: id);
  }

  // Create multiple checklist items
  Future<List<ChecklistItemModel>> createMultipleItems({
    required int checklistId,
    required List<String> titles,
  }) async {
    // Validate titles
    for (final title in titles) {
      if (title.trim().isEmpty || title.length > 255) {
        throw ArgumentError('All titles must be between 1 and 255 characters');
      }
    }

    final existingItems = await _dao.getByChecklistId(checklistId);
    double startPosition = (existingItems.length + 1) * 1024.0;

    final items = titles.asMap().entries.map((entry) {
      return ChecklistItemModel(
        checklistId: checklistId,
        title: entry.value.trim(),
        position: startPosition + (entry.key * 1024.0),
      );
    }).toList();

    final ids = await _dao.insertBatch(items);
    
    return items.asMap().entries.map((entry) {
      return entry.value.copyWith(id: ids[entry.key]);
    }).toList();
  }

  // Get all checklist items for a checklist
  Future<List<ChecklistItemModel>> getChecklistItemsByChecklistId(
    int checklistId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    return await _dao.getByChecklistId(
      checklistId,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }

  // Get active checklist items for a checklist
  Future<List<ChecklistItemModel>> getActiveChecklistItems(int checklistId) async {
    return await _dao.getByChecklistId(checklistId);
  }

  // Get completed items for a checklist
  Future<List<ChecklistItemModel>> getCompletedItems(int checklistId) async {
    return await _dao.getCompletedByChecklistId(checklistId);
  }

  // Get pending items for a checklist
  Future<List<ChecklistItemModel>> getPendingItems(int checklistId) async {
    return await _dao.getPendingByChecklistId(checklistId);
  }

  // Get a specific checklist item
  Future<ChecklistItemModel?> getChecklistItemById(int id) async {
    return await _dao.getById(id);
  }

  // Update checklist item
  Future<ChecklistItemModel?> updateChecklistItem(ChecklistItemModel item) async {
    if (!item.isValidTitle) {
      throw ArgumentError('Title must be between 1 and 255 characters');
    }

    final updatedRows = await _dao.update(item);
    if (updatedRows > 0) {
      return item;
    }
    return null;
  }

  // Update checklist item title
  Future<ChecklistItemModel?> updateChecklistItemTitle(int id, String newTitle) async {
    if (newTitle.trim().isEmpty || newTitle.length > 255) {
      throw ArgumentError('Title must be between 1 and 255 characters');
    }

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
  Future<ChecklistItemModel?> toggleChecklistItemDone(int id) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    await _dao.toggleDone(id);
    return item.copyWith(isDone: !item.isDone);
  }

  // Mark checklist item as completed
  Future<ChecklistItemModel?> markChecklistItemCompleted(int id) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    await _dao.markAsCompleted(id);
    return item.copyWith(isDone: true);
  }

  // Mark checklist item as pending
  Future<ChecklistItemModel?> markChecklistItemPending(int id) async {
    final item = await _dao.getById(id);
    if (item == null) return null;

    await _dao.markAsPending(id);
    return item.copyWith(isDone: false);
  }

  // Delete checklist item (soft delete)
  Future<bool> deleteChecklistItem(int id) async {
    final deletedRows = await _dao.softDelete(id);
    return deletedRows > 0;
  }

  // Hard delete checklist item
  Future<bool> hardDeleteChecklistItem(int id) async {
    final deletedRows = await _dao.hardDelete(id);
    return deletedRows > 0;
  }

  // Restore deleted checklist item
  Future<ChecklistItemModel?> restoreChecklistItem(int id) async {
    final restoredRows = await _dao.restore(id);
    if (restoredRows > 0) {
      return await _dao.getById(id);
    }
    return null;
  }

  // Archive checklist item
  Future<ChecklistItemModel?> archiveChecklistItem(int id) async {
    final archivedRows = await _dao.setArchived(id, true);
    if (archivedRows > 0) {
      return await _dao.getById(id);
    }
    return null;
  }

  // Unarchive checklist item
  Future<ChecklistItemModel?> unarchiveChecklistItem(int id) async {
    final unarchivedRows = await _dao.setArchived(id, false);
    if (unarchivedRows > 0) {
      return await _dao.getById(id);
    }
    return null;
  }

  // Reorder checklist items
  Future<List<ChecklistItemModel>> reorderChecklistItems(List<ChecklistItemModel> items) async {
    await _dao.reorderChecklistItems(items);
    return items;
  }

  // Move checklist item to a new position
  Future<ChecklistItemModel?> moveChecklistItem(int itemId, double newPosition) async {
    final updatedRows = await _dao.updatePosition(itemId, newPosition);
    if (updatedRows > 0) {
      return await _dao.getById(itemId);
    }
    return null;
  }

  // Search checklist items
  Future<List<ChecklistItemModel>> searchChecklistItems(
    String query, {
    int? checklistId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    if (query.trim().isEmpty) {
      if (checklistId != null) {
        return await _dao.getByChecklistId(
          checklistId,
          includeArchived: includeArchived,
          includeDeleted: includeDeleted,
        );
      }
      return await _dao.getAll(
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    }
    
    if (checklistId != null) {
      return await _dao.searchInChecklist(
        checklistId,
        query.trim(),
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    }
    
    return await _dao.search(
      query.trim(),
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }

  // Get checklist progress
  Future<Map<String, dynamic>> getChecklistProgress(int checklistId) async {
    final stats = await _dao.getStatsByChecklistId(checklistId);
    final progress = await _dao.getProgressByChecklistId(checklistId);
    
    return {
      'total': stats['total'] ?? 0,
      'completed': stats['completed'] ?? 0,
      'pending': stats['pending'] ?? 0,
      'archived': stats['archived'] ?? 0,
      'progress': progress,
    };
  }

  // Get archived items
  Future<List<ChecklistItemModel>> getArchivedItems(int checklistId) async {
    return await _dao.getArchivedByChecklistId(checklistId);
  }

  // Get deleted items
  Future<List<ChecklistItemModel>> getDeletedItems(int checklistId) async {
    return await _dao.getDeletedByChecklistId(checklistId);
  }

  // Batch operations
  Future<void> batchToggleDone(List<int> ids) async {
    await _dao.batchToggleDone(ids);
  }

  Future<void> batchMarkAsCompleted(List<int> ids) async {
    await _dao.batchMarkAsCompleted(ids);
  }

  Future<void> batchMarkAsPending(List<int> ids) async {
    await _dao.batchMarkAsPending(ids);
  }

  Future<void> batchDelete(List<int> ids) async {
    await _dao.batchSoftDelete(ids);
  }

  Future<void> batchArchive(List<int> ids) async {
    await _dao.batchSetArchived(ids, true);
  }

  Future<void> batchUnarchive(List<int> ids) async {
    await _dao.batchSetArchived(ids, false);
  }

  // Clear completed items
  Future<bool> clearCompletedItems(int checklistId) async {
    final completedItems = await _dao.getCompletedByChecklistId(checklistId);
    if (completedItems.isEmpty) return true;
    
    final ids = completedItems.map((item) => item.id!).toList();
    await _dao.batchSoftDelete(ids);
    return true;
  }

  // Mark all items as completed/pending
  Future<void> markAllItemsCompleted(int checklistId) async {
    final items = await _dao.getByChecklistId(checklistId);
    final ids = items.map((item) => item.id!).toList();
    await _dao.batchMarkAsCompleted(ids);
  }

  Future<void> markAllItemsPending(int checklistId) async {
    final items = await _dao.getByChecklistId(checklistId);
    final ids = items.map((item) => item.id!).toList();
    await _dao.batchMarkAsPending(ids);
  }

  // Duplicate checklist items
  Future<List<ChecklistItemModel>> duplicateChecklistItems({
    required int fromChecklistId,
    required int toChecklistId,
    bool copyCompletionStatus = false,
  }) async {
    final sourceItems = await _dao.getByChecklistId(fromChecklistId);
    
    if (sourceItems.isEmpty) return [];

    final newItems = sourceItems.map((item) {
      return ChecklistItemModel(
        checklistId: toChecklistId,
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

  // Delete all items for a checklist (cascade delete)
  Future<int> deleteAllItemsForChecklist(int checklistId) async {
    return await _dao.deleteByChecklistId(checklistId);
  }
}


