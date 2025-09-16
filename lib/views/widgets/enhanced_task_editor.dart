// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/utils/helper_functions_utils.dart';
// import '../../controllers/checklist_controller.dart';
// import '../../controllers/board_controller.dart';
// import '../../core/localization/local_keys.dart' show LocalKeys;
// import '../../core/themes/app_colors.dart' show AppColors;
// import '../../models/task_model.dart';
// import '../../core/enums/task_status.dart';
// import 'checklist_widget.dart';

// class EnhancedTaskEditor extends StatefulWidget {
//   final Task? task;
//   final Function(Task) onTaskSaved;

//   const EnhancedTaskEditor({super.key, this.task, required this.onTaskSaved});

//   @override
//   State<EnhancedTaskEditor> createState() => _EnhancedTaskEditorState();
// }

// class _EnhancedTaskEditorState extends State<EnhancedTaskEditor>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   TaskStatus _selectedStatus = TaskStatus.todo;
//   int _selectedPriority = 2;
//   DateTime? _selectedDueDate;

//   late TabController _tabController;
//   int _currentTabIndex = 0;

//   // For new tasks - temporary checklist storage
//   final List<String> _tempChecklistItems = [];
//   final TextEditingController _checklistItemController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       setState(() {
//         _currentTabIndex = _tabController.index;
//       });
//     });

//     if (widget.task != null) {
//       _titleController.text = widget.task!.title;
//       _descriptionController.text = widget.task!.description;
//       _selectedStatus = widget.task!.status;
//       _selectedPriority = widget.task!.priority;
//       _selectedDueDate = widget.task!.dueDate;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _tabController.dispose();
//     _checklistItemController.dispose();
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
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Handle bar
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         widget.task != null
//                             ? LocalKeys.editTask.tr
//                             : LocalKeys.newTask.tr,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
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
//                     color: AppColors.surface.withValues(alpha: 0.5),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     indicator: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     labelColor: AppColors.white,
//                     unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                     unselectedLabelStyle: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 14,
//                     ),
//                     tabs: [
//                       Tab(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.task_alt, size: 16),
//                             const SizedBox(width: 6),
//                             Text('Details'),
//                           ],
//                         ),
//                       ),
//                       Tab(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.checklist, size: 16),
//                             const SizedBox(width: 6),
//                             Text('Checklist'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Tab content
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       // Task Details Tab
//                       _buildTaskDetailsTab(scrollController),

//                       // Checklist Tab
//                       _buildChecklistTab(),
//                     ],
//                   ),
//                 ),

//                 // Action buttons (only show on details tab)
//                 if (_currentTabIndex == 0)
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             child: Text(LocalKeys.cancel.tr),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _saveTask,
//                             child: Text(
//                               widget.task != null
//                                   ? LocalKeys.update.tr
//                                   : LocalKeys.create.tr,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTaskDetailsTab(ScrollController scrollController) {
//     return Form(
//       key: _formKey,
//       child: ListView(
//         controller: scrollController,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         children: [
//           TextFormField(
//             controller: _titleController,
//             decoration: InputDecoration(
//               labelText: LocalKeys.taskTitle.tr,
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return LocalKeys.pleaseEnterTitle.tr;
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _descriptionController,
//             decoration: InputDecoration(
//               labelText: LocalKeys.taskDescription.tr,
//               border: OutlineInputBorder(),
//               alignLabelWithHint: true,
//             ),
//             maxLines: 4,
//           ),
//           const SizedBox(height: 16),
//           DropdownButtonFormField<TaskStatus>(
//             initialValue: _selectedStatus,
//             decoration: InputDecoration(
//               labelText: LocalKeys.taskStatus.tr,
//               border: OutlineInputBorder(),
//             ),
//             items: TaskStatus.values.map((status) {
//               return DropdownMenuItem(
//                 value: status,
//                 child: Text(HelperFunctionsUtils.getStatusDisplayName(status)),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 setState(() {
//                   _selectedStatus = value;
//                 });
//               }
//             },
//           ),
//           const SizedBox(height: 16),
//           DropdownButtonFormField<int>(
//             initialValue: _selectedPriority,
//             decoration: InputDecoration(
//               labelText: LocalKeys.priority.tr,
//               border: OutlineInputBorder(),
//             ),
//             items: [
//               DropdownMenuItem(value: 1, child: Text(LocalKeys.high.tr)),
//               DropdownMenuItem(value: 2, child: Text(LocalKeys.medium.tr)),
//               DropdownMenuItem(value: 3, child: Text(LocalKeys.low.tr)),
//             ],
//             onChanged: (value) {
//               if (value != null) {
//                 setState(() {
//                   _selectedPriority = value;
//                 });
//               }
//             },
//           ),
//           const SizedBox(height: 16),
//           InkWell(
//             onTap: _selectDueDate,
//             child: InputDecorator(
//               decoration: InputDecoration(
//                 labelText: LocalKeys.dueDate.tr,
//                 border: OutlineInputBorder(),
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//               child: Text(
//                 _selectedDueDate != null
//                     ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
//                     : LocalKeys.selectDueDate.tr,
//                 style: TextStyle(
//                   color: _selectedDueDate != null
//                       ? AppColors.secondary
//                       : AppColors.primary,
//                 ),
//               ),
//             ),
//           ),
//           if (_selectedDueDate != null) ...[
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedDueDate = null;
//                   });
//                 },
//                 child: Text(LocalKeys.clearDueDate.tr),
//               ),
//             ),
//           ],
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildChecklistTab() {
//     // For new tasks, show temporary checklist creator
//     if (widget.task?.id == null) {
//       return _buildNewTaskChecklistTab();
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(8),
//       child: ChecklistWidget(
//         taskId: widget.task!.id!,
//         showProgress: true,
//         showActions: true,
//         isEditable: true,
//         header: Container(
//           padding: const EdgeInsets.all(16),
//           margin: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.checklist_rtl, color: AppColors.primary),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Task Checklist',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     Text(
//                       'Break down this task into smaller steps',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.primary.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDueDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDueDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null && picked != _selectedDueDate) {
//       setState(() {
//         _selectedDueDate = picked;
//       });
//     }
//   }

//   void _saveTask() async {
//     if (_formKey.currentState!.validate()) {
//       final task = Task(
//         id: widget.task?.id,
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim(),
//         status: _selectedStatus,
//         priority: _selectedPriority,
//         dueDate: _selectedDueDate,
//         createdAt: widget.task?.createdAt ?? DateTime.now(),
//         updatedAt: widget.task?.updatedAt ?? DateTime.now(),
//       );

//       try {
//         // For new tasks, we need to get the created task with ID
//         if (widget.task?.id == null) {
//           // This is a new task - we need to handle the async creation
//           final createdTask = await _handleNewTaskCreation(task);

//           // If we have temporary checklist items, add them
//           if (_tempChecklistItems.isNotEmpty && createdTask.id != null) {
//             _createChecklistItemsAfterTaskCreation(createdTask);
//           }
//         } else {
//           // This is an existing task - just call the callback
//           widget.onTaskSaved(task);
//         }

//         Navigator.of(context).pop();
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           'Failed to save task: ${e.toString()}',
//           backgroundColor: AppColors.error,
//           colorText: AppColors.white,
//         );
//       }
//     }
//   }

//   Future<Task> _handleNewTaskCreation(Task task) async {
//     // We need to call the board controller directly for new tasks
//     final boardController = Get.find<BoardController>();
//     final createdTask = await boardController.addTask(task);
//     return createdTask;
//   }

//   Widget _buildNewTaskChecklistTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.checklist_rtl,
//                   color: AppColors.primary,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Task Checklist',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       Text(
//                         'Add checklist items for this new task',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.primary.withValues(alpha: 0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Add checklist item input
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.surface.withValues(alpha: 0.7),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.outline.withValues(alpha: 0.2),
//               ),
//             ),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _checklistItemController,
//                   decoration: InputDecoration(
//                     hintText: 'Add checklist item...',
//                     border: InputBorder.none,
//                     prefixIcon: Icon(
//                       Icons.add,
//                       color: AppColors.primary,
//                     ),
//                     suffixIcon: IconButton(
//                       onPressed: () => _addTempChecklistItem(_checklistItemController.text),
//                       icon: Icon(
//                         Icons.send,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                   onSubmitted: _addTempChecklistItem,
//                 ),
//                 if (_tempChecklistItems.isNotEmpty) ...[
//                   const Divider(),
//                   Text(
//                     'Items to add (${_tempChecklistItems.length}):',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.onSurface.withValues(alpha: 0.7),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Temporary checklist items
//           Expanded(
//             child: _tempChecklistItems.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.checklist_outlined,
//                           size: 48,
//                           color: AppColors.onSurface.withOpacity(0.3),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No checklist items yet',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: AppColors.onSurface.withOpacity(0.6),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Add items above to break down this task',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.onSurface.withOpacity(0.4),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _tempChecklistItems.length,
//                     itemBuilder: (context, index) {
//                       final item = _tempChecklistItems[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.surface,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: AppColors.outline.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.radio_button_unchecked,
//                               size: 20,
//                               color: AppColors.outline,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => _removeTempChecklistItem(index),
//                               icon: Icon(
//                                 Icons.close,
//                                 size: 16,
//                                 color: AppColors.error.withOpacity(0.7),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Methods for handling temporary checklist items
//   void _addTempChecklistItem(String title) {
//     if (title.trim().isNotEmpty) {
//       setState(() {
//         _tempChecklistItems.add(title.trim());
//         _checklistItemController.clear();
//       });
//     }
//   }

//   void _removeTempChecklistItem(int index) {
//     setState(() {
//       _tempChecklistItems.removeAt(index);
//     });
//   }

//   void _createChecklistItemsAfterTaskCreation(Task task) async {
//     // Wait a bit for the task to be saved and get an ID
//     await Future.delayed(const Duration(milliseconds: 500));

//     try {
//       final controller = Get.find<ChecklistController>();
//       if (task.id != null) {
//         await controller.createMultipleItems(
//           taskId: task.id!,
//           titles: _tempChecklistItems,
//         );
//       }
//     } catch (e) {
//       // Handle error silently or show a snackbar
//       Get.snackbar(
//         'Note',
//         'Task created successfully. You can add checklist items by editing the task.',
//         backgroundColor: AppColors.primary,
//         colorText: AppColors.white,
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/themes/app_colors.dart';
import '../../core/localization/local_keys.dart';
import '../../models/task_model.dart';
import '../../controllers/task_editor_controller.dart';
import 'checklist_tab_widget.dart';
import 'task_details_tap_widget.dart';

class EnhancedTaskEditor extends StatefulWidget {
  final Task? task;
  final Function(Task) onTaskSaved;

  const EnhancedTaskEditor({super.key, this.task, required this.onTaskSaved});

  @override
  State<EnhancedTaskEditor> createState() => _EnhancedTaskEditorState();
}

class _EnhancedTaskEditorState extends State<EnhancedTaskEditor>
    with SingleTickerProviderStateMixin {
  late TaskEditorController controller;
  final String controllerTag = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    // Create a unique controller instance for this form session
    controller = Get.put(TaskEditorController(), tag: controllerTag);
    controller.setEditingTask(widget.task);
    controller.initTabController();
  }

  @override
  void dispose() {
    // Clean up the controller completely
    Get.delete<TaskEditorController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.task != null
                            ? LocalKeys.editTask.tr
                            : LocalKeys.newTask.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: controller.tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorPadding: const EdgeInsets.all(
                      0,
                    ), // مهم عشان يمتد كامل التاب
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.onSurface.withOpacity(0.6),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Icon(Icons.task_alt, size: 16),
                              SizedBox(width: 6),
                              Text(LocalKeys.detailsTab.tr),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Icon(Icons.checklist, size: 16),
                              SizedBox(width: 6),
                              Text(LocalKeys.checklistTab.tr),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      TaskDetailsTab(controller: controller),
                      ChecklistTab(controller: controller),
                    ],
                  ),
                ),

                // Action buttons only for Details tab
                Obx(() {
                  if (controller.currentTabIndex.value != 0)
                    return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(LocalKeys.cancel.tr),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                final savedTask = await controller.saveTask();
                                // Only call onTaskSaved for task updates, not for new task creation
                                // For new tasks, saveTask() already handles the creation via BoardController
                                if (widget.task?.id != null) {
                                  widget.onTaskSaved(savedTask);
                                }
                                Navigator.of(context).pop();
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e.toString(),
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: Text(
                              widget.task != null
                                  ? LocalKeys.update.tr
                                  : LocalKeys.create.tr,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
