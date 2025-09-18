import '../../models/task_model.dart';
import '../../core/enums/task_status.dart';
import '../../data/repository/task_repository.dart';
import '../../data/repository/checklist_item_repository.dart';
import '../../core/utils/logger/app_logger.dart';

/// Service responsible for automatic task movement based on due dates and checklist completion
class TaskMovementService {
  final TaskRepository _taskRepository = TaskRepository();
  final ChecklistItemRepository _checklistRepository =
      ChecklistItemRepository();

  /// Evaluates and moves tasks automatically based on due dates and checklist completion
  /// Returns a list of tasks that were moved
  Future<List<Task>> evaluateAndMoveTasksAutomatically() async {
    try {
      final allTasks = await _taskRepository.getAllTasks();
      final movedTasks = <Task>[];

      for (final task in allTasks) {
        final newStatus = await _determineTaskStatus(task);

        if (newStatus != task.status) {
          final success = await _taskRepository.moveTaskToStatus(
            task.id!,
            newStatus,
          );
          if (success) {
            final updatedTask = task.copyWith(status: newStatus);
            movedTasks.add(updatedTask);
            AppLogger.info(
              'Task "${task.title}" moved from ${task.status.displayName} to ${newStatus.displayName}',
            );
          }
        }
      }

      return movedTasks;
    } catch (e) {
      AppLogger.error('Error in automatic task movement evaluation: $e');
      return [];
    }
  }

  /// Determines the appropriate status for a task based on due date and checklist completion
  Future<TaskStatus> _determineTaskStatus(Task task) async {
    // Get checklist items for this task
    final checklistItems = task.id != null
        ? await _checklistRepository.getChecklistItemsByTaskId(task.id!)
        : <dynamic>[];

    // Check if task has a due date
    if (task.dueDate != null) {
      final now = DateTime.now();
      final dueDate = task.dueDate!;

      // Check if due date has passed (end of due date)
      final endOfDueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        23,
        59,
        59,
      );

      if (now.isAfter(endOfDueDate)) {
        // Due date has passed - move to done
        return TaskStatus.done;
      } else if (_isSameDay(now, dueDate)) {
        // Today is the due date - check checklist status or move to in progress
        return _getStatusBasedOnChecklist(checklistItems, task.status);
      } else if (_isTomorrow(dueDate)) {
        // Due date is tomorrow - move to in progress if currently in todo
        if (task.status == TaskStatus.todo) {
          return TaskStatus.inProgress;
        }
      }
    }

    // If no due date or due date logic doesn't apply, check checklist status
    return _getStatusBasedOnChecklist(checklistItems, task.status);
  }

  /// Determines status based on checklist completion
  TaskStatus _getStatusBasedOnChecklist(
    List<dynamic> checklistItems,
    TaskStatus currentStatus,
  ) {
    if (checklistItems.isEmpty) {
      // No checklist items - keep current status unless it needs due date adjustment
      return currentStatus;
    }

    final completedItems = checklistItems.where((item) => item.isDone).length;
    final totalItems = checklistItems.length;

    if (completedItems == 0) {
      // No items completed - should be in todo
      return TaskStatus.todo;
    } else if (completedItems == totalItems) {
      // All items completed - move to done
      return TaskStatus.done;
    } else {
      // Some items completed - move to in progress
      return TaskStatus.inProgress;
    }
  }

  /// Checks if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if the given date is tomorrow
  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _isSameDay(date, tomorrow);
  }

  /// Evaluates and moves a specific task
  Future<Task?> evaluateAndMoveTask(Task task) async {
    try {
      final newStatus = await _determineTaskStatus(task);

      if (newStatus != task.status && task.id != null) {
        final success = await _taskRepository.moveTaskToStatus(
          task.id!,
          newStatus,
        );
        if (success) {
          AppLogger.info(
            'Task "${task.title}" moved from ${task.status.displayName} to ${newStatus.displayName}',
          );
          return task.copyWith(status: newStatus);
        }
      }

      return null; // No movement needed or movement failed
    } catch (e) {
      AppLogger.error('Error evaluating task "${task.title}": $e');
      return null;
    }
  }

  /// Gets tasks that need to be moved based on current criteria
  Future<List<Task>> getTasksNeedingMovement() async {
    try {
      final allTasks = await _taskRepository.getAllTasks();
      final tasksNeedingMovement = <Task>[];

      for (final task in allTasks) {
        final newStatus = await _determineTaskStatus(task);
        if (newStatus != task.status) {
          tasksNeedingMovement.add(task);
        }
      }

      return tasksNeedingMovement;
    } catch (e) {
      AppLogger.error('Error getting tasks needing movement: $e');
      return [];
    }
  }

  /// Checks if a task should be moved to a different status
  Future<TaskStatus?> shouldMoveTask(Task task) async {
    try {
      final newStatus = await _determineTaskStatus(task);
      return newStatus != task.status ? newStatus : null;
    } catch (e) {
      AppLogger.error('Error checking if task should move: $e');
      return null;
    }
  }
}
