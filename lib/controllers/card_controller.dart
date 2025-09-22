import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/data/repository/card_repository.dart';
import 'package:kanbankit/core/enums/card_status.dart';

class CardController extends GetxController {
  final CardRepository _repository = CardRepository();
  final DialogService _dialogService = Get.find<DialogService>();

  // Observable lists and states
  final RxList<CardModel> _cards = <CardModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentListId = 0.obs;

  // Form controllers for card creation/editing
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Getters
  List<CardModel> get cards => _cards.toList();
  List<CardModel> get filteredCards {
    if (_searchQuery.value.isEmpty) {
      return _cards.toList();
    }
    return _cards
        .where(
          (card) => card.title.toLowerCase().contains(
            _searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  int get currentListId => _currentListId.value;

  // Computed properties
  int get totalCards => _cards.length;
  bool get hasCards => _cards.isNotEmpty;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Set current list and load its cards
  Future<void> setListId(int listId, {bool showLoading = true}) async {
    _currentListId.value = listId;
    await loadCardsForList(listId, showLoading: showLoading);
  }

  // Load cards for a specific list
  Future<void> loadCardsForList(int listId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final cards = await _repository.getCardsByListId(listId);
      _cards.assignAll(cards);
      _currentListId.value = listId;
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load cards: ${e.toString()}',
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load all cards across all lists
  Future<void> loadAllCards({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final cards = await _repository.getAllCards();
      _cards.assignAll(cards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load all cards: ${e.toString()}',
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Create a new card
  Future<void> createCard({
    required int listId,
    required String title,
    String? description,
    double? position,
    CardStatus? status,
  }) async {
    if (title.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final card = await _repository.createCard(
        listId: listId,
        title: title.trim(),
        description: description?.trim(),
        position: position,
        status: status?.value,
      );

      // Add to cards list (we now load all cards, so always add)
      _cards.add(card);
      _sortCardsByPosition();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.cardAddedSuccessfully.tr,
      );

      clearForm();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: '${LocalKeys.failedToAddCard.tr}: ${e.toString()}',
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update card
  Future<void> updateCard(CardModel card) async {
    try {
      _isUpdating.value = true;

      final updatedCard = await _repository.updateCard(card);
      if (updatedCard != null) {
        final index = _cards.indexWhere((c) => c.id == card.id);
        if (index != -1) {
          _cards[index] = updatedCard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.cardUpdatedSuccessfully.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: '${LocalKeys.failedToUpdateCard.tr}: ${e.toString()}',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Update card title
  Future<void> updateCardTitle(int id, String newTitle) async {
    try {
      final updatedCard = await _repository.updateCardTitle(
        id,
        newTitle.trim(),
      );
      if (updatedCard != null) {
        final index = _cards.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cards[index] = updatedCard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card title updated successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update card title: ${e.toString()}',
      );
    }
  }

  // Update card description
  Future<void> updateCardDescription(int id, String? newDescription) async {
    try {
      final updatedCard = await _repository.updateCardDescription(
        id,
        newDescription?.trim(),
      );
      if (updatedCard != null) {
        final index = _cards.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cards[index] = updatedCard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card description updated successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update card description: ${e.toString()}',
      );
    }
  }

  // Update card status
  Future<void> updateCardStatus(int id, CardStatus newStatus) async {
    try {
      final updatedCard = await _repository.updateCardStatus(
        id,
        newStatus.value,
      );
      if (updatedCard != null) {
        final index = _cards.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cards[index] = updatedCard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card status updated successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update card status: ${e.toString()}',
      );
    }
  }

  // Archive card
  Future<void> archiveCard(int id) async {
    try {
      final success = await _repository.archiveCard(id);
      if (success) {
        _cards.removeWhere((card) => card.id == id);
        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card archived successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive card: ${e.toString()}',
      );
    }
  }

  // Unarchive card
  Future<void> unarchiveCard(int id) async {
    try {
      final success = await _repository.unarchiveCard(id);
      if (success) {
        // Reload cards to include the unarchived card if needed
        if (_currentListId.value > 0) {
          await loadCardsForList(_currentListId.value, showLoading: false);
        }
        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card unarchived successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to unarchive card: ${e.toString()}',
      );
    }
  }

  // Complete card
  Future<void> completeCard(int id) async {
    try {
      // First, mark the card as completed in the database
      final success = await _repository.completeCard(id);
      if (success) {
        // Then update the status to 'done'
        await updateCardStatus(id, CardStatus.done);

        final index = _cards.indexWhere((card) => card.id == id);
        if (index != -1) {
          _cards[index] = _cards[index].copyWith(
            completedAt: DateTime.now(),
            status: CardStatus.done,
          );
        }

        // Use a delayed call to avoid snackbar controller issues
        Future.delayed(Duration.zero, () {
          _dialogService.showSuccessSnackbar(
            title: LocalKeys.success.tr,
            message: 'Card marked as completed',
          );
        });
      }
    } catch (e) {
      // Use a delayed call to avoid snackbar controller issues
      Future.delayed(Duration.zero, () {
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to complete card: ${e.toString()}',
        );
      });
    }
  }

  // Uncomplete card
  Future<void> uncompleteCard(int id) async {
    try {
      // First, mark the card as not completed in the database
      final success = await _repository.uncompleteCard(id);
      if (success) {
        // Then update the status to 'todo'
        await updateCardStatus(id, CardStatus.todo);

        final index = _cards.indexWhere((card) => card.id == id);
        if (index != -1) {
          _cards[index] = _cards[index].copyWith(
            completedAt: null,
            status: CardStatus.todo,
          );
        }

        // Use a delayed call to avoid snackbar controller issues
        Future.delayed(Duration.zero, () {
          _dialogService.showSuccessSnackbar(
            title: LocalKeys.success.tr,
            message: 'Card marked as incomplete',
          );
        });
      }
    } catch (e) {
      // Use a delayed call to avoid snackbar controller issues
      Future.delayed(Duration.zero, () {
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to uncomplete card: ${e.toString()}',
        );
      });
    }
  }

  // Delete card
  Future<void> deleteCard(int id) async {
    try {
      _isDeleting.value = true;
      final success = await _repository.deleteCard(id);
      if (success) {
        _cards.removeWhere((card) => card.id == id);
        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.cardDeletedSuccessfully.tr,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: '${LocalKeys.failedToDeleteCard.tr}: ${e.toString()}',
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Move card to a different list
  Future<void> moveCardToList(
    int cardId,
    int newListId, {
    double? newPosition,
  }) async {
    try {
      final updatedCard = await _repository.moveCardToList(
        cardId,
        newListId,
        newPosition: newPosition,
      );
      if (updatedCard != null) {
        // Update the card in the list (since we load all cards now)
        final index = _cards.indexWhere((card) => card.id == cardId);
        if (index != -1) {
          _cards[index] = updatedCard;
        } else {
          _cards.add(updatedCard);
        }
        _sortCardsByPosition();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Card moved to new list successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to move card: ${e.toString()}',
      );
    }
  }

  // Search cards in current list
  Future<void> searchCardsInList(String query) async {
    _searchQuery.value = query.trim();
    if (_currentListId.value > 0) {
      try {
        _isLoading.value = true;
        final cards = await _repository.searchCardsInList(
          _currentListId.value,
          query,
        );
        _cards.assignAll(cards);
      } catch (e) {
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to search cards: ${e.toString()}',
        );
      } finally {
        _isLoading.value = false;
      }
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    if (_currentListId.value > 0) {
      loadCardsForList(_currentListId.value, showLoading: false);
    }
  }

  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
  }

  // Populate form from card
  void populateFormFromCard(CardModel card) {
    titleController.text = card.title;
    descriptionController.text = card.description ?? '';
  }

  // Sort cards by position
  void _sortCardsByPosition() {
    _cards.sort((a, b) => a.position.compareTo(b.position));
  }

  // Method to refresh cards for a specific list
  Future<void> refreshCardsForList(int listId) async {
    if (listId == _currentListId.value) {
      await loadCardsForList(listId, showLoading: false);
    }
  }
}
