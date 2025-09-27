import 'package:get/get.dart';
import '../data/repository/label_repository.dart';
import '../models/label_model.dart';

class LabelController extends GetxController {
  final LabelRepository _labelRepository = LabelRepository();

  // Observable lists
  final RxList<LabelModel> _labels = <LabelModel>[].obs;
  final RxList<LabelModel> _deletedLabels = <LabelModel>[].obs;
  final RxList<LabelModel> _searchResults = <LabelModel>[].obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxBool _isSearching = false.obs;

  // Search state
  final RxString _searchQuery = ''.obs;
  final RxInt _currentBoardId = 0.obs;

  // Statistics
  final RxMap<String, dynamic> _labelStats = <String, dynamic>{}.obs;

  // Getters
  List<LabelModel> get labels => _labels;
  List<LabelModel> get deletedLabels => _deletedLabels;
  List<LabelModel> get searchResults => _searchResults;
  
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  bool get isSearching => _isSearching.value;
  
  String get searchQuery => _searchQuery.value;
  int get currentBoardId => _currentBoardId.value;
  Map<String, dynamic> get labelStats => _labelStats;

  // Computed getters
  List<LabelModel> get activeLabels => _labels.where((label) => !label.isDeleted).toList();
  int get totalLabelsCount => activeLabels.length;
  int get deletedLabelsCount => _deletedLabels.length;

  // Load labels for a board
  Future<void> loadLabelsByBoardId(int boardId) async {
    try {
      _isLoading.value = true;
      _currentBoardId.value = boardId;
      
      final labels = await _labelRepository.getLabelsByBoardId(boardId);
      _labels.assignAll(labels);
      
      // Clear search if it was for a different board
      if (_searchQuery.value.isNotEmpty) {
        await searchLabels(_searchQuery.value);
      }
    } catch (e) {
      // Error handling is done in repository
    } finally {
      _isLoading.value = false;
    }
  }

  // Load deleted labels for a board
  Future<void> loadDeletedLabelsByBoardId(int boardId) async {
    try {
      _isLoading.value = true;
      
      final deletedLabels = await _labelRepository.getDeletedLabelsByBoardId(boardId);
      _deletedLabels.assignAll(deletedLabels);
    } catch (e) {
      // Error handling is done in repository
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new label
  Future<bool> createLabel({
    required int boardId,
    required String name,
    required String color,
  }) async {
    try {
      _isCreating.value = true;
      
      final label = await _labelRepository.createLabel(
        boardId: boardId,
        name: name,
        color: color,
      );
      
      if (label != null) {
        _labels.add(label);
        
        // Update search results if searching
        if (_searchQuery.value.isNotEmpty) {
          await searchLabels(_searchQuery.value);
        }
        
        // Refresh stats
        await loadLabelStats(boardId);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Update label
  Future<bool> updateLabel(LabelModel label) async {
    try {
      _isUpdating.value = true;
      
      final success = await _labelRepository.updateLabel(label);
      
      if (success) {
        // Update local list
        final index = _labels.indexWhere((l) => l.id == label.id);
        if (index != -1) {
          _labels[index] = label;
        }
        
        // Update search results if searching
        if (_searchQuery.value.isNotEmpty) {
          await searchLabels(_searchQuery.value);
        }
        
        // Refresh stats
        await loadLabelStats(label.boardId);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete label (soft delete)
  Future<bool> deleteLabel(int id) async {
    try {
      _isDeleting.value = true;
      
      final success = await _labelRepository.deleteLabel(id);
      
      if (success) {
        // Remove from active labels
        _labels.removeWhere((label) => label.id == id);
        
        // Update search results if searching
        if (_searchQuery.value.isNotEmpty) {
          await searchLabels(_searchQuery.value);
        }
        
        // Refresh deleted labels and stats
        if (_currentBoardId.value > 0) {
          await loadDeletedLabelsByBoardId(_currentBoardId.value);
          await loadLabelStats(_currentBoardId.value);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Restore label from soft delete
  Future<bool> restoreLabel(int id) async {
    try {
      _isUpdating.value = true;
      
      final success = await _labelRepository.restoreLabel(id);
      
      if (success) {
        // Refresh both lists
        if (_currentBoardId.value > 0) {
          await loadLabelsByBoardId(_currentBoardId.value);
          await loadDeletedLabelsByBoardId(_currentBoardId.value);
          await loadLabelStats(_currentBoardId.value);
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

  // Permanently delete label
  Future<bool> permanentlyDeleteLabel(int id) async {
    try {
      _isDeleting.value = true;
      
      final success = await _labelRepository.permanentlyDeleteLabel(id);
      
      if (success) {
        // Remove from deleted labels
        _deletedLabels.removeWhere((label) => label.id == id);
        
        // Refresh stats
        if (_currentBoardId.value > 0) {
          await loadLabelStats(_currentBoardId.value);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Search labels
  Future<void> searchLabels(String query) async {
    try {
      _isSearching.value = true;
      _searchQuery.value = query;
      
      if (_currentBoardId.value <= 0) {
        _searchResults.clear();
        return;
      }
      
      final results = await _labelRepository.searchLabels(_currentBoardId.value, query);
      _searchResults.assignAll(results);
    } catch (e) {
      _searchResults.clear();
    } finally {
      _isSearching.value = false;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }

  // Get labels by color
  Future<List<LabelModel>> getLabelsByColor(String color) async {
    try {
      if (_currentBoardId.value <= 0) return [];
      
      return await _labelRepository.getLabelsByColor(_currentBoardId.value, color);
    } catch (e) {
      return [];
    }
  }

  // Load label statistics
  Future<void> loadLabelStats(int boardId) async {
    try {
      final stats = await _labelRepository.getLabelStats(boardId);
      if (stats != null) {
        _labelStats.assignAll(stats);
      }
    } catch (e) {
      _labelStats.clear();
    }
  }

  // Duplicate label
  Future<bool> duplicateLabel(int labelId, String newName) async {
    try {
      _isCreating.value = true;
      
      final label = await _labelRepository.duplicateLabel(labelId, newName);
      
      if (label != null) {
        _labels.add(label);
        
        // Update search results if searching
        if (_searchQuery.value.isNotEmpty) {
          await searchLabels(_searchQuery.value);
        }
        
        // Refresh stats
        await loadLabelStats(label.boardId);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Batch operations
  Future<bool> batchCreateLabels(List<LabelModel> labels) async {
    try {
      _isCreating.value = true;
      
      final success = await _labelRepository.batchCreateLabels(labels);
      
      if (success && _currentBoardId.value > 0) {
        // Refresh labels list
        await loadLabelsByBoardId(_currentBoardId.value);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  Future<bool> batchDeleteLabels(List<int> labelIds) async {
    try {
      _isDeleting.value = true;
      
      final success = await _labelRepository.batchDeleteLabels(labelIds);
      
      if (success && _currentBoardId.value > 0) {
        // Refresh both lists
        await loadLabelsByBoardId(_currentBoardId.value);
        await loadDeletedLabelsByBoardId(_currentBoardId.value);
        await loadLabelStats(_currentBoardId.value);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Clean up old deleted labels
  Future<bool> cleanupDeletedLabels({int daysOld = 30}) async {
    try {
      _isDeleting.value = true;
      
      final success = await _labelRepository.cleanupDeletedLabels(daysOld: daysOld);
      
      if (success && _currentBoardId.value > 0) {
        await loadDeletedLabelsByBoardId(_currentBoardId.value);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Validation helpers
  Future<bool> validateLabelName(String name, {int? excludeId}) async {
    if (_currentBoardId.value <= 0) return false;
    
    return await _labelRepository.validateLabelName(
      _currentBoardId.value,
      name,
      excludeId: excludeId,
    );
  }

  bool validateLabelColor(String color) {
    return _labelRepository.validateLabelColor(color);
  }

  // Get label by ID
  LabelModel? getLabelById(int id) {
    try {
      return _labels.firstWhere((label) => label.id == id);
    } catch (e) {
      return null;
    }
  }

  // Convenience method for UI widgets
  Future<void> loadLabelsForBoard(int boardId) async {
    await loadLabelsByBoardId(boardId);
  }

  // Get current board labels (for UI binding)
  List<LabelModel> get boardLabels => _labels;

  // Refresh all data for current board
  Future<void> refreshAll() async {
    if (_currentBoardId.value > 0) {
      await Future.wait([
        loadLabelsByBoardId(_currentBoardId.value),
        loadDeletedLabelsByBoardId(_currentBoardId.value),
        loadLabelStats(_currentBoardId.value),
      ]);
      
      // Refresh search if active
      if (_searchQuery.value.isNotEmpty) {
        await searchLabels(_searchQuery.value);
      }
    }
  }

  // Reset controller state
  void reset() {
    _labels.clear();
    _deletedLabels.clear();
    _searchResults.clear();
    _labelStats.clear();
    _searchQuery.value = '';
    _currentBoardId.value = 0;
    _isLoading.value = false;
    _isCreating.value = false;
    _isUpdating.value = false;
    _isDeleting.value = false;
    _isSearching.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
