import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/checklist_model.dart';
import 'database_provider.dart';

class ChecklistDao {
  static const String _tableName = DatabaseConstants.checklistsTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new checklist
  Future<int> insert(ChecklistModel checklist) async {
    final db = await _database;
    return await db.insert(_tableName, checklist.toMapWithoutId());
  }

  // Insert multiple checklists
  Future<List<int>> insertBatch(List<ChecklistModel> checklists) async {
    final db = await _database;
    final batch = db.batch();

    for (final checklist in checklists) {
      batch.insert(_tableName, checklist.toMapWithoutId());
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all checklists for a specific card
  Future<List<ChecklistModel>> getByCardId(
    int cardId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'card_id = ?';
    List<Object> whereArgs = [cardId];

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

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get all checklists (across all cards)
  Future<List<ChecklistModel>> getAll({
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
      orderBy: 'card_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get checklist by ID
  Future<ChecklistModel?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ChecklistModel.fromMap(maps.first);
    }
    return null;
  }

  // Update checklist
  Future<int> update(ChecklistModel checklist) async {
    final db = await _database;
    final updatedChecklist = checklist.copyWith(updatedAt: DateTime.now());

    return await db.update(
      _tableName,
      updatedChecklist.toMap(),
      where: 'id = ?',
      whereArgs: [checklist.id],
    );
  }

  // Soft delete checklist
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

  // Hard delete checklist
  Future<int> hardDelete(int id) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Restore soft deleted checklist
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

  // Archive/Unarchive checklist
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

  // Get archived checklists for a specific card
  Future<List<ChecklistModel>> getArchivedByCardId(int cardId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'card_id = ? AND archived = 1 AND deleted_at IS NULL',
      whereArgs: [cardId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get all archived checklists (across all cards)
  Future<List<ChecklistModel>> getArchived() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'archived = 1 AND deleted_at IS NULL',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get soft deleted checklists for a specific card
  Future<List<ChecklistModel>> getDeletedByCardId(int cardId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'card_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [cardId],
      orderBy: 'deleted_at DESC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get all soft deleted checklists
  Future<List<ChecklistModel>> getDeleted() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Update checklist position
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

  // Reorder checklists within a card (batch update positions)
  Future<void> reorderChecklists(List<ChecklistModel> checklists) async {
    final db = await _database;
    final batch = db.batch();

    for (int i = 0; i < checklists.length; i++) {
      final checklist = checklists[i];
      if (checklist.id != null) {
        batch.update(
          _tableName,
          {
            'position': i * 1024.0, // Give some spacing between positions
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [checklist.id],
        );
      }
    }

    await batch.commit();
  }

  // Search checklists by title within a card
  Future<List<ChecklistModel>> searchInCard(
    int cardId,
    String query, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final db = await _database;
    String whereClause = 'card_id = ? AND title LIKE ?';
    List<Object> whereArgs = [cardId, '%$query%'];

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

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Search checklists by title across all cards
  Future<List<ChecklistModel>> search(
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
      orderBy: 'card_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get next position for a new checklist in a card
  Future<double> getNextPosition(int cardId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT MAX(position) as max_position FROM $_tableName WHERE card_id = ?',
      [cardId],
    );

    if (result.isNotEmpty && result.first['max_position'] != null) {
      return (result.first['max_position'] as double) + 1024.0;
    }
    return 1024.0; // Default starting position
  }

  // Check if a checklist title already exists in a card (excluding current checklist)
  Future<bool> titleExistsInCard(
    int cardId,
    String title, {
    int? excludeChecklistId,
  }) async {
    final db = await _database;
    String whereClause = 'card_id = ? AND title = ? AND deleted_at IS NULL';
    List<Object> whereArgs = [cardId, title];

    if (excludeChecklistId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeChecklistId);
    }

    final result = await db.query(
      _tableName,
      columns: ['id'],
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Get checklists count by card
  Future<Map<String, int>> getChecklistsCountByCard(int cardId) async {
    final db = await _database;

    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE card_id = ? AND archived = 0 AND deleted_at IS NULL',
      [cardId],
    );

    final archivedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE card_id = ? AND archived = 1 AND deleted_at IS NULL',
      [cardId],
    );

    final deletedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE card_id = ? AND deleted_at IS NOT NULL',
      [cardId],
    );

    return {
      'active': activeResult.first['count'] as int,
      'archived': archivedResult.first['count'] as int,
      'deleted': deletedResult.first['count'] as int,
    };
  }

  // Get total checklists count across all cards
  Future<Map<String, int>> getTotalChecklistsCount() async {
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

  // Duplicate checklist within the same card
  Future<ChecklistModel?> duplicate(int checklistId, String newTitle) async {
    final originalChecklist = await getById(checklistId);
    if (originalChecklist == null) return null;

    final duplicatedChecklist = originalChecklist.copyWith(
      id: null, // Remove ID for new insert
      title: newTitle,
      position: originalChecklist.position + 512, // Place after original
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null, // Ensure the duplicate is not deleted
    );

    final newId = await insert(duplicatedChecklist);
    return duplicatedChecklist.copyWith(id: newId);
  }

  // Move checklist to another card
  Future<int> moveToCard(int checklistId, int newCardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'card_id': newCardId,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [checklistId],
    );
  }

  // Delete all checklists for a specific card (cascade delete)
  Future<int> hardDeleteByCardId(int cardId) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'card_id = ?', whereArgs: [cardId]);
  }

  // Soft delete all checklists for a specific card
  Future<int> softDeleteByCardId(int cardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Archive all checklists for a specific card
  Future<int> archiveByCardId(int cardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'archived': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Unarchive all checklists for a specific card
  Future<int> unarchiveByCardId(int cardId) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'archived': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Get recently created checklists
  Future<List<ChecklistModel>> getRecentlyCreated({
    int limit = 10,
    int? cardId,
  }) async {
    final db = await _database;
    String whereClause = 'archived = 0 AND deleted_at IS NULL';
    List<Object> whereArgs = [];

    if (cardId != null) {
      whereClause += ' AND card_id = ?';
      whereArgs.add(cardId);
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Get recently updated checklists
  Future<List<ChecklistModel>> getRecentlyUpdated({
    int limit = 10,
    int? cardId,
  }) async {
    final db = await _database;
    String whereClause = 'archived = 0 AND deleted_at IS NULL';
    List<Object> whereArgs = [];

    if (cardId != null) {
      whereClause += ' AND card_id = ?';
      whereArgs.add(cardId);
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return maps.map((map) => ChecklistModel.fromMap(map)).toList();
  }

  // Delete all checklists (for testing purposes)
  Future<int> deleteAll() async {
    final db = await _database;
    return await db.delete(_tableName);
  }
}
