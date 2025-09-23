import '../../models/list_model.dart';
import '../database/list_dao.dart';

class ListRepository {
  final ListDao _listDao = ListDao();

  // Create a new list
  Future<ListModel> createList({
    required int boardId,
    required String title,
    String? color,
    double? position,
  }) async {
    // Validate title length
    if (title.isEmpty || title.length > 255) {
      throw Exception('List title must be between 1 and 255 characters');
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

    // Check if title already exists in the board
    final titleExists = await _listDao.titleExistsInBoard(boardId, title);
    if (titleExists) {
      throw Exception('A list with this title already exists in the board');
    }

    // Get next position if not provided
    final listPosition = position ?? await _listDao.getNextPosition(boardId);

    final list = ListModel(
      boardId: boardId,
      title: title,
      color: color,
      position: listPosition,
    );

    final id = await _listDao.insert(list);
    return list.copyWith(id: id);
  }

  // Get all lists for a specific board
  Future<List<ListModel>> getListsByBoardId(int boardId, {bool includeArchived = false}) async {
    return await _listDao.getByBoardId(boardId, includeArchived: includeArchived);
  }

  // Get all lists across all boards
  Future<List<ListModel>> getAllLists({bool includeArchived = false}) async {
    return await _listDao.getAll(includeArchived: includeArchived);
  }

  // Get list by ID
  Future<ListModel?> getListById(int id) async {
    return await _listDao.getById(id);
  }

  // Update list
  Future<ListModel?> updateList(ListModel list) async {
    // Validate title length
    if (list.title.isEmpty || list.title.length > 255) {
      throw Exception('List title must be between 1 and 255 characters');
    }

    // Validate color format if provided
    if (list.color != null && list.color!.isNotEmpty && !list.isValidColor) {
      throw Exception(
        'Invalid color format. Use hex format like #FFF, #RRGGBB, or #RRGGBBAA',
      );
    }

    // Check if title already exists in the board (excluding current list)
    final titleExists = await _listDao.titleExistsInBoard(
      list.boardId,
      list.title,
      excludeListId: list.id,
    );
    if (titleExists) {
      throw Exception('A list with this title already exists in the board');
    }

    final result = await _listDao.update(list);
    if (result > 0) {
      return await _listDao.getById(list.id!);
    }
    return null;
  }

  // Update list title
  Future<ListModel?> updateListTitle(int id, String newTitle) async {
    final list = await _listDao.getById(id);
    if (list == null) return null;

    return await updateList(list.copyWith(title: newTitle));
  }

  // Update list color
  Future<ListModel?> updateListColor(int id, String? newColor) async {
    final list = await _listDao.getById(id);
    if (list == null) return null;

    return await updateList(list.copyWith(color: newColor));
  }

  // Archive list
  Future<bool> archiveList(int id) async {
    final result = await _listDao.setArchived(id, true);
    return result > 0;
  }

  // Unarchive list
  Future<bool> unarchiveList(int id) async {
    final result = await _listDao.setArchived(id, false);
    return result > 0;
  }

  // Delete list
  Future<bool> deleteList(int id) async {
    final result = await _listDao.softDelete(id);
    return result > 0;
  }

  // Hard delete list
  Future<bool> hardDeleteList(int id) async {
    final result = await _listDao.hardDelete(id);
    return result > 0;
  }

  // Get archived lists for a specific board
  Future<List<ListModel>> getArchivedListsByBoardId(int boardId) async {
    return await _listDao.getArchivedByBoardId(boardId);
  }

  // Get all archived lists
  Future<List<ListModel>> getArchivedLists() async {
    return await _listDao.getArchived();
  }

  // Update list position
  Future<bool> updateListPosition(int id, double newPosition) async {
    final result = await _listDao.updatePosition(id, newPosition);
    return result > 0;
  }

  // Reorder lists within a board
  Future<List<ListModel>> reorderLists(List<ListModel> lists) async {
    if (lists.isEmpty) return lists;

    // Validate that all lists belong to the same board
    final boardId = lists.first.boardId;
    if (!lists.every((list) => list.boardId == boardId)) {
      throw Exception('All lists must belong to the same board for reordering');
    }

    await _listDao.reorderLists(lists);
    return await getListsByBoardId(boardId);
  }

  // Move list to new position within the same board
  Future<List<ListModel>> moveListToPosition(int listId, int newPosition) async {
    final list = await _listDao.getById(listId);
    if (list == null) {
      throw Exception('List not found');
    }

    final lists = await getListsByBoardId(list.boardId);
    final listIndex = lists.indexWhere((l) => l.id == listId);

    if (listIndex == -1) {
      throw Exception('List not found in board');
    }

    final movedList = lists.removeAt(listIndex);
    lists.insert(newPosition.clamp(0, lists.length), movedList);

    return await reorderLists(lists);
  }

  // Search lists within a board
  Future<List<ListModel>> searchListsInBoard(
    int boardId,
    String query, {
    bool includeArchived = false,
  }) async {
    if (query.trim().isEmpty) {
      return await getListsByBoardId(boardId, includeArchived: includeArchived);
    }
    return await _listDao.searchInBoard(
      boardId,
      query.trim(),
      includeArchived: includeArchived,
    );
  }

  // Search lists across all boards
  Future<List<ListModel>> searchLists(
    String query, {
    bool includeArchived = false,
  }) async {
    if (query.trim().isEmpty) {
      return await getAllLists(includeArchived: includeArchived);
    }
    return await _listDao.search(
      query.trim(),
      includeArchived: includeArchived,
    );
  }

  // Get lists statistics for a board
  Future<Map<String, int>> getListsStatisticsByBoard(int boardId) async {
    return await _listDao.getListsCountByBoard(boardId);
  }

  // Get total lists statistics
  Future<Map<String, int>> getTotalListsStatistics() async {
    return await _listDao.getTotalListsCount();
  }

  // Duplicate list
  Future<ListModel?> duplicateList(int listId, String newTitle) async {
    // Validate title length
    if (newTitle.isEmpty || newTitle.length > 255) {
      throw Exception('List title must be between 1 and 255 characters');
    }

    final originalList = await _listDao.getById(listId);
    if (originalList == null) {
      throw Exception('Original list not found');
    }

    // Check if title already exists in the board
    final titleExists = await _listDao.titleExistsInBoard(
      originalList.boardId,
      newTitle,
    );
    if (titleExists) {
      throw Exception('A list with this title already exists in the board');
    }

    return await _listDao.duplicate(listId, newTitle);
  }

  // Move list to another board
  Future<ListModel?> moveListToBoard(int listId, int newBoardId) async {
    final list = await _listDao.getById(listId);
    if (list == null) {
      throw Exception('List not found');
    }

    // Check if title already exists in the target board
    final titleExists = await _listDao.titleExistsInBoard(
      newBoardId,
      list.title,
    );
    if (titleExists) {
      throw Exception('A list with this title already exists in the target board');
    }

    final result = await _listDao.moveToBoard(listId, newBoardId);
    if (result > 0) {
      return await _listDao.getById(listId);
    }
    return null;
  }

  // Delete all lists for a board (cascade delete)
  Future<bool> deleteListsByBoardId(int boardId) async {
    final result = await _listDao.deleteByBoardId(boardId);
    return result > 0;
  }

  // Archive all lists for a board
  Future<bool> archiveListsByBoardId(int boardId) async {
    final result = await _listDao.archiveByBoardId(boardId);
    return result > 0;
  }

  // Unarchive all lists for a board
  Future<bool> unarchiveListsByBoardId(int boardId) async {
    final result = await _listDao.unarchiveByBoardId(boardId);
    return result > 0;
  }

  // Get lists by color
  Future<List<ListModel>> getListsByColor(String color, {int? boardId}) async {
    return await _listDao.getByColor(color, boardId: boardId);
  }

  // Get recently created lists
  Future<List<ListModel>> getRecentlyCreatedLists({int limit = 10, int? boardId}) async {
    return await _listDao.getRecentlyCreated(limit: limit, boardId: boardId);
  }

  // Get recently updated lists
  Future<List<ListModel>> getRecentlyUpdatedLists({int limit = 10, int? boardId}) async {
    return await _listDao.getRecentlyUpdated(limit: limit, boardId: boardId);
  }

  // Validate list data
  bool validateListData({required String title, String? color}) {
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

  // Check if list title exists in board
  Future<bool> listTitleExistsInBoard(
    int boardId,
    String title, {
    int? excludeListId,
  }) async {
    return await _listDao.titleExistsInBoard(
      boardId,
      title,
      excludeListId: excludeListId,
    );
  }

  // Get total lists count for a board
  Future<int> getTotalListsCountByBoard(int boardId) async {
    final stats = await getListsStatisticsByBoard(boardId);
    return stats['active']! + stats['archived']!;
  }

  // Get total lists count across all boards
  Future<int> getTotalListsCount() async {
    final stats = await getTotalListsStatistics();
    return stats['active']! + stats['archived']!;
  }

  // Create multiple lists in batch
  Future<List<ListModel>> createMultipleLists(
    List<Map<String, dynamic>> listsData,
  ) async {
    final lists = <ListModel>[];

    for (final data in listsData) {
      // Validate each list data
      final title = data['title'] as String;
      final boardId = data['board_id'] as int;
      final color = data['color'] as String?;

      if (!validateListData(title: title, color: color)) {
        throw Exception('Invalid list data for title: $title');
      }

      // Check for duplicate titles within the same board
      final titleExists = await _listDao.titleExistsInBoard(boardId, title);
      if (titleExists) {
        throw Exception('List with title "$title" already exists in board');
      }

      final position = data['position'] as double? ?? await _listDao.getNextPosition(boardId);

      final list = ListModel(
        boardId: boardId,
        title: title,
        color: color,
        position: position,
      );
      lists.add(list);
    }

    await _listDao.insertBatch(lists);
    
    // Return updated lists with IDs (assuming they were inserted in order)
    final result = <ListModel>[];
    for (final list in lists) {
      final insertedLists = await _listDao.getByBoardId(list.boardId);
      final matchingList = insertedLists.firstWhere(
        (l) => l.title == list.title && l.boardId == list.boardId,
      );
      result.add(matchingList);
    }
    
    return result;
  }

  // Get lists grouped by board
  Future<Map<int, List<ListModel>>> getListsGroupedByBoard({bool includeArchived = false}) async {
    final allLists = await getAllLists(includeArchived: includeArchived);
    final groupedLists = <int, List<ListModel>>{};

    for (final list in allLists) {
      if (!groupedLists.containsKey(list.boardId)) {
        groupedLists[list.boardId] = [];
      }
      groupedLists[list.boardId]!.add(list);
    }

    return groupedLists;
  }

  // Get next available position for a new list in a board
  Future<double> getNextPositionForBoard(int boardId) async {
    return await _listDao.getNextPosition(boardId);
  }
}
