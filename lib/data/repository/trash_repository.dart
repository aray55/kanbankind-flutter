import '../../models/trash_item_model.dart';
import '../database/database_provider.dart';
import '../../core/constants/database_constants.dart';

/// Trash Repository
/// Purpose: Handle all database operations for deleted items
/// Features: Get all deleted items, restore items, permanently delete items

class TrashRepository {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  /// Get all deleted items from all tables
  Future<List<TrashItemModel>> getAllDeletedItems() async {
    final db = await _databaseProvider.database;
    final List<TrashItemModel> allItems = [];

    try {
      // Get deleted boards
      final deletedBoards = await db.rawQuery('''
        SELECT *, 'board' as item_type, NULL as parent_info
        FROM ${DatabaseConstants.boardsTable} 
        WHERE deleted_at IS NOT NULL 
        ORDER BY deleted_at DESC
      ''');

      for (final board in deletedBoards) {
        allItems.add(TrashItemModel.fromMap(board, 'board'));
      }

      // Get deleted lists with board info
      final deletedLists = await db.rawQuery('''
        SELECT l.*, 'list' as item_type, b.title as parent_info
        FROM ${DatabaseConstants.listTable} l
        LEFT JOIN ${DatabaseConstants.boardsTable} b ON l.board_id = b.id
        WHERE l.deleted_at IS NOT NULL 
        ORDER BY l.deleted_at DESC
      ''');

      for (final list in deletedLists) {
        allItems.add(TrashItemModel.fromMap(list, 'list'));
      }

      // Get deleted cards with list and board info
      final deletedCards = await db.rawQuery('''
        SELECT c.*, 'card' as item_type, 
               COALESCE(l.title, 'قائمة محذوفة') || ' - ' || COALESCE(b.title, 'لوحة محذوفة') as parent_info
        FROM ${DatabaseConstants.cardsTable} c
        LEFT JOIN ${DatabaseConstants.listTable} l ON c.list_id = l.id
        LEFT JOIN ${DatabaseConstants.boardsTable} b ON l.board_id = b.id
        WHERE c.deleted_at IS NOT NULL 
        ORDER BY c.deleted_at DESC
      ''');

      for (final card in deletedCards) {
        allItems.add(TrashItemModel.fromMap(card, 'card'));
      }

      // Get deleted checklists with card info
      final deletedChecklists = await db.rawQuery('''
        SELECT ch.*, 'checklist' as item_type, 
               COALESCE(c.title, 'بطاقة محذوفة') as parent_info
        FROM ${DatabaseConstants.checklistsTable} ch
        LEFT JOIN ${DatabaseConstants.cardsTable} c ON ch.card_id = c.id
        WHERE ch.deleted_at IS NOT NULL 
        ORDER BY ch.deleted_at DESC
      ''');

      for (final checklist in deletedChecklists) {
        allItems.add(TrashItemModel.fromMap(checklist, 'checklist'));
      }

      // Get deleted checklist items with checklist info
      final deletedChecklistItems = await db.rawQuery('''
        SELECT ci.*, 'checklist_item' as item_type, 
               COALESCE(ch.title, 'قائمة تحقق محذوفة') as parent_info
        FROM ${DatabaseConstants.checklistItemsTable} ci
        LEFT JOIN ${DatabaseConstants.checklistsTable} ch ON ci.checklist_id = ch.id
        WHERE ci.deleted_at IS NOT NULL 
        ORDER BY ci.deleted_at DESC
      ''');

      for (final item in deletedChecklistItems) {
        allItems.add(TrashItemModel.fromMap(item, 'checklist_item'));
      }

      // Get deleted labels with board info
      final deletedLabels = await db.rawQuery('''
        SELECT l.*, 'label' as item_type, 
               COALESCE(b.title, 'لوحة محذوفة') as parent_info
        FROM ${DatabaseConstants.labelsTable} l
        LEFT JOIN ${DatabaseConstants.boardsTable} b ON l.board_id = b.id
        WHERE l.deleted_at IS NOT NULL 
        ORDER BY l.deleted_at DESC
      ''');

      for (final label in deletedLabels) {
        allItems.add(TrashItemModel.fromMap(label, 'label'));
      }

      // Sort all items by deletion date (most recent first)
      allItems.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

      return allItems;
    } catch (e) {
      throw Exception('Failed to get deleted items: $e');
    }
  }

  /// Get deleted items by type
  Future<List<TrashItemModel>> getDeletedItemsByType(String type) async {
    final allItems = await getAllDeletedItems();
    return allItems.where((item) => item.type == type).toList();
  }

  /// Restore an item (set deleted_at to NULL)
  Future<bool> restoreItem(TrashItemModel item) async {
    final db = await _databaseProvider.database;

    try {
      final tableName = _getTableNameForType(item.type);
      final result = await db.update(
        tableName,
        {'deleted_at': null},
        where: 'id = ?',
        whereArgs: [item.id],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Failed to restore item: $e');
    }
  }

  /// Permanently delete an item
  Future<bool> permanentlyDeleteItem(TrashItemModel item) async {
    final db = await _databaseProvider.database;

    try {
      final tableName = _getTableNameForType(item.type);
      final result = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [item.id],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Failed to permanently delete item: $e');
    }
  }

  /// Empty trash (permanently delete all deleted items)
  Future<int> emptyTrash() async {
    final db = await _databaseProvider.database;
    int totalDeleted = 0;

    try {
      await db.transaction((txn) async {
        // Delete from all tables
        final tables = [
          DatabaseConstants.boardsTable,
          DatabaseConstants.listTable,
          DatabaseConstants.cardsTable,
          DatabaseConstants.checklistsTable,
          DatabaseConstants.checklistItemsTable,
          DatabaseConstants.labelsTable,
          DatabaseConstants.cardLabelsTable,
        ];

        for (final table in tables) {
          final result = await txn.delete(
            table,
            where: 'deleted_at IS NOT NULL',
          );
          totalDeleted += result;
        }
      });

      return totalDeleted;
    } catch (e) {
      throw Exception('Failed to empty trash: $e');
    }
  }

  /// Get trash statistics
  Future<Map<String, int>> getTrashStatistics() async {
    final db = await _databaseProvider.database;

    try {
      final stats = <String, int>{};

      // Count deleted items by type
      final tables = {
        'boards': DatabaseConstants.boardsTable,
        'lists': DatabaseConstants.listTable,
        'cards': DatabaseConstants.cardsTable,
        'checklists': DatabaseConstants.checklistsTable,
        'checklist_items': DatabaseConstants.checklistItemsTable,
        'labels': DatabaseConstants.labelsTable,
      };

      for (final entry in tables.entries) {
        final result = await db.rawQuery('''
          SELECT COUNT(*) as count 
          FROM ${entry.value} 
          WHERE deleted_at IS NOT NULL
        ''');
        stats[entry.key] = (result.first['count'] as int?) ?? 0;
      }

      // Calculate total
      stats['total'] = stats.values.fold(0, (sum, count) => sum + count);

      return stats;
    } catch (e) {
      throw Exception('Failed to get trash statistics: $e');
    }
  }

  /// Clean old deleted items (older than specified days)
  Future<int> cleanOldDeletedItems({int olderThanDays = 30}) async {
    final db = await _databaseProvider.database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .millisecondsSinceEpoch ~/ 1000;

    int totalCleaned = 0;

    try {
      await db.transaction((txn) async {
        final tables = [
          DatabaseConstants.boardsTable,
          DatabaseConstants.listTable,
          DatabaseConstants.cardsTable,
          DatabaseConstants.checklistsTable,
          DatabaseConstants.checklistItemsTable,
          DatabaseConstants.labelsTable,
          DatabaseConstants.cardLabelsTable,
        ];

        for (final table in tables) {
          final result = await txn.delete(
            table,
            where: 'deleted_at IS NOT NULL AND deleted_at < ?',
            whereArgs: [cutoffTime],
          );
          totalCleaned += result;
        }
      });

      return totalCleaned;
    } catch (e) {
      throw Exception('Failed to clean old deleted items: $e');
    }
  }

  /// Get table name for item type
  String _getTableNameForType(String type) {
    switch (type) {
      case 'board':
        return DatabaseConstants.boardsTable;
      case 'list':
        return DatabaseConstants.listTable;
      case 'card':
        return DatabaseConstants.cardsTable;
      case 'checklist':
        return DatabaseConstants.checklistsTable;
      case 'checklist_item':
        return DatabaseConstants.checklistItemsTable;
      case 'label':
        return DatabaseConstants.labelsTable;
      default:
        throw ArgumentError('Unknown item type: $type');
    }
  }

  /// Search deleted items
  Future<List<TrashItemModel>> searchDeletedItems(String query) async {
    if (query.trim().isEmpty) {
      return getAllDeletedItems();
    }

    final allItems = await getAllDeletedItems();
    final searchQuery = query.toLowerCase().trim();

    return allItems.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
          (item.description?.toLowerCase().contains(searchQuery) ?? false) ||
          (item.parentInfo?.toLowerCase().contains(searchQuery) ?? false) ||
          item.typeDisplayName.toLowerCase().contains(searchQuery);
    }).toList();
  }
}
