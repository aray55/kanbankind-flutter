class ListModel {
  final int? id;
  final int boardId;
  final String title;
  final String? color; // Hex color code
  final double position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  final DateTime? deletedAt;

  ListModel({
    this.id,
    required this.boardId,
    required this.title,
    this.color,
    this.position = 1024.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archived = false,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for immutable updates
  ListModel copyWith({
    int? id,
    int? boardId,
    String? title,
    String? color,
    double? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    DateTime? deletedAt,
  }) {
    return ListModel(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      title: title ?? this.title,
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
      'board_id': boardId,
      'title': title,
      'color': color,
      'position': position,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000, // Convert to seconds for SQLite
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
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
  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id']?.toInt(),
      boardId: map['board_id'] as int,
      title: map['title'] as String,
      color: map['color'] as String?,
      position: (map['position'] as num?)?.toDouble() ?? 1024.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000, // Convert from seconds to milliseconds
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updated_at'] as int) * 1000,
      ),
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

  // JSON serialization for API or backup purposes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'board_id': boardId,
      'title': title,
      'color': color,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived': archived,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id']?.toInt(),
      boardId: json['board_id'] as int,
      title: json['title'] as String,
      color: json['color'] as String?,
      position: (json['position'] as num?)?.toDouble() ?? 1024.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archived: json['archived'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'ListModel{id: $id, boardId: $boardId, title: $title, position: $position, archived: $archived, deleted: $isDeleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListModel &&
        other.id == id &&
        other.boardId == boardId &&
        other.title == title &&
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
        boardId.hashCode ^
        title.hashCode ^
        color.hashCode ^
        position.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        archived.hashCode ^
        deletedAt.hashCode;
  }
}
