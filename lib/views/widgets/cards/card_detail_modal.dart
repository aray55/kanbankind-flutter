import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/utils/date_utils.dart';
import 'package:kanbankit/core/enums/card_status.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/views/components/info_row.dart';
import 'package:kanbankit/views/widgets/checklists/checklist_section.dart';
import '../responsive_text.dart';
import 'package:kanbankit/views/components/datetime_picker.dart';
import 'card_due_date.dart';
import 'card_form.dart';
import 'card_actions.dart';
import 'card_cover_widget.dart';

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
                CardCoverWidget(
                  card: card,
                  height: 50,
                  showFullCover: true,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        card.title,
                        variant: AppTextVariant.h2,
                      ),
                    ),
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
                if (card.status != CardStatus.todo) ...[
                  InfoRow(
                    icon: Icons.flag,
                    label: LocalKeys.status.tr,
                    value: card.status.getDisplayName(),
                  ),
                  const SizedBox(height: 8.0),
                ],
                if (card.completedAt != null) ...[
                  InfoRow(
                    icon: Icons.check_circle,
                    label: LocalKeys.completedAt.tr,
                    value: AppDateUtils.formatDateTime(
                      card.completedAt!,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
                _buildDueDateSection(context, cardController, card),
                if (card.description != null &&
                    card.description!.isNotEmpty) ...[
                  AppText(LocalKeys.description.tr, variant: AppTextVariant.h2),
                  const SizedBox(height: 8.0),
                  AppText(
                    card.description!,
                    variant: AppTextVariant.body,
                  ),
                  const SizedBox(height: 16.0),
                ],
                if (card.id != null) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ChecklistSection(cardId: card.id!),
                  ),
                  const SizedBox(height: 16.0),
                ],
                CardActions(
                  card: card,
                  onEdit: () => _openEditForm(context, card),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDueDateSection(
    BuildContext context,
    CardController cardController,
    CardModel card,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          LocalKeys.dueDate.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8.0),
        if (card.dueDate != null)
          InkWell(
            onTap: () =>
                _showDueDatePicker(context, cardController, card),
            borderRadius: BorderRadius.circular(8),
            child: CardDueDateWidget(
              dueDate: card.dueDate,
              isCompleted: card.isCompleted,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () =>
                _showDueDatePicker(context, cardController, card),
            icon: const Icon(Icons.add),
            label: Text(LocalKeys.add.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  void _showDueDatePicker(
    BuildContext context,
    CardController cardController,
    CardModel card,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateTimePicker(
                initialDateTime: card.dueDate,
                onSelected: (date) async {
                  await cardController.setDueDate(card.id!, date);
                  Navigator.of(context).pop();
                },
              ),
              if (card.dueDate != null)
                TextButton(
                  onPressed: () async {
                    await cardController.setDueDate(card.id!, null);
                    Get.back();
                  },
                  child: Text(
                    LocalKeys.removeDueDate.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openEditForm(BuildContext context, CardModel card) {
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

