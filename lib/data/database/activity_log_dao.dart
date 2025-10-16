import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../../models/activity_log_model.dart';
import 'database_provider.dart';

/// Activity Log Data Access Object
/// Handles all database operations for activity logs
class ActivityLogDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  // Create a new activity log entry
  Future<int> createActivityLog(ActivityLogModel activityLog) async {
    final db = await _databaseProvider.database;
    return await db.insert(
      DatabaseConstants.activityLogTable,
      activityLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get activity log by ID
  Future<ActivityLogModel?> getActivityLogById(int id) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ActivityLogModel.fromMap(maps.first);
  }

  // Get all activity logs for an entity
  Future<List<ActivityLogModel>> getActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType.value, entityId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get all activity logs by entity type
  Future<List<ActivityLogModel>> getActivityLogsByEntityType(
    EntityType entityType,
  ) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'entity_type = ?',
      whereArgs: [entityType.value],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get all activity logs by action type
  Future<List<ActivityLogModel>> getActivityLogsByActionType(
    ActionType actionType,
  ) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'action_type = ?',
      whereArgs: [actionType.value],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get all activity logs
  Future<List<ActivityLogModel>> getAllActivityLogs() async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get recent activity logs (limit)
  Future<List<ActivityLogModel>> getRecentActivityLogs({int limit = 50}) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get activity logs by date range
  Future<List<ActivityLogModel>> getActivityLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseProvider.database;
    final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Get activity logs for today
  Future<List<ActivityLogModel>> getTodayActivityLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getActivityLogsByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get activity logs for a specific card (including related entities)
  Future<List<ActivityLogModel>> getCardActivityLogs(int cardId) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [EntityType.card.value, cardId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Search activity logs by description
  Future<List<ActivityLogModel>> searchActivityLogs(String query) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.activityLogTable,
      where: 'description LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // Count activity logs by entity
  Future<int> countActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.activityLogTable} WHERE entity_type = ? AND entity_id = ?',
      [entityType.value, entityId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Count activity logs by action type
  Future<int> countActivityLogsByActionType(ActionType actionType) async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.activityLogTable} WHERE action_type = ?',
      [actionType.value],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete activity log by ID
  Future<int> deleteActivityLog(int id) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.activityLogTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all activity logs for an entity
  Future<int> deleteActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      DatabaseConstants.activityLogTable,
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType.value, entityId],
    );
  }

  // Delete old activity logs (older than specified days)
  Future<int> deleteOldActivityLogs({int daysOld = 90}) async {
    final db = await _databaseProvider.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;

    return await db.delete(
      DatabaseConstants.activityLogTable,
      where: 'created_at < ?',
      whereArgs: [cutoffTimestamp],
    );
  }

  // Clear all activity logs
  Future<int> clearAllActivityLogs() async {
    final db = await _databaseProvider.database;
    return await db.delete(DatabaseConstants.activityLogTable);
  }

  // Get activity statistics by entity type
  Future<Map<String, int>> getActivityStatsByEntityType() async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT entity_type, COUNT(*) as count FROM ${DatabaseConstants.activityLogTable} GROUP BY entity_type',
    );

    final Map<String, int> stats = {};
    for (final row in result) {
      stats[row['entity_type'] as String] = row['count'] as int;
    }
    return stats;
  }

  // Get activity statistics by action type
  Future<Map<String, int>> getActivityStatsByActionType() async {
    final db = await _databaseProvider.database;
    final result = await db.rawQuery(
      'SELECT action_type, COUNT(*) as count FROM ${DatabaseConstants.activityLogTable} GROUP BY action_type',
    );

    final Map<String, int> stats = {};
    for (final row in result) {
      stats[row['action_type'] as String] = row['count'] as int;
    }
    return stats;
  }

  // Batch insert activity logs
  Future<void> batchInsertActivityLogs(List<ActivityLogModel> activityLogs) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final log in activityLogs) {
      batch.insert(
        DatabaseConstants.activityLogTable,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Batch delete activity logs
  Future<void> batchDeleteActivityLogs(List<int> logIds) async {
    final db = await _databaseProvider.database;
    final batch = db.batch();

    for (final id in logIds) {
      batch.delete(
        DatabaseConstants.activityLogTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }
}
