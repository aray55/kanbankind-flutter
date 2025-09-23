import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_item_model.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../responsive_text.dart';

class AddEditChecklistItemModal extends StatefulWidget {
  final int checklistId;
  final ChecklistItemModel? item;

  const AddEditChecklistItemModal({
    Key? key,
    required this.checklistId,
    this.item,
  }) : super(key: key);

  bool get isEditing => item != null;

  // Static method to show the modal
  static Future<void> show(
    BuildContext context, {
    required int checklistId,
    ChecklistItemModel? item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditChecklistItemModal(
        checklistId: checklistId,
        item: item,
      ),
    );
  }

  @override
  State<AddEditChecklistItemModal> createState() => _AddEditChecklistItemModalState();
}

class _AddEditChecklistItemModalState extends State<AddEditChecklistItemModal> {
  late final TextEditingController _titleController;
  late final FocusNode _titleFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _titleFocusNode = FocusNode();

    // Auto-focus for new items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isEditing) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = Get.put(ChecklistItemController(), permanent: false);
      final title = _titleController.text.trim();

      if (widget.isEditing) {
        // Update existing item
        await controller.updateItemTitle(widget.item!.id!, title);
      } else {
        // Create new item
        await controller.createChecklistItem(
          checklistId: widget.checklistId,
          title: title,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling is done in the controller
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Form
              _buildForm(),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.isEditing ? Icons.edit : Icons.add,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                widget.isEditing
                    ? LocalKeys.editChecklistItem.tr
                    : LocalKeys.addChecklistItem.tr,
                variant: AppTextVariant.h2,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              AppText(
                widget.isEditing
                    ? LocalKeys.editChecklistItem.tr
                    : LocalKeys.addChecklistItem.tr,
                variant: AppTextVariant.body,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            LocalKeys.itemTitle.tr,
            variant: AppTextVariant.body,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: InputDecoration(
              hintText: LocalKeys.enterItemTitle.tr,
              prefixIcon: Icon(
                Icons.check_box_outline_blank,
                color: Theme.of(context).colorScheme.primary,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            maxLines: 3,
            minLines: 1,
            maxLength: 255,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return LocalKeys.itemTitleRequired.tr;
              }
              if (value.trim().length > 255) {
                return LocalKeys.itemTitleTooLong.tr;
              }
              return null;
            },
            onFieldSubmitted: (_) => _saveItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: AppText(
              LocalKeys.cancel.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _isLoading ? null : _saveItem,
            child: AppText(
              widget.isEditing ? LocalKeys.update.tr : LocalKeys.add.tr,
              variant: AppTextVariant.button,
            ),
          ),
        ),
      ],
    );
  }
}
