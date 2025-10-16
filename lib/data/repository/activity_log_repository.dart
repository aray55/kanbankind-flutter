import '../../models/activity_log_model.dart';
import '../database/activity_log_dao.dart';

/// Activity Log Repository
/// Business logic layer for activity logs
class ActivityLogRepository {
  final ActivityLogDao _activityLogDao = ActivityLogDao();

  // Create a new activity log entry
  Future<ActivityLogModel?> createActivityLog(ActivityLogModel activityLog) async {
    try {
      // Validate activity log
      final validationError = activityLog.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      final id = await _activityLogDao.createActivityLog(activityLog);
      if (id > 0) {
        return activityLog.copyWith(id: id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Log board activity
  Future<ActivityLogModel?> logBoardActivity({
    required int boardId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.board,
      entityId: boardId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log list activity
  Future<ActivityLogModel?> logListActivity({
    required int listId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.list,
      entityId: listId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log card activity
  Future<ActivityLogModel?> logCardActivity({
    required int cardId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.card,
      entityId: cardId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log checklist activity
  Future<ActivityLogModel?> logChecklistActivity({
    required int checklistId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.checklist,
      entityId: checklistId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log comment activity
  Future<ActivityLogModel?> logCommentActivity({
    required int commentId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.comment,
      entityId: commentId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log attachment activity
  Future<ActivityLogModel?> logAttachmentActivity({
    required int attachmentId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.attachment,
      entityId: attachmentId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Log label activity
  Future<ActivityLogModel?> logLabelActivity({
    required int labelId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    final log = ActivityLogModel(
      entityType: EntityType.label,
      entityId: labelId,
      actionType: actionType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
    return await createActivityLog(log);
  }

  // Get activity log by ID
  Future<ActivityLogModel?> getActivityLogById(int id) async {
    try {
      return await _activityLogDao.getActivityLogById(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all activity logs for an entity
  Future<List<ActivityLogModel>> getActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    try {
      return await _activityLogDao.getActivityLogsByEntity(
        entityType: entityType,
        entityId: entityId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all activity logs by entity type
  Future<List<ActivityLogModel>> getActivityLogsByEntityType(
    EntityType entityType,
  ) async {
    try {
      return await _activityLogDao.getActivityLogsByEntityType(entityType);
    } catch (e) {
      rethrow;
    }
  }

  // Get all activity logs by action type
  Future<List<ActivityLogModel>> getActivityLogsByActionType(
    ActionType actionType,
  ) async {
    try {
      return await _activityLogDao.getActivityLogsByActionType(actionType);
    } catch (e) {
      rethrow;
    }
  }

  // Get all activity logs
  Future<List<ActivityLogModel>> getAllActivityLogs() async {
    try {
      return await _activityLogDao.getAllActivityLogs();
    } catch (e) {
      rethrow;
    }
  }

  // Get recent activity logs
  Future<List<ActivityLogModel>> getRecentActivityLogs({int limit = 50}) async {
    try {
      return await _activityLogDao.getRecentActivityLogs(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get activity logs by date range
  Future<List<ActivityLogModel>> getActivityLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _activityLogDao.getActivityLogsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get today's activity logs
  Future<List<ActivityLogModel>> getTodayActivityLogs() async {
    try {
      return await _activityLogDao.getTodayActivityLogs();
    } catch (e) {
      rethrow;
    }
  }

  // Get card activity logs
  Future<List<ActivityLogModel>> getCardActivityLogs(int cardId) async {
    try {
      return await _activityLogDao.getCardActivityLogs(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Search activity logs
  Future<List<ActivityLogModel>> searchActivityLogs(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await _activityLogDao.searchActivityLogs(query);
    } catch (e) {
      rethrow;
    }
  }

  // Count activity logs by entity
  Future<int> countActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    try {
      return await _activityLogDao.countActivityLogsByEntity(
        entityType: entityType,
        entityId: entityId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Count activity logs by action type
  Future<int> countActivityLogsByActionType(ActionType actionType) async {
    try {
      return await _activityLogDao.countActivityLogsByActionType(actionType);
    } catch (e) {
      rethrow;
    }
  }

  // Delete activity log
  Future<bool> deleteActivityLog(int id) async {
    try {
      final result = await _activityLogDao.deleteActivityLog(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Delete all activity logs for an entity
  Future<bool> deleteActivityLogsByEntity({
    required EntityType entityType,
    required int entityId,
  }) async {
    try {
      final result = await _activityLogDao.deleteActivityLogsByEntity(
        entityType: entityType,
        entityId: entityId,
      );
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Delete old activity logs
  Future<bool> deleteOldActivityLogs({int daysOld = 90}) async {
    try {
      final result = await _activityLogDao.deleteOldActivityLogs(daysOld: daysOld);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Clear all activity logs
  Future<bool> clearAllActivityLogs() async {
    try {
      final result = await _activityLogDao.clearAllActivityLogs();
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Get activity statistics by entity type
  Future<Map<String, int>> getActivityStatsByEntityType() async {
    try {
      return await _activityLogDao.getActivityStatsByEntityType();
    } catch (e) {
      rethrow;
    }
  }

  // Get activity statistics by action type
  Future<Map<String, int>> getActivityStatsByActionType() async {
    try {
      return await _activityLogDao.getActivityStatsByActionType();
    } catch (e) {
      rethrow;
    }
  }

  // Batch create activity logs
  Future<bool> batchCreateActivityLogs(List<ActivityLogModel> activityLogs) async {
    try {
      // Validate all logs
      for (final log in activityLogs) {
        final validationError = log.validate();
        if (validationError != null) {
          throw Exception('Invalid activity log: $validationError');
        }
      }

      await _activityLogDao.batchInsertActivityLogs(activityLogs);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Batch delete activity logs
  Future<bool> batchDeleteActivityLogs(List<int> logIds) async {
    try {
      await _activityLogDao.batchDeleteActivityLogs(logIds);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Get activity timeline (grouped by date)
  Future<Map<String, List<ActivityLogModel>>> getActivityTimeline({
    int limit = 100,
  }) async {
    try {
      final logs = await _activityLogDao.getRecentActivityLogs(limit: limit);
      final Map<String, List<ActivityLogModel>> timeline = {};

      for (final log in logs) {
        final dateKey = _formatDate(log.createdAt);
        if (!timeline.containsKey(dateKey)) {
          timeline[dateKey] = [];
        }
        timeline[dateKey]!.add(log);
      }

      return timeline;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
