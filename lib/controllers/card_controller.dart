import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import 'package:kanbankit/models/card_model.dart';
import 'package:kanbankit/data/repository/card_repository.dart';
import 'package:kanbankit/core/enums/card_status.dart';

import '../core/utils/logger/app_logger.dart';
import '../controllers/activity_log_controller.dart';
import '../models/activity_log_model.dart';

class CardController extends GetxController {
  final CardRepository _repository = CardRepository();
  final DialogService _dialogService = Get.find<DialogService>();
  
  // Activity log controller (lazy loaded)
  ActivityLogController? get _activityLogController {
    try {
      return Get.isRegistered<ActivityLogController>() 
          ? Get.find<ActivityLogController>() 
          : null;
    } catch (e) {
      return null;
    }
  }

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
    DateTime? dueDate,
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
        dueDate: dueDate,
      );

      // Add to cards list (we now load all cards, so always add)
      _cards.add(card);
      _sortCardsByPosition();

      // Log activity
      _activityLogController?.logCardActivity(
        cardId: card.id!,
        actionType: ActionType.created,
        description: 'Created card: ${card.title}',
      );

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
      AppLogger.error('Failed to update card: ${e.toString()}');
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
        String? oldTitle;
        if (index != -1) {
          oldTitle = _cards[index].title;
          _cards[index] = updatedCard;
          _cards.refresh();
        }

        // Log activity
        _activityLogController?.logCardActivity(
          cardId: id,
          actionType: ActionType.updated,
          oldValue: oldTitle,
          newValue: newTitle.trim(),
          description: 'Updated card title',
        );

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
        String? oldDescription;
        if (index != -1) {
          oldDescription = _cards[index].description;
          _cards[index] = updatedCard;
          _cards.refresh();
        }

        // Log activity
        _activityLogController?.logCardActivity(
          cardId: id,
          actionType: ActionType.updated,
          oldValue: oldDescription,
          newValue: newDescription?.trim(),
          description: 'Updated card description',
        );

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
      AppLogger.error('Failed to update card description: ${e.toString()}');
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
          _cards.refresh();
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
          final updatedCard = _cards[index].copyWith(
            completedAt: DateTime.now(),
            status: CardStatus.done,
            updatedAt: DateTime.now(),
          );
          _cards[index] = updatedCard;
          _cards.refresh();
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
          final updatedCard = _cards[index].copyWith(
            clearCompletedAt: true, // Clear completed date
            status: CardStatus.todo,
            updatedAt: DateTime.now(),
          );
          _cards[index] = updatedCard;
          _cards.refresh();
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

  // Delete card (soft delete)
  Future<void> softDeleteCard(int id) async {
    try {
      _isDeleting.value = true;
      final success = await _repository.softDeleteCard(id);
      if (success) {
        final deletedCard = _cards.firstWhere((card) => card.id == id);
        _cards.removeWhere((card) => card.id == id);
        
        // Log activity
        _activityLogController?.logCardActivity(
          cardId: id,
          actionType: ActionType.deleted,
          description: 'Deleted card: ${deletedCard.title}',
        );
        
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

  //Change cover color
  Future<void> changeCoverColor(int cardId, String coverColor) async {
    try {
      AppLogger.info(
        'Attempting to change cover color for card $cardId to: "$coverColor"',
      );
      final success = await _repository.changeCoverColor(cardId, coverColor);
      AppLogger.info('Repository changeCoverColor returned: $success');

      if (success) {
        final index = _cards.indexWhere((card) => card.id == cardId);
        AppLogger.info('Found card at index: $index');

        if (index != -1) {
          // Create a new card instance with updated cover color
          final updatedCard = coverColor.isEmpty
              ? _cards[index].copyWith(
                  clearCoverColor: true, // Only clear flag when removing
                  updatedAt: DateTime.now(),
                )
              : _cards[index].copyWith(
                  coverColor: coverColor, // Only set color when adding/changing
                  updatedAt: DateTime.now(),
                );
          AppLogger.info('Updated card cover color: ${updatedCard.coverColor}');

          // Replace the card in the list to trigger reactivity
          _cards[index] = updatedCard;
          // Force refresh of the observable list
          _cards.refresh();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: coverColor.isEmpty
              ? 'Cover color removed successfully'
              : 'Cover color changed successfully',
        );
      } else {
        AppLogger.warning('Repository changeCoverColor returned false');
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to update cover color in database',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to change cover color: ${e.toString()}',
      );
      AppLogger.error('Failed to change cover color: ${e.toString()}');
    }
  }

  //Change cover image
  Future<void> changeCoverImage(int cardId, String coverImage) async {
    try {
      AppLogger.info(
        'Attempting to change cover image for card $cardId to: "$coverImage"',
      );
      final success = await _repository.changeCoverImage(cardId, coverImage);
      AppLogger.info('Repository changeCoverImage returned: $success');

      if (success) {
        final index = _cards.indexWhere((card) => card.id == cardId);
        AppLogger.info('Found card at index: $index');

        if (index != -1) {
          // Create a new card instance with updated cover image
          final updatedCard = coverImage.isEmpty
              ? _cards[index].copyWith(
                  clearCoverImage: true, // Only clear flag when removing
                  updatedAt: DateTime.now(),
                )
              : _cards[index].copyWith(
                  coverImage: coverImage, // Only set image when adding/changing
                  updatedAt: DateTime.now(),
                );
          AppLogger.info('Updated card cover image: ${updatedCard.coverImage}');

          // Replace the card in the list to trigger reactivity
          _cards[index] = updatedCard;
          // Force refresh of the observable list
          _cards.refresh();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: coverImage.isEmpty
              ? 'Cover image removed successfully'
              : 'Cover image changed successfully',
        );
      } else {
        AppLogger.warning('Repository changeCoverImage returned false');
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to update cover image in database',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to change cover image: ${e.toString()}',
      );
      AppLogger.error('Failed to change cover image: ${e.toString()}');
    }
  }

  Future<void> setDueDate(int cardId, DateTime? dueDate) async {
    try {
      _isUpdating.value = true;
      AppLogger.info(
        'Attempting to set due date for card $cardId to: $dueDate',
      );

      final success = await _repository.setDueDate(cardId, dueDate);
      AppLogger.info('Repository setDueDate returned: $success');

      if (success > 0) {
        final index = _cards.indexWhere((card) => card.id == cardId);
        AppLogger.info('Found card at index: $index');

        if (index != -1) {
          // Create a new card instance with updated due date
          final updatedCard = _cards[index].copyWith(
            dueDate: dueDate,
            clearDueDate: dueDate == null, // Clear due date if null
            updatedAt: DateTime.now(),
          );
          AppLogger.info('Updated card due date: ${updatedCard.dueDate}');

          // Replace the card in the list to trigger reactivity
          _cards[index] = updatedCard;
          // Force refresh of the observable list
          _cards.refresh();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: dueDate != null
              ? 'Due date set successfully'
              : 'Due date cleared',
        );
      } else {
        AppLogger.warning('Repository setDueDate returned 0 or negative value');
        _dialogService.showErrorSnackbar(
          title: LocalKeys.error.tr,
          message: 'Failed to update due date in database',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update due date: ${e.toString()}',
      );
      AppLogger.error('Failed to update due date: ${e.toString()}');
    } finally {
      _isUpdating.value = false;
    }
  }

  Future<void> loadCardsByDueDate({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final cardsWithDueDate = await _repository.fetchCardsWithDueDates();
      _cards.assignAll(cardsWithDueDate);
      _cards.sort(
        (a, b) =>
            a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ??
            (b.dueDate != null ? 1 : 0),
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load cards by due date: ${e.toString()}',
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  Future<void> loadOverdueCards({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final overdueCards = await _repository.fetchOverdueCards();
      _cards.assignAll(overdueCards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load overdue cards: ${e.toString()}',
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }
}
