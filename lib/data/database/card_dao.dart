import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/card_model.dart';
import 'database_provider.dart';

class CardDao {
  static const String _tableName = DatabaseConstants.cardsTable;

  // Get database instance
  Future<Database> get _database async {
    return await DatabaseProvider().database;
  }

  // Insert a new card
  Future<int> insert(CardModel card) async {
    final db = await _database;
    return await db.insert(_tableName, card.toMapWithoutId());
  }

  // Insert multiple cards
  Future<List<int>> insertBatch(List<CardModel> cards) async {
    final db = await _database;
    final batch = db.batch();

    for (final card in cards) {
      batch.insert(_tableName, card.toMapWithoutId());
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  // Get all cards for a specific list
  Future<List<CardModel>> getByListId(
    int listId, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause = 'list_id = ?';
    List<Object> whereArgs = [listId];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Get all cards for a specific board (across all lists)
  Future<List<CardModel>> getByBoardId(
    int boardId, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause =
        'list_id IN (SELECT id FROM ${DatabaseConstants.listTable} WHERE board_id = ?)';
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

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Get all cards (across all boards and lists)
  Future<List<CardModel>> getAll({bool includeArchived = false}) async {
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
      orderBy: 'list_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Get card by ID
  Future<CardModel?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return CardModel.fromMap(maps.first);
    }
    return null;
  }

  // Update card
  Future<int> update(CardModel card) async {
    final db = await _database;
    final updatedCard = card.copyWith(updatedAt: DateTime.now());

    return await db.update(
      _tableName,
      updatedCard.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // Delete card (hard delete)
  Future<int> hardDelete(int id) async {
    final db = await _database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Archive/Unarchive card
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

  // Mark card as completed
  Future<int> setCompleted(int id, bool completed) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'completed_at': completed
            ? DateTime.now().millisecondsSinceEpoch ~/ 1000
            : null,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get archived cards for a specific list
  Future<List<CardModel>> getArchivedByListId(int listId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'list_id = ? AND archived = 1',
      whereArgs: [listId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Get all archived cards (across all lists)
  Future<List<CardModel>> getArchived() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'archived = 1',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Update card position
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
  //Soft delete Method
  Future<int> softDelete(int id)async{
    final db=await _database;
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
  // Reorder cards within a list (batch update positions)
  Future<void> reorderCards(List<CardModel> cards) async {
    final db = await _database;
    final batch = db.batch();

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      if (card.id != null) {
        batch.update(
          _tableName,
          {
            'position': i * 1024.0, // Give some spacing between positions
            'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
          where: 'id = ?',
          whereArgs: [card.id],
        );
      }
    }

    await batch.commit();
  }

  // Search cards by title within a list
  Future<List<CardModel>> searchInList(
    int listId,
    String query, {
    bool includeArchived = false,
  }) async {
    final db = await _database;
    String whereClause = 'list_id = ? AND title LIKE ?';
    List<Object> whereArgs = [listId, '%$query%'];

    if (!includeArchived) {
      whereClause += ' AND archived = 0';
    }

    final maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'position ASC, created_at ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Search cards by title across all lists
  Future<List<CardModel>> search(
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
      orderBy: 'list_id ASC, position ASC, created_at ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  // Get next position for a new card in a list
  Future<double> getNextPosition(int listId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT MAX(position) as max_position FROM $_tableName WHERE list_id = ?',
      [listId],
    );

    if (result.isNotEmpty && result.first['max_position'] != null) {
      return (result.first['max_position'] as double) + 1024.0;
    }
    return 1024.0; // Default starting position
  }

  // Check if a card title already exists in a list (excluding current card)
  Future<bool> titleExistsInList(
    int listId,
    String title, {
    int? excludeCardId,
  }) async {
    final db = await _database;
    String whereClause = 'list_id = ? AND title = ?';
    List<Object> whereArgs = [listId, title];

    if (excludeCardId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeCardId);
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
}
