import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../../../controllers/list_controller.dart';
import '../../../models/list_model.dart';
import '../color_picker_widget.dart';
import '../responsive_text.dart';

class AddEditListModal extends StatefulWidget {
  final ListModel? list;
  final int boardId;

  const AddEditListModal({
    super.key,
    this.list,
    required this.boardId,
  });

  @override
  State<AddEditListModal> createState() => _AddEditListModalState();

  // Static method to show the modal
  static Future<void> show(
    BuildContext context, {
    ListModel? list,
    required int boardId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditListModal(
        list: list,
        boardId: boardId,
      ),
    );
  }
}

class _AddEditListModalState extends State<AddEditListModal> {
  final _formKey = GlobalKey<FormState>();
  late final ListController _listController;
  bool _isKeyboardVisible = false;

  bool get isEditing => widget.list != null;

  @override
  void initState() {
    super.initState();
    _listController = Get.find<ListController>();

    // If editing, populate form with existing data
    if (isEditing) {
      _listController.populateFormFromList(widget.list!);
    } else {
      _listController.clearForm();
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
                    // List title field
                    _buildTitleField(context),

                    const SizedBox(height: 20),

                    // Color picker section
                    _buildColorSection(context),

                    const SizedBox(height: 32),

                    // Action buttons
                    _buildActionButtons(context),

                    // Add bottom padding for keyboard
                    if (_isKeyboardVisible) const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isEditing ? 'Edit List' : 'Create New List',
                      variant: AppTextVariant.h2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      isEditing
                          ? 'Update list settings'
                          : 'Set up a new list for your board',
                      variant: AppTextVariant.body2,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
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
          'List Name',
          variant: AppTextVariant.body2,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _listController.titleController,
          decoration: InputDecoration(
            hintText: 'Enter list name',
            prefixIcon: Icon(
              Icons.view_column,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocalKeys.pleaseEnterTitle.tr;
            }
            if (value.trim().length > 255) {
              return 'List name must be 255 characters or less';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
          maxLength: 255,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AppText(
                '$currentLength/${maxLength ?? 255}',
                variant: AppTextVariant.body2,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
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
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        Obx(() => ColorPickerWidget(
              selectedColor: _listController.selectedColor,
              onColorSelected: _listController.setSelectedColor,
            )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(() {
      final isLoading = _listController.isCreating || _listController.isUpdating;

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
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: AppText(
                LocalKeys.cancel.tr,
                variant: AppTextVariant.body,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Create/Update button
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      variant: AppTextVariant.body,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
            ),
          ),
        ],
      );
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEditing) {
        await _listController.updateListFromForm();
      } else {
        await _listController.createListFromForm(widget.boardId);
      }
      
      // Close modal on success
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling is done in the controller
      // The controller will show appropriate error messages
    }
  }
}
