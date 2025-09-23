// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/utils/helper_functions_utils.dart';
// import '../../controllers/task_editor_controller.dart';
// import '../../controllers/datetime_picker_controller.dart';
// import '../../core/localization/local_keys.dart';
// import '../../core/enums/task_status.dart';
// import '../components/datetime_picker.dart';

// class TaskDetailsTab extends StatelessWidget {
//   final TaskEditorController? controller;

//   const TaskDetailsTab({super.key, this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final controller = this.controller ?? Get.find<TaskEditorController>();
//     return Form(
//       key: controller.formKey,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           TextFormField(
//             controller: controller.titleController,
//             style: Theme.of(context).textTheme.bodyLarge,
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
//             controller: controller.descriptionController,
//             maxLines: 4,
//             style: Theme.of(context).textTheme.bodyLarge,
//             decoration: InputDecoration(
//               labelText: LocalKeys.taskDescription.tr,
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Obx(
//             () => DropdownButtonFormField<TaskStatus>(
//               style: Theme.of(context).textTheme.bodyLarge,
//               dropdownColor: Theme.of(context).colorScheme.surface,
//               items: TaskStatus.values
//                   .map(
//                     (s) => DropdownMenuItem(
//                       value: s,
//                       child: Text(
//                         HelperFunctionsUtils.getStatusDisplayName(s),
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                     ),
//                   )
//                   .toList(),
//               value: controller.selectedStatus.value,
//               onChanged: (val) {
//                 if (val != null) controller.selectedStatus.value = val;
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: LocalKeys.taskStatus.tr,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Obx(
//             () => DropdownButtonFormField<int>(
//               style: Theme.of(context).textTheme.bodyLarge,
//               dropdownColor: Theme.of(context).colorScheme.surface,
//               value: controller.selectedPriority.value,
//               items: [
//                 DropdownMenuItem(
//                   value: 1,
//                   child: Text(
//                     LocalKeys.high.tr,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ),
//                 DropdownMenuItem(
//                   value: 2,
//                   child: Text(
//                     LocalKeys.medium.tr,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ),
//                 DropdownMenuItem(
//                   value: 3,
//                   child: Text(
//                     LocalKeys.low.tr,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ),
//               ],
//               onChanged: (val) {
//                 if (val != null) controller.selectedPriority.value = val;
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: LocalKeys.priority.tr,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Obx(
//             () => DateTimePicker(
//               key: Key('task_due_date'),
//               label: LocalKeys.dueDate.tr,
//               placeholder: LocalKeys.selectDueDate.tr,
//               mode: DateTimePickerMode.dateTime,
//               initialDateTime: controller.dueDate.value,
//               minDate: DateTime.now(),
//               maxDate: DateTime.now().add(Duration(days: 365)),
//               onSelected: (dateTime) {
//                 controller.setDueDate(dateTime);
//               },
//               prefixIcon: Icons.schedule,
//               helperText: LocalKeys.chooseWhenThisTaskShouldBeCompleted.tr,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
