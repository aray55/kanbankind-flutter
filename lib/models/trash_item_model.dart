/// Trash Item Model
/// Purpose: Represents a deleted item from any table in the database
/// Used in: Trash screen to display all deleted items uniformly

class TrashItemModel {
  final int id;
  final String type; // 'board', 'list', 'card', 'checklist', 'checklist_item', 'label'
  final String title;
  final String? description;
  final String? parentInfo; // Board name for lists/cards, List name for cards, etc.
  final DateTime deletedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> originalData; // Store original data for restoration

  const TrashItemModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.parentInfo,
    required this.deletedAt,
    required this.createdAt,
    this.updatedAt,
    required this.originalData,
  });

  /// Create TrashItemModel from database map
  factory TrashItemModel.fromMap(Map<String, dynamic> map, String type) {
    return TrashItemModel(
      id: map['id'] as int,
      type: type,
      title: map['title'] as String? ?? map['name'] as String? ?? 'Unknown',
      description: map['description'] as String?,
      parentInfo: map['parent_info'] as String?,
      deletedAt: DateTime.fromMillisecondsSinceEpoch((map['deleted_at'] as int) * 1000),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000)
          : null,
      originalData: Map<String, dynamic>.from(map),
    );
  }

  /// Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'parent_info': parentInfo,
      'deleted_at': deletedAt.millisecondsSinceEpoch ~/ 1000,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt?.millisecondsSinceEpoch != null ? updatedAt!.millisecondsSinceEpoch ~/ 1000 : null,
      'original_data': originalData,
    };
  }

  /// Get display name for the item type
  String get typeDisplayName {
    switch (type) {
      case 'board':
        return 'لوحة';
      case 'list':
        return 'قائمة';
      case 'card':
        return 'بطاقة';
      case 'checklist':
        return 'قائمة تحقق';
      case 'checklist_item':
        return 'عنصر تحقق';
      case 'label':
        return 'تسمية';
      default:
        return 'عنصر';
    }
  }

  /// Get icon for the item type
  String get typeIcon {
    switch (type) {
      case 'board':
        return '📋';
      case 'list':
        return '📝';
      case 'card':
        return '🎫';
      case 'checklist':
        return '☑️';
      case 'checklist_item':
        return '✅';
      case 'label':
        return '🏷️';
      default:
        return '📄';
    }
  }

  /// Get color for the item type
  String get typeColor {
    switch (type) {
      case 'board':
        return '#2196F3'; // Blue
      case 'list':
        return '#4CAF50'; // Green
      case 'card':
        return '#FF9800'; // Orange
      case 'checklist':
        return '#9C27B0'; // Purple
      case 'checklist_item':
        return '#E91E63'; // Pink
      case 'label':
        return '#607D8B'; // Blue Grey
      default:
        return '#757575'; // Grey
    }
  }

  /// Get formatted deletion time
  String get formattedDeletedAt {
    final now = DateTime.now();
    final difference = now.difference(deletedAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// Create a copy with updated fields
  TrashItemModel copyWith({
    int? id,
    String? type,
    String? title,
    String? description,
    String? parentInfo,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? originalData,
  }) {
    return TrashItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      parentInfo: parentInfo ?? this.parentInfo,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalData: originalData ?? this.originalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrashItemModel &&
        other.id == id &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() {
    return 'TrashItemModel(id: $id, type: $type, title: $title, deletedAt: $deletedAt)';
  }
}

/// Enum for trash item types
enum TrashItemType {
  board,
  list,
  card,
  checklist,
  checklistItem,
  label,
}

extension TrashItemTypeExtension on TrashItemType {
  String get value {
    switch (this) {
      case TrashItemType.board:
        return 'board';
      case TrashItemType.list:
        return 'list';
      case TrashItemType.card:
        return 'card';
      case TrashItemType.checklist:
        return 'checklist';
      case TrashItemType.checklistItem:
        return 'checklist_item';
      case TrashItemType.label:
        return 'label';
    }
  }

  String get displayName {
    switch (this) {
      case TrashItemType.board:
        return 'لوحة';
      case TrashItemType.list:
        return 'قائمة';
      case TrashItemType.card:
        return 'بطاقة';
      case TrashItemType.checklist:
        return 'قائمة تحقق';
      case TrashItemType.checklistItem:
        return 'عنصر تحقق';
      case TrashItemType.label:
        return 'تسمية';
    }
  }
}
