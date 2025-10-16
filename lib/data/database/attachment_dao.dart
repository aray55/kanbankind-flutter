import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/attachment_model.dart';
import 'database_provider.dart';

/// Attachment Data Access Object
/// Handles all database operations for attachments
class AttachmentDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  // Create a new attachment
  Future<int> createAttachment(AttachmentModel attachment) async {
    final db = await _databaseProvider.database;
    return await db.insert(
      DatabaseConstants.attachmentsTable,
      attachment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get attachment by ID
  Future<AttachmentModel?> getAttachmentById(int id) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return AttachmentModel.fromMap(maps.first);
  }

  // Get all attachments for a card
  Future<List<AttachmentModel>> getAttachmentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get attachments by file type
  Future<List<AttachmentModel>> getAttachmentsByType({
    required int cardId,
    required String fileType,
  }) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'card_id = ? AND file_type = ? AND deleted_at IS NULL',
      whereArgs: [cardId, fileType],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get all image attachments for a card
  Future<List<AttachmentModel>> getImageAttachments(int cardId) async {
    return await getAttachmentsByType(cardId: cardId, fileType: 'image');
  }

  // Get all document attachments for a card
  Future<List<AttachmentModel>> getDocumentAttachments(int cardId) async {
    return await getAttachmentsByType(cardId: cardId, fileType: 'document');
  }

  // Get all active attachments
  Future<List<AttachmentModel>> getAllActiveAttachments() async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get deleted attachments for a card
  Future<List<AttachmentModel>> getDeletedAttachmentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'card_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [cardId],
      orderBy: 'deleted_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Update attachment
  Future<int> updateAttachment(AttachmentModel attachment) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.attachmentsTable,
      attachment.toMap(),
      where: 'id = ?',
      whereArgs: [attachment.id],
    );
  }

  // Soft delete attachment
  Future<int> softDeleteAttachment(int id) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.attachmentsTable,
      {'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Restore deleted attachment
  Future<int> restoreAttachment(int id) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.attachmentsTable,
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Permanently delete attachment
  Future<int> permanentlyDeleteAttachment(int id) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.attachmentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all attachments for a card (soft delete)
  Future<int> softDeleteAllAttachmentsForCard(int cardId) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.attachmentsTable,
      {'deleted_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'card_id = ? AND deleted_at IS NULL',
      whereArgs: [cardId],
    );
  }

  // Permanently delete all attachments for a card
  Future<int> permanentlyDeleteAllAttachmentsForCard(int cardId) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.attachmentsTable,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
  }

  // Count attachments for a card
  Future<int> countAttachmentsByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.attachmentsTable} WHERE card_id = ? AND deleted_at IS NULL',
      [cardId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Count attachments by type for a card
  Future<int> countAttachmentsByType({
    required int cardId,
    required String fileType,
  }) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.attachmentsTable} WHERE card_id = ? AND file_type = ? AND deleted_at IS NULL',
      [cardId, fileType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total size of attachments for a card
  Future<int> getTotalSizeByCardId(int cardId) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT SUM(file_size) as total FROM ${DatabaseConstants.attachmentsTable} WHERE card_id = ? AND deleted_at IS NULL',
      [cardId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search attachments by file name
  Future<List<AttachmentModel>> searchAttachments(String query) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'file_name LIKE ? AND deleted_at IS NULL',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get recent attachments (limit)
  Future<List<AttachmentModel>> getRecentAttachments({int limit = 10}) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get attachments by date range
  Future<List<AttachmentModel>> getAttachmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseProvider.database;
    final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'created_at BETWEEN ? AND ? AND deleted_at IS NULL',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Get attachments with thumbnails
  Future<List<AttachmentModel>> getAttachmentsWithThumbnails(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.attachmentsTable,
      where: 'card_id = ? AND thumbnail_path IS NOT NULL AND deleted_at IS NULL',
      whereArgs: [cardId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => AttachmentModel.fromMap(maps[i]));
  }

  // Batch insert attachments
  Future<void> batchInsertAttachments(List<AttachmentModel> attachments) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final attachment in attachments) {
      batch.insert(
        DatabaseConstants.attachmentsTable,
        attachment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Batch delete attachments
  Future<void> batchDeleteAttachments(List<int> attachmentIds) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final id in attachmentIds) {
      batch.delete(
        DatabaseConstants.attachmentsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }
}
