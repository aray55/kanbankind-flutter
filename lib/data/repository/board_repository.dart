import '../../models/board_model.dart';
import '../database/board_dao.dart';

class BoardRepository {
  final BoardDao _boardDao = BoardDao();

  // Create a new board
  Future<Board> createBoard({
    required String uuid,
    required String title,
    String? description,
    String? color,
    int position = 1024,
  }) async {
    // Validate UUID uniqueness
    final uuidExists = await _boardDao.uuidExists(uuid);
    if (uuidExists) {
      throw Exception('Board with UUID $uuid already exists');
    }

    // Validate title length
    if (title.isEmpty || title.length > 255) {
      throw Exception('Board title must be between 1 and 255 characters');
    }

    // Validate color format if provided
    if (color != null && color.isNotEmpty) {
      final colorRegex = RegExp(
        r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$',
      );
      if (!colorRegex.hasMatch(color)) {
        throw Exception(
          'Invalid color format. Use hex format like #FFF, #RRGGBB, or #RRGGBBAA',
        );
      }
    }

    final board = Board(
      uuid: uuid,
      title: title,
      description: description,
      color: color,
      position: position,
    );

    final id = await _boardDao.insert(board);
    return board.copyWith(id: id);
  }

  // Get all active boards
  Future<List<Board>> getAllBoards({bool includeArchived = false}) async {
    return await _boardDao.getAll(includeArchived: includeArchived);
  }

  // Get board by ID
  Future<Board?> getBoardById(int id) async {
    return await _boardDao.getById(id);
  }

  // Get board by UUID
  Future<Board?> getBoardByUuid(String uuid) async {
    return await _boardDao.getByUuid(uuid);
  }

  // Update board
  Future<Board?> updateBoard(Board board) async {
    // Validate title length
    if (board.title.isEmpty || board.title.length > 255) {
      throw Exception('Board title must be between 1 and 255 characters');
    }

    // Validate color format if provided
    if (board.color != null && board.color!.isNotEmpty && !board.isValidColor) {
      throw Exception(
        'Invalid color format. Use hex format like #FFF, #RRGGBB, or #RRGGBBAA',
      );
    }

    final result = await _boardDao.update(board);
    if (result > 0) {
      return await _boardDao.getById(board.id!);
    }
    return null;
  }

  // Update board title
  Future<Board?> updateBoardTitle(int id, String newTitle) async {
    final board = await _boardDao.getById(id);
    if (board == null) return null;

    return await updateBoard(board.copyWith(title: newTitle));
  }

  // Update board description
  Future<Board?> updateBoardDescription(int id, String? newDescription) async {
    final board = await _boardDao.getById(id);
    if (board == null) return null;

    return await updateBoard(board.copyWith(description: newDescription));
  }

  // Update board color
  Future<Board?> updateBoardColor(int id, String? newColor) async {
    final board = await _boardDao.getById(id);
    if (board == null) return null;

    return await updateBoard(board.copyWith(color: newColor));
  }

  // Archive board
  Future<bool> archiveBoard(int id) async {
    final result = await _boardDao.setArchived(id, true);
    return result > 0;
  }

  // Unarchive board
  Future<bool> unarchiveBoard(int id) async {
    final result = await _boardDao.setArchived(id, false);
    return result > 0;
  }

  // Soft delete board
  Future<bool> deleteBoard(int id) async {
    final result = await _boardDao.softDelete(id);
    return result > 0;
  }

  // Permanently delete board
  Future<bool> permanentlyDeleteBoard(int id) async {
    final result = await _boardDao.hardDelete(id);
    return result > 0;
  }

  // Restore deleted board
  Future<bool> restoreBoard(int id) async {
    final result = await _boardDao.restore(id);
    return result > 0;
  }

  // Get archived boards
  Future<List<Board>> getArchivedBoards() async {
    return await _boardDao.getArchived();
  }

  // Get deleted boards (for admin purposes)
  Future<List<Board>> getDeletedBoards() async {
    return await _boardDao.getDeleted();
  }

  // Update board position
  Future<bool> updateBoardPosition(int id, int newPosition) async {
    final result = await _boardDao.updatePosition(id, newPosition);
    return result > 0;
  }

  // Reorder boards
  Future<List<Board>> reorderBoards(List<Board> boards) async {
    await _boardDao.reorderBoards(boards);
    return await getAllBoards();
  }

  // Move board to new position
  Future<List<Board>> moveBoardToPosition(int boardId, int newPosition) async {
    final boards = await getAllBoards();
    final boardIndex = boards.indexWhere((b) => b.id == boardId);

    if (boardIndex == -1) {
      throw Exception('Board not found');
    }

    final board = boards.removeAt(boardIndex);
    boards.insert(newPosition.clamp(0, boards.length), board);

    return await reorderBoards(boards);
  }

  // Search boards
  Future<List<Board>> searchBoards(
    String query, {
    bool includeArchived = false,
  }) async {
    if (query.trim().isEmpty) {
      return await getAllBoards(includeArchived: includeArchived);
    }
    return await _boardDao.search(
      query.trim(),
      includeArchived: includeArchived,
    );
  }

  // Get boards statistics
  Future<Map<String, int>> getBoardsStatistics() async {
    return await _boardDao.getBoardsCount();
  }

  // Duplicate board
  Future<Board?> duplicateBoard(
    int boardId,
    String newTitle,
    String newUuid,
  ) async {
    // Validate UUID uniqueness
    final uuidExists = await _boardDao.uuidExists(newUuid);
    if (uuidExists) {
      throw Exception('Board with UUID $newUuid already exists');
    }

    // Validate title length
    if (newTitle.isEmpty || newTitle.length > 255) {
      throw Exception('Board title must be between 1 and 255 characters');
    }

    return await _boardDao.duplicate(boardId, newTitle, newUuid);
  }

  // Generate unique UUID for new board
  Future<String> generateUniqueUuid() async {
    String uuid;
    bool exists;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      if (attempts >= maxAttempts) {
        throw Exception(
          'Failed to generate unique UUID after $maxAttempts attempts',
        );
      }

      uuid = _generateUuid();
      exists = await _boardDao.uuidExists(uuid);
      attempts++;
    } while (exists);

    return uuid;
  }

  // Create multiple boards in batch
  Future<List<Board>> createMultipleBoards(
    List<Map<String, dynamic>> boardsData,
  ) async {
    final boards = <Board>[];

    for (final data in boardsData) {
      final board = Board(
        uuid: data['uuid'] as String,
        title: data['title'] as String,
        description: data['description'] as String?,
        color: data['color'] as String?,
        position: data['position'] as int? ?? 1024,
      );
      boards.add(board);
    }

    await _boardDao.insertBatch(boards);
    return await getAllBoards();
  }

  // Clean up old deleted boards
  Future<int> cleanupOldDeletedBoards({int daysOld = 30}) async {
    return await _boardDao.cleanupDeletedBoards(daysOld: daysOld);
  }

  // Validate board data
  bool validateBoardData({required String title, String? color}) {
    // Check title
    if (title.isEmpty || title.length > 255) {
      return false;
    }

    // Check color format if provided
    if (color != null && color.isNotEmpty) {
      final colorRegex = RegExp(
        r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$',
      );
      if (!colorRegex.hasMatch(color)) {
        return false;
      }
    }

    return true;
  }

  // Private helper method to generate UUID
  String _generateUuid() {
    // Simple UUID v4 generation (for production, consider using uuid package)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'board_${timestamp}_$random';
  }

  // Get total boards count (excluding deleted)
  Future<int> getTotalBoardsCount() async {
    final stats = await getBoardsStatistics();
    return stats['active']! + stats['archived']!;
  }

  // Check if board title exists (for duplicate prevention)
  Future<bool> boardTitleExists(String title, {int? excludeBoardId}) async {
    final boards = await getAllBoards(includeArchived: true);
    return boards.any(
      (board) =>
          board.title.toLowerCase() == title.toLowerCase() &&
          board.id != excludeBoardId,
    );
  }

  // Get boards by color
  Future<List<Board>> getBoardsByColor(String color) async {
    final allBoards = await getAllBoards();
    return allBoards.where((board) => board.color == color).toList();
  }

  // Get recently created boards
  Future<List<Board>> getRecentlyCreatedBoards({int limit = 10}) async {
    final allBoards = await getAllBoards();
    allBoards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allBoards.take(limit).toList();
  }

  // Get recently updated boards
  Future<List<Board>> getRecentlyUpdatedBoards({int limit = 10}) async {
    final allBoards = await getAllBoards();
    final boardsWithUpdates = allBoards
        .where((board) => board.updatedAt != null)
        .toList();
    boardsWithUpdates.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return boardsWithUpdates.take(limit).toList();
  }
}
