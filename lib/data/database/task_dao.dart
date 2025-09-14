import '../../models/task_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/task_status.dart';
import 'database_provider.dart';

class TaskDao {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  Future<int> insertTask(Task task) async {
    final db = await _databaseProvider.database;
    return await db.insert(AppConstants.tasksTable, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tasksTable,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tasksTable,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseProvider.database;
    return await db.update(
      AppConstants.tasksTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseProvider.database;
    return await db.delete(
      AppConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await _databaseProvider.database;
    return await db.delete(AppConstants.tasksTable);
  }
}
