// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/localization/local_keys.dart';
// import 'package:kanbankit/views/widgets/responsive_text.dart';
// import '../../controllers/checklist_controller.dart';
// import '../../core/themes/app_colors.dart';

// class AddChecklistItemWidget extends StatefulWidget {
//   final int taskId;
//   final ChecklistController? controller;
//   final String? hintText;
//   final bool autoFocus;
//   final VoidCallback? onItemAdded;

//   const AddChecklistItemWidget({
//     Key? key,
//     required this.taskId,
//     this.controller,
//     this.hintText,
//     this.autoFocus = false,
//     this.onItemAdded,
//   }) : super(key: key);

//   @override
//   State<AddChecklistItemWidget> createState() => _AddChecklistItemWidgetState();
// }

// class _AddChecklistItemWidgetState extends State<AddChecklistItemWidget> {
//   late TextEditingController _textController;
//   late FocusNode _focusNode;
//   bool _isExpanded = false;
//   bool _isMultiline = false;

//   ChecklistController get _controller =>
//       widget.controller ?? Get.find<ChecklistController>();

//   @override
//   void initState() {
//     super.initState();
//     _textController = TextEditingController();
//     _focusNode = FocusNode();

//     if (widget.autoFocus) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _focusNode.requestFocus();
//       });
//     }

//     _focusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _onFocusChange() {
//     if (_focusNode.hasFocus && !_isExpanded) {
//       setState(() {
//         _isExpanded = true;
//       });
//     } else if (!_focusNode.hasFocus &&
//         _textController.text.isEmpty &&
//         _isExpanded) {
//       setState(() {
//         _isExpanded = false;
//       });
//     }
//   }

//   void _addItem() async {
//     final title = _textController.text.trim();
//     if (title.isEmpty) return;

//     await _controller.createChecklistItem(taskId: widget.taskId, title: title);

//     _textController.clear();
//     if (widget.onItemAdded != null) {
//       widget.onItemAdded!();
//     }

//     // Keep focus for quick adding
//     _focusNode.requestFocus();
//   }

//   void _addMultipleItems() async {
//     final text = _textController.text.trim();
//     if (text.isEmpty) return;

//     // Split by new lines and filter empty lines
//     final titles = text
//         .split('\n')
//         .map((line) => line.trim())
//         .where((line) => line.isNotEmpty)
//         .toList();

//     if (titles.isEmpty) return;

//     if (titles.length == 1) {
//       _addItem();
//       return;
//     }

//     await _controller.createMultipleItems(
//       taskId: widget.taskId,
//       titles: titles,
//     );

//     _textController.clear();
//     setState(() {
//       _isMultiline = false;
//       _isExpanded = false;
//     });

//     if (widget.onItemAdded != null) {
//       widget.onItemAdded!();
//     }
//   }

//   void _toggleMultiline() {
//     setState(() {
//       _isMultiline = !_isMultiline;
//     });

//     if (_isMultiline) {
//       _focusNode.requestFocus();
//     }
//   }

//   void _cancel() {
//     _textController.clear();
//     setState(() {
//       _isExpanded = false;
//       _isMultiline = false;
//     });
//     _focusNode.unfocus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       decoration: BoxDecoration(
//         color: _isExpanded
//             ? AppColors.surface
//             : AppColors.surface.withValues(alpha: 0.7),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _isExpanded
//               ? AppColors.primary.withValues(alpha: 0.3)
//               : AppColors.outline.withValues(alpha: 0.2),
//           width: _isExpanded ? 2 : 1,
//         ),
//         boxShadow: _isExpanded
//             ? [
//                 BoxShadow(
//                   color: AppColors.primary.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ]
//             : null,
//       ),
//       child: Column(
//         children: [
//           // Main input area
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 // Add icon
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _isExpanded
//                         ? AppColors.primary
//                         : AppColors.outline.withValues(alpha: 0.3),
//                   ),
//                   child: Icon(
//                     Icons.add,
//                     color: _isExpanded ? AppColors.white : AppColors.onSurface,
//                     size: 16,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // Text input
//                 Expanded(
//                   child: TextField(
//                     controller: _textController,
//                     focusNode: _focusNode,
//                     maxLines: _isMultiline ? null : 1,
//                     minLines: _isMultiline ? 3 : 1,
//                     style: const TextStyle(fontSize: 16),
//                     decoration: InputDecoration(
//                       hintText: _isMultiline
//                           ? LocalKeys.addMultipleItemsHint.tr
//                           : widget.hintText ??
//                                 LocalKeys.addChecklistItemHint.tr,
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     textInputAction: _isMultiline
//                         ? TextInputAction.newline
//                         : TextInputAction.done,
//                     onSubmitted: _isMultiline ? null : (_) => _addItem(),
//                   ),
//                 ),

//                 // Action buttons (when expanded)
//                 if (_isExpanded) ...[
//                   const SizedBox(width: 8),

//                   // Multiline toggle
//                   IconButton(
//                     onPressed: _toggleMultiline,
//                     icon: Icon(
//                       _isMultiline ? Icons.short_text : Icons.notes,
//                       size: 18,
//                       color: _isMultiline
//                           ? AppColors.primary
//                           : AppColors.onSurface.withValues(alpha: 0.6),
//                     ),
//                     padding: const EdgeInsets.all(4),
//                     constraints: const BoxConstraints(
//                       minWidth: 32,
//                       minHeight: 32,
//                     ),
//                     tooltip: _isMultiline
//                         ? LocalKeys.singleLine.tr
//                         : LocalKeys.multipleLines.tr,
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // Action buttons (when expanded)
//           if (_isExpanded)
//             Container(
//               padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // Cancel button
//                   TextButton(
//                     onPressed: _cancel,
//                     child: AppText(
//                       LocalKeys.cancel.tr,
//                       variant: AppTextVariant.button,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.onSurface.withValues(alpha: 0.6),
//                     ),
//                   ),

//                   const SizedBox(width: 8),

//                   // Add button
//                   Obx(
//                     () => ElevatedButton(
//                       onPressed: _controller.isCreating
//                           ? null
//                           : (_isMultiline ? _addMultipleItems : _addItem),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: AppColors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                       ),
//                       child: _controller.isCreating
//                           ? const SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   AppColors.white,
//                                 ),
//                               ),
//                             )
//                           : AppText(
//                               _isMultiline
//                                   ? LocalKeys.addItems.tr
//                                   : LocalKeys.addItem.tr,
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Quick add button for floating action
// class QuickAddChecklistItemButton extends StatelessWidget {
//   final int taskId;
//   final VoidCallback? onPressed;

//   const QuickAddChecklistItemButton({
//     Key? key,
//     required this.taskId,
//     this.onPressed,
//   }) : super(key: key);

//   void _showAddDialog(BuildContext context) {
//     final textController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AppText(LocalKeys.addItem.tr),
//         content: TextField(
//           controller: textController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: LocalKeys.addItem.tr,
//             border: OutlineInputBorder(),
//           ),
//           onSubmitted: (value) {
//             if (value.trim().isNotEmpty) {
//               Navigator.of(context).pop(value.trim());
//             }
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: AppText(LocalKeys.cancel.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final title = textController.text.trim();
//               if (title.isNotEmpty) {
//                 Navigator.of(context).pop(title);
//               }
//             },
//             child: AppText(LocalKeys.add.tr),
//           ),
//         ],
//       ),
//     ).then((title) {
//       if (title != null) {
//         final controller = Get.find<ChecklistController>();
//         controller.createChecklistItem(taskId: taskId, title: title);
//         if (onPressed != null) onPressed!();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () => _showAddDialog(context),
//       backgroundColor: AppColors.primary,
//       child: AppText(
//         LocalKeys.addItem.tr,
//         variant: AppTextVariant.button,
//         fontWeight: FontWeight.w500,
//         color: AppColors.white,
//       ),
//     );
//   }
// }
