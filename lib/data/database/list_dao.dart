import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/list_model.dart';
import 'database_provider.dart';

class ListDao {
  static const String _tableName = DatabaseConstants.listTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new list
  Future<int> insert(ListModel list) async {
    final db = await _database;
    return await db.insert(_tableName, list.toMapWithoutId());
  }

  // Insert multiple lists
  Future<List<int>> insertBatch(List<ListModel> lists) async {
    final db = await _database;
    final batch = db.batch();

    for (final list in lists) {
      batch.insert(_tableName, list.toMapWithoutId());
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all lists for a specific board
  Future<List<ListModel>> getByBoardId(int boardId, {bool includeArchived = false}) async {
    final db = await _database;
    String whereClause = 'board_id = ?';
    List<Object> whereArgs = [boardId];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get all lists (across all boards)
  Future<List<ListModel>> getAll({bool includeArchived = false}) async {
    final db = await _database;
    String whereClause = '';
    List<Object> whereArgs = [];

    if (!includeArchived) {
      whereClause = 'archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'board_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get list by ID
  Future<ListModel?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ListModel.fromMap(maps.first);
    }
    return null;
  }

  // Update list
  Future<int> update(ListModel list) async {
    final db = await _database;
    final updatedList = list.copyWith(updatedAt: DateTime.now());

    return await db.update(
      _tableName,
      updatedList.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  // Delete list (hard delete)
  Future<int> hardDelete(int id) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Archive/Unarchive list
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

  // Get archived lists for a specific board
  Future<List<ListModel>> getArchivedByBoardId(int boardId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'board_id = ? AND archived = 1',
      whereArgs: [boardId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get all archived lists (across all boards)
  Future<List<ListModel>> getArchived() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'archived = 1',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Update list position
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

  // Reorder lists within a board (batch update positions)
  Future<void> reorderLists(List<ListModel> lists) async {
    final db = await _database;
    final batch = db.batch();

    for (int i = 0; i < lists.length; i++) {
      final list = lists[i];
      if (list.id != null) {
        batch.update(
          _tableName,
          {
            'position': i * 1024.0, // Give some spacing between positions
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [list.id],
        );
      }
    }

    await batch.commit();
  }

  // Search lists by title within a board
  Future<List<ListModel>> searchInBoard(
    int boardId,
    String query, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause = 'board_id = ? AND title LIKE ?';
    List<Object> whereArgs = [boardId, '%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  //Soft Delete Method
  Future<int> softDelete(int id)async{
    final db=await _database;
    return await db.update(
      _tableName,
      {
        'deleted_at':DateTime.now().millisecondsSinceEpoch~/1000,
        'updated_at':DateTime.now().millisecondsSinceEpoch~/1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search lists by title across all boards
  Future<List<ListModel>> search(
    String query, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause = 'title LIKE ?';
    List<Object> whereArgs = ['%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'board_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get lists count by board
  Future<Map<String, int>> getListsCountByBoard(int boardId) async {
    final db = await _database;

    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE board_id = ? AND archived = 0',
      [boardId],
    );

    final archivedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE board_id = ? AND archived = 1',
      [boardId],
    );

    return {
      'active': activeResult.first['count'] as int,
      'archived': archivedResult.first['count'] as int,
    };
  }

  // Get total lists count across all boards
  Future<Map<String, int>> getTotalListsCount() async {
    final db = await _database;

    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE archived = 0',
    );

    final archivedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE archived = 1',
    );

    return {
      'active': activeResult.first['count'] as int,
      'archived': archivedResult.first['count'] as int,
    };
  }

  // Duplicate list within the same board
  Future<ListModel?> duplicate(int listId, String newTitle) async {
    final originalList = await getById(listId);
    if (originalList == null) return null;

    final duplicatedList = originalList.copyWith(
      id: null, // Remove ID for new insert
      title: newTitle,
      position: originalList.position + 512, // Place after original
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final newId = await insert(duplicatedList);
    return duplicatedList.copyWith(id: newId);
  }

  // Move list to another board
  Future<int> moveToBoard(int listId, int newBoardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'board_id': newBoardId,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  // Delete all lists for a specific board (cascade delete)
  Future<int> deleteByBoardId(int boardId) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'board_id = ?', whereArgs: [boardId]);
  }

  // Archive all lists for a specific board
  Future<int> archiveByBoardId(int boardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'archived': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'board_id = ?',
      whereArgs: [boardId],
    );
  }

  // Unarchive all lists for a specific board
  Future<int> unarchiveByBoardId(int boardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'archived': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'board_id = ?',
      whereArgs: [boardId],
    );
  }

  // Get lists by color
  Future<List<ListModel>> getByColor(String color, {int? boardId}) async {
    final db = await _database;
    String whereClause = 'color = ?';
    List<Object> whereArgs = [color];

    if (boardId != null) {
      whereClause += ' AND board_id = ?';
      whereArgs.add(boardId);
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'board_id ASC, position ASC',
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get recently created lists
  Future<List<ListModel>> getRecentlyCreated({int limit = 10, int? boardId}) async {
    final db = await _database;
    String whereClause = 'archived = 0';
    List<Object> whereArgs = [];

    if (boardId != null) {
      whereClause += ' AND board_id = ?';
      whereArgs.add(boardId);
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Get recently updated lists
  Future<List<ListModel>> getRecentlyUpdated({int limit = 10, int? boardId}) async {
    final db = await _database;
    String whereClause = 'archived = 0';
    List<Object> whereArgs = [];

    if (boardId != null) {
      whereClause += ' AND board_id = ?';
      whereArgs.add(boardId);
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return maps.map((map) => ListModel.fromMap(map)).toList();
  }

  // Check if list title exists within a board
  Future<bool> titleExistsInBoard(int boardId, String title, {int? excludeListId}) async {
    final db = await _database;
    String whereClause = 'board_id = ? AND LOWER(title) = ?';
    List<Object> whereArgs = [boardId, title.toLowerCase()];

    if (excludeListId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeListId);
    }

    final result = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Get next position for new list in board
  Future<double> getNextPosition(int boardId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT MAX(position) as max_position FROM $_tableName WHERE board_id = ?',
      [boardId],
    );

    final maxPosition = result.first['max_position'] as double?;
    return (maxPosition ?? 0) + 1024;
  }

  // Delete all lists (for testing purposes)
  Future<int> deleteAll() async {
    final db = await _database;
    return await db.delete(_tableName);
  }
}
