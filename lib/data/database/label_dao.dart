import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/label_model.dart';
import 'database_provider.dart';

class LabelDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  // Get database instance
  Future<Database> get _database async => await _databaseProvider.database;

  // Create a new label
  Future<int> createLabel(LabelModel label) async {
    final db = await _database;
    final labelMap = label.toMap();
    labelMap.remove('id'); // Remove id for auto-increment
    return await db.insert(DatabaseConstants.labelsTable, labelMap);
  }

  // Get label by ID
  Future<LabelModel?> getLabelById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return LabelModel.fromMap(maps.first);
    }
    return null;
  }

  // Get all labels for a board
  Future<List<LabelModel>> getLabelsByBoardId(int boardId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: 'board_id = ? AND deleted_at IS NULL',
      whereArgs: [boardId],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => LabelModel.fromMap(maps[i]));
  }

  // Get all labels (including deleted)
  Future<List<LabelModel>> getAllLabels() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => LabelModel.fromMap(maps[i]));
  }

  // Get deleted labels for a board
  Future<List<LabelModel>> getDeletedLabelsByBoardId(int boardId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: 'board_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [boardId],
      orderBy: 'deleted_at DESC',
    );

    return List.generate(maps.length, (i) => LabelModel.fromMap(maps[i]));
  }

  // Update label
  Future<int> updateLabel(LabelModel label) async {
    final db = await _database;
    final labelMap = label.toMap();
    labelMap['updated_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    return await db.update(
      DatabaseConstants.labelsTable,
      labelMap,
      where: 'id = ?',
      whereArgs: [label.id],
    );
  }

  // Soft delete label
  Future<int> softDeleteLabel(int id) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    return await db.update(
      DatabaseConstants.labelsTable,
      {
        'deleted_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Restore label from soft delete
  Future<int> restoreLabel(int id) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    return await db.update(
      DatabaseConstants.labelsTable,
      {
        'deleted_at': null,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hard delete label (permanent)
  Future<int> hardDeleteLabel(int id) async {
    final db = await _database;
    return await db.delete(
      DatabaseConstants.labelsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search labels by name
  Future<List<LabelModel>> searchLabelsByName(int boardId, String query) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: 'board_id = ? AND name LIKE ? AND deleted_at IS NULL',
      whereArgs: [boardId, '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => LabelModel.fromMap(maps[i]));
  }

  // Get labels by color
  Future<List<LabelModel>> getLabelsByColor(int boardId, String color) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: 'board_id = ? AND color = ? AND deleted_at IS NULL',
      whereArgs: [boardId, color],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => LabelModel.fromMap(maps[i]));
  }

  // Check if label name exists in board
  Future<bool> labelNameExists(int boardId, String name, {int? excludeId}) async {
    final db = await _database;
    String whereClause = 'board_id = ? AND name = ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [boardId, name];
    
    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.labelsTable,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }

  // Get label statistics
  Future<Map<String, dynamic>> getLabelStats(int boardId) async {
    final db = await _database;
    
    // Total labels
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as total FROM ${DatabaseConstants.labelsTable}
      WHERE board_id = ? AND deleted_at IS NULL
    ''', [boardId]);
    
    // Labels usage count (how many cards use each label)
    final usageResult = await db.rawQuery('''
      SELECT l.id, l.name, l.color, COUNT(cl.id) as usage_count
      FROM ${DatabaseConstants.labelsTable} l
      LEFT JOIN ${DatabaseConstants.cardLabelsTable} cl ON l.id = cl.label_id AND cl.deleted_at IS NULL
      WHERE l.board_id = ? AND l.deleted_at IS NULL
      GROUP BY l.id, l.name, l.color
      ORDER BY usage_count DESC, l.name ASC
    ''', [boardId]);
    
    return {
      'total_labels': totalResult.first['total'],
      'label_usage': usageResult,
    };
  }

  // Batch operations
  Future<void> batchCreateLabels(List<LabelModel> labels) async {
    final db = await _database;
    final batch = db.batch();
    
    for (final label in labels) {
      final labelMap = label.toMap();
      labelMap.remove('id');
      batch.insert(DatabaseConstants.labelsTable, labelMap);
    }
    
    await batch.commit(noResult: true);
  }

  Future<void> batchDeleteLabels(List<int> labelIds) async {
    final db = await _database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    for (final id in labelIds) {
      batch.update(
        DatabaseConstants.labelsTable,
        {
          'deleted_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Clean up old deleted labels (hard delete after X days)
  Future<int> cleanupDeletedLabels({int daysOld = 30}) async {
    final db = await _database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch ~/ 1000;
    
    return await db.delete(
      DatabaseConstants.labelsTable,
      where: 'deleted_at IS NOT NULL AND deleted_at < ?',
      whereArgs: [cutoffTime],
    );
  }
}
