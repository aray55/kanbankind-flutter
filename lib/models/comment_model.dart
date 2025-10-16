/// Comment Model
/// Represents a comment on a card
class CommentModel {
  final int? id;
  final int cardId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CommentModel({
    this.id,
    required this.cardId,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert from Map (from database)
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as int?,
      cardId: map['card_id'] as int,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000),
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['deleted_at'] as int) * 1000)
          : null,
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
      if (deletedAt != null) 'deleted_at': deletedAt!.millisecondsSinceEpoch ~/ 1000,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int?,
      cardId: json['card_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  CommentModel copyWith({
    int? id,
    int? cardId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return CommentModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  // Helper methods
  bool get isDeleted => deletedAt != null;
  bool get isEdited => updatedAt.isAfter(createdAt.add(const Duration(seconds: 1)));

  // Validation
  bool isValid() {
    return content.trim().isNotEmpty && cardId > 0;
  }

  String? validate() {
    if (content.trim().isEmpty) {
      return 'Comment content cannot be empty';
    }
    if (cardId <= 0) {
      return 'Invalid card ID';
    }
    return null;
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, cardId: $cardId, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., createdAt: $createdAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
