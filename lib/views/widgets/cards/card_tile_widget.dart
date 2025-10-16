import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'card_detail_modal_tabbed.dart';
import 'card_due_date.dart';
import 'card_title_text.dart';
import 'card_description_preview.dart';
import 'card_status_chip.dart';
import 'card_checklist_indicator.dart';
import 'card_cover_widget.dart';
import '../labels/card_labels_display.dart';

class CardTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;

  const CardTile({Key? key, required this.card, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();


      return GestureDetector(
      key: ValueKey('card_tile_gesture_${card.id}_${card.title}_${card.updatedAt}'),
      onTap: onTap ?? () => _openCardDetail(context),
      child: Container(
        key: ValueKey('card_tile_container_${card.id}'),
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [BoxShadow(blurRadius: 4.0, offset: const Offset(0, 2))],
        ),
        child: Column(
          key: ValueKey('card_column_${card.id}_${card.title}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card cover (if exists) - show at the top
            if (card.hasCover)
              CardCoverWidget(
                key: ValueKey('card_cover_${card.id}_${card.coverColor}_${card.coverImage}_${card.updatedAt.millisecondsSinceEpoch}'),
                card: card,
                height: 80,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),

            // Title and completion indicator row
            Row(
              children: [
                Expanded(child: CardTitleText(title: card.title, maxLines: 2)),
                GestureDetector(
                  onTap: () {
                    if (card.isCompleted) {
                      cardController.uncompleteCard(card.id!);
                    } else {
                      cardController.completeCard(card.id!);
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: card.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: card.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: card.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),

            // Labels (if card has any)
            if (card.id != null) ...[
              CardLabelsDots(
                key: ValueKey('card_labels_${card.id}_${card.title}_${card.updatedAt.millisecondsSinceEpoch}'),
                cardId: card.id!,
                boardId: 1, // TODO: Get actual boardId
                maxLabels: 5,
                onTap: () => _openCardDetail(context),
              ),
              const SizedBox(height: 6.0),
            ],

            // Status indicator and description preview
            LayoutBuilder(
              builder: (context, constraints) {
                // If we have both status and due date, use a more compact layout
                if (card.status != CardStatus.todo && card.dueDate != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row: Status and Due Date
                      Row(
                        children: [
                          Flexible(
                            child: CardStatusChip(status: card.status.getDisplayName()),
                          ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: CardDueDateWidget(
                              dueDate: card.dueDate,
                              isCompleted: card.isCompleted,
                              showStatus: false, // Disable status badges in card tiles to prevent overflow
                              compact: true, // Use compact mode in card tiles
                            ),
                          ),
                        ],
                      ),
                      // Second row: Description
                      if (card.description != null && card.description!.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        CardDescriptionPreview(
                          description: card.description,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  );
                } else {
                  // Single row layout when we have fewer elements
                  return Row(
                    children: [
                      // Status indicator
                      if (card.status != CardStatus.todo) ...[
                        Flexible(
                          child: CardStatusChip(status: card.status.getDisplayName()),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      // Due date widget with flexible sizing
                      if (card.dueDate != null) ...[
                        Flexible(
                          child: CardDueDateWidget(
                            dueDate: card.dueDate,
                            isCompleted: card.isCompleted,
                            showStatus: false, // Disable status badges in card tiles to prevent overflow
                            compact: true, // Use compact mode in card tiles
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      // Description preview
                      Expanded(
                        child: CardDescriptionPreview(
                          description: card.description,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            // Checklist indicator (if card has checklists)
            if (card.id != null) ...[
              const SizedBox(height: 6.0),
              Align(
                alignment: Alignment.centerLeft,
                child: CardChecklistIndicator(
                  key: ValueKey('card_checklist_${card.id}_${card.title}_${card.updatedAt.millisecondsSinceEpoch}'),
                  cardId: card.id!, 
                  compact: true
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openCardDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return CardDetailModalTabbed(card: card);
      },
    );
  }
}
