// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/views/components/state_widgets.dart';
// import 'package:kanbankit/views/widgets/responsive_text.dart';
// import '../../models/task_model.dart';
// import '../../controllers/task_controller.dart';
// import '../../controllers/checklist_controller.dart';
// import '../../controllers/task_editor_controller.dart';
// import '../../core/localization/local_keys.dart';
// import '../components/text_buttons/app_text_button.dart';
// import '../widgets/enhanced_task_editor.dart';
// import '../widgets/checklist_tab_widget.dart';
// import '../components/task_details_tab.dart';

// class TaskDetailsPage extends StatefulWidget {
//   const TaskDetailsPage({super.key});

//   @override
//   State<TaskDetailsPage> createState() => _TaskDetailsPageState();
// }

// class _TaskDetailsPageState extends State<TaskDetailsPage>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   Task? task;
//   final TaskController _taskController = Get.find<TaskController>();
//   final ChecklistController _checklistController = Get.put(
//     ChecklistController(),
//   );
//   late TaskEditorController _taskEditorController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//     // Get task from arguments
//     final arguments = Get.arguments;
//     if (arguments is Task) {
//       task = arguments;
//       if (task?.id != null) {
//         _checklistController.loadChecklistItems(task!.id!);
//       }
//     }

//     // Initialize TaskEditorController for ChecklistTab
//     _taskEditorController = Get.put(
//       TaskEditorController(),
//       tag: 'task_details',
//     );
//     _taskEditorController.setEditingTask(task);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     // Clean up the TaskEditorController
//     Get.delete<TaskEditorController>(tag: 'task_details');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (task == null) {
//       return EmptyView(
//         buttonText: LocalKeys.cancel.tr,
//         message: LocalKeys.taskNotFound.tr,
//         onRefresh: () => Get.back(),
//       );
//     }

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: AppText(
//             task!.title,
//             variant: AppTextVariant.h1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           actions: [
//             IconButton(icon: const Icon(Icons.edit), onPressed: _editTask),
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'delete') {
//                   _deleteTask();
//                 }
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       const Icon(Icons.delete, size: 16, color: Colors.red),
//                       const SizedBox(width: 8),
//                       AppText(LocalKeys.deleteTask.tr, color: Colors.red),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],

//           bottom: TabBar(
//             controller: _tabController,
//             tabs: [
//               Tab(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.info_outline, size: 16),
//                     const SizedBox(width: 8),
//                     AppText(LocalKeys.detailsTab.tr),
//                   ],
//                 ),
//               ),
//               Tab(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.checklist, size: 16),
//                     const SizedBox(width: 8),
//                     AppText(LocalKeys.checklistTab.tr),
//                     Obx(() {
//                       if (_checklistController.hasItems) {
//                         return Container(
//                           margin: const EdgeInsets.only(left: 4),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).primaryColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: AppText(
//                             '${_checklistController.completedItems}/${_checklistController.totalItems}',
//                             variant: AppTextVariant.small,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     }),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             TaskDetailsTab(
//               task: task!,
//               checklistController: _checklistController,
//             ),
//             _buildChecklistTab(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChecklistTab() {
//     if (task?.id == null) {
//       return EmptyView(
//         buttonText: LocalKeys.addTask.tr,
//         message: LocalKeys.noChecklistItems.tr,
//         onRefresh: () => _checklistController.loadChecklistItems(task!.id!),
//       );
//     }

//     return ChecklistTab(controller: _taskEditorController);
//   }

//   void _editTask() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => EnhancedTaskEditor(
//         task: task!,
//         onTaskSaved: (updatedTask) {
//           setState(() {
//             task = updatedTask;
//           });
//         },
//       ),
//     );
//   }

//   void _deleteTask() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AppText(LocalKeys.deleteTask.tr),
//         content: AppText('${LocalKeys.areYouSureDelete.tr} "${task!.title}"?'),
//         actions: [
//           AppTextButton(
//             onPressed: () => Navigator.pop(context),
//             label: LocalKeys.cancel.tr,
//           ),
//           AppTextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               if (task?.id != null) {
//                 await _taskController.deleteTask(task!.id!);
//                 Get.back(result: {'deleted': true});
//               }
//             },
//             label: LocalKeys.delete.tr,
//           ),
//         ],
//       ),
//     );
//   }
// }
