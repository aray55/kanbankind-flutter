import '../database/checklist_dao.dart';
import '../../models/checklist_model.dart';

class ChecklistRepository {
  final ChecklistDao _checklistDao = ChecklistDao();

  // Create a new checklist
  Future<ChecklistModel?> createChecklist(ChecklistModel checklist) async {
    try {
      // Validate checklist data
      if (!checklist.isValidTitle) {
        throw Exception('Invalid checklist title');
      }

      // Check if title already exists in the card
      final titleExists = await _checklistDao.titleExistsInCard(
        checklist.cardId,
        checklist.title,
      );

      if (titleExists) {
        throw Exception('Checklist with this title already exists in this card');
      }

      // Get next position if not provided
      double position = checklist.position;
      if (position == 1024.0) {
        position = await _checklistDao.getNextPosition(checklist.cardId);
      }

      final checklistToCreate = checklist.copyWith(
        position: position,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _checklistDao.insert(checklistToCreate);
      return checklistToCreate.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create checklist: $e');
    }
  }

  // Get all checklists for a specific card
  Future<List<ChecklistModel>> getChecklistsByCardId(
    int cardId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      return await _checklistDao.getByCardId(
        cardId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    } catch (e) {
      throw Exception('Failed to get checklists for card: $e');
    }
  }

  // Get all checklists
  Future<List<ChecklistModel>> getAllChecklists({
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      return await _checklistDao.getAll(
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    } catch (e) {
      throw Exception('Failed to get all checklists: $e');
    }
  }

  // Get checklist by ID
  Future<ChecklistModel?> getChecklistById(int id) async {
    try {
      return await _checklistDao.getById(id);
    } catch (e) {
      throw Exception('Failed to get checklist by ID: $e');
    }
  }

  // Update checklist
  Future<bool> updateChecklist(ChecklistModel checklist) async {
    try {
      if (checklist.id == null) {
        throw Exception('Checklist ID is required for update');
      }

      // Validate checklist data
      if (!checklist.isValidTitle) {
        throw Exception('Invalid checklist title');
      }

      // Check if title already exists in the card (excluding current checklist)
      final titleExists = await _checklistDao.titleExistsInCard(
        checklist.cardId,
        checklist.title,
        excludeChecklistId: checklist.id,
      );

      if (titleExists) {
        throw Exception('Checklist with this title already exists in this card');
      }

      final updatedChecklist = checklist.copyWith(updatedAt: DateTime.now());
      final result = await _checklistDao.update(updatedChecklist);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update checklist: $e');
    }
  }

  // Soft delete checklist
  Future<bool> deleteChecklist(int id) async {
    try {
      final result = await _checklistDao.softDelete(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete checklist: $e');
    }
  }

  // Hard delete checklist (permanent)
  Future<bool> hardDeleteChecklist(int id) async {
    try {
      final result = await _checklistDao.hardDelete(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to permanently delete checklist: $e');
    }
  }

  // Restore soft deleted checklist
  Future<bool> restoreChecklist(int id) async {
    try {
      final result = await _checklistDao.restore(id);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to restore checklist: $e');
    }
  }

  // Archive checklist
  Future<bool> archiveChecklist(int id) async {
    try {
      final result = await _checklistDao.setArchived(id, true);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to archive checklist: $e');
    }
  }

  // Unarchive checklist
  Future<bool> unarchiveChecklist(int id) async {
    try {
      final result = await _checklistDao.setArchived(id, false);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to unarchive checklist: $e');
    }
  }

  // Get archived checklists for a specific card
  Future<List<ChecklistModel>> getArchivedChecklistsByCardId(int cardId) async {
    try {
      return await _checklistDao.getArchivedByCardId(cardId);
    } catch (e) {
      throw Exception('Failed to get archived checklists for card: $e');
    }
  }

  // Get all archived checklists
  Future<List<ChecklistModel>> getArchivedChecklists() async {
    try {
      return await _checklistDao.getArchived();
    } catch (e) {
      throw Exception('Failed to get archived checklists: $e');
    }
  }

  // Get soft deleted checklists for a specific card
  Future<List<ChecklistModel>> getDeletedChecklistsByCardId(int cardId) async {
    try {
      return await _checklistDao.getDeletedByCardId(cardId);
    } catch (e) {
      throw Exception('Failed to get deleted checklists for card: $e');
    }
  }

  // Get all soft deleted checklists
  Future<List<ChecklistModel>> getDeletedChecklists() async {
    try {
      return await _checklistDao.getDeleted();
    } catch (e) {
      throw Exception('Failed to get deleted checklists: $e');
    }
  }

  // Update checklist position
  Future<bool> updateChecklistPosition(int id, double newPosition) async {
    try {
      final result = await _checklistDao.updatePosition(id, newPosition);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update checklist position: $e');
    }
  }

  // Reorder checklists within a card
  Future<bool> reorderChecklists(List<ChecklistModel> checklists) async {
    try {
      await _checklistDao.reorderChecklists(checklists);
      return true;
    } catch (e) {
      throw Exception('Failed to reorder checklists: $e');
    }
  }

  // Search checklists by title within a card
  Future<List<ChecklistModel>> searchChecklistsInCard(
    int cardId,
    String query, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return await getChecklistsByCardId(
          cardId,
          includeArchived: includeArchived,
          includeDeleted: includeDeleted,
        );
      }

      return await _checklistDao.searchInCard(
        cardId,
        query.trim(),
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    } catch (e) {
      throw Exception('Failed to search checklists in card: $e');
    }
  }

  // Search checklists by title across all cards
  Future<List<ChecklistModel>> searchChecklists(
    String query, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllChecklists(
          includeArchived: includeArchived,
          includeDeleted: includeDeleted,
        );
      }

      return await _checklistDao.search(
        query.trim(),
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
    } catch (e) {
      throw Exception('Failed to search checklists: $e');
    }
  }

  // Duplicate checklist
  Future<ChecklistModel?> duplicateChecklist(
    int checklistId,
    String newTitle,
  ) async {
    try {
      if (newTitle.trim().isEmpty || newTitle.length > 255) {
        throw Exception('Invalid new title for duplicate checklist');
      }

      return await _checklistDao.duplicate(checklistId, newTitle.trim());
    } catch (e) {
      throw Exception('Failed to duplicate checklist: $e');
    }
  }

  // Move checklist to another card
  Future<bool> moveChecklistToCard(int checklistId, int newCardId) async {
    try {
      final result = await _checklistDao.moveToCard(checklistId, newCardId);
      return result > 0;
    } catch (e) {
      throw Exception('Failed to move checklist to card: $e');
    }
  }

  // Get checklists statistics for a card
  Future<Map<String, int>> getChecklistsStatsByCard(int cardId) async {
    try {
      return await _checklistDao.getChecklistsCountByCard(cardId);
    } catch (e) {
      throw Exception('Failed to get checklists statistics for card: $e');
    }
  }

  // Get total checklists statistics
  Future<Map<String, int>> getTotalChecklistsStats() async {
    try {
      return await _checklistDao.getTotalChecklistsCount();
    } catch (e) {
      throw Exception('Failed to get total checklists statistics: $e');
    }
  }

  // Get recently created checklists
  Future<List<ChecklistModel>> getRecentlyCreatedChecklists({
    int limit = 10,
    int? cardId,
  }) async {
    try {
      return await _checklistDao.getRecentlyCreated(
        limit: limit,
        cardId: cardId,
      );
    } catch (e) {
      throw Exception('Failed to get recently created checklists: $e');
    }
  }

  // Get recently updated checklists
  Future<List<ChecklistModel>> getRecentlyUpdatedChecklists({
    int limit = 10,
    int? cardId,
  }) async {
    try {
      return await _checklistDao.getRecentlyUpdated(
        limit: limit,
        cardId: cardId,
      );
    } catch (e) {
      throw Exception('Failed to get recently updated checklists: $e');
    }
  }

  // Bulk operations for card management
  
  // Archive all checklists for a card
  Future<bool> archiveAllChecklistsForCard(int cardId) async {
    try {
      final result = await _checklistDao.archiveByCardId(cardId);
      return result >= 0; // Could be 0 if no checklists to archive
    } catch (e) {
      throw Exception('Failed to archive all checklists for card: $e');
    }
  }

  // Unarchive all checklists for a card
  Future<bool> unarchiveAllChecklistsForCard(int cardId) async {
    try {
      final result = await _checklistDao.unarchiveByCardId(cardId);
      return result >= 0; // Could be 0 if no checklists to unarchive
    } catch (e) {
      throw Exception('Failed to unarchive all checklists for card: $e');
    }
  }

  // Soft delete all checklists for a card
  Future<bool> deleteAllChecklistsForCard(int cardId) async {
    try {
      final result = await _checklistDao.softDeleteByCardId(cardId);
      return result >= 0; // Could be 0 if no checklists to delete
    } catch (e) {
      throw Exception('Failed to delete all checklists for card: $e');
    }
  }

  // Hard delete all checklists for a card (permanent)
  Future<bool> hardDeleteAllChecklistsForCard(int cardId) async {
    try {
      final result = await _checklistDao.hardDeleteByCardId(cardId);
      return result >= 0; // Could be 0 if no checklists to delete
    } catch (e) {
      throw Exception('Failed to permanently delete all checklists for card: $e');
    }
  }

  // Batch create checklists
  Future<List<ChecklistModel>> createChecklistsBatch(
    List<ChecklistModel> checklists,
  ) async {
    try {
      // Validate all checklists
      for (final checklist in checklists) {
        if (!checklist.isValidTitle) {
          throw Exception('Invalid checklist title: ${checklist.title}');
        }
      }

      final ids = await _checklistDao.insertBatch(checklists);
      
      // Return checklists with their new IDs
      final result = <ChecklistModel>[];
      for (int i = 0; i < checklists.length; i++) {
        result.add(checklists[i].copyWith(id: ids[i]));
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to create checklists batch: $e');
    }
  }

  // Check if checklist title exists in card
  Future<bool> checkTitleExistsInCard(
    int cardId,
    String title, {
    int? excludeChecklistId,
  }) async {
    try {
      return await _checklistDao.titleExistsInCard(
        cardId,
        title,
        excludeChecklistId: excludeChecklistId,
      );
    } catch (e) {
      throw Exception('Failed to check if title exists: $e');
    }
  }

  // Get next position for new checklist in card
  Future<double> getNextPositionForCard(int cardId) async {
    try {
      return await _checklistDao.getNextPosition(cardId);
    } catch (e) {
      throw Exception('Failed to get next position: $e');
    }
  }
}
