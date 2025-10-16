import 'package:flutter/material.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/views/widgets/cards/card_tile_widget.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';

class CardDraggableWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const CardDraggableWidget({
    super.key,
    required this.card,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<CardModel>(
      data: card,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: CardTile(
          key: ValueKey('dragging_card_${card.id}'),
          card: card
        ),
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        onDragStart?.call();
      },
      onDragCompleted: () {
        onDragEnd?.call();
      },
      onDraggableCanceled: (velocity, offset) {
        onDragEnd?.call();
      },
      child: CardTile(
        key: ValueKey('card_tile_${card.id}'),
        card: card
      ),
    );
  }
}
