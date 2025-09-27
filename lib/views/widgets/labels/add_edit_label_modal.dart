import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/label_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/label_model.dart';
import '../../../core/utils/color_utils.dart';

enum LabelModalMode { create, edit }

/// Add/Edit Label Modal
/// Purpose: Handles creating or editing a label
/// Responsibilities:
/// - Form fields for title and color
/// - Calls controller methods to save changes
class AddEditLabelModal extends StatefulWidget {
  final int boardId;
  final LabelModalMode mode;
  final LabelModel? existingLabel;

  const AddEditLabelModal({
    Key? key,
    required this.boardId,
    required this.mode,
    this.existingLabel,
  }) : super(key: key);

  @override
  State<AddEditLabelModal> createState() => _AddEditLabelModalState();
}

class _AddEditLabelModalState extends State<AddEditLabelModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  
  Color _selectedColor = ColorUtils.predefinedColors.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.mode == LabelModalMode.edit && widget.existingLabel != null) {
      _nameController.text = widget.existingLabel!.name;
      _selectedColor = ColorUtils.parseColor(widget.existingLabel!.color);
    } else {
      _selectedColor = ColorUtils.getRandomColor();
    }

    // Focus on name field when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxModalHeight = screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxHeight: maxModalHeight,
        minHeight: 200,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? 16 : 0,
                ),
                child: _buildForm(),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.mode == LabelModalMode.create 
                  ? LocalKeys.addLabel.tr 
                  : LocalKeys.editLabel.tr,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label Name Field
            Text(
              LocalKeys.labelName.tr,
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                hintText: LocalKeys.labelName.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocalKeys.labelNameRequired.tr;
                }
                if (value.trim().length > 100) {
                  return 'Label name must be less than 100 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSave(),
            ),
            
            const SizedBox(height: 24),

            // Color Selection
            Text(
              LocalKeys.labelColor.tr,
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(),

            const SizedBox(height: 16),

            // Preview
            _buildPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a color:',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ColorUtils.predefinedColors.map((color) {
              final isSelected = color.value == _selectedColor.value;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Get.theme.colorScheme.primary 
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: isSelected 
                      ? Icon(
                          Icons.check,
                          color: ColorUtils.getContrastingTextColor(color),
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_nameController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview:',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _nameController.text.trim(),
            style: Get.textTheme.bodyMedium?.copyWith(
              color: ColorUtils.getContrastingTextColor(_selectedColor),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Get.back(),
              child: Text(LocalKeys.cancel.tr),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.mode == LabelModalMode.create 
                          ? LocalKeys.create.tr 
                          : LocalKeys.update.tr,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final labelController = Get.find<LabelController>();
      final name = _nameController.text.trim();
      final colorHex = ColorUtils.colorToHex(_selectedColor);

      bool success = false;

      if (widget.mode == LabelModalMode.create) {
        success = await labelController.createLabel(
          boardId: widget.boardId,
          name: name,
          color: colorHex,
        );
      } else if (widget.existingLabel != null) {
        final updatedLabel = widget.existingLabel!.updateWith(
          name: name,
          color: colorHex,
        );
        success = await labelController.updateLabel(updatedLabel);
      }

      if (success) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
