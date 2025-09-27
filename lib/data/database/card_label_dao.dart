import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/card_label_model.dart';
import 'database_provider.dart';

class CardLabelDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  // Get database instance
  Future<Database> get _database async => await _databaseProvider.database;

  // Assign label to card
  Future<int> assignLabelToCard(int cardId, int labelId) async {
    final db = await _database;
    
    // Check if assignment already exists (including soft deleted)
    final existing = await db.query(
      DatabaseConstants.cardLabelsTable,
      where: 'card_id = ? AND label_id = ?',
      whereArgs: [cardId, labelId],
    );
    
    if (existing.isNotEmpty) {
      // If exists but soft deleted, restore it
      if (existing.first['deleted_at'] != null) {
        return await db.update(
          DatabaseConstants.cardLabelsTable,
          {'deleted_at': null},
          where: 'card_id = ? AND label_id = ?',
          whereArgs: [cardId, labelId],
        );
      } else {
        // Already assigned and active
        return existing.first['id'] as int;
      }
    }
    
    // Create new assignment
    final cardLabel = CardLabelModel.create(cardId: cardId, labelId: labelId);
    return await db.insert(DatabaseConstants.cardLabelsTable, cardLabel.toMap());
  }

  // Remove label from card (soft delete)
  Future<int> removeLabelFromCard(int cardId, int labelId) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    return await db.update(
      DatabaseConstants.cardLabelsTable,
      {'deleted_at': now},
      where: 'card_id = ? AND label_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId, labelId],
    );
  }

  // Get all labels for a card (with label details)
  Future<List<CardLabelModel>> getCardLabels(int cardId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        cl.id,
        cl.card_id,
        cl.label_id,
        cl.deleted_at,
        l.board_id as label_board_id,
        l.name as label_name,
        l.color as label_color,
        l.created_at as label_created_at,
        l.updated_at as label_updated_at,
        l.deleted_at as label_deleted_at
      FROM ${DatabaseConstants.cardLabelsTable} cl
      INNER JOIN ${DatabaseConstants.labelsTable} l ON cl.label_id = l.id
      WHERE cl.card_id = ? AND cl.deleted_at IS NULL AND l.deleted_at IS NULL
      ORDER BY l.name ASC
    ''', [cardId]);

    return List.generate(maps.length, (i) => CardLabelModel.fromMap(maps[i]));
  }

  // Get all cards that have a specific label
  Future<List<int>> getCardsByLabel(int labelId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.cardLabelsTable,
      columns: ['card_id'],
      where: 'label_id = ? AND deleted_at IS NULL',
      whereArgs: [labelId],
    );

    return List.generate(maps.length, (i) => maps[i]['card_id'] as int);
  }

  // Check if card has specific label
  Future<bool> cardHasLabel(int cardId, int labelId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.cardLabelsTable,
      where: 'card_id = ? AND label_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId, labelId],
    );

    return maps.isNotEmpty;
  }

  // Get card label assignment by ID
  Future<CardLabelModel?> getCardLabelById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        cl.id,
        cl.card_id,
        cl.label_id,
        cl.deleted_at,
        l.board_id as label_board_id,
        l.name as label_name,
        l.color as label_color,
        l.created_at as label_created_at,
        l.updated_at as label_updated_at,
        l.deleted_at as label_deleted_at
      FROM ${DatabaseConstants.cardLabelsTable} cl
      INNER JOIN ${DatabaseConstants.labelsTable} l ON cl.label_id = l.id
      WHERE cl.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return CardLabelModel.fromMap(maps.first);
    }
    return null;
  }

  // Remove all labels from card
  Future<int> removeAllLabelsFromCard(int cardId) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    return await db.update(
      DatabaseConstants.cardLabelsTable,
      {'deleted_at': now},
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Restore label assignment
  Future<int> restoreCardLabel(int cardId, int labelId) async {
    final db = await _database;
    
    return await db.update(
      DatabaseConstants.cardLabelsTable,
      {'deleted_at': null},
      where: 'card_id = ? AND label_id = ?',
      whereArgs: [cardId, labelId],
    );
  }

  // Hard delete card label assignment
  Future<int> hardDeleteCardLabel(int id) async {
    final db = await _database;
    return await db.delete(
      DatabaseConstants.cardLabelsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get label usage statistics
  Future<Map<String, dynamic>> getLabelUsageStats(int labelId) async {
    final db = await _database;
    
    // Total cards using this label
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as total FROM ${DatabaseConstants.cardLabelsTable}
      WHERE label_id = ? AND deleted_at IS NULL
    ''', [labelId]);
    
    // Cards by status using this label
    final statusResult = await db.rawQuery('''
      SELECT c.status, COUNT(*) as count
      FROM ${DatabaseConstants.cardLabelsTable} cl
      INNER JOIN ${DatabaseConstants.cardsTable} c ON cl.card_id = c.id
      WHERE cl.label_id = ? AND cl.deleted_at IS NULL AND c.deleted_at IS NULL
      GROUP BY c.status
    ''', [labelId]);
    
    return {
      'total_cards': totalResult.first['total'],
      'cards_by_status': statusResult,
    };
  }

  // Batch assign labels to card
  Future<void> batchAssignLabelsToCard(int cardId, List<int> labelIds) async {
    final db = await _database;
    final batch = db.batch();
    
    for (final labelId in labelIds) {
      // Check if assignment already exists
      final existing = await db.query(
        DatabaseConstants.cardLabelsTable,
        where: 'card_id = ? AND label_id = ?',
        whereArgs: [cardId, labelId],
      );
      
      if (existing.isNotEmpty) {
        // If exists but soft deleted, restore it
        if (existing.first['deleted_at'] != null) {
          batch.update(
            DatabaseConstants.cardLabelsTable,
            {'deleted_at': null},
            where: 'card_id = ? AND label_id = ?',
            whereArgs: [cardId, labelId],
          );
        }
      } else {
        // Create new assignment
        final cardLabel = CardLabelModel.create(cardId: cardId, labelId: labelId);
        batch.insert(DatabaseConstants.cardLabelsTable, cardLabel.toMap());
      }
    }
    
    await batch.commit(noResult: true);
  }

  // Batch remove labels from card
  Future<void> batchRemoveLabelsFromCard(int cardId, List<int> labelIds) async {
    final db = await _database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    for (final labelId in labelIds) {
      batch.update(
        DatabaseConstants.cardLabelsTable,
        {'deleted_at': now},
        where: 'card_id = ? AND label_id = ? AND deleted_at IS NULL',
        whereArgs: [cardId, labelId],
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Update card labels (replace all labels for a card)
  Future<void> updateCardLabels(int cardId, List<int> labelIds) async {
    final db = await _database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // First, soft delete all existing labels for this card
    batch.update(
      DatabaseConstants.cardLabelsTable,
      {'deleted_at': now},
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
    
    // Then assign new labels
    for (final labelId in labelIds) {
      final cardLabel = CardLabelModel.create(cardId: cardId, labelId: labelId);
      batch.insert(DatabaseConstants.cardLabelsTable, cardLabel.toMap());
    }
    
    await batch.commit(noResult: true);
  }

  // Get all card-label assignments (including deleted)
  Future<List<CardLabelModel>> getAllCardLabels() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        cl.id,
        cl.card_id,
        cl.label_id,
        cl.deleted_at,
        l.board_id as label_board_id,
        l.name as label_name,
        l.color as label_color,
        l.created_at as label_created_at,
        l.updated_at as label_updated_at,
        l.deleted_at as label_deleted_at
      FROM ${DatabaseConstants.cardLabelsTable} cl
      INNER JOIN ${DatabaseConstants.labelsTable} l ON cl.label_id = l.id
      ORDER BY cl.card_id, l.name ASC
    ''');

    return List.generate(maps.length, (i) => CardLabelModel.fromMap(maps[i]));
  }

  // Clean up old deleted card label assignments
  Future<int> cleanupDeletedCardLabels({int daysOld = 30}) async {
    final db = await _database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch ~/ 1000;
    
    return await db.delete(
      DatabaseConstants.cardLabelsTable,
      where: 'deleted_at IS NOT NULL AND deleted_at < ?',
      whereArgs: [cutoffTime],
    );
  }
}
