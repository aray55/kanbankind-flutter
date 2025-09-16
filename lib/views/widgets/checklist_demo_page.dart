// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/themes/app_colors.dart';
// import 'checklist_widget.dart';
// import 'add_checklist_item_widget.dart';

// /// Demo page showing how to use all the checklist widgets
// class ChecklistDemoPage extends StatelessWidget {
//   final int taskId;

//   const ChecklistDemoPage({
//     Key? key,
//     required this.taskId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checklist Demo'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Main checklist widget
//             Text(
//               'Full Checklist Widget',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             ChecklistWidget(
//               taskId: taskId,
//               showProgress: true,
//               showActions: true,
//               isEditable: true,
//               header: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.checklist_rtl,
//                       color: AppColors.primary,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Task Checklist',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 32),
            
//             // Compact checklist widget
//             Text(
//               'Compact Checklist Widget',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.outline.withOpacity(0.2),
//                 ),
//               ),
//               child: CompactChecklistWidget(
//                 taskId: taskId,
//                 maxItems: 3,
//                 onViewAll: () {
//                   Get.snackbar(
//                     'View All',
//                     'This would navigate to the full checklist view',
//                     backgroundColor: AppColors.primary,
//                     colorText: AppColors.white,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       // Quick add floating action button
//       floatingActionButton: QuickAddChecklistItemButton(
//         taskId: taskId,
//         onPressed: () {
//           Get.snackbar(
//             'Item Added',
//             'Checklist item has been added successfully',
//             backgroundColor: AppColors.primary,
//             colorText: AppColors.white,
//           );
//         },
//       ),
//     );
//   }
// }
