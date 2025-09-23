/// Represents a checklist item in a checklist
class ChecklistItemModel {
  final int? id;
  final int checklistId;
  final String title;
  final bool isDone;
  final double position;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ChecklistItemModel({
    this.id,
    required this.checklistId,
    required this.title,
    this.isDone = false,
    this.position = 1024.0,
    this.archived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this checklist item with the given fields replaced with new values
  ChecklistItemModel copyWith({
    int? id,
    int? checklistId,
    String? title,
    bool? isDone,
    double? position,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      checklistId: checklistId ?? this.checklistId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      position: position ?? this.position,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Converts this checklist item to a map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'checklist_id': checklistId,
      'title': title,
      'is_done': isDone ? 1 : 0,
      'position': position,
      'archived': archived ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000, // Convert to seconds for SQLite
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
      'deleted_at': deletedAt != null
          ? deletedAt!.millisecondsSinceEpoch ~/ 1000
          : null,
    };

    // Only include id if it's not null (for updates)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// Converts this checklist item to a map without the id (for inserts)
  Map<String, dynamic> toMapWithoutId() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// Creates a checklist item from a database map
  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id']?.toInt(),
      checklistId: map['checklist_id'] as int,
      title: map['title'] as String,
      isDone: (map['is_done'] as int) == 1,
      position: (map['position'] as num?)?.toDouble() ?? 1024.0,
      archived: (map['archived'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000, // Convert from seconds to milliseconds
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updated_at'] as int) * 1000,
      ),
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['deleted_at'] as int) * 1000,
            )
          : null,
    );
  }

  /// Helper methods
  bool get isDeleted => deletedAt != null;
  bool get isActive => !archived && !isDeleted;
  bool get isCompleted => isDone && !isDeleted;
  bool get isPending => !isDone && !isDeleted;

  /// Validation helpers
  bool get isValidTitle => title.isNotEmpty && title.length <= 255;

  /// Toggle completion status
  ChecklistItemModel toggleDone() {
    return copyWith(isDone: !isDone);
  }

  /// Mark as completed
  ChecklistItemModel markAsCompleted() {
    return copyWith(isDone: true);
  }

  /// Mark as pending
  ChecklistItemModel markAsPending() {
    return copyWith(isDone: false);
  }

  /// Archive this item
  ChecklistItemModel archive() {
    return copyWith(archived: true);
  }

  /// Restore this item from archive
  ChecklistItemModel restore() {
    return copyWith(archived: false);
  }

  /// Soft delete this item
  ChecklistItemModel softDelete() {
    return copyWith(deletedAt: DateTime.now());
  }

  /// JSON serialization for API or backup purposes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checklist_id': checklistId,
      'title': title,
      'is_done': isDone,
      'position': position,
      'archived': archived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id']?.toInt(),
      checklistId: json['checklist_id'] as int,
      title: json['title'] as String,
      isDone: json['is_done'] as bool? ?? false,
      position: (json['position'] as num?)?.toDouble() ?? 1024.0,
      archived: json['archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'ChecklistItemModel{id: $id, checklistId: $checklistId, title: $title, isDone: $isDone, position: $position, archived: $archived, deleted: $isDeleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItemModel &&
        other.id == id &&
        other.checklistId == checklistId &&
        other.title == title &&
        other.isDone == isDone &&
        other.position == position &&
        other.archived == archived &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        checklistId.hashCode ^
        title.hashCode ^
        isDone.hashCode ^
        position.hashCode ^
        archived.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
