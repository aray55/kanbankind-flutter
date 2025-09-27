import 'dart:convert';
import 'label_model.dart';

class CardLabelModel {
  final int? id;
  final int cardId;
  final int labelId;
  final int? deletedAt;

  // Optional populated label data
  final LabelModel? label;

  const CardLabelModel({
    this.id,
    required this.cardId,
    required this.labelId,
    this.deletedAt,
    this.label,
  });

  // Validation
  bool get isValid {
    return cardId > 0 && labelId > 0;
  }

  // Helper getters
  bool get isDeleted => deletedAt != null;
  DateTime? get deletedAtDateTime => deletedAt != null 
      ? DateTime.fromMillisecondsSinceEpoch(deletedAt! * 1000) 
      : null;

  // Create from Map (Database)
  factory CardLabelModel.fromMap(Map<String, dynamic> map) {
    return CardLabelModel(
      id: map['id']?.toInt(),
      cardId: map['card_id']?.toInt() ?? 0,
      labelId: map['label_id']?.toInt() ?? 0,
      deletedAt: map['deleted_at']?.toInt(),
      // If label data is included in the map (from JOIN query)
      label: map.containsKey('label_name') ? LabelModel(
        id: map['label_id']?.toInt(),
        boardId: map['label_board_id']?.toInt() ?? 0,
        name: map['label_name']?.toString() ?? '',
        color: map['label_color']?.toString() ?? '',
        createdAt: map['label_created_at']?.toInt() ?? 0,
        updatedAt: map['label_updated_at']?.toInt() ?? 0,
        deletedAt: map['label_deleted_at']?.toInt(),
      ) : null,
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'label_id': labelId,
      if (deletedAt != null) 'deleted_at': deletedAt,
    };
  }

  // Create from JSON
  factory CardLabelModel.fromJson(String source) {
    return CardLabelModel.fromMap(json.decode(source));
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Copy with modifications
  CardLabelModel copyWith({
    int? id,
    int? cardId,
    int? labelId,
    int? deletedAt,
    bool clearDeletedAt = false,
    LabelModel? label,
  }) {
    return CardLabelModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      labelId: labelId ?? this.labelId,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      label: label ?? this.label,
    );
  }

  // Equality and HashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardLabelModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.labelId == labelId &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        labelId.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'CardLabelModel(id: $id, cardId: $cardId, labelId: $labelId, deletedAt: $deletedAt, label: $label)';
  }

  // Factory methods for common operations
  factory CardLabelModel.create({
    required int cardId,
    required int labelId,
  }) {
    return CardLabelModel(
      cardId: cardId,
      labelId: labelId,
    );
  }

  // Soft delete
  CardLabelModel markAsDeleted() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return copyWith(deletedAt: now);
  }

  // Restore from soft delete
  CardLabelModel restore() {
    return copyWith(clearDeletedAt: true);
  }
}
