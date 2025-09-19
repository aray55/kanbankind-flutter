class Board {
  final int? id;
  final String uuid;
  final String title;
  final String? description;
  final String? color; // Hex color code
  final int position;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool archived;
  final DateTime? deletedAt;

  Board({
    this.id,
    required this.uuid,
    required this.title,
    this.description,
    this.color,
    this.position = 1024,
    DateTime? createdAt,
    this.updatedAt,
    this.archived = false,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method for immutable updates
  Board copyWith({
    int? id,
    String? uuid,
    String? title,
    String? description,
    String? color,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    DateTime? deletedAt,
  }) {
    return Board(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uuid': uuid,
      'title': title,
      'description': description,
      'color': color,
      'position': position,
      'created_at':
          createdAt.millisecondsSinceEpoch ~/
          1000, // Convert to seconds for SQLite
      'updated_at': updatedAt != null
          ? updatedAt!.millisecondsSinceEpoch ~/ 1000
          : null,
      'archived': archived ? 1 : 0,
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

  // Convert to map without id (for inserts)
  Map<String, dynamic> toMapWithoutId() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Create from database map
  factory Board.fromMap(Map<String, dynamic> map) {
    return Board(
      id: map['id']?.toInt(),
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      color: map['color'] as String?,
      position: map['position']?.toInt() ?? 1024,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) *
            1000, // Convert from seconds to milliseconds
      ),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['updated_at'] as int) * 1000,
            )
          : null,
      archived: (map['archived'] as int) == 1,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['deleted_at'] as int) * 1000,
            )
          : null,
    );
  }

  // Helper methods
  bool get isDeleted => deletedAt != null;
  bool get isActive => !archived && !isDeleted;

  // Validation helpers
  bool get isValidColor {
    if (color == null) return true;
    final colorRegex = RegExp(
      r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$',
    );
    return colorRegex.hasMatch(color!);
  }

  bool get isValidTitle => title.isNotEmpty && title.length <= 255;

  @override
  String toString() {
    return 'Board{id: $id, uuid: $uuid, title: $title, position: $position, archived: $archived, deleted: $isDeleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Board &&
        other.id == id &&
        other.uuid == uuid &&
        other.title == title &&
        other.description == description &&
        other.color == color &&
        other.position == position &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.archived == archived &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uuid.hashCode ^
        title.hashCode ^
        description.hashCode ^
        color.hashCode ^
        position.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        archived.hashCode ^
        deletedAt.hashCode;
  }
}
