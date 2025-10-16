import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/comment_model.dart';
import 'database_provider.dart';

/// Comment Data Access Object
/// Handles all database operations for comments
class CommentDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  // Create a new comment
  Future<int> createComment(CommentModel comment) async {
    final db = await _databaseProvider.database;
    return await db.insert(
      DatabaseConstants.commentsTable,
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get comment by ID
  Future<CommentModel?> getCommentById(int id) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CommentModel.fromMap(maps.first);
  }

  // Get all comments for a card
  Future<List<CommentModel>> getCommentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Get all active comments
  Future<List<CommentModel>> getAllActiveComments() async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Get deleted comments for a card
  Future<List<CommentModel>> getDeletedCommentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'card_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [cardId],
      orderBy: 'deleted_at DESC',
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Update comment
  Future<int> updateComment(CommentModel comment) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.commentsTable,
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  // Soft delete comment
  Future<int> softDeleteComment(int id) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.commentsTable,
      {'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Restore deleted comment
  Future<int> restoreComment(int id) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.commentsTable,
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently delete comment
  Future<int> permanentlyDeleteComment(int id) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.commentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all comments for a card (soft delete)
  Future<int> softDeleteAllCommentsForCard(int cardId) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.commentsTable,
      {'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Permanently delete all comments for a card
  Future<int> permanentlyDeleteAllCommentsForCard(int cardId) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.commentsTable,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
  }

  // Count comments for a card
  Future<int> countCommentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.commentsTable} WHERE card_id = ? AND deleted_at IS NULL',
      [cardId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search comments by content
  Future<List<CommentModel>> searchComments(String query) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'content LIKE ? AND deleted_at IS NULL',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Get recent comments (limit)
  Future<List<CommentModel>> getRecentComments({int limit = 10}) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Get comments by date range
  Future<List<CommentModel>> getCommentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseProvider.database;
    final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.commentsTable,
      where: 'created_at BETWEEN ? AND ? AND deleted_at IS NULL',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  // Batch insert comments
  Future<void> batchInsertComments(List<CommentModel> comments) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final comment in comments) {
      batch.insert(
        DatabaseConstants.commentsTable,
        comment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Batch delete comments
  Future<void> batchDeleteComments(List<int> commentIds) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final id in commentIds) {
      batch.delete(
        DatabaseConstants.commentsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }
}
