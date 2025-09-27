import 'package:get/get.dart';
import '../../core/services/dialog_service.dart';
import '../../core/localization/local_keys.dart';
import '../../models/label_model.dart';
import '../database/label_dao.dart';

class LabelRepository {
  final LabelDao _labelDao = LabelDao();
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

  // Create a new label
  Future<LabelModel?> createLabel({
    required int boardId,
    required String name,
    required String color,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        _showError(LocalKeys.labelNameRequired.tr);
        return null;
      }

      if (color.trim().isEmpty) {
        _showError(LocalKeys.labelColorRequired.tr);
        return null;
      }

      // Check if label name already exists in this board
      final nameExists = await _labelDao.labelNameExists(boardId, name.trim());
      if (nameExists) {
        _showError(LocalKeys.labelNameAlreadyExists.tr);
        return null;
      }

      // Create label
      final label = LabelModel.create(
        boardId: boardId,
        name: name.trim(),
        color: color.trim(),
      );

      // Validate label
      if (!label.isValid) {
        _showError(LocalKeys.invalidLabelData.tr);
        return null;
      }

      final labelId = await _labelDao.createLabel(label);
      final createdLabel = await _labelDao.getLabelById(labelId);

      if (createdLabel != null) {
        _showSuccess(LocalKeys.labelCreatedSuccessfully.tr);
        return createdLabel;
      }

      return null;
    } catch (e) {
      _showError('${LocalKeys.errorCreatingLabel.tr}: $e');
      return null;
    }
  }

  // Get label by ID
  Future<LabelModel?> getLabelById(int id) async {
    try {
      return await _labelDao.getLabelById(id);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingLabel.tr}: $e');
      return null;
    }
  }

  // Get all labels for a board
  Future<List<LabelModel>> getLabelsByBoardId(int boardId) async {
    try {
      return await _labelDao.getLabelsByBoardId(boardId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingLabels.tr}: $e');
      return [];
    }
  }

  // Get deleted labels for a board
  Future<List<LabelModel>> getDeletedLabelsByBoardId(int boardId) async {
    try {
      return await _labelDao.getDeletedLabelsByBoardId(boardId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingDeletedLabels.tr}: $e');
      return [];
    }
  }

  // Update label
  Future<bool> updateLabel(LabelModel label) async {
    try {
      // Validate input
      if (!label.isValid) {
        _showError(LocalKeys.invalidLabelData.tr);
        return false;
      }

      // Check if new name already exists (excluding current label)
      if (label.name.trim().isNotEmpty) {
        final nameExists = await _labelDao.labelNameExists(
          label.boardId,
          label.name.trim(),
          excludeId: label.id,
        );
        if (nameExists) {
          _showError(LocalKeys.labelNameAlreadyExists.tr);
          return false;
        }
      }

      final updatedLabel = label.updateWith(
        name: label.name.trim(),
        color: label.color.trim(),
      );

      final result = await _labelDao.updateLabel(updatedLabel);
      if (result > 0) {
        _showSuccess(LocalKeys.labelUpdatedSuccessfully.tr);
        return true;
      }

      return false;
    } catch (e) {
      _showError('${LocalKeys.errorUpdatingLabel.tr}: $e');
      return false;
    }
  }

  // Delete label (soft delete)
  Future<bool> deleteLabel(int id) async {
    try {
      final result = await _labelDao.softDeleteLabel(id);
      if (result > 0) {
        _showSuccess(LocalKeys.labelDeletedSuccessfully.tr);
        return true;
      }
      return false;
    } catch (e) {
      _showError('${LocalKeys.errorDeletingLabel.tr}: $e');
      return false;
    }
  }

  // Restore label from soft delete
  Future<bool> restoreLabel(int id) async {
    try {
      final result = await _labelDao.restoreLabel(id);
      if (result > 0) {
        _showSuccess(LocalKeys.labelRestoredSuccessfully.tr);
        return true;
      }
      return false;
    } catch (e) {
      _showError('${LocalKeys.errorRestoringLabel.tr}: $e');
      return false;
    }
  }

  // Permanently delete label
  Future<bool> permanentlyDeleteLabel(int id) async {
    try {
      final result = await _labelDao.hardDeleteLabel(id);
      if (result > 0) {
        _showSuccess(LocalKeys.labelPermanentlyDeletedSuccessfully.tr);
        return true;
      }
      return false;
    } catch (e) {
      _showError('${LocalKeys.errorPermanentlyDeletingLabel.tr}: $e');
      return false;
    }
  }

  // Search labels by name
  Future<List<LabelModel>> searchLabels(int boardId, String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getLabelsByBoardId(boardId);
      }
      return await _labelDao.searchLabelsByName(boardId, query.trim());
    } catch (e) {
      _showError('${LocalKeys.errorSearchingLabels.tr}: $e');
      return [];
    }
  }

  // Get labels by color
  Future<List<LabelModel>> getLabelsByColor(int boardId, String color) async {
    try {
      return await _labelDao.getLabelsByColor(boardId, color);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingLabelsByColor.tr}: $e');
      return [];
    }
  }

  // Get label statistics
  Future<Map<String, dynamic>?> getLabelStats(int boardId) async {
    try {
      return await _labelDao.getLabelStats(boardId);
    } catch (e) {
      _showError('${LocalKeys.errorLoadingLabelStats.tr}: $e');
      return null;
    }
  }

  // Duplicate label
  Future<LabelModel?> duplicateLabel(int labelId, String newName) async {
    try {
      final originalLabel = await _labelDao.getLabelById(labelId);
      if (originalLabel == null) {
        _showError(LocalKeys.labelNotFound.tr);
        return null;
      }

      return await createLabel(
        boardId: originalLabel.boardId,
        name: newName.trim(),
        color: originalLabel.color,
      );
    } catch (e) {
      _showError('${LocalKeys.errorDuplicatingLabel.tr}: $e');
      return null;
    }
  }

  // Batch operations
  Future<bool> batchCreateLabels(List<LabelModel> labels) async {
    try {
      // Validate all labels
      for (final label in labels) {
        if (!label.isValid) {
          _showError(LocalKeys.invalidLabelData.tr);
          return false;
        }
      }

      await _labelDao.batchCreateLabels(labels);
      _showSuccess(LocalKeys.labelsCreatedSuccessfully.tr);
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorCreatingLabels.tr}: $e');
      return false;
    }
  }

  Future<bool> batchDeleteLabels(List<int> labelIds) async {
    try {
      await _labelDao.batchDeleteLabels(labelIds);
      _showSuccess(LocalKeys.labelsDeletedSuccessfully.tr);
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorDeletingLabels.tr}: $e');
      return false;
    }
  }

  // Clean up old deleted labels
  Future<bool> cleanupDeletedLabels({int daysOld = 30}) async {
    try {
      final deletedCount = await _labelDao.cleanupDeletedLabels(daysOld: daysOld);
      if (deletedCount > 0) {
        _showSuccess(
          '${LocalKeys.cleanupCompleted.tr}: $deletedCount ${LocalKeys.labelsRemoved.tr}'
        );
      }
      return true;
    } catch (e) {
      _showError('${LocalKeys.errorCleaningUpLabels.tr}: $e');
      return false;
    }
  }

  // Validation helpers
  Future<bool> validateLabelName(int boardId, String name, {int? excludeId}) async {
    try {
      if (name.trim().isEmpty) return false;
      if (name.trim().length > 100) return false;
      
      return !(await _labelDao.labelNameExists(boardId, name.trim(), excludeId: excludeId));
    } catch (e) {
      return false;
    }
  }

  bool validateLabelColor(String color) {
    if (color.trim().isEmpty) return false;
    
    // Check if color is a valid hex color
    final hexPattern = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexPattern.hasMatch(color.trim());
  }
}
