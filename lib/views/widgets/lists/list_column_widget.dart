import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/models/list_model.dart';
import 'package:kanbankit/views/widgets/lists/add_edit_list_modal.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/controllers/list_controller.dart';
import 'package:kanbankit/views/components/text_buttons/app_text_button.dart';
import 'package:kanbankit/views/components/text_buttons/button_variant.dart';
import 'package:kanbankit/controllers/card_controller.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/views/widgets/cards/card_tile_widget.dart';
import 'package:kanbankit/views/widgets/cards/add_card_button.dart';
import 'package:kanbankit/views/widgets/cards/card_form.dart';
import 'package:flutter/services.dart';
import '../responsive_text.dart';

class ListColumnWidget extends StatefulWidget {
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
  State<ListColumnWidget> createState() => _ListColumnWidgetState();
}

class _ListColumnWidgetState extends State<ListColumnWidget> {
  late final DialogService _dialogService;
  late final ListController _listController;
  late final CardController _cardController;

  @override
  void initState() {
    super.initState();
    _listController = Get.find<ListController>();
    _dialogService = Get.find<DialogService>();

    // Ensure CardController is registered as a singleton
    if (!Get.isRegistered<CardController>()) {
      Get.put<CardController>(CardController(), permanent: true);
    }

    // Get the registered CardController instance
    _cardController = Get.find<CardController>();

    // Load cards for this list
    _loadCardsForList();
  }

  Future<void> _loadCardsForList() async {
    // Load all cards so that each list can filter its own cards
    await _cardController.loadAllCards(showLoading: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listColor = _getListColor();

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
          _buildHeader(colorScheme, listColor),

          // Body (Cards Section)
          Expanded(child: _buildCardsSection(colorScheme)),

          // Footer
          _buildFooter(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, Color listColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: listColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              color: listColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Title (editable)
          Expanded(
            child: AppText(
              widget.list.title,
              variant: AppTextVariant.h2,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Menu icon for List actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: _handleListAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.edit.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_color',
                child: Row(
                  children: [
                    const Icon(Icons.color_lens, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.boardColor.tr),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    const Icon(Icons.archive, size: 18),
                    const SizedBox(width: 12),
                    Text(LocalKeys.archive.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text(
                      LocalKeys.delete.tr,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(ColorScheme colorScheme) {
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
        final listCards = _cardController.cards
            .where((card) => card.listId == widget.list.id!)
            .toList();

        // Show loading indicator while cards are loading
        if (_cardController.isLoading && listCards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show cards or empty state
        if (listCards.isEmpty) {
          return _buildEmptyState();
        }

        return DragTarget<CardModel>(
          onAcceptWithDetails: (details) {
            // Handle dropping a card into this list
            _handleCardDropped(details.data, widget.list.id!);
          },
          onWillAcceptWithDetails: (details) {
            // Only accept cards that are not from this list
            return details.data!.listId != widget.list.id!;
          },
          onLeave: (data) {
            // Optional: Handle when a draggable leaves the target
            
          },
          builder: (context, candidateData, rejectedData) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listCards.length + 1, // +1 for the add button
              itemBuilder: (context, index) {
                // Last item is the add button
                if (index == listCards.length) {
                  return AddCardButton(listId: widget.list.id!);
                }

                // Card items with drag support
                final card = listCards[index];
                return _buildDraggableCard(card);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildDraggableCard(CardModel card) {
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
          child: Text(card.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: CardTile(card: card)),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        print('Drag started');
        // Notify parent that dragging has started
        widget.onDragStart?.call();
      },
      onDragCompleted: () {
        print('Drag completed');
        widget.onDragEnd?.call();
      },
      onDraggableCanceled: (velocity, offset) {
        print('Drag canceled');
        widget.onDragEnd?.call();
      },
      child: CardTile(card: card),
    );
  }


  Widget _buildEmptyState() {
    return DragTarget<CardModel>(
      onAcceptWithDetails: (details) {
        // Handle dropping a card into this empty list
        _handleCardDropped(details.data, widget.list.id!);
      },
      onWillAccept: (data) {
        // Only accept cards that are not from this list
        return data != null && data.listId != widget.list.id!;
      },
      builder: (context, candidateData, rejectedData) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_outlined,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                AppText(
                  LocalKeys.noTasks.tr,
                  variant: AppTextVariant.body,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                AddCardButton(listId: widget.list.id!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: AppTextButton(
        onPressed: _showAddTaskModal,
        label: LocalKeys.addTask.tr,
        leadingIcon: Icons.add,
        variant: AppButtonVariant.secondary,
      ),
    );
  }

  Color _getListColor() {
    if (widget.list.color != null && widget.list.color!.isNotEmpty) {
      try {
        return Color(int.parse(widget.list.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback to default color if parsing fails
      }
    }
    return Theme.of(context).colorScheme.primary;
  }

  void _handleListAction(String action) {
    switch (action) {
      case 'edit':
        _showEditListModal();
        break;
      case 'change_color':
        // TODO: Implement color change functionality
        break;
      case 'archive':
        widget.onListArchived(widget.list);
        break;
      case 'delete':
        widget.onListDeleted(widget.list);
        break;
    }
  }

  void _handleCardDropped(CardModel card, int newListId) {
    // Move the card to the new list
    _cardController.moveCardToList(card.id!, newListId).then((_) {
      // Refresh all cards to reflect the card movement
      _cardController.loadAllCards(showLoading: false);
      // Also refresh the lists to reflect the card movement
      _listController.refreshAfterCardMovement();
    });
  }

  // Method to refresh cards in this list
  Future<void> refreshCards() async {
    await _cardController.loadAllCards(showLoading: false);
  }

  void _showEditListModal() {
    AddEditListModal.show(
      context,
      list: widget.list,
      boardId: widget.list.boardId,
    );
  }

  void _showAddTaskModal() {
    // Open the add card form directly
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return CardForm(listId: widget.list.id!);
      },
    );
  }
}
