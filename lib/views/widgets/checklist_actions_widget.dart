// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/localization/local_keys.dart';
// import 'package:kanbankit/views/widgets/responsive_text.dart';
// import '../../controllers/checklist_controller.dart';
// import '../../core/themes/app_colors.dart';

// class ChecklistActionsWidget extends StatelessWidget {
//   final ChecklistController controller;
//   final bool isEditable;
//   final bool showSearch;
//   final bool compact;

//   const ChecklistActionsWidget({
//     Key? key,
//     required this.controller,
//     this.isEditable = true,
//     this.showSearch = true,
//     this.compact = false,
//   }) : super(key: key);

//   void _showClearCompletedDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AppText(LocalKeys.clearCompletedItems.tr),
//         content: AppText(
//           '${LocalKeys.areYouSure.tr} ${LocalKeys.clearCompletedItems.tr} ${controller.completedItems} ${LocalKeys.items.tr}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: AppText(LocalKeys.cancel.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               controller.clearCompletedItems();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             child: AppText(LocalKeys.clear.tr),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showMarkAllDialog(BuildContext context, bool markAsDone) {
//     final action = markAsDone ? 'complete' : 'uncomplete';
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AppText(
//           '${markAsDone ? LocalKeys.completeAllItems.tr : LocalKeys.uncompleteAllItems.tr}',
//         ),
//         content: AppText(
//           '${LocalKeys.areYouSure.tr} ${LocalKeys.markAllItems.tr} ${controller.totalItems} ${LocalKeys.items.tr}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: AppText(LocalKeys.cancel.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               controller.markAllItems(markAsDone);
//             },
//             child: AppText(
//               markAsDone
//                   ? LocalKeys.completeAllItems.tr
//                   : LocalKeys.uncompleteAllItems.tr,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!controller.hasItems) {
//         return const SizedBox.shrink();
//       }

//       return Container(
//         margin: EdgeInsets.symmetric(
//           vertical: compact ? 4 : 8,
//           horizontal: compact ? 4 : 8,
//         ),
//         padding: EdgeInsets.all(compact ? 8 : 12),
//         decoration: BoxDecoration(
//           color: AppColors.surface.withOpacity(0.7),
//           borderRadius: BorderRadius.circular(compact ? 8 : 12),
//           border: Border.all(
//             color: AppColors.outline.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             // Search bar
//             if (showSearch && !compact)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: AppColors.background,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.outline.withOpacity(0.3)),
//                 ),
//                 child: TextField(
//                   onChanged: controller.updateSearchQuery,
//                   decoration: InputDecoration(
//                     hintText: LocalKeys.searchChecklistItems.tr,

//                     prefixIcon: Icon(Icons.search),
//                     suffixIcon: controller.searchQuery.isNotEmpty
//                         ? IconButton(
//                             onPressed: controller.clearSearch,
//                             icon: Icon(Icons.clear),
//                           )
//                         : null,
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ),

//             // Action buttons
//             Row(
//               children: [
//                 // Statistics
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.checklist,
//                           size: compact ? 16 : 18,
//                           color: AppColors.primary,
//                         ),
//                         const SizedBox(width: 6),
//                         AppText(
//                           '${controller.completedItems}/${controller.totalItems}',
//                           variant: AppTextVariant.body,
//                           color: AppColors.primary,
//                         ),
//                         if (!compact) ...[
//                           const SizedBox(width: 4),
//                           AppText(
//                             LocalKeys.completed.tr,
//                             variant: AppTextVariant.body,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),

//                 if (isEditable) ...[
//                   const SizedBox(width: 8),

//                   // Mark all complete/incomplete
//                   PopupMenuButton<String>(
//                     icon: Icon(Icons.more_vert),
//                     onSelected: (value) {
//                       switch (value) {
//                         case 'mark_all_complete':
//                           if (controller.remainingItems > 0) {
//                             _showMarkAllDialog(context, true);
//                           }
//                           break;
//                         case 'mark_all_incomplete':
//                           if (controller.completedItems > 0) {
//                             _showMarkAllDialog(context, false);
//                           }
//                           break;
//                         case 'clear_completed':
//                           if (controller.completedItems > 0) {
//                             _showClearCompletedDialog(context);
//                           }
//                           break;
//                         case 'refresh':
//                           controller.refresh();
//                           break;
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       if (controller.remainingItems > 0)
//                         PopupMenuItem(
//                           value: 'mark_all_complete',
//                           child: Row(
//                             children: [
//                               const Icon(Icons.check_circle_outline),
//                               const SizedBox(width: 12),
//                               Text(
//                                 '${LocalKeys.completeAllItems.tr} (${controller.remainingItems})',
//                               ),
//                             ],
//                           ),
//                         ),

//                       if (controller.completedItems > 0)
//                         PopupMenuItem(
//                           value: 'mark_all_incomplete',
//                           child: Row(
//                             children: [
//                               const Icon(Icons.radio_button_unchecked),
//                               const SizedBox(width: 12),
//                               Text(
//                                 '${LocalKeys.uncompleteAllItems.tr} (${controller.completedItems})',
//                               ),
//                             ],
//                           ),
//                         ),

//                       if (controller.completedItems > 0) ...[
//                         const PopupMenuDivider(),
//                         PopupMenuItem(
//                           value: 'clear_completed',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.delete_outline,
//                                 color: AppColors.error,
//                               ),
//                               const SizedBox(width: 12),
//                               AppText(
//                                 '${LocalKeys.clearCompletedItems.tr} (${controller.completedItems})',
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],

//                       const PopupMenuDivider(),
//                       PopupMenuItem(
//                         value: 'refresh',
//                         child: Row(
//                           children: [
//                             Icon(Icons.refresh),
//                             SizedBox(width: 12),
//                             AppText(LocalKeys.refresh.tr),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),

//             // Quick action chips (compact mode)
//             if (compact &&
//                 isEditable &&
//                 (controller.completedItems > 0 ||
//                     controller.remainingItems > 0))
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Wrap(
//                   spacing: 6,
//                   children: [
//                     if (controller.remainingItems > 0)
//                       ActionChip(
//                         label: AppText(LocalKeys.completeAllItems.tr),
//                         onPressed: () => _showMarkAllDialog(context, true),
//                         backgroundColor: AppColors.primary.withOpacity(0.1),
//                         side: BorderSide(
//                           color: AppColors.primary.withOpacity(0.3),
//                         ),
//                       ),

//                     if (controller.completedItems > 0)
//                       ActionChip(
//                         label: AppText(LocalKeys.clearCompletedItems.tr),
//                         onPressed: () => _showClearCompletedDialog(context),
//                         backgroundColor: AppColors.error.withOpacity(0.1),
//                         side: BorderSide(
//                           color: AppColors.error.withOpacity(0.3),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }
// }

// // Floating action menu for checklist actions
// class ChecklistFloatingActions extends StatelessWidget {
//   final ChecklistController controller;
//   final int taskId;

//   const ChecklistFloatingActions({
//     Key? key,
//     required this.controller,
//     required this.taskId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!controller.hasItems) {
//         return const SizedBox.shrink();
//       }

//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Clear completed
//           if (controller.completedItems > 0)
//             FloatingActionButton(
//               heroTag: "clear_completed",
//               mini: true,
//               onPressed: () => controller.clearCompletedItems(),
//               backgroundColor: AppColors.error,
//               child: const Icon(Icons.clear_all, color: AppColors.white),
//             ),

//           if (controller.completedItems > 0) const SizedBox(height: 8),

//           // Mark all complete
//           if (controller.remainingItems > 0)
//             FloatingActionButton(
//               heroTag: "mark_all_complete",
//               mini: true,
//               onPressed: () => controller.markAllItems(true),
//               backgroundColor: AppColors.primary,
//               child: const Icon(Icons.done_all, color: AppColors.white),
//             ),

//           if (controller.remainingItems > 0) const SizedBox(height: 8),

//           // Add new item
//           FloatingActionButton(
//             heroTag: "add_item",
//             onPressed: () {
//               // This could trigger a bottom sheet or dialog
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 builder: (context) => Padding(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         AppText(LocalKeys.addChecklistItem.tr),
//                         const SizedBox(height: 16),
//                         // Add your AddChecklistItemWidget here
//                         // AddChecklistItemWidget(taskId: taskId, autoFocus: true),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//             backgroundColor: AppColors.primary,
//             child: const Icon(Icons.add, color: AppColors.white),
//           ),
//         ],
//       );
//     });
//   }
// }
