// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/views/widgets/responsive_text.dart';
// import '../../controllers/checklist_controller.dart';
// import '../../core/localization/local_keys.dart';
// import '../../core/themes/app_colors.dart';
// import '../../models/checklist_item_model.dart';
// import '../components/text_buttons/app_text_button.dart';
// import '../components/text_buttons/button_variant.dart';
// import 'checklist_item_widget.dart';
// import 'add_checklist_item_widget.dart';
// import 'checklist_progress_widget.dart';
// import 'checklist_actions_widget.dart';

// class ChecklistWidget extends StatelessWidget {
//   final int taskId;
//   final bool showProgress;
//   final bool showActions;
//   final bool isEditable;
//   final String? emptyMessage;
//   final Widget? header;

//   const ChecklistWidget({
//     Key? key,
//     required this.taskId,
//     this.showProgress = true,
//     this.showActions = true,
//     this.isEditable = true,
//     this.emptyMessage,
//     this.header,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<ChecklistController>();

//     // Load checklist items if not already loaded for this task
//     if (controller.currentTaskId != taskId) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         controller.loadChecklistItems(taskId);
//       });
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         if (header != null) ...[header!, const SizedBox(height: 16)],

//         // Progress indicator
//         if (showProgress)
//           Obx(
//             () => controller.hasItems
//                 ? ChecklistProgressWidget(
//                     progress: controller.progress,
//                     totalItems: controller.totalItems,
//                     completedItems: controller.completedItems,
//                   )
//                 : const SizedBox.shrink(),
//           ),

//         // Actions bar
//         if (showActions)
//           Obx(
//             () => controller.hasItems
//                 ? ChecklistActionsWidget(
//                     controller: controller,
//                     isEditable: isEditable,
//                   )
//                 : const SizedBox.shrink(),
//           ),

//         // Add new item widget
//         if (isEditable)
//           AddChecklistItemWidget(taskId: taskId, controller: controller),

//         const SizedBox(height: 8),

//         // Checklist items
//         Obx(() {
//           if (controller.isLoading) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(32),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           final items = controller.filteredItems;

//           if (items.isEmpty) {
//             return Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: AppColors.surface.withValues(alpha: 0.5),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.outline.withValues(alpha: 0.2),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.checklist_outlined,
//                     size: 48,
//                   ),
//                   const SizedBox(height: 16),
//                   AppText(
//                     emptyMessage ?? LocalKeys.noChecklistItems.tr,
//                     variant: AppTextVariant.body,
//                     textAlign: TextAlign.center,
//                   ),
//                   if (isEditable) ...[
//                     const SizedBox(height: 8),
//                     AppText(
//                       LocalKeys.addItemsAboveToCreateChecklist.tr,
//                       variant: AppTextVariant.body,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }

//           return ReorderableListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: items.length,
//             onReorder: isEditable
//                 ? (int oldIndex, int newIndex) {
//                     if (newIndex > oldIndex) newIndex--;

//                     final reorderedItems = List<ChecklistItem>.from(items);
//                     final item = reorderedItems.removeAt(oldIndex);
//                     reorderedItems.insert(newIndex, item);

//                     // Update positions
//                     for (int i = 0; i < reorderedItems.length; i++) {
//                       reorderedItems[i] = reorderedItems[i].copyWith(
//                         position: i,
//                       );
//                     }

//                     controller.reorderItems(reorderedItems);
//                   }
//                 : (int oldIndex, int newIndex) {},
//             itemBuilder: (context, index) {
//               final item = items[index];

//               return ChecklistItemWidget(
//                 key: ValueKey(item.id),
//                 item: item,
//                 isEditable: isEditable,
//                 showActions: true,
//               );
//             },
//           );
//         }),

//         // Loading indicator for operations
//         Obx(() {
//           if (controller.isCreating || controller.isUpdating) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                   const SizedBox(width: 12),
//                   AppText(
//                     controller.isCreating
//                         ? LocalKeys.addingItem.tr
//                         : LocalKeys.updating.tr,
//                     variant: AppTextVariant.body,
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         }),

//         // Loading indicator for operations
//         Obx(() {
//           if (controller.isCreating || controller.isUpdating) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                   const SizedBox(width: 12),
//                   AppText(
//                     controller.isCreating
//                         ? LocalKeys.addingItem.tr
//                         : LocalKeys.updating.tr,
//                     variant: AppTextVariant.body,
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         }),
//       ],
//     );
//   }
// }

// // Compact version for smaller spaces
// class CompactChecklistWidget extends StatelessWidget {
//   final int taskId;
//   final int? maxItems;
//   final VoidCallback? onViewAll;

//   const CompactChecklistWidget({
//     Key? key,
//     required this.taskId,
//     this.maxItems = 3,
//     this.onViewAll,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ChecklistController>(
//       init: ChecklistController(),
//       builder: (controller) {
//         if (controller.currentTaskId != taskId) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             controller.loadChecklistItems(taskId);
//           });
//         }

//         return Obx(() {
//           if (controller.isLoading) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           final items = controller.checklistItems;
//           if (items.isEmpty) {
//             return const SizedBox.shrink();
//           }

//           final displayItems = maxItems != null && items.length > maxItems!
//               ? items.take(maxItems!).toList()
//               : items;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Progress bar
//               if (controller.hasItems)
//                 ChecklistProgressWidget(
//                   progress: controller.progress,
//                   totalItems: controller.totalItems,
//                   completedItems: controller.completedItems,
//                   compact: true,
//                 ),

//               const SizedBox(height: 8),

//               // Items
//               ...displayItems.map(
//                 (item) => ChecklistItemWidget(
//                   key: ValueKey(item.id),
//                   item: item,
//                   isEditable: false,
//                   showActions: false,
//                 ),
//               ),

//               // View all button
//               if (maxItems != null && items.length > maxItems!)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: AppTextButton(
//                     onPressed: onViewAll,
//                     label: '${LocalKeys.viewAll.tr}${items.length} ${LocalKeys.items.tr}',
//                     variant: AppButtonVariant.primary,
//                   ),
//                 ),
//             ],
//           );
//         });
//       },
//     );
//   }
// }
