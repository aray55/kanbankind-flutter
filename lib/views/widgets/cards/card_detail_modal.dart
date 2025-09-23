import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/utils/date_utils.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'card_form.dart';
import 'card_actions.dart';
import '../checklist_items/checklist_section.dart';

class CardDetailModal extends StatelessWidget {
  final CardModel card;

  const CardDetailModal({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<CardController>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title, completion indicator and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Completion indicator circle
                  GestureDetector(
                    onTap: () {
                      if (card.isCompleted) {
                        // Mark as incomplete
                        cardController.uncompleteCard(card.id!);
                        Navigator.of(context).pop(); // Close modal after action
                      } else {
                        // Mark as complete
                        cardController.completeCard(card.id!);
                        Navigator.of(context).pop(); // Close modal after action
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
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Status
              if (card.status != CardStatus.todo) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.flag,
                  label: LocalKeys.status.tr,
                  value: card.status.getDisplayName(),
                ),
                const SizedBox(height: 8.0),
              ],

              // Completed at
              if (card.completedAt != null) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.check_circle,
                  label: LocalKeys.completedAt.tr,
                  value: AppDateUtils.formatDateTime(card.completedAt!),
                ),
                const SizedBox(height: 8.0),
              ],

              // Description
              if (card.description != null && card.description!.isNotEmpty) ...[
                Text(
                  LocalKeys.description.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  card.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
              ],

              // Checklists Section
              if (card.id != null) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 400, // Limit height to prevent overflow
                  ),
                  child: ChecklistSection(
                    cardId: card.id!,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],

              // Actions
              CardActions(card: card, onEdit: () => _openEditForm(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  void _openEditForm(BuildContext context) {
    Navigator.of(context).pop(); // Close detail modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return CardForm(card: card, listId: card.listId);
      },
    );
  }
}
