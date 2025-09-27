import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/checklists_controller.dart';
import '../../../../core/localization/local_keys.dart';
import '../../../../models/checklist_model.dart';
import '../../../components/icon_buttons/app_icon_button.dart';
import '../../../components/icon_buttons/icon_button_size.dart';
import '../../../components/icon_buttons/icon_button_variant.dart';
import '../../responsive_text.dart';
import '../checklist_options_modal.dart';
import '../add_edit_checklist_modal.dart';

class ChecklistHeader extends StatefulWidget {
  final ChecklistModel checklist;
  final bool isEditable;
  final VoidCallback? onTitleUpdated;

  const ChecklistHeader({
    Key? key,
    required this.checklist,
    this.isEditable = true,
    this.onTitleUpdated,
  }) : super(key: key);

  @override
  State<ChecklistHeader> createState() => _ChecklistHeaderState();
}

class _ChecklistHeaderState extends State<ChecklistHeader> {
  late TextEditingController _titleController;
  final RxBool _isEditingTitle = false.obs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.checklist.title);
  }

  @override
  void didUpdateWidget(ChecklistHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if checklist title changed
    if (oldWidget.checklist.title != widget.checklist.title) {
      _titleController.text = widget.checklist.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    return Row(
      key: ValueKey('checklist_header_${widget.checklist.id}'),
      children: [
        // Title (editable)
        Expanded(
          child: Obx(() => _isEditingTitle.value
              ? _buildTitleEditor(context, controller)
              : _buildTitleDisplay(context)),
        ),

        // Options button
        if (widget.isEditable)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsModal(context, controller),
            tooltip: LocalKeys.options.tr,
          ),
      ],
    );
  }

  Widget _buildTitleDisplay(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEditable
          ? () => _isEditingTitle.value = true
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: AppText(
          widget.checklist.title,
          variant: AppTextVariant.h2,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTitleEditor(
    BuildContext context,
    ChecklistsController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _titleController,
            autofocus: true,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: LocalKeys.checklistTitle.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onSubmitted: (value) => _saveTitle(controller),
          ),
        ),
        const SizedBox(width: 8),
        AppIconButton(
          onPressed: () => _saveTitle(controller),
          variant: AppIconButtonVariant.primary,
          size: AppIconButtonSize.small,
          child: const Icon(Icons.check),
        ),
        AppIconButton(
          onPressed: () => _cancelTitleEdit(),
          variant: AppIconButtonVariant.primary,
          size: AppIconButtonSize.small,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  void _saveTitle(ChecklistsController controller) {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.checklist.title) {
      final updatedChecklist = widget.checklist.copyWith(title: newTitle);
      controller.updateChecklist(updatedChecklist);
      widget.onTitleUpdated?.call();
    }
    _isEditingTitle.value = false;
  }

  void _cancelTitleEdit() {
    _titleController.text = widget.checklist.title;
    _isEditingTitle.value = false;
  }

  void _showOptionsModal(
    BuildContext context,
    ChecklistsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChecklistOptionsModal(
        checklist: widget.checklist,
        onEdit: () => _showEditModal(context, controller),
        onArchive: () => controller.archiveChecklist(widget.checklist.id!),
        onDelete: () => _confirmDelete(context, controller),
        onDuplicate: () => _showDuplicateDialog(context, controller),
      ),
    );
  }

  void _showEditModal(BuildContext context, ChecklistsController controller) {
    Navigator.of(context).pop(); // Close options modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditChecklistModal(
        cardId: widget.checklist.cardId,
        checklist: widget.checklist,
        onSaved: () {
          controller.loadChecklistsByCardId(widget.checklist.cardId);
          widget.onTitleUpdated?.call();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChecklistsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.deleteChecklist.tr),
        content: Text(LocalKeys.deleteChecklistConfirmation.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteChecklist(widget.checklist.id!);
            },
            child: Text(LocalKeys.delete.tr),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog(
    BuildContext context,
    ChecklistsController controller,
  ) {
    final titleController = TextEditingController(
      text: '${widget.checklist.title} ${LocalKeys.copy.tr}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.duplicateChecklist.tr),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: LocalKeys.checklistTitle.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.of(context).pop();
                controller.duplicateChecklist(widget.checklist.id!, newTitle);
              }
            },
            child: Text(LocalKeys.duplicate.tr),
          ),
        ],
      ),
    );
  }
}
