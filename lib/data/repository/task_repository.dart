// import '../../models/task_model.dart';
// import '../../core/enums/task_status.dart';
// import '../database/task_dao.dart';

// class TaskRepository {
//   final TaskDao _taskDao = TaskDao();

//   Future<int> createTask(Task task) async {
//     return await _taskDao.insertTask(task);
//   }

//   Future<List<Task>> getAllTasks() async {
//     return await _taskDao.getAllTasksWithChecklists();
//   }

//   Future<List<Task>> getTasksByStatus(TaskStatus status) async {
//     return await _taskDao.getTasksByStatusWithChecklists(status);
//   }

//   Future<Task?> getTaskById(int id) async {
//     return await _taskDao.getTaskByIdWithChecklist(id);
//   }

//   Future<bool> updateTask(Task task) async {
//     final result = await _taskDao.updateTask(task);
//     return result > 0;
//   }

//   Future<bool> deleteTask(int id) async {
//     final result = await _taskDao.deleteTask(id);
//     return result > 0;
//   }

//   Future<bool> moveTaskToStatus(int taskId, TaskStatus newStatus) async {
//     final task = await _taskDao.getTaskByIdWithChecklist(taskId);
//     if (task != null) {
//       final updatedTask = task.copyWith(
//         status: newStatus,
//         updatedAt: DateTime.now(),
//       );
//       return await updateTask(updatedTask);
//     }
//     return false;
//   }

//   Future<List<Task>> getTodoTasks() async {
//     return await getTasksByStatus(TaskStatus.todo);
//   }

//   Future<List<Task>> getInProgressTasks() async {
//     return await getTasksByStatus(TaskStatus.inProgress);
//   }

//   Future<List<Task>> getDoneTasks() async {
//     return await getTasksByStatus(TaskStatus.done);
//   }

//   Future<bool> clearAllTasks() async {
//     final result = await _taskDao.deleteAllTasks();
//     return result > 0;
//   }
// }
