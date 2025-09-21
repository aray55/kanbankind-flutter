import 'package:kanbankit/core/constants/database_constants.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/checklist_item_model.dart';
import 'database_provider.dart';

class ChecklistItemDao {
  static const String _tableName = DatabaseConstants.checklistItemsTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new checklist item
  Future<int> insert(ChecklistItem item) async {
    final db = await _database;
    return await db.insert(_tableName, item.toMapWithoutId());
  }

  // Insert multiple checklist items
  Future<List<int>> insertBatch(List<ChecklistItem> items) async {
    final db = await _database;
    final batch = db.batch();
    
    for (final item in items) {
      batch.insert(_tableName, item.toMapWithoutId());
    }
    
    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all checklist items for a specific task
  Future<List<ChecklistItem>> getByTaskId(int taskId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'position ASC, created_at ASC',
    );
    
    return maps.map((map) => ChecklistItem.fromMap(map)).toList();
  }

  // Get a specific checklist item by ID
  Future<ChecklistItem?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return ChecklistItem.fromMap(maps.first);
  }

  // Update a checklist item
  Future<int> update(ChecklistItem item) async {
    final db = await _database;
    return await db.update(
      _tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Update multiple checklist items
  Future<void> updateBatch(List<ChecklistItem> items) async {
    final db = await _database;
    final batch = db.batch();
    
    for (final item in items) {
      batch.update(
        _tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
    
    await batch.commit();
  }

  // Toggle the done status of a checklist item
  Future<int> toggleDone(int id) async {
    final db = await _database;
    final item = await getById(id);
    if (item == null) return 0;
    
    return await db.update(
      _tableName,
      {'is_done': item.isDone ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update positions of multiple items (for reordering)
  Future<void> updatePositions(List<ChecklistItem> items) async {
    final db = await _database;
    final batch = db.batch();
    
    for (int i = 0; i < items.length; i++) {
      batch.update(
        _tableName,
        {'position': i},
        where: 'id = ?',
        whereArgs: [items[i].id],
      );
    }
    
    await batch.commit();
  }

  // Delete a checklist item
  Future<int> delete(int id) async {
    final db = await _database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all checklist items for a specific task
  Future<int> deleteByTaskId(int taskId) async {
    final db = await _database;
    return await db.delete(
      _tableName,
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Delete multiple checklist items
  Future<void> deleteBatch(List<int> ids) async {
    final db = await _database;
    final batch = db.batch();
    
    for (final id in ids) {
      batch.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    
    await batch.commit();
  }

  // Get count of checklist items for a task
  Future<int> getCountByTaskId(int taskId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE task_id = ?',
      [taskId],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count of completed checklist items for a task
  Future<int> getCompletedCountByTaskId(int taskId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE task_id = ? AND is_done = 1',
      [taskId],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get checklist progress for a task (returns percentage)
  Future<double> getProgressByTaskId(int taskId) async {
    final total = await getCountByTaskId(taskId);
    if (total == 0) return 0.0;
    
    final completed = await getCompletedCountByTaskId(taskId);
    return completed / total;
  }

  // Search checklist items by title
  Future<List<ChecklistItem>> searchByTitle(String query, {int? taskId}) async {
    final db = await _database;
    
    String whereClause = 'title LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];
    
    if (taskId != null) {
      whereClause += ' AND task_id = ?';
      whereArgs.add(taskId);
    }
    
    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );
    
    return maps.map((map) => ChecklistItem.fromMap(map)).toList();
  }

  // Get all checklist items (for debugging or admin purposes)
  Future<List<ChecklistItem>> getAll() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      orderBy: 'task_id ASC, position ASC, created_at ASC',
    );
    
    return maps.map((map) => ChecklistItem.fromMap(map)).toList();
  }

  // Clear all checklist items (for testing or reset purposes)
  Future<int> deleteAll() async {
    final db = await _database;
    return await db.delete(_tableName);
  }
}
