import 'package:flutter/material.dart';
import 'package:kanbankit/models/card_model.dart';
import 'card_tile_widget.dart';

class CardListView extends StatelessWidget {
  final List<CardModel> cards;
  final void Function(CardModel card)? onCardTap;

  const CardListView({Key? key, required this.cards, this.onCardTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardTile(
          key: ValueKey('card_list_tile_${card.id}_${card.title}_${card.updatedAt.millisecondsSinceEpoch}'),
          card: card,
          onTap: onCardTap != null ? () => onCardTap!(card) : null,
        );
      },
    );
  }
}
