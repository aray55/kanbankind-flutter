import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'card_form.dart';

class AddCardButton extends StatelessWidget {
  final int listId;

  const AddCardButton({Key? key, required this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openAddCardForm(context),
      icon: const Icon(Icons.add),
      label: Text(LocalKeys.addCard.tr),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  void _openAddCardForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return CardForm(listId: listId);
      },
    );
  }
}
