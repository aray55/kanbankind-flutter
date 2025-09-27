import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/card_label_controller.dart';
import '../../../controllers/label_controller.dart';
import '../../../models/label_model.dart';
import '../../../core/utils/color_utils.dart';
import 'label_selector_widget.dart';

/// Card Labels Display Widget
/// Purpose: Shows labels assigned to a card in various display modes
/// Used in: Card tiles, card details, card previews
class CardLabelsDisplay extends StatelessWidget {
  final int cardId;
  final int boardId;
  final CardLabelsDisplayMode mode;
  final int? maxLabels;
  final bool showAddButton;
  final bool isInteractive;
  final VoidCallback? onTap;
  final Function(List<LabelModel>)? onLabelsChanged;

  const CardLabelsDisplay({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.mode = CardLabelsDisplayMode.compact,
    this.maxLabels,
    this.showAddButton = false,
    this.isInteractive = true,
    this.onTap,
    this.onLabelsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controllers safely
    final cardLabelController = Get.find<CardLabelController>();
    final labelController = Get.find<LabelController>();

    // Load data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cardLabelController.cardLabels.isEmpty) {
        cardLabelController.loadCardLabels(cardId);
      }
      if (labelController.boardLabels.isEmpty) {
        labelController.loadLabelsForBoard(boardId);
      }
    });

    return Obx(() {
      final assignedLabelIds = cardLabelController.cardLabels
          .map((cl) => cl.labelId)
          .toSet();

      final assignedLabels = labelController.boardLabels
          .where((label) => assignedLabelIds.contains(label.id))
          .toList();

      return _buildLabelsDisplay(assignedLabels);
    });
  }

  Widget _buildLabelsDisplay(List<LabelModel> labels) {
    if (labels.isEmpty && !showAddButton) {
      return const SizedBox.shrink();
    }

    switch (mode) {
      case CardLabelsDisplayMode.compact:
        return _buildCompactDisplay(labels);
      case CardLabelsDisplayMode.chips:
        return _buildChipsDisplay(labels);
      case CardLabelsDisplayMode.dots:
        return _buildDotsDisplay(labels);
      case CardLabelsDisplayMode.list:
        return _buildListDisplay(labels);
    }
  }

  Widget _buildCompactDisplay(List<LabelModel> labels) {
    final displayLabels = maxLabels != null && labels.length > maxLabels!
        ? labels.take(maxLabels!).toList()
        : labels;
    
    final hasMore = maxLabels != null && labels.length > maxLabels!;
    final moreCount = hasMore ? labels.length - maxLabels! : 0;

    return GestureDetector(
      onTap: isInteractive ? (onTap ?? _showLabelSelector) : null,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ...displayLabels.map((label) => _buildCompactLabel(label)),
          if (hasMore) _buildMoreIndicator(moreCount),
          if (showAddButton && labels.isEmpty) _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildChipsDisplay(List<LabelModel> labels) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...labels.map((label) => _buildChipLabel(label)),
        if (showAddButton) _buildAddChip(),
      ],
    );
  }

  Widget _buildDotsDisplay(List<LabelModel> labels) {
    final displayLabels = maxLabels != null && labels.length > maxLabels!
        ? labels.take(maxLabels!).toList()
        : labels;
    
    final hasMore = maxLabels != null && labels.length > maxLabels!;

    return GestureDetector(
      onTap: isInteractive ? (onTap ?? _showLabelSelector) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayLabels.map((label) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _buildDotLabel(label),
          )),
          if (hasMore) _buildMoreDots(),
          if (showAddButton && labels.isEmpty) _buildAddDot(),
        ],
      ),
    );
  }

  Widget _buildListDisplay(List<LabelModel> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...labels.map((label) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildListLabel(label),
        )),
        if (showAddButton) _buildAddListItem(),
      ],
    );
  }

  Widget _buildCompactLabel(LabelModel label) {
    final labelColor = ColorUtils.parseColor(label.color);
    final textColor = ColorUtils.getContrastingTextColor(labelColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: labelColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.name,
        style: Get.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildChipLabel(LabelModel label) {
    final labelColor = ColorUtils.parseColor(label.color);
    final textColor = ColorUtils.getContrastingTextColor(labelColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: labelColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.name,
        style: Get.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDotLabel(LabelModel label) {
    final labelColor = ColorUtils.parseColor(label.color);

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: labelColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildListLabel(LabelModel label) {
    final labelColor = ColorUtils.parseColor(label.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: labelColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label.name,
            style: Get.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+$count',
        style: Get.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildMoreDots() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.outline.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add,
        size: 12,
        color: Get.theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAddChip() {
    return GestureDetector(
      onTap: _showLabelSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14,
              color: Get.theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Add Label',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.5),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.add,
        size: 6,
        color: Get.theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAddListItem() {
    return GestureDetector(
      onTap: _showLabelSelector,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(
                color: Get.theme.colorScheme.primary.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.add,
              size: 8,
              color: Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Add Label',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLabelSelector() {
    Get.bottomSheet(
      LabelSelectorModal(
        cardId: cardId,
        boardId: boardId,
        onSelectionChanged: onLabelsChanged,
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      ignoreSafeArea: false,
      useRootNavigator: true,
    );
  }
}

/// Display modes for card labels
enum CardLabelsDisplayMode {
  /// Compact horizontal labels with text
  compact,
  
  /// Chip-style labels with rounded corners
  chips,
  
  /// Small colored dots only
  dots,
  
  /// Vertical list with color indicator and text
  list,
}

/// Convenience widgets for specific use cases

/// Compact labels for card tiles
class CardLabelsCompact extends StatelessWidget {
  final int cardId;
  final int boardId;
  final int maxLabels;
  final VoidCallback? onTap;

  const CardLabelsCompact({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.maxLabels = 3,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardLabelsDisplay(
      cardId: cardId,
      boardId: boardId,
      mode: CardLabelsDisplayMode.compact,
      maxLabels: maxLabels,
      onTap: onTap,
    );
  }
}

/// Dots display for minimal space usage
class CardLabelsDots extends StatelessWidget {
  final int cardId;
  final int boardId;
  final int maxLabels;
  final VoidCallback? onTap;

  const CardLabelsDots({
    Key? key,
    required this.cardId,
    required this.boardId,
    this.maxLabels = 5,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardLabelsDisplay(
      cardId: cardId,
      boardId: boardId,
      mode: CardLabelsDisplayMode.dots,
      maxLabels: maxLabels,
      onTap: onTap,
    );
  }
}
