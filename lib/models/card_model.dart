import '../core/enums/card_status.dart';

/// Represents a card in a Kanban board list
class CardModel {
  final int? id;
  final int listId;
  final String title;
  final String? description;
  final double position;
  final CardStatus status;
  final String? coverColor;
  final String? coverImage;
  final DateTime? completedAt;
  final bool archived;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;

  CardModel({
    this.id,
    required this.listId,
    required this.title,
    this.description,
    this.position = 1024.0,
    this.status = CardStatus.todo,
    this.coverColor,
    this.coverImage,
    this.completedAt,
    this.archived = false,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dueDate,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
       

  /// Creates a copy of this card with the given fields replaced with new values
  CardModel copyWith({
    int? id,
    int? listId,
    String? title,
    String? description,
    double? position,
    CardStatus? status,
    String? coverColor,
    String? coverImage,
    DateTime? completedAt,
    bool? archived,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool clearDescription = false,
    bool clearCoverColor = false,
    bool clearCoverImage = false,
    bool clearCompletedAt = false,
    bool clearDeletedAt = false,
  }) {
    return CardModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      position: position ?? this.position,
      status: status ?? this.status,
      coverColor: clearCoverColor ? null : (coverColor ?? this.coverColor),
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      archived: archived ?? this.archived,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  /// Converts this card to a map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'list_id': listId,
      'title': title,
      'description': description,
      'position': position,
      'status': status.value,
      'completed_at': completedAt != null
          ? completedAt!.millisecondsSinceEpoch ~/ 1000
          : null, // Convert to seconds for SQLite
      'archived': archived ? 1 : 0,
      'deleted_at': deletedAt != null
          ? deletedAt!.millisecondsSinceEpoch ~/ 1000
          : null,
      'cover_color': coverColor,
      'cover_image': coverImage,
      'created_at':
          createdAt.millisecondsSinceEpoch ~/
          1000, // Convert to seconds for SQLite
      'updated_at':
          updatedAt.millisecondsSinceEpoch ~/
          1000, // Convert to seconds for SQLite
      'due_date': dueDate != null
          ? dueDate!.millisecondsSinceEpoch ~/ 1000
          : null, // Convert to seconds for SQLite
    };

    // Only include id if it's not null (for updates)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// Converts this card to a map without the id (for inserts)
  Map<String, dynamic> toMapWithoutId() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// Creates a card from a database map
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id']?.toInt(),
      listId: map['list_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      position: (map['position'] as num?)?.toDouble() ?? 1024.0,
      status: CardStatus.fromString(map['status'] as String? ?? 'todo'),
      coverColor: map['cover_color'] as String?,
      coverImage: map['cover_image'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['completed_at'] as int) * 1000,
            ) // Convert from seconds to milliseconds
          : null,
      archived: (map['archived'] as int) == 1,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['deleted_at'] as int) * 1000,
            )
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ), // Convert from seconds to milliseconds
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updated_at'] as int) * 1000,
      ), // Convert from seconds to milliseconds
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['due_date'] as int) * 1000,
            ) // Convert from seconds to milliseconds
          : null,
      );
  }

  /// Helper methods
  bool get isDeleted => deletedAt != null;
  bool get isActive => !archived && !isDeleted;
  bool get isCompleted => completedAt != null;
  bool get hasCover => coverColor != null || coverImage != null;

  /// Validation helpers
  bool get isValidTitle => title.isNotEmpty && title.length <= 255;

  /// JSON serialization for API or backup purposes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'description': description,
      'position': position,
      'status': status.value,
      'completed_at': completedAt?.toIso8601String(),
      'archived': archived,
      'deleted_at': deletedAt?.toIso8601String(),
      'cover_color': coverColor,
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id']?.toInt(),
      listId: json['list_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num?)?.toDouble() ?? 1024.0,
      status: CardStatus.fromString(json['status'] as String? ?? 'todo'),
      coverColor: json['cover_color'] as String?,
      coverImage: json['cover_image'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      archived: json['archived'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'CardModel{id: $id, listId: $listId, title: $title, position: $position, status: ${status.value}, archived: $archived, deleted: $isDeleted, coverColor: $coverColor, coverImage: $coverImage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardModel &&
        other.id == id &&
        other.listId == listId &&
        other.title == title &&
        other.description == description &&
        other.position == position &&
        other.status == status &&
        other.coverColor == coverColor &&
        other.coverImage == coverImage &&
        other.completedAt == completedAt &&
        other.archived == archived &&
        other.deletedAt == deletedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueDate == dueDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        position.hashCode ^
        status.hashCode ^
        coverColor.hashCode ^
        coverImage.hashCode ^
        completedAt.hashCode ^
        archived.hashCode ^
        deletedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        dueDate.hashCode;
  }
}
