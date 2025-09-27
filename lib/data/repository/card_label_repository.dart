import 'package:get/get.dart';
import '../../core/services/dialog_service.dart';
import '../../core/localization/local_keys.dart';
import '../../models/card_label_model.dart';
import '../database/card_label_dao.dart';

class CardLabelRepository {
  final CardLabelDao _cardLabelDao = CardLabelDao();
  final DialogService _dialogService = DialogService();

  // Helper methods for dialog service
  void _showError(String message) {
    _dialogService.showErrorSnackbar(
      title: LocalKeys.error.tr,
      message: message,
    );
  }

  void _showSuccess(String message) {
    _dialogService.showSuccessSnackbar(
      title: LocalKeys.success.tr,
      message: message,
    );
  }

  void _showInfo(String message) {
    _dialogService.showSnack(
      title: 'Info',
      message: message,
    );
  }

  // Assign label to card
  Future<bool> assignLabelToCard(int cardId, int labelId) async {
    try {
      // Check if already assigned
      final alreadyAssigned = await _cardLabelDao.cardHasLabel(cardId, labelId);
      if (alreadyAssigned) {
        _showError(LocalKeys.labelAlreadyAssignedToCard.tr);
        return true; // Consider this a success
      }

      final result = await _cardLabelDao.assignLabelToCard(cardId, labelId);
      if (result > 0) {
        _showSuccess(LocalKeys.labelAssignedToCardSuccessfully.tr);
        return true;
      }

      return false;
    } catch (e) {
      _showError('${LocalKeys.errorAssigningLabelToCard.tr}: $e');
      return false;
    }
  }

  // Remove label from card
  Future<bool> removeLabelFromCard(int cardId, int labelId) async {
    try {
      final result = await _cardLabelDao.removeLabelFromCard(cardId, labelId);
      if (result > 0) {
        _showSuccess(LocalKeys.labelRemovedFromCardSuccessfully.tr);
        return true;
      }

      _showError(LocalKeys.labelNotAssignedToCard.tr);
      return false;
    } catch (e) {
      _showError('${LocalKeys.errorRemovingLabelFromCard.tr}: $e');
      return false;
    }
  }

  // Get all labels for a card
  Future<List<CardLabelModel>> getCardLabels(int cardId) async {
    try {
      return await _cardLabelDao.getCardLabels(cardId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingCardLabels.tr}: $e');
      return [];
    }
  }

  // Get all cards that have a specific label
  Future<List<int>> getCardsByLabel(int labelId) async {
    try {
      return await _cardLabelDao.getCardsByLabel(labelId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingCardsByLabel.tr}: $e');
      return [];
    }
  }

  // Check if card has specific label
  Future<bool> cardHasLabel(int cardId, int labelId) async {
    try {
      return await _cardLabelDao.cardHasLabel(cardId, labelId);
    } catch (e) {
      return false;
    }
  }

  // Get card label assignment by ID
  Future<CardLabelModel?> getCardLabelById(int id) async {
    try {
      return await _cardLabelDao.getCardLabelById(id);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingCardLabel.tr}: $e');
      return null;
    }
  }

  // Remove all labels from card
  Future<bool> removeAllLabelsFromCard(int cardId) async {
    try {
      final result = await _cardLabelDao.removeAllLabelsFromCard(cardId);
      if (result > 0) {
        _showSuccess(LocalKeys.allLabelsRemovedFromCardSuccessfully.tr);
        return true;
      }

      return false;
    } catch (e) {
      _showError('${LocalKeys.errorRemovingAllLabelsFromCard.tr}: $e');
      return false;
    }
  }

  // Restore label assignment
  Future<bool> restoreCardLabel(int cardId, int labelId) async {
    try {
      final result = await _cardLabelDao.restoreCardLabel(cardId, labelId);
      if (result > 0) {
        _showSuccess(LocalKeys.labelAssignmentRestoredSuccessfully.tr);
        return true;
      }

      return false;
    } catch (e) {
      _showError('${LocalKeys.errorRestoringLabelAssignment.tr}: $e');
      return false;
    }
  }

  // Permanently delete card label assignment
  Future<bool> permanentlyDeleteCardLabel(int id) async {
    try {
      final result = await _cardLabelDao.hardDeleteCardLabel(id);
      if (result > 0) {
        _showSuccess(LocalKeys.labelAssignmentPermanentlyDeletedSuccessfully.tr);
        return true;
      }

      return false;
    } catch (e) {
      _showError('${LocalKeys.errorPermanentlyDeletingLabelAssignment.tr}: $e');
      return false;
    }
  }

  // Get label usage statistics
  Future<Map<String, dynamic>?> getLabelUsageStats(int labelId) async {
    try {
      return await _cardLabelDao.getLabelUsageStats(labelId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingLabelUsageStats.tr}: $e');
      return null;
    }
  }

  // Batch assign labels to card
  Future<bool> batchAssignLabelsToCard(int cardId, List<int> labelIds) async {
    try {
      if (labelIds.isEmpty) {
        return true; // Nothing to assign
      }

      await _cardLabelDao.batchAssignLabelsToCard(cardId, labelIds);
      _showSuccess(LocalKeys.labelsAssignedToCardSuccessfully.tr);
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorAssigningLabelsToCard.tr}: $e');
      return false;
    }
  }

  // Batch remove labels from card
  Future<bool> batchRemoveLabelsFromCard(int cardId, List<int> labelIds) async {
    try {
      if (labelIds.isEmpty) {
        return true; // Nothing to remove
      }

      await _cardLabelDao.batchRemoveLabelsFromCard(cardId, labelIds);
      _showSuccess(LocalKeys.labelsRemovedFromCardSuccessfully.tr);
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorRemovingLabelsFromCard.tr}: $e');
      return false;
    }
  }

  // Update card labels (replace all labels for a card)
  Future<bool> updateCardLabels(int cardId, List<int> labelIds) async {
    try {
      await _cardLabelDao.updateCardLabels(cardId, labelIds);
      _showSuccess(LocalKeys.cardLabelsUpdatedSuccessfully.tr);
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorUpdatingCardLabels.tr}: $e');
      return false;
    }
  }

  // Toggle label assignment (assign if not assigned, remove if assigned)
  Future<bool> toggleLabelAssignment(int cardId, int labelId) async {
    try {
      final hasLabel = await cardHasLabel(cardId, labelId);
      
      if (hasLabel) {
        return await removeLabelFromCard(cardId, labelId);
      } else {
        return await assignLabelToCard(cardId, labelId);
      }
    } catch (e) {
      _showError('${LocalKeys.errorTogglingLabelAssignment.tr}: $e');
      return false;
    }
  }

  // Get all card-label assignments
  Future<List<CardLabelModel>> getAllCardLabels() async {
    try {
      return await _cardLabelDao.getAllCardLabels();
    } catch (e) {
      _showError('${LocalKeys.errorLoadingAllCardLabels.tr}: $e');
      return [];
    }
  }

  // Clean up old deleted card label assignments
  Future<bool> cleanupDeletedCardLabels({int daysOld = 30}) async {
    try {
      final deletedCount = await _cardLabelDao.cleanupDeletedCardLabels(daysOld: daysOld);
      if (deletedCount > 0) {
        _showSuccess(
          '${LocalKeys.cleanupCompleted.tr}: $deletedCount ${LocalKeys.labelAssignmentsRemoved.tr}'
        );
      }
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorCleaningUpLabelAssignments.tr}: $e');
      return false;
    }
  }

  // Advanced operations
  
  // Copy labels from one card to another
  Future<bool> copyLabelsToCard(int fromCardId, int toCardId) async {
    try {
      final sourceLabels = await getCardLabels(fromCardId);
      final labelIds = sourceLabels.map((cl) => cl.labelId).toList();
      
      if (labelIds.isEmpty) {
        _showError(LocalKeys.noLabelsToCoopy.tr);
        return true;
      }

      return await batchAssignLabelsToCard(toCardId, labelIds);
    } catch (e) {
      _showError('${LocalKeys.errorCopyingLabelsToCard.tr}: $e');
      return false;
    }
  }

  // Move labels from one card to another (copy then remove from source)
  Future<bool> moveLabelsToCard(int fromCardId, int toCardId) async {
    try {
      final sourceLabels = await getCardLabels(fromCardId);
      final labelIds = sourceLabels.map((cl) => cl.labelId).toList();
      
      if (labelIds.isEmpty) {
        _showError(LocalKeys.noLabelsToMove.tr);
        return true;
      }

      // First assign to target card
      final assignSuccess = await batchAssignLabelsToCard(toCardId, labelIds);
      if (!assignSuccess) {
        return false;
      }

      // Then remove from source card
      return await removeAllLabelsFromCard(fromCardId);
    } catch (e) {
      _showError('${LocalKeys.errorMovingLabelsToCard.tr}: $e');
      return false;
    }
  }

  // Get cards count by label
  Future<Map<int, int>> getCardsCountByLabels(List<int> labelIds) async {
    try {
      final Map<int, int> result = {};
      
      for (final labelId in labelIds) {
        final cards = await getCardsByLabel(labelId);
        result[labelId] = cards.length;
      }
      
      return result;
    } catch (e) {
      return {};
    }
  }
}
