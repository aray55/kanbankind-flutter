import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import '../core/themes/app_colors.dart' show AppColors;
import '../models/board_model.dart';
import '../data/repository/board_repository.dart';

class BoardController extends GetxController {
  final BoardRepository _repository = BoardRepository();
  final DialogService _dialogService = Get.find<DialogService>();

  // Observable lists and states
  final RxList<Board> _boards = <Board>[].obs;
  final RxList<Board> _archivedBoards = <Board>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<Board?> _selectedBoard = Rx<Board?>(null);

  // Form controllers for board creation/editing
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final RxString _selectedColor = '#3498db'.obs;

  // Getters
  List<Board> get boards => _boards.toList();
  List<Board> get archivedBoards => _archivedBoards.toList();
  List<Board> get filteredBoards {
    if (_searchQuery.value.isEmpty) {
      return _boards.toList();
    }
    return _boards
        .where(
          (board) =>
              board.title.toLowerCase().contains(
                _searchQuery.value.toLowerCase(),
              ) ||
              (board.description?.toLowerCase().contains(
                    _searchQuery.value.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  String get searchQuery => _searchQuery.value;
  Board? get selectedBoard => _selectedBoard.value;
  String get selectedColor => _selectedColor.value;

  // Computed properties
  int get totalBoards => _boards.length;
  int get totalArchivedBoards => _archivedBoards.length;
  bool get hasBoards => _boards.isNotEmpty;
  bool get hasArchivedBoards => _archivedBoards.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadBoards();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    colorController.dispose();
    super.onClose();
  }

  // Load all boards
  Future<void> loadBoards({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final boards = await _repository.getAllBoards();
      _boards.assignAll(boards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load boards: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load archived boards
  Future<void> loadArchivedBoards() async {
    try {
      _isLoading.value = true;
      final archivedBoards = await _repository.getArchivedBoards();
      _archivedBoards.assignAll(archivedBoards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to load archived boards: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new board
  Future<void> createBoard({
    required String title,
    String? description,
    String? color,
  }) async {
    if (title.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final uuid = await _repository.generateUniqueUuid();
      final board = await _repository.createBoard(
        uuid: uuid,
        title: title.trim(),
        description: description?.trim(),
        color: color,
      );

      _boards.add(board);
      _sortBoardsByPosition();

      _dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: 'Board created successfully',
        backgroundColor: AppColors.primary,
        icon: Icons.check_circle_outline,
      );

      clearForm();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to create board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Update board
  Future<void> updateBoard(Board board) async {
    try {
      _isUpdating.value = true;

      final updatedBoard = await _repository.updateBoard(board);
      if (updatedBoard != null) {
        final index = _boards.indexWhere((b) => b.id == board.id);
        if (index != -1) {
          _boards[index] = updatedBoard;
        }

        // Update selected board if it's the one being updated
        if (_selectedBoard.value?.id == board.id) {
          _selectedBoard.value = updatedBoard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Update board title
  Future<void> updateBoardTitle(int boardId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      final updatedBoard = await _repository.updateBoardTitle(
        boardId,
        newTitle.trim(),
      );
      if (updatedBoard != null) {
        final index = _boards.indexWhere((b) => b.id == boardId);
        if (index != -1) {
          _boards[index] = updatedBoard;
        }

        if (_selectedBoard.value?.id == boardId) {
          _selectedBoard.value = updatedBoard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board title updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update board title: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Update board description
  Future<void> updateBoardDescription(
    int boardId,
    String? newDescription,
  ) async {
    try {
      final updatedBoard = await _repository.updateBoardDescription(
        boardId,
        newDescription?.trim(),
      );
      if (updatedBoard != null) {
        final index = _boards.indexWhere((b) => b.id == boardId);
        if (index != -1) {
          _boards[index] = updatedBoard;
        }

        if (_selectedBoard.value?.id == boardId) {
          _selectedBoard.value = updatedBoard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board description updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update board description: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Update board color
  Future<void> updateBoardColor(int boardId, String? newColor) async {
    try {
      final updatedBoard = await _repository.updateBoardColor(
        boardId,
        newColor,
      );
      if (updatedBoard != null) {
        final index = _boards.indexWhere((b) => b.id == boardId);
        if (index != -1) {
          _boards[index] = updatedBoard;
        }

        if (_selectedBoard.value?.id == boardId) {
          _selectedBoard.value = updatedBoard;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board color updated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to update board color: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Archive board
  Future<void> archiveBoard(int boardId) async {
    try {
      final success = await _repository.archiveBoard(boardId);
      if (success) {
        _boards.removeWhere((board) => board.id == boardId);
        await loadArchivedBoards(); // Refresh archived boards

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.boardArchivedSuccessfully.tr,
          backgroundColor: AppColors.primary,
          icon: Icons.archive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to archive board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Unarchive board
  Future<void> unarchiveBoard(int boardId) async {
    try {
      final success = await _repository.unarchiveBoard(boardId);
      if (success) {
        _archivedBoards.removeWhere((board) => board.id == boardId);
        await loadBoards(showLoading: false); // Refresh active boards

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.boardRestoredSuccessfully.tr,
          backgroundColor: AppColors.primary,
          icon: Icons.unarchive_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to restore board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  // Delete board (soft delete)
  Future<void> softDeleteBoard(int boardId) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.softDeleteBoard(boardId);
      if (success) {
        _boards.removeWhere((board) => board.id == boardId);
        _archivedBoards.removeWhere((board) => board.id == boardId);

        // Clear selected board if it was deleted
        if (_selectedBoard.value?.id == boardId) {
          _selectedBoard.value = null;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board deleted successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.delete_outline,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to delete board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Permanently delete board (hard delete)
  Future<void> hardDeleteBoard(int boardId) async {
    try {
      _isDeleting.value = true;

      final success = await _repository.hardDeleteBoard(boardId);
      if (success) {
        _boards.removeWhere((board) => board.id == boardId);
        _archivedBoards.removeWhere((board) => board.id == boardId);

        // Clear selected board if it was deleted
        if (_selectedBoard.value?.id == boardId) {
          _selectedBoard.value = null;
        }

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board permanently deleted',
          backgroundColor: AppColors.primary,
          icon: Icons.delete_forever,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to permanently delete board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  // Duplicate board
  Future<void> duplicateBoard(int boardId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: LocalKeys.pleaseEnterTitle.tr,
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    try {
      _isCreating.value = true;

      final uuid = await _repository.generateUniqueUuid();
      final duplicatedBoard = await _repository.duplicateBoard(
        boardId,
        newTitle.trim(),
        uuid,
      );

      if (duplicatedBoard != null) {
        _boards.add(duplicatedBoard);
        _sortBoardsByPosition();

        _dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: 'Board duplicated successfully',
          backgroundColor: AppColors.primary,
          icon: Icons.copy_outlined,
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to duplicate board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isCreating.value = false;
    }
  }

  // Reorder boards
  Future<void> reorderBoards(List<Board> newOrder) async {
    try {
      final reorderedBoards = await _repository.reorderBoards(newOrder);
      _boards.assignAll(reorderedBoards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to reorder boards: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload boards to restore original order
      await loadBoards(showLoading: false);
    }
  }

  // Move board to new position
  Future<void> moveBoardToPosition(int boardId, int newPosition) async {
    try {
      final reorderedBoards = await _repository.moveBoardToPosition(
        boardId,
        newPosition,
      );
      _boards.assignAll(reorderedBoards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to move board: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      // Reload boards to restore original order
      await loadBoards(showLoading: false);
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  // Search boards
  Future<void> searchBoards(String query) async {
    try {
      _isLoading.value = true;

      final boards = await _repository.searchBoards(query.trim());
      _boards.assignAll(boards);
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: 'Failed to search boards: ${e.toString()}',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Select board
  void selectBoard(Board? board) {
    _selectedBoard.value = board;
    if (board != null) {
      populateFormFromBoard(board);
    }
  }

  // Get board by ID
  Board? getBoardById(int id) {
    try {
      return _boards.firstWhere((board) => board.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get board statistics
  Future<Map<String, int>> getBoardStatistics() async {
    try {
      return await _repository.getBoardsStatistics();
    } catch (e) {
      return {'active': 0, 'archived': 0, 'deleted': 0};
    }
  }

  // Form management
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    colorController.clear();
    _selectedColor.value = '#3498db';
    _selectedBoard.value = null;
  }

  void populateFormFromBoard(Board board) {
    titleController.text = board.title;
    descriptionController.text = board.description ?? '';
    colorController.text = board.color ?? '';
    _selectedColor.value = board.color ?? '#3498db';
  }

  void setSelectedColor(String color) {
    _selectedColor.value = color;
    colorController.text = color;
  }

  // Validation
  bool validateBoardForm() {
    final title = titleController.text.trim();
    if (title.isEmpty || title.length > 255) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message: 'Board title must be between 1 and 255 characters',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return false;
    }

    final color = colorController.text.trim();
    if (color.isNotEmpty &&
        !_repository.validateBoardData(title: title, color: color)) {
      _dialogService.showErrorSnackbar(
        title: LocalKeys.invalidInput.tr,
        message:
            'Invalid color format. Use hex format like #FFF, #RRGGBB, or #RRGGBBAA',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return false;
    }

    return true;
  }

  // Create board from form
  Future<void> createBoardFromForm() async {
    if (!validateBoardForm()) return;

    await createBoard(
      title: titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      color: colorController.text.trim().isEmpty
          ? null
          : colorController.text.trim(),
    );
  }

  // Update board from form
  Future<void> updateBoardFromForm() async {
    if (_selectedBoard.value == null) return;
    if (!validateBoardForm()) return;

    final updatedBoard = _selectedBoard.value!.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      color: colorController.text.trim().isEmpty
          ? null
          : colorController.text.trim(),
    );

    await updateBoard(updatedBoard);
  }

  // Private helper methods
  void _sortBoardsByPosition() {
    _boards.sort((a, b) => a.position.compareTo(b.position));
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadBoards();
    if (_archivedBoards.isNotEmpty) {
      await loadArchivedBoards();
    }
  }

  // Get recent boards
  Future<List<Board>> getRecentBoards({int limit = 5}) async {
    try {
      return await _repository.getRecentlyCreatedBoards(limit: limit);
    } catch (e) {
      return [];
    }
  }

  // Check if board title exists
  Future<bool> boardTitleExists(String title, {int? excludeBoardId}) async {
    try {
      return await _repository.boardTitleExists(
        title,
        excludeBoardId: excludeBoardId,
      );
    } catch (e) {
      return false;
    }
  }

  // Get boards by color
  Future<List<Board>> getBoardsByColor(String color) async {
    try {
      return await _repository.getBoardsByColor(color);
    } catch (e) {
      return [];
    }
  }

  // Get total boards count
  Future<int> getTotalBoardsCount() async {
    try {
      return await _repository.getTotalBoardsCount();
    } catch (e) {
      return 0;
    }
  }

  // Navigation helper to lists screen
  void navigateToLists(int boardId) {
    Get.toNamed('/list_screen/$boardId');
  }
}
