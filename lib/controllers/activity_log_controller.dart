import 'package:get/get.dart';
import '../data/repository/activity_log_repository.dart';
import '../models/activity_log_model.dart';
import '../core/services/dialog_service.dart';

/// Activity Log Controller
/// Manages activity log state and operations using GetX
class ActivityLogController extends GetxController {
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();
  final DialogService _dialogService = DialogService();

  // Observable lists
  final RxList<ActivityLogModel> _activityLogs = <ActivityLogModel>[].obs;
  final RxMap<String, List<ActivityLogModel>> _activityTimeline = <String, List<ActivityLogModel>>{}.obs;
  final RxMap<EntityType, List<ActivityLogModel>> _logsByEntityType = <EntityType, List<ActivityLogModel>>{}.obs;
  final RxMap<ActionType, List<ActivityLogModel>> _logsByActionType = <ActionType, List<ActivityLogModel>>{}.obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isLogging = false.obs;

  // Statistics
  final RxMap<String, int> _statsByEntityType = <String, int>{}.obs;
  final RxMap<String, int> _statsByActionType = <String, int>{}.obs;

  // Getters
  List<ActivityLogModel> get activityLogs => _activityLogs;
  Map<String, List<ActivityLogModel>> get activityTimeline => _activityTimeline;
  Map<EntityType, List<ActivityLogModel>> get logsByEntityType => _logsByEntityType;
  Map<ActionType, List<ActivityLogModel>> get logsByActionType => _logsByActionType;
  
  bool get isLoading => _isLoading.value;
  bool get isLogging => _isLogging.value;
  
  Map<String, int> get statsByEntityType => _statsByEntityType;
  Map<String, int> get statsByActionType => _statsByActionType;

  // Get logs for a specific entity
  List<ActivityLogModel> getLogsForEntity(EntityType entityType, int entityId) {
    return _activityLogs
        .where((log) => log.entityType == entityType && log.entityId == entityId)
        .toList();
  }

  // Log board activity
  Future<bool> logBoardActivity({
    required int boardId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logBoardActivity(
        boardId: boardId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log list activity
  Future<bool> logListActivity({
    required int listId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logListActivity(
        listId: listId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log card activity
  Future<bool> logCardActivity({
    required int cardId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logCardActivity(
        cardId: cardId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log checklist activity
  Future<bool> logChecklistActivity({
    required int checklistId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logChecklistActivity(
        checklistId: checklistId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log comment activity
  Future<bool> logCommentActivity({
    required int commentId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logCommentActivity(
        commentId: commentId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log attachment activity
  Future<bool> logAttachmentActivity({
    required int attachmentId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logAttachmentActivity(
        attachmentId: attachmentId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Log label activity
  Future<bool> logLabelActivity({
    required int labelId,
    required ActionType actionType,
    String? oldValue,
    String? newValue,
    String? description,
  }) async {
    try {
      _isLogging.value = true;

      final log = await _activityLogRepository.logLabelActivity(
        labelId: labelId,
        actionType: actionType,
        oldValue: oldValue,
        newValue: newValue,
        description: description,
      );

      if (log != null) {
        _activityLogs.insert(0, log);
        _updateTimeline(log);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLogging.value = false;
    }
  }

  // Load activity logs for an entity
  Future<void> loadActivityLogsForEntity({
    required EntityType entityType,
    required int entityId,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) _isLoading.value = true;

      final logs = await _activityLogRepository.getActivityLogsByEntity(
        entityType: entityType,
        entityId: entityId,
      );

      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading activity logs: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load all activity logs
  Future<void> loadAllActivityLogs({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final logs = await _activityLogRepository.getAllActivityLogs();
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
      
      // Group by entity type
      _logsByEntityType.clear();
      for (final log in logs) {
        if (!_logsByEntityType.containsKey(log.entityType)) {
          _logsByEntityType[log.entityType] = [];
        }
        _logsByEntityType[log.entityType]!.add(log);
      }
      
      // Group by action type
      _logsByActionType.clear();
      for (final log in logs) {
        if (!_logsByActionType.containsKey(log.actionType)) {
          _logsByActionType[log.actionType] = [];
        }
        _logsByActionType[log.actionType]!.add(log);
      }
    } catch (e) {
      _dialogService.showError('Error loading activity logs: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load recent activity logs
  Future<void> loadRecentActivityLogs({int limit = 50, bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final logs = await _activityLogRepository.getRecentActivityLogs(limit: limit);
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading recent activity: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load today's activity logs
  Future<void> loadTodayActivityLogs({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final logs = await _activityLogRepository.getTodayActivityLogs();
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading today\'s activity: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load card activity logs
  Future<void> loadCardActivityLogs(int cardId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final logs = await _activityLogRepository.getCardActivityLogs(cardId);
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading card activity: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load activity logs by entity type
  Future<void> loadActivityLogsByEntityType(EntityType entityType) async {
    try {
      _isLoading.value = true;

      final logs = await _activityLogRepository.getActivityLogsByEntityType(entityType);
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading activity logs: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load activity logs by action type
  Future<void> loadActivityLogsByActionType(ActionType actionType) async {
    try {
      _isLoading.value = true;

      final logs = await _activityLogRepository.getActivityLogsByActionType(actionType);
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading activity logs: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load activity logs by date range
  Future<void> loadActivityLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _isLoading.value = true;

      final logs = await _activityLogRepository.getActivityLogsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      _activityLogs.assignAll(logs);
      _buildTimeline(logs);
    } catch (e) {
      _dialogService.showError('Error loading activity logs: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search activity logs
  Future<void> searchActivityLogs(String query) async {
    try {
      _isLoading.value = true;

      if (query.trim().isEmpty) {
        await loadAllActivityLogs(showLoading: false);
        return;
      }

      final results = await _activityLogRepository.searchActivityLogs(query);
      _activityLogs.assignAll(results);
      _buildTimeline(results);
    } catch (e) {
      _dialogService.showError('Error searching activity logs: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete activity log
  Future<bool> deleteActivityLog(int logId) async {
    try {
      final success = await _activityLogRepository.deleteActivityLog(logId);
      
      if (success) {
        _activityLogs.removeWhere((log) => log.id == logId);
        _rebuildTimeline();
        _dialogService.showSuccess('Activity log deleted');
        return true;
      }
      
      _dialogService.showError('Failed to delete activity log');
      return false;
    } catch (e) {
      _dialogService.showError('Error deleting activity log: ${e.toString()}');
      return false;
    }
  }

  // Delete old activity logs
  Future<bool> deleteOldActivityLogs({int daysOld = 90}) async {
    try {
      _isLoading.value = true;

      final success = await _activityLogRepository.deleteOldActivityLogs(daysOld: daysOld);
      
      if (success) {
        await loadAllActivityLogs(showLoading: false);
        _dialogService.showSuccess('Old activity logs deleted');
        return true;
      }
      
      _dialogService.showError('Failed to delete old activity logs');
      return false;
    } catch (e) {
      _dialogService.showError('Error deleting old logs: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear all activity logs
  Future<bool> clearAllActivityLogs() async {
    try {
      _isLoading.value = true;

      final success = await _activityLogRepository.clearAllActivityLogs();
      
      if (success) {
        _activityLogs.clear();
        _activityTimeline.clear();
        _logsByEntityType.clear();
        _logsByActionType.clear();
        _statsByEntityType.clear();
        _statsByActionType.clear();
        
        _dialogService.showSuccess('All activity logs cleared');
        return true;
      }
      
      _dialogService.showError('Failed to clear activity logs');
      return false;
    } catch (e) {
      _dialogService.showError('Error clearing logs: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      final entityStats = await _activityLogRepository.getActivityStatsByEntityType();
      final actionStats = await _activityLogRepository.getActivityStatsByActionType();
      
      _statsByEntityType.assignAll(entityStats);
      _statsByActionType.assignAll(actionStats);
    } catch (e) {
      _dialogService.showError('Error loading statistics: ${e.toString()}');
    }
  }

  // Helper method to update timeline with new log
  void _updateTimeline(ActivityLogModel log) {
    final dateKey = _formatDate(log.createdAt);
    if (!_activityTimeline.containsKey(dateKey)) {
      _activityTimeline[dateKey] = [];
    }
    _activityTimeline[dateKey]!.insert(0, log);
  }

  // Helper method to build timeline from logs
  void _buildTimeline(List<ActivityLogModel> logs) {
    _activityTimeline.clear();
    
    for (final log in logs) {
      final dateKey = _formatDate(log.createdAt);
      if (!_activityTimeline.containsKey(dateKey)) {
        _activityTimeline[dateKey] = [];
      }
      _activityTimeline[dateKey]!.add(log);
    }
  }

  // Helper method to rebuild timeline
  void _rebuildTimeline() {
    _buildTimeline(_activityLogs);
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

  // Clear all data (for logout or reset)
  void clearActivityLogs() {
    _activityLogs.clear();
    _activityTimeline.clear();
    _logsByEntityType.clear();
    _logsByActionType.clear();
    _statsByEntityType.clear();
    _statsByActionType.clear();
  }

  @override
  void onClose() {
    clearActivityLogs();
    super.onClose();
  }
}
