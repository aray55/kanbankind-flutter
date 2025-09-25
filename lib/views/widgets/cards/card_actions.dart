import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import 'card_cover_selector.dart';

class CardActions extends StatelessWidget {
  final CardModel card;
  final VoidCallback onEdit;

  const CardActions({Key? key, required this.card, required this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mark as complete/incomplete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (card.isCompleted) {
                // Mark as incomplete
                cardController.uncompleteCard(card.id!);
              } else {
                // Mark as complete
                cardController.completeCard(card.id!);
              }
              Navigator.of(context).pop(); // Close detail modal
            },
            icon: Icon(
              card.isCompleted
                  ? Icons.radio_button_unchecked
                  : Icons.check_circle,
            ),
            label: AppText(
              card.isCompleted
                  ? LocalKeys.markAsIncomplete.tr
                  : LocalKeys.markAsComplete.tr,
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Cover action (only for existing cards)
        if (card.id != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCoverSelector(context),
              icon: Icon(
                card.hasCover ? Icons.image : Icons.add_photo_alternate,
                size: 18.0,
              ),
              label: AppText(
                card.hasCover ? LocalKeys.changeCover.tr : LocalKeys.addCover.tr,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],

        // Other actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit button
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18.0),
              label: AppText(LocalKeys.edit.tr),
            ),

            // Archive button
            ElevatedButton.icon(
              onPressed: () => _confirmArchive(context, cardController),
              icon: const Icon(Icons.archive, size: 18.0),
              label: AppText(LocalKeys.archive.tr),
            ),

            // Delete button
            ElevatedButton.icon(
              onPressed: () => _confirmDelete(context, cardController),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete, size: 18.0),
              label: AppText(LocalKeys.delete.tr),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmArchive(BuildContext context, CardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AppText(LocalKeys.archive.tr),
          content: AppText('${LocalKeys.areYouSureArchive.tr} "${card.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText(LocalKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close detail modal
                controller.archiveCard(card.id!);
              },
              child: AppText(LocalKeys.archive.tr),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AppText(LocalKeys.delete.tr),
          content: AppText(
            '${LocalKeys.areYouSureDelete.tr} "${card.title}"? ${LocalKeys.cannotBeUndone.tr}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText(LocalKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close detail modal
                controller.softDeleteCard(card.id!);
              },
              child: AppText(LocalKeys.delete.tr),
            ),
          ],
        );
      },
    );
  }

  void _showCoverSelector(BuildContext context) {
    CardCoverSelector.show(
      context: context,
      card: card,
      onCoverChanged: (updatedCard) {
        // The card will be updated through the controller
        // and the UI will refresh automatically
      },
    );
  }
}
