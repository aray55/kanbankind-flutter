import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/label_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/label_model.dart';
import 'label_item_widget.dart';
import 'add_edit_label_modal.dart';

/// Main Labels Container Widget
/// Purpose: Acts as the main wrapper inside a Card or Board view
/// Responsibilities:
/// - Loads the labels for the current Board using GetX Controller
/// - Displays a list of labels
/// - Opens modals for creating/editing labels
class LabelsWidget extends StatelessWidget {
  final int boardId;
  final bool showAddButton;
  final bool isCompact;
  final Function(LabelModel)? onLabelTap;
  final Function(LabelModel)? onLabelEdit;
  final Function(LabelModel)? onLabelDelete;

  const LabelsWidget({
    Key? key,
    required this.boardId,
    this.showAddButton = true,
    this.isCompact = false,
    this.onLabelTap,
    this.onLabelEdit,
    this.onLabelDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the LabelController instance
    final labelController = Get.find<LabelController>();

    // Load labels for this board when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      labelController.loadLabelsForBoard(boardId);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with title and add button
        if (!isCompact) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalKeys.labels.tr,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showAddButton)
                IconButton(
                  onPressed: () => _showAddLabelModal(context),
                  icon: const Icon(Icons.add),
                  tooltip: LocalKeys.addLabel.tr,
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Labels List
        Obx(() {
          final labels = labelController.boardLabels;
          
          if (labelController.isLoading) {
            return _buildLoadingState();
          }

          if (labels.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildLabelsList(labels);
        }),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: isCompact ? 40 : 60,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (isCompact) {
      return Container(
        height: 40,
        child: Center(
          child: Text(
            LocalKeys.noLabels.tr,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.label_outline,
            size: 32,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            LocalKeys.noLabels.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (showAddButton) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showAddLabelModal(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text(LocalKeys.addLabel.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabelsList(List<LabelModel> labels) {
    if (isCompact) {
      // Compact horizontal scrollable list
      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length + (showAddButton ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (showAddButton && index == labels.length) {
              return _buildAddButton();
            }
            
            final label = labels[index];
            return LabelItemWidget(
              label: label,
              isCompact: true,
              onTap: onLabelTap != null ? () => onLabelTap!(label) : null,
              onEdit: onLabelEdit != null ? () => onLabelEdit!(label) : null,
              onDelete: onLabelDelete != null ? () => onLabelDelete!(label) : null,
            );
          },
        ),
      );
    }

    // Full vertical list
    return Column(
      children: [
        ...labels.map((label) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: LabelItemWidget(
            label: label,
            isCompact: false,
            onTap: onLabelTap != null ? () => onLabelTap!(label) : null,
            onEdit: onLabelEdit != null ? () => onLabelEdit!(label) : null,
            onDelete: onLabelDelete != null ? () => onLabelDelete!(label) : null,
          ),
        )),
        if (showAddButton) ...[
          const SizedBox(height: 8),
          _buildAddButton(),
        ],
      ],
    );
  }

  Widget _buildAddButton() {
    if (isCompact) {
      return Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          onPressed: () => _showAddLabelModal(Get.context!),
          icon: Icon(
            Icons.add,
            size: 16,
            color: Get.theme.colorScheme.primary,
          ),
          padding: EdgeInsets.zero,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showAddLabelModal(Get.context!),
      icon: const Icon(Icons.add, size: 16),
      label: Text(LocalKeys.addLabel.tr),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showAddLabelModal(BuildContext context) {
    Get.bottomSheet(
      AddEditLabelModal(
        boardId: boardId,
        mode: LabelModalMode.create,
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      ignoreSafeArea: false,
      useRootNavigator: true,
    );
  }

  void _showEditLabelModal(BuildContext context, LabelModel label) {
    Get.bottomSheet(
      AddEditLabelModal(
        boardId: boardId,
        mode: LabelModalMode.edit,
        existingLabel: label,
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      ignoreSafeArea: false,
      useRootNavigator: true,
    );
  }
}
