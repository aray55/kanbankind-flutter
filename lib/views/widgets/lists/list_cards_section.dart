import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/models/list_model.dart';
import 'package:kanbankit/views/components/empty_state.dart';
import 'card_draggable_widget.dart';

class ListCardsSection extends StatelessWidget {
  final ListModel list;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Function(CardModel, int)? onCardDropped;

  const ListCardsSection({
    super.key,
    required this.list,
    this.onDragStart,
    this.onDragEnd,
    this.onCardDropped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardController = Get.find<CardController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Obx(() {
        // Filter cards for this specific list
        final listCards = cardController.cards
            .where((card) => card.listId == list.id!)
            .toList();

        // Show loading indicator while cards are loading
        if (cardController.isLoading && listCards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show cards or empty state
        if (listCards.isEmpty) {
          return _buildEmptyState(context);
        }

        return DragTarget<CardModel>(
          onAcceptWithDetails: (details) {
            // Handle dropping a card into this list
            onCardDropped?.call(details.data, list.id!);
          },
          onWillAcceptWithDetails: (details) {
            // Only accept cards that are not from this list
            return details.data.listId != list.id!;
          },
          builder: (context, candidateData, rejectedData) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listCards.length,
              itemBuilder: (context, index) {
                final card = listCards[index];
                return CardDraggableWidget(
                  card: card,
                  onDragStart: onDragStart,
                  onDragEnd: onDragEnd,
                );
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return DragTarget<CardModel>(
      onAcceptWithDetails: (details) {
        // Handle dropping a card into this empty list
        onCardDropped?.call(details.data, list.id!);
      },
      onWillAcceptWithDetails: (details) {
        // Only accept cards that are not from this list
        return details.data.listId != list.id!;
      },
      builder: (context, candidateData, rejectedData) {
        return EmptyState(
          icon: Icons.task_outlined,
          title: LocalKeys.noCards.tr,
          subtitle: LocalKeys.noCardsDescription.tr,
        );
      },
    );
  }
}
