import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/checklists_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_model.dart';
import '../../components/text_buttons/app_text_button.dart';
import '../../components/text_buttons/button_variant.dart';
import '../responsive_text.dart';

class AddEditChecklistModal extends StatefulWidget {
  final int cardId;
  final ChecklistModel? checklist; // null for add, non-null for edit
  final VoidCallback? onSaved;

  const AddEditChecklistModal({
    Key? key,
    required this.cardId,
    this.checklist,
    this.onSaved,
  }) : super(key: key);

  @override
  State<AddEditChecklistModal> createState() => _AddEditChecklistModalState();
}

class _AddEditChecklistModalState extends State<AddEditChecklistModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();

  bool get isEditing => widget.checklist != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.checklist!.title;
    }

    // Auto-focus the title field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(context),

                const SizedBox(height: 24),

                // Title Field
                _buildTitleField(context),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          isEditing ? LocalKeys.editChecklist.tr : LocalKeys.addChecklist.tr,
          variant: AppTextVariant.h2,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(LocalKeys.checklistName.tr, variant: AppTextVariant.body2),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          decoration: InputDecoration(
            hintText: LocalKeys.enterChecklistTitle.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon: const Icon(Icons.checklist_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocalKeys.checklistTitleRequired.tr;
            }
            if (value.trim().length > 255) {
              return LocalKeys.checklistTitleTooLong.tr;
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) =>
              _saveChecklist(context, Get.find<ChecklistsController>()),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ChecklistsController controller,
  ) {
    return Obx(() {
      final isLoading = controller.isCreating || controller.isUpdating;

      return Row(
        children: [
          // Cancel Button
          Expanded(
            child: AppTextButton(
              label: LocalKeys.cancel.tr,
              variant: AppButtonVariant.secondary,
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            ),
          ),

          const SizedBox(width: 16),

          // Save Button
          Expanded(
            child: AppTextButton(
              label: isEditing ? LocalKeys.update.tr : LocalKeys.create.tr,
              variant: AppButtonVariant.primary,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => _saveChecklist(context, controller),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _saveChecklist(
    BuildContext context,
    ChecklistsController controller,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    try {
      if (isEditing) {
        // Update existing checklist
        final updatedChecklist = widget.checklist!.copyWith(title: title);
        await controller.updateChecklist(updatedChecklist);
      } else {
        // Create new checklist
        await controller.createChecklist(cardId: widget.cardId, title: title);
      }

      // Close modal and call callback
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    } catch (e) {
      // Error handling is done in the controller
      // The controller will show appropriate error messages
    }
  }
}

// Compact version for inline use (e.g., inside card creation forms)
class InlineChecklistForm extends StatefulWidget {
  final int cardId;
  final Function(ChecklistModel)? onChecklistAdded;
  final bool showTitle;

  const InlineChecklistForm({
    Key? key,
    required this.cardId,
    this.onChecklistAdded,
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<InlineChecklistForm> createState() => _InlineChecklistFormState();
}

class _InlineChecklistFormState extends State<InlineChecklistForm> {
  final _titleController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    if (!_isExpanded) {
      return AppTextButton(
        label: LocalKeys.addChecklist.tr,
        variant: AppButtonVariant.secondary,
        leadingIcon: Icons.checklist_outlined,
        onPressed: () => setState(() => _isExpanded = true),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            AppText(LocalKeys.addChecklist.tr, variant: AppTextVariant.h2),
            const SizedBox(height: 12),
          ],

          // Title Field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: LocalKeys.enterChecklistTitle.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addChecklist(controller),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppTextButton(
                  label: LocalKeys.cancel.tr,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => setState(() {
                    _isExpanded = false;
                    _titleController.clear();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => AppTextButton(
                    label: LocalKeys.add.tr,
                    variant: AppButtonVariant.primary,
                    isLoading: controller.isCreating,
                    onPressed: controller.isCreating
                        ? null
                        : () => _addChecklist(controller),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addChecklist(ChecklistsController controller) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    try {
      await controller.createChecklist(cardId: widget.cardId, title: title);

      // Reset form
      setState(() {
        _isExpanded = false;
        _titleController.clear();
      });

      // Notify parent if callback provided
      if (widget.onChecklistAdded != null) {
        final newChecklist = ChecklistModel(
          cardId: widget.cardId,
          title: title,
        );
        widget.onChecklistAdded!(newChecklist);
      }
    } catch (e) {
      // Error handling is done in the controller
    }
  }
}
