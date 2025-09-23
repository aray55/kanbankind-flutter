import 'package:get/get.dart';
import '../models/checklist_model.dart';
import '../data/repository/checklist_repository.dart';
import '../core/services/dialog_service.dart';
import '../core/localization/local_keys.dart';

class ChecklistsController extends GetxController {
  late final ChecklistRepository _repository;
  late final DialogService _dialogService;

  @override
  void onInit() {
    super.onInit();
    _repository = ChecklistRepository();
    _dialogService = Get.find<DialogService>();
    // Initialize with empty data
    _loadStatistics();
  }

  // Observable lists and states
  final RxList<ChecklistModel> _checklists = <ChecklistModel>[].obs;
  final RxList<ChecklistModel> _archivedChecklists = <ChecklistModel>[].obs;
  final RxList<ChecklistModel> _deletedChecklists = <ChecklistModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _currentCardId = 0.obs;
  final RxMap<String, int> _statistics = <String, int>{}.obs;

  // Getters
  List<ChecklistModel> get checklists => _checklists.toList();
  List<ChecklistModel> get archivedChecklists => _archivedChecklists.toList();
  List<ChecklistModel> get deletedChecklists => _deletedChecklists.toList();
  List<ChecklistModel> get filteredChecklists {
    if (_searchQuery.value.isEmpty) {
      return _checklists.toList();
    }
    return _checklists
        .where(
          (checklist) => checklist.title.toLowerCase().contains(
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
  int get currentCardId => _currentCardId.value;
  Map<String, int> get statistics => Map<String, int>.from(_statistics);

  // Computed properties
  int get totalChecklists => _checklists.length;
  int get totalArchivedChecklists => _archivedChecklists.length;
  int get totalDeletedChecklists => _deletedChecklists.length;
  bool get hasChecklists => _checklists.isNotEmpty;
  bool get hasArchivedChecklists => _archivedChecklists.isNotEmpty;
  bool get hasDeletedChecklists => _deletedChecklists.isNotEmpty;

  // Load checklists for a specific card
  Future<void> loadChecklistsByCardId(
    int cardId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      _isLoading.value = true;
      _currentCardId.value = cardId;

      final checklists = await _repository.getChecklistsByCardId(
        cardId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      _checklists.assignAll(checklists.where((c) => c.isActive).toList());
      
      if (includeArchived) {
        _archivedChecklists.assignAll(
          checklists.where((c) => c.archived && !c.isDeleted).toList(),
        );
      }
      
      if (includeDeleted) {
        _deletedChecklists.assignAll(
          checklists.where((c) => c.isDeleted).toList(),
        );
      }

      await _loadStatistics();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load checklists: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load all checklists
  Future<void> loadAllChecklists({
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      _isLoading.value = true;
      _currentCardId.value = 0;

      final checklists = await _repository.getAllChecklists(
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      _checklists.assignAll(checklists.where((c) => c.isActive).toList());
      
      if (includeArchived) {
        _archivedChecklists.assignAll(
          checklists.where((c) => c.archived && !c.isDeleted).toList(),
        );
      }
      
      if (includeDeleted) {
        _deletedChecklists.assignAll(
          checklists.where((c) => c.isDeleted).toList(),
        );
      }

      await _loadStatistics();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load checklists: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new checklist
  Future<void> createChecklist({
    required int cardId,
    required String title,
    double? position,
  }) async {
    if (title.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: 'Checklist title cannot be empty',
      );
      return;
    }

    try {
      _isCreating.value = true;

      final newChecklist = ChecklistModel(
        cardId: cardId,
        title: title.trim(),
        position: position ?? await _repository.getNextPositionForCard(cardId),
      );

      final createdChecklist = await _repository.createChecklist(newChecklist);
      
      if (createdChecklist != null) {
        _checklists.add(createdChecklist);
        _sortChecklistsByPosition();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist created successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to create checklist: $e',
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update checklist
  Future<void> updateChecklist(ChecklistModel checklist) async {
    if (checklist.id == null) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Checklist ID is required for update',
      );
      return;
    }

    if (!checklist.isValidTitle) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: 'Invalid checklist title',
      );
      return;
    }

    try {
      _isUpdating.value = true;

      final success = await _repository.updateChecklist(checklist);
      
      if (success) {
        final index = _checklists.indexWhere((c) => c.id == checklist.id);
        if (index != -1) {
          _checklists[index] = checklist;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist updated successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update checklist: $e',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Soft delete checklist
  Future<void> deleteChecklist(int id) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.deleteChecklist(id);
      
      if (success) {
        _checklists.removeWhere((c) => c.id == id);
        _archivedChecklists.removeWhere((c) => c.id == id);

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist deleted successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to delete checklist: $e',
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Hard delete checklist (permanent)
  Future<void> hardDeleteChecklist(int id) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.hardDeleteChecklist(id);
      
      if (success) {
        _checklists.removeWhere((c) => c.id == id);
        _archivedChecklists.removeWhere((c) => c.id == id);
        _deletedChecklists.removeWhere((c) => c.id == id);

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist permanently deleted',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to permanently delete checklist: $e',
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Restore soft deleted checklist
  Future<void> restoreChecklist(int id) async {
    try {
      _isUpdating.value = true;

      final success = await _repository.restoreChecklist(id);
      
      if (success) {
        // Remove from deleted list and reload active checklists
        _deletedChecklists.removeWhere((c) => c.id == id);
        
        if (_currentCardId.value > 0) {
          await loadChecklistsByCardId(_currentCardId.value);
        } else {
          await loadAllChecklists();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist restored successfully',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to restore checklist: $e',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Archive checklist
  Future<void> archiveChecklist(int id) async {
    try {
      _isUpdating.value = true;

      final success = await _repository.archiveChecklist(id);
      
      if (success) {
        final checklist = _checklists.firstWhereOrNull((c) => c.id == id);
        if (checklist != null) {
          _checklists.removeWhere((c) => c.id == id);
          _archivedChecklists.add(checklist.copyWith(archived: true));
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist archived successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive checklist: $e',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Unarchive checklist
  Future<void> unarchiveChecklist(int id) async {
    try {
      _isUpdating.value = true;

      final success = await _repository.unarchiveChecklist(id);
      
      if (success) {
        final checklist = _archivedChecklists.firstWhereOrNull((c) => c.id == id);
        if (checklist != null) {
          _archivedChecklists.removeWhere((c) => c.id == id);
          _checklists.add(checklist.copyWith(archived: false));
          _sortChecklistsByPosition();
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist unarchived successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to unarchive checklist: $e',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Update checklist position
  Future<void> updateChecklistPosition(int id, double newPosition) async {
    try {
      final success = await _repository.updateChecklistPosition(id, newPosition);
      
      if (success) {
        final index = _checklists.indexWhere((c) => c.id == id);
        if (index != -1) {
          _checklists[index] = _checklists[index].copyWith(position: newPosition);
          _sortChecklistsByPosition();
        }
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update checklist position: $e',
      );
    }
  }

  // Reorder checklists
  Future<void> reorderChecklists(List<ChecklistModel> newOrder) async {
    try {
      final success = await _repository.reorderChecklists(newOrder);
      
      if (success) {
        _checklists.assignAll(newOrder);
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to reorder checklists: $e',
      );
      
      // Reload to restore original order
      if (_currentCardId.value > 0) {
        await loadChecklistsByCardId(_currentCardId.value);
      } else {
        await loadAllChecklists();
      }
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  // Search checklists
  Future<void> searchChecklists(String query, {int? cardId}) async {
    if (query.trim().isEmpty) {
      if (cardId != null) {
        await loadChecklistsByCardId(cardId);
      } else {
        await loadAllChecklists();
      }
      return;
    }

    try {
      _isLoading.value = true;

      List<ChecklistModel> results;
      if (cardId != null) {
        results = await _repository.searchChecklistsInCard(cardId, query.trim());
      } else {
        results = await _repository.searchChecklists(query.trim());
      }

      _checklists.assignAll(results.where((c) => c.isActive).toList());
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to search checklists: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Duplicate checklist
  Future<void> duplicateChecklist(int checklistId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: 'New title cannot be empty',
      );
      return;
    }

    try {
      _isCreating.value = true;

      final duplicatedChecklist = await _repository.duplicateChecklist(
        checklistId,
        newTitle.trim(),
      );
      
      if (duplicatedChecklist != null) {
        _checklists.add(duplicatedChecklist);
        _sortChecklistsByPosition();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist duplicated successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to duplicate checklist: $e',
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Move checklist to another card
  Future<void> moveChecklistToCard(int checklistId, int newCardId) async {
    try {
      _isUpdating.value = true;

      final success = await _repository.moveChecklistToCard(checklistId, newCardId);
      
      if (success) {
        // Remove from current list if we're viewing a specific card
        if (_currentCardId.value > 0) {
          _checklists.removeWhere((c) => c.id == checklistId);
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Checklist moved successfully',
        );

        await _loadStatistics();
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to move checklist: $e',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Get checklist by ID
  ChecklistModel? getChecklistById(int id) {
    try {
      return _checklists.firstWhere((c) => c.id == id);
    } catch (e) {
      try {
        return _archivedChecklists.firstWhere((c) => c.id == id);
      } catch (e) {
        try {
          return _deletedChecklists.firstWhere((c) => c.id == id);
        } catch (e) {
          return null;
        }
      }
    }
  }

  // Load archived checklists
  Future<void> loadArchivedChecklists({int? cardId}) async {
    try {
      _isLoading.value = true;

      List<ChecklistModel> archived;
      if (cardId != null) {
        archived = await _repository.getArchivedChecklistsByCardId(cardId);
      } else {
        archived = await _repository.getArchivedChecklists();
      }

      _archivedChecklists.assignAll(archived);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load archived checklists: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load deleted checklists
  Future<void> loadDeletedChecklists({int? cardId}) async {
    try {
      _isLoading.value = true;

      List<ChecklistModel> deleted;
      if (cardId != null) {
        deleted = await _repository.getDeletedChecklistsByCardId(cardId);
      } else {
        deleted = await _repository.getDeletedChecklists();
      }

      _deletedChecklists.assignAll(deleted);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load deleted checklists: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Private helper methods
  void _sortChecklistsByPosition() {
    _checklists.sort((a, b) => a.position.compareTo(b.position));
  }

  Future<void> _loadStatistics() async {
    try {
      Map<String, int> stats;
      if (_currentCardId.value > 0) {
        stats = await _repository.getChecklistsStatsByCard(_currentCardId.value);
      } else {
        stats = await _repository.getTotalChecklistsStats();
      }
      _statistics.assignAll(stats);
    } catch (e) {
      // Silent fail for statistics
    }
  }

  // Refresh data
  Future<void> refresh() async {
    if (_currentCardId.value > 0) {
      await loadChecklistsByCardId(_currentCardId.value);
    } else {
      await loadAllChecklists();
    }
  }

  // Clear all data
  void clearData() {
    if (!isClosed) {
      _checklists.clear();
      _archivedChecklists.clear();
      _deletedChecklists.clear();
      _currentCardId.value = 0;
      _searchQuery.value = '';
      _statistics.clear();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
