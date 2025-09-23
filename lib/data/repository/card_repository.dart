import '../../models/card_model.dart';
import '../../core/enums/card_status.dart';
import '../database/card_dao.dart';

class CardRepository {
  final CardDao _cardDao = CardDao();

  // Create a new card
  Future<CardModel> createCard({
    required int listId,
    required String title,
    String? description,
    double? position,
    String? status,
  }) async {
    // Validate title length
    if (title.isEmpty || title.length > 255) {
      throw Exception('Card title must be between 1 and 255 characters');
    }

    // Check if title already exists in the list
    final titleExists = await _cardDao.titleExistsInList(listId, title);
    if (titleExists) {
      throw Exception('A card with this title already exists in the list');
    }

    // Get next position if not provided
    final cardPosition = position ?? await _cardDao.getNextPosition(listId);

    final card = CardModel(
      listId: listId,
      title: title,
      description: description,
      position: cardPosition,
      status: status != null ? CardStatus.fromString(status) : CardStatus.todo,
    );

    final id = await _cardDao.insert(card);
    return card.copyWith(id: id);
  }

  // Get all cards for a specific list
  Future<List<CardModel>> getCardsByListId(
    int listId, {
    bool includeArchived = false,
  }) async {
    return await _cardDao.getByListId(listId, includeArchived: includeArchived);
  }

  // Get all cards for a specific board (across all lists)
  Future<List<CardModel>> getCardsByBoardId(
    int boardId, {
    bool includeArchived = false,
  }) async {
    return await _cardDao.getByBoardId(
      boardId,
      includeArchived: includeArchived,
    );
  }

  // Get all cards across all boards and lists
  Future<List<CardModel>> getAllCards({bool includeArchived = false}) async {
    return await _cardDao.getAll(includeArchived: includeArchived);
  }

  // Get card by ID
  Future<CardModel?> getCardById(int id) async {
    return await _cardDao.getById(id);
  }

  // Update card
  Future<CardModel?> updateCard(CardModel card) async {
    // Validate title length
    if (card.title.isEmpty || card.title.length > 255) {
      throw Exception('Card title must be between 1 and 255 characters');
    }

    // Check if title already exists in the list (excluding current card)
    final titleExists = await _cardDao.titleExistsInList(
      card.listId,
      card.title,
      excludeCardId: card.id,
    );
    if (titleExists) {
      throw Exception('A card with this title already exists in the list');
    }

    final result = await _cardDao.update(card);
    if (result > 0) {
      return await _cardDao.getById(card.id!);
    }
    return null;
  }

  // Update card title
  Future<CardModel?> updateCardTitle(int id, String newTitle) async {
    final card = await _cardDao.getById(id);
    if (card == null) return null;

    return await updateCard(card.copyWith(title: newTitle));
  }

  // Update card description
  Future<CardModel?> updateCardDescription(
    int id,
    String? newDescription,
  ) async {
    final card = await _cardDao.getById(id);
    if (card == null) return null;

    return await updateCard(card.copyWith(description: newDescription));
  }

  // Update card status
  Future<CardModel?> updateCardStatus(int id, String newStatus) async {
    final card = await _cardDao.getById(id);
    if (card == null) return null;

    return await updateCard(
      card.copyWith(status: CardStatus.fromString(newStatus)),
    );
  }

  // Archive card
  Future<bool> archiveCard(int id) async {
    final result = await _cardDao.setArchived(id, true);
    return result > 0;
  }

  // Unarchive card
  Future<bool> unarchiveCard(int id) async {
    final result = await _cardDao.setArchived(id, false);
    return result > 0;
  }

  // Mark card as completed
  Future<bool> completeCard(int id) async {
    final result = await _cardDao.setCompleted(id, true);
    return result > 0;
  }

  // Mark card as not completed
  Future<bool> uncompleteCard(int id) async {
    final result = await _cardDao.setCompleted(id, false);
    return result > 0;
  }

  // Delete card
  Future<bool> softDeleteCard(int id) async {
    final result = await _cardDao.softDelete(id);
    return result > 0;
  }

  // Hard delete card
  Future<bool> hardDeleteCard(int id) async {
    final result = await _cardDao.hardDelete(id);
    return result > 0;
  }

  // Get archived cards for a specific list
  Future<List<CardModel>> getArchivedCardsByListId(int listId) async {
    return await _cardDao.getArchivedByListId(listId);
  }

  // Get all archived cards
  Future<List<CardModel>> getArchivedCards() async {
    return await _cardDao.getArchived();
  }

  // Update card position
  Future<bool> updateCardPosition(int id, double newPosition) async {
    final result = await _cardDao.updatePosition(id, newPosition);
    return result > 0;
  }

  // Reorder cards within a list
  Future<List<CardModel>> reorderCards(List<CardModel> cards) async {
    if (cards.isEmpty) return cards;

    // Validate that all cards belong to the same list
    final listId = cards.first.listId;
    if (!cards.every((card) => card.listId == listId)) {
      throw Exception('All cards must belong to the same list for reordering');
    }

    await _cardDao.reorderCards(cards);
    return await getCardsByListId(listId);
  }

  // Move card to new position within the same list
  Future<List<CardModel>> moveCardToPosition(
    int cardId,
    int newPosition,
  ) async {
    final card = await _cardDao.getById(cardId);
    if (card == null) {
      throw Exception('Card not found');
    }

    final cards = await getCardsByListId(card.listId);
    final cardIndex = cards.indexWhere((c) => c.id == cardId);

    if (cardIndex == -1) {
      throw Exception('Card not found in list');
    }

    final movedCard = cards.removeAt(cardIndex);
    cards.insert(newPosition.clamp(0, cards.length), movedCard);

    return await reorderCards(cards);
  }

  // Move card to a different list
  Future<CardModel?> moveCardToList(
    int cardId,
    int newListId, {
    double? newPosition,
  }) async {
    final card = await _cardDao.getById(cardId);
    if (card == null) return null;

    // Get next position if not provided
    final cardPosition =
        newPosition ?? await _cardDao.getNextPosition(newListId);

    final updatedCard = card.copyWith(
      listId: newListId,
      position: cardPosition,
    );

    final result = await _cardDao.update(updatedCard);
    if (result > 0) {
      return await _cardDao.getById(cardId);
    }
    return null;
  }

  // Search cards in a specific list
  Future<List<CardModel>> searchCardsInList(
    int listId,
    String query, {
    bool includeArchived = false,
  }) async {
    if (query.trim().isEmpty) {
      return await getCardsByListId(listId, includeArchived: includeArchived);
    }
    return await _cardDao.searchInList(
      listId,
      query.trim(),
      includeArchived: includeArchived,
    );
  }

  // Search cards across all lists
  Future<List<CardModel>> searchCards(
    String query, {
    bool includeArchived = false,
  }) async {
    if (query.trim().isEmpty) {
      return await getAllCards(includeArchived: includeArchived);
    }
    return await _cardDao.search(
      query.trim(),
      includeArchived: includeArchived,
    );
  }

  // Validate card data
  bool validateCardData({required String title, String? description}) {
    // Title validation
    if (title.isEmpty || title.length > 255) {
      return false;
    }

    // Description validation (if provided)
    if (description != null && description.length > 1000) {
      return false;
    }

    return true;
  }
}
