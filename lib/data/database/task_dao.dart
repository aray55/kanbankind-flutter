import '../../core/constants/database_constants.dart';
import '../../models/task_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/task_status.dart';
import 'database_provider.dart';
import 'checklist_item_dao.dart';
import '../../models/checklist_item_model.dart';

class TaskDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  final ChecklistItemDao _checklistItemDao = ChecklistItemDao();

  Future<int> insertTask(Task task) async {
    final db = await _databaseProvider.database;
    // Ensure we're creating a new task without an ID for auto-increment
    final taskData = task.toMap();
    // Remove id if it exists to ensure auto-increment works properly
    taskData.remove('id');
    return await db.insert(DatabaseConstants.tasksTable, taskData);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tasksTable,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get all tasks with their checklist items
  Future<List<Task>> getAllTasksWithChecklists() async {
    final tasks = await getAllTasks();
    final List<Task> tasksWithChecklists = [];

    for (final task in tasks) {
      if (task.id != null) {
        final checklistItems = await _checklistItemDao.getByTaskId(task.id!);
        tasksWithChecklists.add(task.copyWith(checklistItems: checklistItems));
      } else {
        tasksWithChecklists.add(task);
      }
    }

    return tasksWithChecklists;
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tasksTable,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by status with their checklist items
  Future<List<Task>> getTasksByStatusWithChecklists(TaskStatus status) async {
    final tasks = await getTasksByStatus(status);
    final List<Task> tasksWithChecklists = [];

    for (final task in tasks) {
      if (task.id != null) {
        final checklistItems = await _checklistItemDao.getByTaskId(task.id!);
        tasksWithChecklists.add(task.copyWith(checklistItems: checklistItems));
      } else {
        tasksWithChecklists.add(task);
      }
    }

    return tasksWithChecklists;
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // Get task by ID with checklist items
  Future<Task?> getTaskByIdWithChecklist(int id) async {
    final task = await getTaskById(id);
    if (task == null) return null;

    final checklistItems = await _checklistItemDao.getByTaskId(id);
    return task.copyWith(checklistItems: checklistItems);
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseProvider.database;
    return await db.update(
      DatabaseConstants.tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseProvider.database;
    // First delete all checklist items for this task
    await _checklistItemDao.deleteByTaskId(id);
    // Then delete the task itself
    return await db.delete(
      DatabaseConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await _databaseProvider.database;
    // First delete all checklist items
    await _checklistItemDao.deleteAll();
    // Then delete all tasks
    return await db.delete(DatabaseConstants.tasksTable);
  }

  // Insert task with checklist items
  Future<Task> insertTaskWithChecklist(
    Task task,
    List<ChecklistItem> checklistItems,
  ) async {
    final taskId = await insertTask(task);
    final createdTask = task.copyWith(id: taskId);

    if (checklistItems.isNotEmpty) {
      final itemsWithTaskId = checklistItems
          .map((item) => item.copyWith(taskId: taskId))
          .toList();

      await _checklistItemDao.insertBatch(itemsWithTaskId);
      final savedItems = await _checklistItemDao.getByTaskId(taskId);
      return createdTask.copyWith(checklistItems: savedItems);
    }

    return createdTask;
  }

  // Update task and preserve checklist items
  Future<Task?> updateTaskWithChecklist(Task task) async {
    final updatedRows = await updateTask(task);
    if (updatedRows > 0 && task.id != null) {
      return await getTaskByIdWithChecklist(task.id!);
    }
    return null;
  }

  // Get tasks with checklist progress
  Future<List<Map<String, dynamic>>> getTasksWithProgress() async {
    final tasks = await getAllTasksWithChecklists();
    return tasks
        .map(
          (task) => {
            'task': task,
            'total_items': task.totalChecklistItems,
            'completed_items': task.completedChecklistItems,
            'progress': task.checklistProgress,
            'is_completed': task.isChecklistCompleted,
          },
        )
        .toList();
  }
}
