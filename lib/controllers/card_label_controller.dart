import 'package:get/get.dart';
import '../data/repository/card_label_repository.dart';
import '../models/card_label_model.dart';

class CardLabelController extends GetxController {
  final CardLabelRepository _cardLabelRepository = CardLabelRepository();

  // Observable lists
  final RxList<CardLabelModel> _cardLabels = <CardLabelModel>[].obs;
  final RxMap<int, List<CardLabelModel>> _cardLabelsMap = <int, List<CardLabelModel>>{}.obs;
  final RxMap<int, List<int>> _labelCardsMap = <int, List<int>>{}.obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isAssigning = false.obs;
  final RxBool _isRemoving = false.obs;
  final RxBool _isUpdating = false.obs;

  // Statistics
  final RxMap<int, Map<String, dynamic>> _labelUsageStats = <int, Map<String, dynamic>>{}.obs;
  final RxMap<int, int> _cardsCountByLabels = <int, int>{}.obs;

  // Getters
  List<CardLabelModel> get cardLabels => _cardLabels;
  Map<int, List<CardLabelModel>> get cardLabelsMap => _cardLabelsMap;
  Map<int, List<int>> get labelCardsMap => _labelCardsMap;
  
  bool get isLoading => _isLoading.value;
  bool get isAssigning => _isAssigning.value;
  bool get isRemoving => _isRemoving.value;
  bool get isUpdating => _isUpdating.value;
  
  Map<int, Map<String, dynamic>> get labelUsageStats => _labelUsageStats;
  Map<int, int> get cardsCountByLabels => _cardsCountByLabels;

  // Assign label to card
  Future<bool> assignLabelToCard(int cardId, int labelId) async {
    try {
      _isAssigning.value = true;
      
      final success = await _cardLabelRepository.assignLabelToCard(cardId, labelId);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update label cards mapping
        await loadCardsByLabel(labelId);
        
        // Update statistics
        await loadLabelUsageStats(labelId);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isAssigning.value = false;
    }
  }

  // Remove label from card
  Future<bool> removeLabelFromCard(int cardId, int labelId) async {
    try {
      _isRemoving.value = true;
      
      final success = await _cardLabelRepository.removeLabelFromCard(cardId, labelId);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update label cards mapping
        await loadCardsByLabel(labelId);
        
        // Update statistics
        await loadLabelUsageStats(labelId);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRemoving.value = false;
    }
  }

  // Load all labels for a card
  Future<void> loadCardLabels(int cardId) async {
    try {
      _isLoading.value = true;
      
      final labels = await _cardLabelRepository.getCardLabels(cardId);
      
      // Update the map for this specific card
      _cardLabelsMap[cardId] = labels;
      
      // Update the main list if it's the currently focused card
      _cardLabels.assignAll(labels);
    } catch (e) {
      _cardLabelsMap[cardId] = [];
      _cardLabels.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // Load all cards that have a specific label
  Future<void> loadCardsByLabel(int labelId) async {
    try {
      final cardIds = await _cardLabelRepository.getCardsByLabel(labelId);
      _labelCardsMap[labelId] = cardIds;
    } catch (e) {
      _labelCardsMap[labelId] = [];
    }
  }

  // Check if card has specific label
  Future<bool> cardHasLabel(int cardId, int labelId) async {
    try {
      return await _cardLabelRepository.cardHasLabel(cardId, labelId);
    } catch (e) {
      return false;
    }
  }

  // Get card label assignment by ID
  Future<CardLabelModel?> getCardLabelById(int id) async {
    try {
      return await _cardLabelRepository.getCardLabelById(id);
    } catch (e) {
      return null;
    }
  }

  // Remove all labels from card
  Future<bool> removeAllLabelsFromCard(int cardId) async {
    try {
      _isRemoving.value = true;
      
      // Get current labels to update their stats later
      final currentLabels = getCardLabelsFromMap(cardId);
      final labelIds = currentLabels.map((cl) => cl.labelId).toList();
      
      final success = await _cardLabelRepository.removeAllLabelsFromCard(cardId);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update all affected label mappings and stats
        for (final labelId in labelIds) {
          await loadCardsByLabel(labelId);
          await loadLabelUsageStats(labelId);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRemoving.value = false;
    }
  }

  // Restore label assignment
  Future<bool> restoreCardLabel(int cardId, int labelId) async {
    try {
      _isUpdating.value = true;
      
      final success = await _cardLabelRepository.restoreCardLabel(cardId, labelId);
      
      if (success) {
        await loadCardLabels(cardId);
        await loadCardsByLabel(labelId);
        await loadLabelUsageStats(labelId);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Permanently delete card label assignment
  Future<bool> permanentlyDeleteCardLabel(int id) async {
    try {
      _isRemoving.value = true;
      
      // Get the assignment details before deletion
      final cardLabel = await getCardLabelById(id);
      
      final success = await _cardLabelRepository.permanentlyDeleteCardLabel(id);
      
      if (success && cardLabel != null) {
        await loadCardLabels(cardLabel.cardId);
        await loadCardsByLabel(cardLabel.labelId);
        await loadLabelUsageStats(cardLabel.labelId);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRemoving.value = false;
    }
  }

  // Load label usage statistics
  Future<void> loadLabelUsageStats(int labelId) async {
    try {
      final stats = await _cardLabelRepository.getLabelUsageStats(labelId);
      if (stats != null) {
        _labelUsageStats[labelId] = stats;
      }
    } catch (e) {
      _labelUsageStats.remove(labelId);
    }
  }

  // Batch assign labels to card
  Future<bool> batchAssignLabelsToCard(int cardId, List<int> labelIds) async {
    try {
      _isAssigning.value = true;
      
      final success = await _cardLabelRepository.batchAssignLabelsToCard(cardId, labelIds);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update all affected label mappings and stats
        for (final labelId in labelIds) {
          await loadCardsByLabel(labelId);
          await loadLabelUsageStats(labelId);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isAssigning.value = false;
    }
  }

  // Batch remove labels from card
  Future<bool> batchRemoveLabelsFromCard(int cardId, List<int> labelIds) async {
    try {
      _isRemoving.value = true;
      
      final success = await _cardLabelRepository.batchRemoveLabelsFromCard(cardId, labelIds);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update all affected label mappings and stats
        for (final labelId in labelIds) {
          await loadCardsByLabel(labelId);
          await loadLabelUsageStats(labelId);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRemoving.value = false;
    }
  }

  // Update card labels (replace all labels for a card)
  Future<bool> updateCardLabels(int cardId, List<int> labelIds) async {
    try {
      _isUpdating.value = true;
      
      // Get current labels to know which ones to update stats for
      final currentLabels = getCardLabelsFromMap(cardId);
      final currentLabelIds = currentLabels.map((cl) => cl.labelId).toList();
      
      final success = await _cardLabelRepository.updateCardLabels(cardId, labelIds);
      
      if (success) {
        // Refresh card labels
        await loadCardLabels(cardId);
        
        // Update all affected label mappings and stats (both old and new)
        final allAffectedLabelIds = {...currentLabelIds, ...labelIds};
        for (final labelId in allAffectedLabelIds) {
          await loadCardsByLabel(labelId);
          await loadLabelUsageStats(labelId);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Toggle label assignment
  Future<bool> toggleLabelAssignment(int cardId, int labelId) async {
    try {
      final success = await _cardLabelRepository.toggleLabelAssignment(cardId, labelId);
      
      if (success) {
        await loadCardLabels(cardId);
        await loadCardsByLabel(labelId);
        await loadLabelUsageStats(labelId);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Load all card-label assignments
  Future<void> loadAllCardLabels() async {
    try {
      _isLoading.value = true;
      
      final allCardLabels = await _cardLabelRepository.getAllCardLabels();
      _cardLabels.assignAll(allCardLabels);
      
      // Group by card ID
      _cardLabelsMap.clear();
      for (final cardLabel in allCardLabels) {
        if (!_cardLabelsMap.containsKey(cardLabel.cardId)) {
          _cardLabelsMap[cardLabel.cardId] = [];
        }
        _cardLabelsMap[cardLabel.cardId]!.add(cardLabel);
      }
      
      // Group by label ID
      _labelCardsMap.clear();
      for (final cardLabel in allCardLabels) {
        if (!_labelCardsMap.containsKey(cardLabel.labelId)) {
          _labelCardsMap[cardLabel.labelId] = [];
        }
        if (!_labelCardsMap[cardLabel.labelId]!.contains(cardLabel.cardId)) {
          _labelCardsMap[cardLabel.labelId]!.add(cardLabel.cardId);
        }
      }
    } catch (e) {
      _cardLabels.clear();
      _cardLabelsMap.clear();
      _labelCardsMap.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // Clean up old deleted card label assignments
  Future<bool> cleanupDeletedCardLabels({int daysOld = 30}) async {
    try {
      _isRemoving.value = true;
      
      final success = await _cardLabelRepository.cleanupDeletedCardLabels(daysOld: daysOld);
      
      if (success) {
        // Refresh all data
        await loadAllCardLabels();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRemoving.value = false;
    }
  }

  // Advanced operations
  
  // Copy labels from one card to another
  Future<bool> copyLabelsToCard(int fromCardId, int toCardId) async {
    try {
      _isUpdating.value = true;
      
      final success = await _cardLabelRepository.copyLabelsToCard(fromCardId, toCardId);
      
      if (success) {
        await loadCardLabels(fromCardId);
        await loadCardLabels(toCardId);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Move labels from one card to another
  Future<bool> moveLabelsToCard(int fromCardId, int toCardId) async {
    try {
      _isUpdating.value = true;
      
      final success = await _cardLabelRepository.moveLabelsToCard(fromCardId, toCardId);
      
      if (success) {
        await loadCardLabels(fromCardId);
        await loadCardLabels(toCardId);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Load cards count by labels
  Future<void> loadCardsCountByLabels(List<int> labelIds) async {
    try {
      final counts = await _cardLabelRepository.getCardsCountByLabels(labelIds);
      _cardsCountByLabels.addAll(counts);
    } catch (e) {
      // Handle error silently
    }
  }

  // Helper methods
  
  // Get labels for a specific card from the map
  List<CardLabelModel> getCardLabelsFromMap(int cardId) {
    return _cardLabelsMap[cardId] ?? [];
  }

  // Get cards for a specific label from the map
  List<int> getCardsFromMap(int labelId) {
    return _labelCardsMap[labelId] ?? [];
  }

  // Get label IDs for a specific card
  List<int> getLabelIdsForCard(int cardId) {
    final cardLabels = getCardLabelsFromMap(cardId);
    return cardLabels.map((cl) => cl.labelId).toList();
  }

  // Check if card has label (from local data)
  bool cardHasLabelLocal(int cardId, int labelId) {
    final cardLabels = getCardLabelsFromMap(cardId);
    return cardLabels.any((cl) => cl.labelId == labelId);
  }

  // Get cards count for a label
  int getCardsCountForLabel(int labelId) {
    return _cardsCountByLabels[labelId] ?? getCardsFromMap(labelId).length;
  }

  // Refresh data for specific card
  Future<void> refreshCardData(int cardId) async {
    await loadCardLabels(cardId);
  }

  // Refresh data for specific label
  Future<void> refreshLabelData(int labelId) async {
    await Future.wait([
      loadCardsByLabel(labelId),
      loadLabelUsageStats(labelId),
    ]);
  }

  // Reset controller state
  void reset() {
    _cardLabels.clear();
    _cardLabelsMap.clear();
    _labelCardsMap.clear();
    _labelUsageStats.clear();
    _cardsCountByLabels.clear();
    _isLoading.value = false;
    _isAssigning.value = false;
    _isRemoving.value = false;
    _isUpdating.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
