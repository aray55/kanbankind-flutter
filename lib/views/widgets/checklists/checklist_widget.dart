import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/expandable_controller.dart';
import 'package:kanbankit/views/components/expandable_widget.dart';
import '../../../controllers/checklists_controller.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_model.dart';
import '../../../models/checklist_item_model.dart';
import '../../components/text_buttons/app_text_button.dart';
import '../../components/text_buttons/button_variant.dart';
import '../../components/text_buttons/button_size.dart';
import '../responsive_text.dart';
import '../checklist_items/add_edit_checklist_item_modal.dart';
import '../checklist_items/checklist_item_widget.dart';
import 'checklist_options_modal.dart';
import 'add_edit_checklist_modal.dart';

class ChecklistWidget extends StatefulWidget {
  final ChecklistModel checklist;
  final bool isEditable;
  final bool showArchiveActions;

  const ChecklistWidget({
    Key? key,
    required this.checklist,
    this.isEditable = true,
    this.showArchiveActions = false,
  }) : super(key: key);

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;
  late ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    expandableController = ExpandableController();

    _titleController.text = widget.checklist.title;

    // Load checklist items for this checklist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<ChecklistItemController>()) {
        Get.put(ChecklistItemController(), permanent: true);
      }
      final checklistItemController = Get.find<ChecklistItemController>();
      checklistItemController.loadActiveItems(widget.checklist.id!);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpandableWidget(
        header: _buildHeader(context, controller),
        controller: expandableController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and options
            // _buildHeader(context, controller),
            const SizedBox(height: 12),

            // Progress Bar
            _buildProgressBar(context),

            const SizedBox(height: 12),

            // Checklist Items
            _buildChecklistItems(context),

            // Add Checklist Item Field
            if (widget.isEditable && !widget.checklist.archived) ...[
              const SizedBox(height: 8),
              _buildAddItemField(context),
            ],

            // Archive actions for archived checklists
            if (widget.showArchiveActions && widget.checklist.archived)
              _buildArchiveActions(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChecklistsController controller) {
    return Row(
      children: [
        // Title (editable)
        Expanded(
          child: _isEditingTitle
              ? _buildTitleEditor(context, controller)
              : _buildTitleDisplay(context),
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
          ? () => setState(() => _isEditingTitle = true)
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
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => _saveTitle(controller),
          tooltip: LocalKeys.save.tr,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _cancelTitleEdit(),
          tooltip: LocalKeys.cancel.tr,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      // Initialize ChecklistItemController if not already registered
      if (!Get.isRegistered<ChecklistItemController>()) {
        Get.put(ChecklistItemController(), permanent: true);
      }

      final checklistItemController = Get.find<ChecklistItemController>();
      final allItems = checklistItemController.checklistItems;
      final items = allItems
          .where((item) => item.checklistId == widget.checklist.id)
          .toList();

      final totalItems = items.length;
      final completedItems = items.where((item) => item.isDone).length;
      final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '${LocalKeys.progress.tr}: $completedItems/$totalItems',
                variant: AppTextVariant.small,
              ),
              AppText(
                '${(progress * 100).toInt()}%',
                variant: AppTextVariant.small,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChecklistItems(BuildContext context) {
    return Obx(() {
      // Initialize ChecklistItemController if not already registered
      if (!Get.isRegistered<ChecklistItemController>()) {
        Get.put(ChecklistItemController(), permanent: true);
      }

      final checklistItemController = Get.find<ChecklistItemController>();
      final allItems = checklistItemController.checklistItems;
      final items = allItems
          .where((item) => item.checklistId == widget.checklist.id)
          .toList();

      if (items.isEmpty) {
        return const SizedBox.shrink(); // Don't show anything if no items
      }

      return Column(
        children: [
          // Load checklist items when widget is first built
          ...items.map((item) {
            return ChecklistItemWidget(
              key: ValueKey(item.id),
              item: item,
              isEditable: widget.isEditable,
              showActions: widget.isEditable,
              showDragHandle: false, // Disable drag handle for now
              onToggle: () {
                checklistItemController.toggleItemDone(item.id!);
              },
              onEdit: () {
                AddEditChecklistItemModal.show(
                  context,
                  checklistId: widget.checklist.id!,
                  item: item,
                );
              },
              onDelete: () {
                checklistItemController.deleteChecklistItem(item.id!);
              },
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildAddItemField(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddItemModal(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                LocalKeys.addChecklistItem.tr,
                variant: AppTextVariant.body,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemModal(BuildContext context) {
    // Initialize ChecklistItemController if not already registered
    if (!Get.isRegistered<ChecklistItemController>()) {
      Get.put(ChecklistItemController(), permanent: true);
    }

    AddEditChecklistItemModal.show(
      context,
      checklistId: widget.checklist.id!,
    ).then((_) {
      // Refresh items after modal closes
      final checklistItemController = Get.find<ChecklistItemController>();
      checklistItemController.loadActiveItems(widget.checklist.id!);
    });
  }

  Widget _buildArchiveActions(
    BuildContext context,
    ChecklistsController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AppTextButton(
            label: LocalKeys.unarchive.tr,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            leadingIcon: Icons.unarchive_outlined,
            onPressed: () =>
                controller.unarchiveChecklist(widget.checklist.id!),
          ),
          const SizedBox(width: 8),
          AppTextButton(
            label: LocalKeys.delete.tr,
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
            leadingIcon: Icons.delete_outline,
            onPressed: () => _confirmDelete(context, controller),
          ),
        ],
      ),
    );
  }

  void _saveTitle(ChecklistsController controller) {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.checklist.title) {
      final updatedChecklist = widget.checklist.copyWith(title: newTitle);
      controller.updateChecklist(updatedChecklist);
    }
    setState(() => _isEditingTitle = false);
  }

  void _cancelTitleEdit() {
    _titleController.text = widget.checklist.title;
    setState(() => _isEditingTitle = false);
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
