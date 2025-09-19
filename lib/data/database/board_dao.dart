import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../models/board_model.dart';
import 'database_provider.dart';

class BoardDao {
  static const String _tableName = AppConstants.boardsTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new board
  Future<int> insert(Board board) async {
    final db = await _database;
    return await db.insert(_tableName, board.toMapWithoutId());
  }

  // Insert multiple boards
  Future<List<int>> insertBatch(List<Board> boards) async {
    final db = await _database;
    final batch = db.batch();

    for (final board in boards) {
      batch.insert(_tableName, board.toMapWithoutId());
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all boards (non-deleted)
  Future<List<Board>> getAll({bool includeArchived = false}) async {
    final db = await _database;
    String whereClause = 'deleted_at IS NULL';

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => Board.fromMap(map)).toList();
  }

  // Get board by ID
  Future<Board?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Board.fromMap(maps.first);
    }
    return null;
  }

  // Get board by UUID
  Future<Board?> getByUuid(String uuid) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'uuid = ? AND deleted_at IS NULL',
      whereArgs: [uuid],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Board.fromMap(maps.first);
    }
    return null;
  }

  // Update board
  Future<int> update(Board board) async {
    final db = await _database;
    final updatedBoard = board.copyWith(updatedAt: DateTime.now());

    return await db.update(
      _tableName,
      updatedBoard.toMap(),
      where: 'id = ?',
      whereArgs: [board.id],
    );
  }

  // Soft delete board (sets deleted_at timestamp)
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

  // Hard delete board (permanent removal)
  Future<int> hardDelete(int id) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Archive/Unarchive board
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

  // Restore soft-deleted board
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

  // Get archived boards
  Future<List<Board>> getArchived() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'archived = 1 AND deleted_at IS NULL',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Board.fromMap(map)).toList();
  }

  // Get deleted boards (for admin purposes)
  Future<List<Board>> getDeleted() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );

    return maps.map((map) => Board.fromMap(map)).toList();
  }

  // Update board position
  Future<int> updatePosition(int id, int newPosition) async {
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

  // Reorder boards (batch update positions)
  Future<void> reorderBoards(List<Board> boards) async {
    final db = await _database;
    final batch = db.batch();

    for (int i = 0; i < boards.length; i++) {
      final board = boards[i];
      if (board.id != null) {
        batch.update(
          _tableName,
          {
            'position': i * 1024, // Give some spacing between positions
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [board.id],
        );
      }
    }

    await batch.commit();
  }

  // Search boards by title or description
  Future<List<Board>> search(
    String query, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause =
        '(title LIKE ? OR description LIKE ?) AND deleted_at IS NULL';
    List<Object> whereArgs = ['%$query%', '%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => Board.fromMap(map)).toList();
  }

  // Get boards count by status
  Future<Map<String, int>> getBoardsCount() async {
    final db = await _database;

    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE archived = 0 AND deleted_at IS NULL',
    );

    final archivedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE archived = 1 AND deleted_at IS NULL',
    );

    final deletedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE deleted_at IS NOT NULL',
    );

    return {
      'active': activeResult.first['count'] as int,
      'archived': archivedResult.first['count'] as int,
      'deleted': deletedResult.first['count'] as int,
    };
  }

  // Duplicate board
  Future<Board?> duplicate(int boardId, String newTitle, String newUuid) async {
    final originalBoard = await getById(boardId);
    if (originalBoard == null) return null;

    final duplicatedBoard = originalBoard.copyWith(
      id: null, // Remove ID for new insert
      uuid: newUuid,
      title: newTitle,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    final newId = await insert(duplicatedBoard);
    return duplicatedBoard.copyWith(id: newId);
  }

  // Check if UUID exists
  Future<bool> uuidExists(String uuid) async {
    final db = await _database;
    final result = await db.query(
      _tableName,
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Clean up old deleted boards (hard delete boards deleted more than X days ago)
  Future<int> cleanupDeletedBoards({int daysOld = 30}) async {
    final db = await _database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;

    return await db.delete(
      _tableName,
      where: 'deleted_at IS NOT NULL AND deleted_at < ?',
      whereArgs: [cutoffTimestamp],
    );
  }

  // Delete all boards (for testing purposes)
  Future<int> deleteAll() async {
    final db = await _database;
    return await db.delete(_tableName);
  }
}
