import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

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
            label: Text(
              card.isCompleted
                  ? LocalKeys.markAsIncomplete.tr
                  : LocalKeys.markAsComplete.tr,
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Other actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit button
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18.0),
              label: Text(LocalKeys.edit.tr),
            ),

            // Archive button
            ElevatedButton.icon(
              onPressed: () => _confirmArchive(context, cardController),
              icon: const Icon(Icons.archive, size: 18.0),
              label: Text(LocalKeys.archive.tr),
            ),

            // Delete button
            ElevatedButton.icon(
              onPressed: () => _confirmDelete(context, cardController),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete, size: 18.0),
              label: Text(LocalKeys.delete.tr),
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
          title: Text(LocalKeys.archive.tr),
          content: Text('${LocalKeys.areYouSureArchive.tr} "${card.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close detail modal
                controller.archiveCard(card.id!);
              },
              child: Text(LocalKeys.archive.tr),
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
          title: Text(LocalKeys.delete.tr),
          content: Text(
            '${LocalKeys.areYouSureDelete.tr} "${card.title}"? ${LocalKeys.cannotBeUndone.tr}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalKeys.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close detail modal
                controller.softDeleteCard(card.id!);
              },
              child: Text(LocalKeys.delete.tr),
            ),
          ],
        );
      },
    );
  }
}
