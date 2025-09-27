import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/expandable_controller.dart';
import 'package:kanbankit/views/components/expandable_widget.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../../../models/checklist_model.dart';
import 'components/checklist_header.dart';
import 'components/checklist_progress_bar.dart';
import 'components/checklist_items_list.dart';
import 'components/checklist_add_item_field.dart';
import 'components/checklist_archive_actions.dart';

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
  late ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    expandableController = ExpandableController();

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
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('checklist_widget_${widget.checklist.id}'),
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
        header: ChecklistHeader(
          checklist: widget.checklist,
          isEditable: widget.isEditable,
          onTitleUpdated: _onComponentUpdated,
        ),
        controller: expandableController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Progress Bar
            ChecklistProgressBar(
              checklist: widget.checklist,
            ),

            const SizedBox(height: 12),

            // Checklist Items
            ChecklistItemsList(
              checklist: widget.checklist,
              isEditable: widget.isEditable,
              onItemsChanged: _onComponentUpdated,
            ),

            // Add Checklist Item Field
            if (widget.isEditable && !widget.checklist.archived) ...[
              const SizedBox(height: 8),
              ChecklistAddItemField(
                checklist: widget.checklist,
                onItemAdded: _onComponentUpdated,
              ),
            ],

            // Archive actions for archived checklists
            if (widget.showArchiveActions && widget.checklist.archived)
              ChecklistArchiveActions(
                checklist: widget.checklist,
                onActionCompleted: _onComponentUpdated,
              ),
          ],
        ),
      ),
    );
  }

  /// Callback for when any component updates to trigger parent refresh if needed
  void _onComponentUpdated() {
    // This can be used to trigger parent widget refresh if needed
    // For now, the reactive nature of GetX handles most updates automatically
  }
}
