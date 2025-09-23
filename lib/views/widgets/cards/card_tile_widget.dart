import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'card_detail_modal.dart';
import 'card_title_text.dart';
import 'card_description_preview.dart';
import 'card_status_chip.dart';
import 'card_checklist_indicator.dart';

class CardTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;

  const CardTile({Key? key, required this.card, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();

    return GestureDetector(
      onTap: onTap ?? () => _openCardDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [BoxShadow(blurRadius: 4.0, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and completion indicator row
            Row(
              children: [
                // Title
                Expanded(child: CardTitleText(title: card.title, maxLines: 2)),
                // Completion indicator circle
                GestureDetector(
                  onTap: () {
                    if (card.isCompleted) {
                      // Mark as incomplete
                      cardController.uncompleteCard(card.id!);
                    } else {
                      // Mark as complete
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

            // Status indicator and description preview
            Row(
              children: [
                // Status indicator
                if (card.status != CardStatus.todo)
                  CardStatusChip(status: card.status.getDisplayName()),
                if (card.status != CardStatus.todo) const SizedBox(width: 8.0),

                // Description preview
                Expanded(
                  child: CardDescriptionPreview(
                    description: card.description,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            // Checklist indicator (if card has checklists)
            if (card.id != null) ...[
              const SizedBox(height: 6.0),
              Align(
                alignment: Alignment.centerLeft,
                child: CardChecklistIndicator(
                  cardId: card.id!,
                  compact: true,
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
        return CardDetailModal(card: card);
      },
    );
  }
}
