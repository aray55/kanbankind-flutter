// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:kanbankit/core/localization/local_keys.dart';
// import 'package:kanbankit/views/components/icon_buttons/app_icon_button.dart';
// import 'package:kanbankit/views/widgets/responsive_text.dart';
// import '../../models/checklist_item_model.dart';
// import '../../controllers/checklist_controller.dart';
// import '../components/icon_buttons/icon_button_style.dart';

// class ChecklistItemWidget extends StatefulWidget {
//   final ChecklistItem item;
//   final VoidCallback? onToggle;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//   final bool isEditable;
//   final bool showActions;

//   const ChecklistItemWidget({
//     Key? key,
//     required this.item,
//     this.onToggle,
//     this.onEdit,
//     this.onDelete,
//     this.isEditable = true,
//     this.showActions = true,
//   }) : super(key: key);

//   @override
//   State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
// }

// class _ChecklistItemWidgetState extends State<ChecklistItemWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<Color?> _colorAnimation;

//   bool _isEditing = false;
//   bool _isHovered = false;
//   bool _hasError = false;
//   String? _errorMessage;
//   late TextEditingController _textController;
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );

//     _fadeAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _textController = TextEditingController(text: widget.item.title);
//     _focusNode = FocusNode();

//     // Add listeners for better UX
//     _focusNode.addListener(_onFocusChanged);
//     _textController.addListener(_onTextChanged);

//     if (widget.item.isDone) {
//       _animationController.forward();
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Initialize color animation here where Theme.of(context) is available
//     _colorAnimation =
//         ColorTween(
//           begin: Theme.of(context).colorScheme.surface,
//           end: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
//         ).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeInOut,
//           ),
//         );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _focusNode.removeListener(_onFocusChanged);
//     _textController.removeListener(_onTextChanged);
//     _textController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _onFocusChanged() {
//     if (!_focusNode.hasFocus && _isEditing) {
//       _saveEdit();
//     }
//   }

//   void _onTextChanged() {
//     // Clear error when user starts typing
//     if (_hasError && _textController.text.trim().isNotEmpty) {
//       setState(() {
//         _hasError = false;
//         _errorMessage = null;
//       });
//     }
//   }

//   @override
//   void didUpdateWidget(ChecklistItemWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.item.isDone != widget.item.isDone) {
//       if (widget.item.isDone) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     }

//     if (oldWidget.item.title != widget.item.title) {
//       _textController.text = widget.item.title;
//     }
//   }

//   void _toggleCompletion() {
//     // Provide immediate visual feedback
//     HapticFeedback.selectionClick();

//     if (widget.onToggle != null) {
//       widget.onToggle!();
//     } else {
//       final controller = Get.find<ChecklistController>();
//       controller.toggleItemCompletion(widget.item.id!);
//     }
//   }

//   void _startEditing() {
//     if (!widget.isEditable) return;

//     setState(() {
//       _isEditing = true;
//       _hasError = false;
//       _errorMessage = null;
//     });

//     // Provide haptic feedback
//     HapticFeedback.lightImpact();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//       _textController.selection = TextSelection(
//         baseOffset: 0,
//         extentOffset: _textController.text.length,
//       );
//     });
//   }

//   void _saveEdit() {
//     final newTitle = _textController.text.trim();

//     // Validate input
//     if (newTitle.isEmpty) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = LocalKeys.itemTitleEmpty.tr;
//       });

//       // Shake animation for error feedback
//       _animationController.forward().then((_) {
//         _animationController.reverse();
//       });

//       HapticFeedback.mediumImpact();
//       return;
//     }

//     // Only save if content actually changed
//     if (newTitle != widget.item.title) {
//       try {
//         final controller = Get.find<ChecklistController>();
//         controller.updateItemTitle(widget.item.id!, newTitle);

//         // Success feedback
//         HapticFeedback.selectionClick();

//         // Show success snackbar briefly
//         Get.showSnackbar(
//           GetSnackBar(
//             message: LocalKeys.saveChanges.tr,
//             duration: const Duration(seconds: 1),
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             snackPosition: SnackPosition.BOTTOM,
//             margin: const EdgeInsets.all(8),
//             borderRadius: 8,
//           ),
//         );
//       } catch (e) {
//         // Handle save error
//         setState(() {
//           _hasError = true;
//           _errorMessage = 'Error saving changes';
//         });
//         return;
//       }
//     }

//     _cancelEdit();
//   }

//   void _cancelEdit() {
//     setState(() {
//       _isEditing = false;
//       _hasError = false;
//       _errorMessage = null;
//     });
//     _textController.text = widget.item.title;
//   }

//   void _deleteItem() {
//     // Show confirmation dialog for better UX
//     Get.dialog(
//       AlertDialog(
//         title: AppText(LocalKeys.deleteItem.tr, variant: AppTextVariant.h2),
//         content: AppText(
//           '${LocalKeys.areYouSureDelete.tr} "${widget.item.title}"?',
//           variant: AppTextVariant.body,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: AppText(
//               LocalKeys.cancel.tr,
//               variant: AppTextVariant.button,
//               color: Theme.of(
//                 context,
//               ).colorScheme.onSurface.withValues(alpha: 0.7),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();

//               // Perform delete with haptic feedback
//               HapticFeedback.mediumImpact();

//               if (widget.onDelete != null) {
//                 widget.onDelete!();
//               } else {
//                 final controller = Get.find<ChecklistController>();
//                 controller.deleteItem(widget.item.id!);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.error,
//               foregroundColor: Theme.of(context).colorScheme.onError,
//             ),
//             child: AppText(
//               LocalKeys.delete.tr,
//               variant: AppTextVariant.button,
//               color: Theme.of(context).colorScheme.onError,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//               decoration: BoxDecoration(
//                 gradient: widget.item.isDone
//                     ? LinearGradient(
//                         colors: [
//                           colorScheme.primary.withValues(alpha: 0.1),
//                           colorScheme.surface.withValues(alpha: 0.8),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : LinearGradient(
//                         colors: [
//                           colorScheme.surface,
//                           colorScheme.surface.withValues(alpha: 0.9),
//                         ],
//                       ),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: _hasError
//                       ? colorScheme.error
//                       : widget.item.isDone
//                       ? colorScheme.primary.withValues(alpha: 0.4)
//                       : colorScheme.outline.withValues(alpha: 0.3),
//                   width: _hasError ? 2 : 1,
//                 ),
//                 boxShadow: [
//                   if (!widget.item.isDone && !_hasError)
//                     BoxShadow(
//                       color: isDarkMode
//                           ? Colors.black.withValues(alpha: 0.3)
//                           : Colors.black.withValues(alpha: 0.08),
//                       blurRadius: isDarkMode ? 12 : 8,
//                       offset: const Offset(0, 3),
//                       spreadRadius: 0,
//                     ),
//                   if (_isHovered)
//                     BoxShadow(
//                       color: colorScheme.primary.withValues(alpha: 0.2),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: MouseRegion(
//                   onEnter: (_) => setState(() => _isHovered = true),
//                   onExit: (_) => setState(() => _isHovered = false),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(16),
//                     onTap: _isEditing ? null : _toggleCompletion,
//                     onLongPress: widget.isEditable && !_isEditing
//                         ? _startEditing
//                         : null,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               // Enhanced Checkbox with animation
//                               _buildAnimatedCheckbox(),

//                               const SizedBox(width: 16),

//                               // Title with enhanced styling
//                               Expanded(child: _buildTitleWidget()),

//                               // Action buttons with better spacing
//                               if (widget.showActions && !_isEditing) ...[
//                                 const SizedBox(width: 8),
//                                 _buildActionButtons(),
//                               ],

//                               // Edit mode buttons
//                               if (_isEditing) ...[
//                                 const SizedBox(width: 8),
//                                 _buildEditModeButtons(),
//                               ],
//                             ],
//                           ),

//                           // Error message with slide animation
//                           if (_hasError && _errorMessage != null)
//                             _buildErrorMessage(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Helper method to build animated checkbox
//   Widget _buildAnimatedCheckbox() {
//     return GestureDetector(
//       onTap: _toggleCompletion,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 26,
//         height: 26,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: widget.item.isDone
//               ? Theme.of(context).colorScheme.primary
//               : Colors.transparent,
//           border: Border.all(
//             color: widget.item.isDone
//                 ? Theme.of(context).colorScheme.primary
//                 : Theme.of(context).colorScheme.outline,
//             width: 2.5,
//           ),
//           boxShadow: [
//             if (widget.item.isDone)
//               BoxShadow(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.primary.withValues(alpha: 0.3),
//                 blurRadius: 8,
//                 spreadRadius: 1,
//               ),
//           ],
//         ),
//         child: widget.item.isDone
//             ? Icon(
//                 Icons.check,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 18,
//               )
//             : null,
//       ),
//     );
//   }

//   // Helper method to build title widget
//   Widget _buildTitleWidget() {
//     if (_isEditing) {
//       return Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: _hasError
//                 ? Theme.of(context).colorScheme.error
//                 : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
//             width: 1,
//           ),
//         ),
//         child: TextField(
//           controller: _textController,
//           focusNode: _focusNode,

//           decoration: InputDecoration(
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             hintText: LocalKeys.editItem.tr,
//             hintStyle: TextStyle(
//               color: Theme.of(
//                 context,
//               ).colorScheme.onSurface.withValues(alpha: 0.5),
//             ),
//           ),
//           onSubmitted: (_) => _saveEdit(),
//           onEditingComplete: _saveEdit,
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           widget.item.title,
//           variant: AppTextVariant.body,
//           fontWeight: widget.item.isDone ? FontWeight.w400 : FontWeight.w500,
//           color: widget.item.isDone
//               ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
//               : Theme.of(context).colorScheme.onSurface,
//           maxLines: 3,
//           overflow: TextOverflow.ellipsis,
//         ),
//         if (!_isEditing && widget.isEditable)
//           Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: AppText(
//               LocalKeys.longPressToEdit.tr,
//               variant: AppTextVariant.small,
//               color: Theme.of(
//                 context,
//               ).colorScheme.onSurface.withValues(alpha: 0.4),
//             ),
//           ),
//       ],
//     );
//   }

//   // Helper method to build action buttons
//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Edit button
//         if (widget.isEditable)
//           Tooltip(
//             message: LocalKeys.editItem.tr,
//             child: AppIconButton(
//               style: AppIconButtonStyle.plain,
//               onPressed: _startEditing,
//               child: Icon(
//                 Icons.edit_outlined,
//                 size: 20,
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.primary.withValues(alpha: 0.7),
//               ),
//             ),
//           ),

//         const SizedBox(width: 4),

//         // Delete button
//         Tooltip(
//           message: LocalKeys.deleteItem.tr,
//           child: AppIconButton(
//             style: AppIconButtonStyle.plain,
//             onPressed: _deleteItem,
//             child: Icon(
//               Icons.delete_outline,
//               size: 20,
//               color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper method to build edit mode buttons
//   Widget _buildEditModeButtons() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Save button
//         Tooltip(
//           message: LocalKeys.saveChanges.tr,
//           child: AppIconButton(
//             style: AppIconButtonStyle.plain,
//             onPressed: _saveEdit,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.primary.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.check,
//                 size: 18,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(width: 4),

//         // Cancel button
//         Tooltip(
//           message: LocalKeys.discardChanges.tr,
//           child: AppIconButton(
//             style: AppIconButtonStyle.plain,
//             onPressed: _cancelEdit,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.error.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.close,
//                 size: 18,
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.error.withValues(alpha: 0.8),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper method to build error message
//   Widget _buildErrorMessage() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 16,
//             color: Theme.of(context).colorScheme.error,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: AppText(
//               _errorMessage!,
//               variant: AppTextVariant.small,
//               color: Theme.of(context).colorScheme.error,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
