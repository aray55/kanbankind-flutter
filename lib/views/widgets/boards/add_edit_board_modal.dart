import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../../../../controllers/board_controller.dart';
import '../../../../models/board_model.dart';
import '../color_picker_widget.dart';
import '../responsive_text.dart';

class AddEditBoardModal extends StatefulWidget {
  final Board? board;

  const AddEditBoardModal({super.key, this.board});

  @override
  State<AddEditBoardModal> createState() => _AddEditBoardModalState();
}

class _AddEditBoardModalState extends State<AddEditBoardModal> {
  final _formKey = GlobalKey<FormState>();
  late final BoardController _boardController;
  bool _isKeyboardVisible = false;

  bool get isEditing => widget.board != null;

  @override
  void initState() {
    super.initState();
    _boardController = Get.find<BoardController>();

    // If editing, populate form with existing data
    if (isEditing) {
      _boardController.populateFormFromBoard(widget.board!);
    } else {
      _boardController.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = keyboardHeight > 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context),

          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                _isKeyboardVisible ? 16 : 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Board title field
                    _buildTitleField(context),

                    const SizedBox(height: 20),

                    // Board description field
                    _buildDescriptionField(context),

                    const SizedBox(height: 20),

                    // Color picker section
                    _buildColorSection(context),

                    const SizedBox(height: 32),

                    // Action buttons
                    _buildActionButtons(context),

                    // Add bottom padding for keyboard
                    if (_isKeyboardVisible) SizedBox(height: keyboardHeight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.dashboard_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  isEditing
                      ? LocalKeys.editBoard.tr
                      : LocalKeys.createNewBoard.tr,
                  variant: AppTextVariant.h2,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                AppText(
                  isEditing
                      ? LocalKeys.updateBoardSettings.tr
                      : LocalKeys.setUpNewBoard.tr,
                  variant: AppTextVariant.body,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          LocalKeys.boardName.tr,
          variant: AppTextVariant.body,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _boardController.titleController,
          decoration: InputDecoration(
            hintText: LocalKeys.enterBoardName.tr,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocalKeys.pleaseEnterBoardName.tr;
            }
            if (value.trim().length > 255) {
              return LocalKeys.boardNameTooLong.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          LocalKeys.descriptionOptional.tr,
          variant: AppTextVariant.body,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _boardController.descriptionController,
          decoration: InputDecoration(
            hintText: LocalKeys.describeBoardPurpose.tr,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildColorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          LocalKeys.boardColor.tr,
          variant: AppTextVariant.body,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        ColorPickerWidget(
          selectedColor: _boardController.selectedColor,
          onColorSelected: (color) {
            _boardController.setSelectedColor(color);
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(() {
      final isLoading = isEditing
          ? _boardController.isUpdating
          : _boardController.isCreating;

      return Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: AppText(
                LocalKeys.cancel.tr,
                variant: AppTextVariant.button,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Save button
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isLoading ? null : _handleSave,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : AppText(
                      isEditing ? LocalKeys.update.tr : LocalKeys.create.tr,
                      variant: AppTextVariant.button,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (isEditing) {
        await _boardController.updateBoardFromForm();
      } else {
        await _boardController.createBoardFromForm();
      }

      // Close modal on success
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling is done in the controller
    }
  }
}
