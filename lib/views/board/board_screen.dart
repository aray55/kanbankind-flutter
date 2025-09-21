// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/controllers/board_controller.dart';
// import 'package:kanbankit/controllers/list_controller.dart';
// import 'package:kanbankit/controllers/task_controller.dart';
// import 'package:kanbankit/models/board_model.dart';
// import 'package:kanbankit/models/list_model.dart';
// import 'package:kanbankit/models/task_model.dart';
// import 'package:kanbankit/views/widgets/lists/list_column_widget.dart';
// import 'package:kanbankit/core/enums/task_status.dart';
// import 'package:kanbankit/views/components/state_widgets.dart';
// import 'package:kanbankit/views/components/responsive_app_bar.dart';
// import 'package:kanbankit/views/components/empty_state.dart';

// class BoardScreen extends StatefulWidget {
//   final Board board;

//   const BoardScreen({super.key, required this.board});

//   @override
//   State<BoardScreen> createState() => _BoardScreenState();
// }

// class _BoardScreenState extends State<BoardScreen> {
//   late final BoardController _boardController;
//   late final ListController _listController;
//   late final TaskController _taskController;

//   @override
//   void initState() {
//     super.initState();
//     _boardController = Get.find<BoardController>();
//     _listController = Get.find<ListController>();
//     _taskController = Get.find<TaskController>();

//     // Load the board data
//     _loadBoardData();
//   }

//   void _loadBoardData() {
//     _listController.setBoardId(widget.board.id!);
//     _taskController.loadAllTasks();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ResponsiveAppBar(
//         title: widget.board.title,
//         actions: [
//           IconButton(
//             onPressed: _showBoardMenu,
//             icon: const Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         // Show loading state
//         if (_listController.isLoading || _taskController.isLoading.value) {
//           return const LoadingView();
//         }

//         // Get lists for this board
//         final lists = _listController.lists
//             .where((list) => list.boardId == widget.board.id && list.isActive)
//             .toList();

//         // Show empty state if no lists
//         if (lists.isEmpty) {
//           return EmptyState(
//             title: 'No Lists Yet',
//             subtitle: 'Create your first list to start organizing tasks.',
//             icon: Icons.view_column_outlined,
//             actionText: 'Add List',
//             onActionPressed: _showAddListModal,
//           );
//         }

//         // Group tasks by status (todo, inProgress, done)
//         final todoTasks = _taskController.todoTasks.toList();
//         final inProgressTasks = _taskController.inProgressTasks.toList();
//         final doneTasks = _taskController.doneTasks.toList();

//         // For demonstration, we'll create 3 columns with dummy data
//         // In a real implementation, you would map lists to their tasks
//         final columns = [
//           {'title': 'To Do', 'tasks': todoTasks, 'status': TaskStatus.todo},
//           {
//             'title': 'In Progress',
//             'tasks': inProgressTasks,
//             'status': TaskStatus.inProgress,
//           },
//           {'title': 'Done', 'tasks': doneTasks, 'status': TaskStatus.done},
//         ];

//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: columns.map((columnData) {
//               // Create a dummy list model for each column
//               final status = columnData['status'] as TaskStatus;
//               final dummyList = ListModel(
//                 id: status.index,
//                 boardId: widget.board.id!,
//                 title: columnData['title'] as String,
//                 color: _getDefaultColorForStatus(status),
//                 position: status.index.toDouble(),
//               );

//               return ListColumnWidget(
//                 list: dummyList,
//                 tasks: columnData['tasks'] as List<Task>,
//                 onTaskMoved: _handleTaskMoved,
//                 onTaskDeleted: _handleTaskDeleted,
//                 onTaskUpdated: _handleTaskUpdated,
//                 onListUpdated: _handleListUpdated,
//                 onListDeleted: _handleListDeleted,
//                 onListArchived: _handleListArchived,
//               );
//             }).toList(),
//           ),
//         );
//       }),
//     );
//   }

//   String _getDefaultColorForStatus(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.todo:
//         return '#FF9800'; // Orange
//       case TaskStatus.inProgress:
//         return '#2196F3'; // Blue
//       case TaskStatus.done:
//         return '#4CAF50'; // Green
//       default:
//         return '#9E9E9E'; // Grey
//     }
//   }

//   void _handleTaskMoved(Task task, TaskStatus newStatus) {
//     // Handle moving task between lists/statuses
//     _taskController.moveTask(task, newStatus);
//   }

//   void _handleTaskDeleted(int taskId) {
//     // Handle deleting a task
//     _taskController.deleteTask(taskId);
//   }

//   void _handleTaskUpdated(Task updatedTask) {
//     // Handle updating a task
//     _taskController.updateTask(updatedTask);
//   }

//   void _handleListUpdated(ListModel updatedList) {
//     // Handle updating a list
//     // In this implementation, we're using dummy lists, so this won't be called
//   }

//   void _handleListDeleted(ListModel list) {
//     // Handle deleting a list
//     // In this implementation, we're using dummy lists, so this won't be called
//   }

//   void _handleListArchived(ListModel list) {
//     // Handle archiving a list
//     // In this implementation, we're using dummy lists, so this won't be called
//   }

//   void _showAddListModal() {
//     // TODO: Implement add list functionality
//   }

//   void _showBoardMenu() {
//     // TODO: Implement board menu functionality
//   }
// }
