/// Represents a checklist in a Kanban card
class ChecklistModel {
  final int? id;
  final int cardId;
  final String title;
  final double position;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ChecklistModel({
    this.id,
    required this.cardId,
    required this.title,
    this.position = 1024.0,
    this.archived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this checklist with the given fields replaced with new values
  ChecklistModel copyWith({
    int? id,
    int? cardId,
    String? title,
    double? position,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ChecklistModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      position: position ?? this.position,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Converts this checklist to a map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'card_id': cardId,
      'title': title,
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

  /// Converts this checklist to a map without the id (for inserts)
  Map<String, dynamic> toMapWithoutId() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// Creates a checklist from a database map
  factory ChecklistModel.fromMap(Map<String, dynamic> map) {
    return ChecklistModel(
      id: map['id']?.toInt(),
      cardId: map['card_id'] as int,
      title: map['title'] as String,
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

  /// Validation helpers
  bool get isValidTitle => title.isNotEmpty && title.length <= 255;

  /// JSON serialization for API or backup purposes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'title': title,
      'position': position,
      'archived': archived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    return ChecklistModel(
      id: json['id']?.toInt(),
      cardId: json['card_id'] as int,
      title: json['title'] as String,
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
    return 'ChecklistModel{id: $id, cardId: $cardId, title: $title, position: $position, archived: $archived, deleted: $isDeleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.title == title &&
        other.position == position &&
        other.archived == archived &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        title.hashCode ^
        position.hashCode ^
        archived.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
