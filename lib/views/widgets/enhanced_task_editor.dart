// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/themes/app_colors.dart';
// import '../../core/localization/local_keys.dart';
// import '../../models/task_model.dart';
// import '../../controllers/task_editor_controller.dart';
// import 'checklist_tab_widget.dart';
// import 'responsive_text.dart';
// import 'task_details_tap_widget.dart';

// class EnhancedTaskEditor extends StatefulWidget {
//   final Task? task;
//   final Function(Task) onTaskSaved;

//   const EnhancedTaskEditor({super.key, this.task, required this.onTaskSaved});

//   @override
//   State<EnhancedTaskEditor> createState() => _EnhancedTaskEditorState();
// }

// class _EnhancedTaskEditorState extends State<EnhancedTaskEditor>
//     with SingleTickerProviderStateMixin {
//   late TaskEditorController controller;
//   final String controllerTag = DateTime.now().millisecondsSinceEpoch.toString();

//   @override
//   void initState() {
//     super.initState();
//     // Create a unique controller instance for this form session
//     controller = Get.put(TaskEditorController(), tag: controllerTag);
//     controller.setEditingTask(widget.task);
//     controller.initTabController();
//   }

//   @override
//   void dispose() {
//     // Clean up the controller completely
//     Get.delete<TaskEditorController>(tag: controllerTag);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.8,
//         minChildSize: 0.6,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 // Handle bar
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       AppText(
//                         widget.task != null
//                             ? LocalKeys.editTask.tr
//                             : LocalKeys.newTask.tr,
//                         variant: AppTextVariant.h2,
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         icon: const Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Tab bar
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TabBar(
//                     controller: controller.tabController,
//                     indicator: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     indicatorPadding: const EdgeInsets.all(
//                       0,
//                     ), // مهم عشان يمتد كامل التاب
//                     labelColor: AppColors.white,
//                     // unselectedLabelColor: AppColors.onSurface.withValues(
//                     //   alpha: 0.6,
//                     // ),
//                     labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//                     unselectedLabelStyle: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                     tabs: [
//                       Tab(
//                         child: Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.task_alt, size: 16),
//                               SizedBox(width: 6),
//                               Text(LocalKeys.detailsTab.tr),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Tab(
//                         child: Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.checklist, size: 16),
//                               SizedBox(width: 6),
//                               AppText(LocalKeys.checklistTab.tr),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Tab content
//                 Expanded(
//                   child: TabBarView(
//                     controller: controller.tabController,
//                     children: [
//                       TaskDetailsTab(controller: controller),
//                       ChecklistTab(controller: controller),
//                     ],
//                   ),
//                 ),

//                 // Action buttons only for Details tab
//                 Obx(() {
//                   if (controller.currentTabIndex.value != 0)
//                     return const SizedBox.shrink();
//                   return Container(
//                     padding: const EdgeInsets.all(20),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             child: AppText(LocalKeys.cancel.tr),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               try {
//                                 final savedTask = await controller.saveTask();
//                                 // Only call onTaskSaved for task updates, not for new task creation
//                                 // For new tasks, saveTask() already handles the creation via BoardController
//                                 if (widget.task?.id != null) {
//                                   widget.onTaskSaved(savedTask);
//                                 }
//                                 Navigator.of(context).pop();
//                               } catch (e) {
//                                 Get.snackbar(
//                                   'Error',
//                                   e.toString(),
//                                   backgroundColor: Colors.red,
//                                   colorText: Colors.white,
//                                 );
//                               }
//                             },
//                             child: AppText(
//                               widget.task != null
//                                   ? LocalKeys.update.tr
//                                   : LocalKeys.create.tr,
//                               variant: AppTextVariant.button,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
