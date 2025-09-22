import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/controllers/list_controller.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/models/list_model.dart';
import 'package:kanbankit/views/widgets/cards/card_form.dart';
import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
import 'package:kanbankit/views/widgets/lists/list_cards_section.dart';
import 'package:kanbankit/views/widgets/lists/list_footer_widget.dart';
import 'package:kanbankit/views/widgets/lists/list_header_widget.dart';

/// Main Container for a single list column
/// Acts as the main container holding header, cards section, and footer
/// Delegates all specific functionality to sub-widgets
class ListColumnWidget extends StatelessWidget {
  final ListModel list;
  final Function(ListModel) onListUpdated;
  final Function(ListModel) onListDeleted;
  final Function(ListModel) onListArchived;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const ListColumnWidget({
    super.key,
    required this.list,
    required this.onListUpdated,
    required this.onListDeleted,
    required this.onListArchived,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listColor = _getListColor(context);

    return Container(
      width: 280, // Fixed width as per requirements
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListHeaderWidget(
            list: list,
            color: listColor,
            onEdit: _showEditListModal,
            onArchive: () => onListArchived(list),
            onDelete: () => onListDeleted(list),
            onChangeColor: _handleChangeColor,
          ),

          // Body (Cards Section)
          Expanded(
            child: ListCardsSection(
              list: list,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd,
              onCardDropped: _handleCardDropped,
            ),
          ),

          // Footer
          ListFooterWidget(
            onAddCard: _showAddCardModal,
          ),
        ],
      ),
    );
  }

  Color _getListColor(BuildContext context) {
    if (list.color != null && list.color!.isNotEmpty) {
      try {
        return Color(int.parse(list.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback to default color if parsing fails
      }
    }
    return Theme.of(context).colorScheme.primary;
  }

  void _handleCardDropped(CardModel card, int newListId) {
    final cardController = Get.find<CardController>();
    final listController = Get.find<ListController>();
    
    // Move the card to the new list
    cardController.moveCardToList(card.id!, newListId).then((_) {
      // Refresh all cards to reflect the card movement
      cardController.loadAllCards(showLoading: false);
      // Also refresh the lists to reflect the card movement
      listController.refreshAfterCardMovement();
    });
  }

  void _showEditListModal() {
    // Get context from the current widget tree
    final context = Get.context!;
    AddEditListModal.show(
      context,
      list: list,
      boardId: list.boardId,
    );
  }

  void _handleChangeColor() {
  }

  void _showAddCardModal() {
    // Get context from the current widget tree
    final context = Get.context!;
    
    // Open the add card form directly
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return CardForm(listId: list.id!);
      },
    );
  }
}
