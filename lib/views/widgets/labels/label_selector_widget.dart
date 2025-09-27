import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/label_controller.dart';
import '../../../controllers/card_label_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/label_model.dart';
import 'label_item_widget.dart';
import 'add_edit_label_modal.dart';

/// Label Selection / Assignment Widget
/// Purpose: Used when assigning labels to a Card
/// Responsibilities:
/// - Shows all available labels from the Board
/// - Allows toggling labels assigned to a specific card
/// - Updates the card_labels table via the controller
class LabelSelectorWidget extends StatefulWidget {
  final int cardId;
  final int boardId;
  final bool showCreateButton;
  final bool isCompact;
  final Function(List<LabelModel>)? onSelectionChanged;

  const LabelSelectorWidget({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.showCreateButton = true,
    this.isCompact = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<LabelSelectorWidget> createState() => _LabelSelectorWidgetState();
}

class _LabelSelectorWidgetState extends State<LabelSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final labelController = Get.find<LabelController>();
    final cardLabelController = Get.find<CardLabelController>();
    
    // Load labels for board and card labels
    labelController.loadLabelsForBoard(widget.boardId);
    cardLabelController.loadCardLabels(widget.cardId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isCompact) _buildHeader(),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildLabelsList(),
          if (widget.showCreateButton && !widget.isCompact) ...[
            const SizedBox(height: 16),
            _buildCreateButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        LocalKeys.cardLabels.tr,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: LocalKeys.searchLabels.tr,
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildLabelsList() {
    // Get controllers safely
    final labelController = Get.find<LabelController>();
    final cardLabelController = Get.find<CardLabelController>();

    return Obx(() {
      if (labelController.isLoading || cardLabelController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final allLabels = labelController.boardLabels;
      final assignedLabelIds = cardLabelController.cardLabels
          .map((cl) => cl.labelId)
          .toSet();

      // Filter labels based on search query
      final filteredLabels = allLabels.where((label) {
        if (_searchQuery.isEmpty) return true;
        return label.name.toLowerCase().contains(_searchQuery);
      }).toList();

      if (filteredLabels.isEmpty) {
        return _buildEmptyState();
      }

      return _buildLabelsGrid(filteredLabels, assignedLabelIds);
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_outline,
            size: widget.isCompact ? 32 : 48,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? LocalKeys.noLabels.tr 
                : LocalKeys.noLabelsFound.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showCreateButton && _searchQuery.isEmpty && !widget.isCompact) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _showCreateLabelModal,
              icon: const Icon(Icons.add, size: 16),
              label: Text(LocalKeys.addLabel.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabelsGrid(List<LabelModel> labels, Set<int> assignedLabelIds) {
    if (widget.isCompact) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = assignedLabelIds.contains(label.id);
          
          return LabelItemWidget(
            label: label,
            isCompact: true,
            isSelected: isSelected,
            showActions: false,
            onToggle: () => _toggleLabel(label, isSelected),
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        final label = labels[index];
        final isSelected = assignedLabelIds.contains(label.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: LabelItemWidget(
            label: label,
            isCompact: false,
            isSelected: isSelected,
            showActions: false,
            onToggle: () => _toggleLabel(label, isSelected),
          ),
        );
      },
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showCreateLabelModal,
        icon: const Icon(Icons.add, size: 16),
        label: Text(LocalKeys.addLabel.tr),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _toggleLabel(LabelModel label, bool isCurrentlySelected) async {
    final cardLabelController = Get.find<CardLabelController>();
    
    bool success = false;
    
    if (isCurrentlySelected) {
      // Remove label from card
      success = await cardLabelController.removeLabelFromCard(
        widget.cardId, 
        label.id!,
      );
    } else {
      // Assign label to card
      success = await cardLabelController.assignLabelToCard(
        widget.cardId, 
        label.id!,
      );
    }

    if (success && widget.onSelectionChanged != null) {
      // Get updated selected labels
      final updatedAssignedIds = cardLabelController.cardLabels
          .map((cl) => cl.labelId)
          .toSet();
      
      final labelController = Get.find<LabelController>();
      final selectedLabels = labelController.boardLabels
          .where((label) => updatedAssignedIds.contains(label.id))
          .toList();
      
      widget.onSelectionChanged!(selectedLabels);
    }
  }

  void _showCreateLabelModal() {
    Get.bottomSheet(
      AddEditLabelModal(
        boardId: widget.boardId,
        mode: LabelModalMode.create,
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      ignoreSafeArea: false,
      useRootNavigator: true,
    ).then((_) {
      // Reload labels after modal closes
      _loadData();
    });
  }
}

/// Compact version for quick access
class CompactLabelSelector extends StatelessWidget {
  final int cardId;
  final int boardId;
  final Function(List<LabelModel>)? onSelectionChanged;

  const CompactLabelSelector({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LabelSelectorWidget(
        cardId: cardId,
        boardId: boardId,
        isCompact: true,
        showCreateButton: false,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

/// Full screen label selector modal
class LabelSelectorModal extends StatelessWidget {
  final int cardId;
  final int boardId;
  final Function(List<LabelModel>)? onSelectionChanged;

  const LabelSelectorModal({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxModalHeight = screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxHeight: maxModalHeight,
        minHeight: 300,
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
            // Header
            Container(
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
                      LocalKeys.cardLabels.tr,
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
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: keyboardHeight > 0 ? 16 : 20,
                ),
                child: LabelSelectorWidget(
                  cardId: cardId,
                  boardId: boardId,
                  showCreateButton: true,
                  isCompact: false,
                  onSelectionChanged: onSelectionChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
