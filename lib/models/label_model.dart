import 'dart:convert';

class LabelModel {
  final int? id;
  final int boardId;
  final String name;
  final String color;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const LabelModel({
    this.id,
    required this.boardId,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Validation
  bool get isValid {
    return name.isNotEmpty && 
           name.length <= 100 && 
           color.isNotEmpty &&
           _isValidHexColor(color) &&
           boardId > 0;
  }

  bool _isValidHexColor(String color) {
    // Check if color is a valid hex color (with or without #)
    final hexPattern = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexPattern.hasMatch(color);
  }

  // Helper getters
  bool get isDeleted => deletedAt != null;
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
  DateTime get updatedAtDateTime => DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000);
  DateTime? get deletedAtDateTime => deletedAt != null 
      ? DateTime.fromMillisecondsSinceEpoch(deletedAt! * 1000) 
      : null;

  // Ensure color has # prefix
  String get formattedColor => color.startsWith('#') ? color : '#$color';

  // Create from Map (Database)
  factory LabelModel.fromMap(Map<String, dynamic> map) {
    return LabelModel(
      id: map['id']?.toInt(),
      boardId: map['board_id']?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      color: map['color']?.toString() ?? '',
      createdAt: map['created_at']?.toInt() ?? 0,
      updatedAt: map['updated_at']?.toInt() ?? 0,
      deletedAt: map['deleted_at']?.toInt(),
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'board_id': boardId,
      'name': name,
      'color': color,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    };
  }

  // Create from JSON
  factory LabelModel.fromJson(String source) {
    return LabelModel.fromMap(json.decode(source));
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Copy with modifications
  LabelModel copyWith({
    int? id,
    int? boardId,
    String? name,
    String? color,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return LabelModel(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  // Equality and HashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelModel &&
        other.id == id &&
        other.boardId == boardId &&
        other.name == name &&
        other.color == color &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        boardId.hashCode ^
        name.hashCode ^
        color.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'LabelModel(id: $id, boardId: $boardId, name: $name, color: $color, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  // Factory methods for common operations
  factory LabelModel.create({
    required int boardId,
    required String name,
    required String color,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LabelModel(
      boardId: boardId,
      name: name.trim(),
      color: color.startsWith('#') ? color : '#$color',
      createdAt: now,
      updatedAt: now,
    );
  }

  // Soft delete
  LabelModel markAsDeleted() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return copyWith(
      deletedAt: now,
      updatedAt: now,
    );
  }

  // Restore from soft delete
  LabelModel restore() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return copyWith(
      clearDeletedAt: true,
      updatedAt: now,
    );
  }

  // Update with new timestamp
  LabelModel updateWith({
    String? name,
    String? color,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return copyWith(
      name: name,
      color: color,
      updatedAt: now,
    );
  }
}
