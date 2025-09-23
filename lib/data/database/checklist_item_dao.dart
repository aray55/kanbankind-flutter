import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/checklist_item_model.dart';
import 'database_provider.dart';

class ChecklistItemDao {
  static const String _tableName = DatabaseConstants.checklistItemsTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new checklist item
  Future<int> insert(ChecklistItemModel checklistItem) async {
    final db = await _database;
    return await db.insert(_tableName, checklistItem.toMapWithoutId());
  }

  // Insert multiple checklist items
  Future<List<int>> insertBatch(List<ChecklistItemModel> checklistItems) async {
    final db = await _database;
    final batch = db.batch();

    for (final checklistItem in checklistItems) {
      batch.insert(_tableName, checklistItem.toMapWithoutId());
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all checklist items for a specific checklist
  Future<List<ChecklistItemModel>> getByChecklistId(
    int checklistId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'checklist_id = ?';
    List<Object> whereArgs = [checklistId];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    if (!includeDeleted) {
      whereClause += ' AND deleted_at IS NULL';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get all checklist items (across all checklists)
  Future<List<ChecklistItemModel>> getAll({
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = '';
    List<Object> whereArgs = [];

    List<String> conditions = [];
    if (!includeArchived) {
      conditions.add('archived = 0');
    }
    if (!includeDeleted) {
      conditions.add('deleted_at IS NULL');
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    final maps = await db.query(
      _tableName,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'checklist_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get checklist item by ID
  Future<ChecklistItemModel?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ChecklistItemModel.fromMap(maps.first);
    }
    return null;
  }

  // Update checklist item
  Future<int> update(ChecklistItemModel checklistItem) async {
    final db = await _database;
    final updatedChecklistItem = checklistItem.copyWith(updatedAt: DateTime.now());

    return await db.update(
      _tableName,
      updatedChecklistItem.toMap(),
      where: 'id = ?',
      whereArgs: [checklistItem.id],
    );
  }

  // Toggle completion status
  Future<int> toggleDone(int id) async {
    final db = await _database;
    final item = await getById(id);
    if (item == null) return 0;

    return await db.update(
      _tableName,
      {
        'is_done': item.isDone ? 0 : 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark item as completed
  Future<int> markAsCompleted(int id) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'is_done': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark item as pending
  Future<int> markAsPending(int id) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'is_done': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Soft delete checklist item
  Future<int> softDelete(int id) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hard delete checklist item
  Future<int> hardDelete(int id) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Restore soft deleted checklist item
  Future<int> restore(int id) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'deleted_at': null,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Archive/Unarchive checklist item
  Future<int> setArchived(int id, bool archived) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'archived': archived ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get completed items for a specific checklist
  Future<List<ChecklistItemModel>> getCompletedByChecklistId(int checklistId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'checklist_id = ? AND is_done = 1 AND archived = 0 AND deleted_at IS NULL',
      whereArgs: [checklistId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get pending items for a specific checklist
  Future<List<ChecklistItemModel>> getPendingByChecklistId(int checklistId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'checklist_id = ? AND is_done = 0 AND archived = 0 AND deleted_at IS NULL',
      whereArgs: [checklistId],
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get archived checklist items for a specific checklist
  Future<List<ChecklistItemModel>> getArchivedByChecklistId(int checklistId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'checklist_id = ? AND archived = 1 AND deleted_at IS NULL',
      whereArgs: [checklistId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get all archived checklist items (across all checklists)
  Future<List<ChecklistItemModel>> getArchived() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'archived = 1 AND deleted_at IS NULL',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get soft deleted checklist items for a specific checklist
  Future<List<ChecklistItemModel>> getDeletedByChecklistId(int checklistId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'checklist_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [checklistId],
      orderBy: 'deleted_at DESC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get all soft deleted checklist items
  Future<List<ChecklistItemModel>> getDeleted() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Update checklist item position
  Future<int> updatePosition(int id, double newPosition) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'position': newPosition,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reorder checklist items within a checklist (batch update positions)
  Future<void> reorderChecklistItems(List<ChecklistItemModel> checklistItems) async {
    final db = await _database;
    final batch = db.batch();

    for (int i = 0; i < checklistItems.length; i++) {
      final checklistItem = checklistItems[i];
      if (checklistItem.id != null) {
        batch.update(
          _tableName,
          {
            'position': i * 1024.0, // Give some spacing between positions
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [checklistItem.id],
        );
      }
    }

    await batch.commit();
  }

  // Search checklist items by title within a checklist
  Future<List<ChecklistItemModel>> searchInChecklist(
    int checklistId,
    String query, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'checklist_id = ? AND title LIKE ?';
    List<Object> whereArgs = [checklistId, '%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    if (!includeDeleted) {
      whereClause += ' AND deleted_at IS NULL';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Search checklist items by title across all checklists
  Future<List<ChecklistItemModel>> search(
    String query, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'title LIKE ?';
    List<Object> whereArgs = ['%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    if (!includeDeleted) {
      whereClause += ' AND deleted_at IS NULL';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'checklist_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistItemModel.fromMap(map)).toList();
  }

  // Get checklist item count by checklist
  Future<int> getCountByChecklistId(int checklistId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'checklist_id = ?';
    List<Object> whereArgs = [checklistId];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    if (!includeDeleted) {
      whereClause += ' AND deleted_at IS NULL';
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE $whereClause',
      whereArgs,
    );

    return result.first['count'] as int;
  }

  // Get completed count by checklist
  Future<int> getCompletedCountByChecklistId(int checklistId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE checklist_id = ? AND is_done = 1 AND archived = 0 AND deleted_at IS NULL',
      [checklistId],
    );

    return result.first['count'] as int;
  }

  // Get progress percentage for a checklist
  Future<double> getProgressByChecklistId(int checklistId) async {
    final totalCount = await getCountByChecklistId(checklistId);
    if (totalCount == 0) return 0.0;

    final completedCount = await getCompletedCountByChecklistId(checklistId);
    return (completedCount / totalCount) * 100;
  }

  // Batch operations for performance
  Future<void> batchToggleDone(List<int> ids) async {
    final db = await _database;
    final batch = db.batch();

    for (final id in ids) {
      final item = await getById(id);
      if (item != null) {
        batch.update(
          _tableName,
          {
            'is_done': item.isDone ? 0 : 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }

    await batch.commit();
  }

  // Batch mark as completed
  Future<void> batchMarkAsCompleted(List<int> ids) async {
    final db = await _database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        _tableName,
        {
          'is_done': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  // Batch mark as pending
  Future<void> batchMarkAsPending(List<int> ids) async {
    final db = await _database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        _tableName,
        {
          'is_done': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  // Batch soft delete
  Future<void> batchSoftDelete(List<int> ids) async {
    final db = await _database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        _tableName,
        {
          'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  // Batch archive/unarchive
  Future<void> batchSetArchived(List<int> ids, bool archived) async {
    final db = await _database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        _tableName,
        {
          'archived': archived ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  // Delete all items for a checklist (cascade delete)
  Future<int> deleteByChecklistId(int checklistId) async {
    final db = await _database;
    return await db.delete(
      _tableName,
      where: 'checklist_id = ?',
      whereArgs: [checklistId],
    );
  }

  // Get statistics for a checklist
  Future<Map<String, int>> getStatsByChecklistId(int checklistId) async {
    final db = await _database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE checklist_id = ? AND deleted_at IS NULL',
      [checklistId],
    );
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE checklist_id = ? AND is_done = 1 AND deleted_at IS NULL',
      [checklistId],
    );
    
    final archivedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE checklist_id = ? AND archived = 1 AND deleted_at IS NULL',
      [checklistId],
    );

    final total = totalResult.first['count'] as int;
    final completed = completedResult.first['count'] as int;
    final archived = archivedResult.first['count'] as int;
    final pending = total - completed - archived;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'archived': archived,
    };
  }
}
