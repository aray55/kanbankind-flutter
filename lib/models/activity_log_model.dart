/// Activity Log Model
/// Represents an activity/action performed on an entity
class ActivityLogModel {
  final int? id;
  final EntityType entityType;
  final int entityId;
  final ActionType actionType;
  final String? oldValue;
  final String? newValue;
  final String? description;
  final DateTime createdAt;

  ActivityLogModel({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.actionType,
    this.oldValue,
    this.newValue,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from Map (from database)
  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as int?,
      entityType: EntityType.fromString(map['entity_type'] as String),
      entityId: map['entity_id'] as int,
      actionType: ActionType.fromString(map['action_type'] as String),
      oldValue: map['old_value'] as String?,
      newValue: map['new_value'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entity_type': entityType.value,
      'entity_id': entityId,
      'action_type': actionType.value,
      'old_value': oldValue,
      'new_value': newValue,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType.value,
      'entity_id': entityId,
      'action_type': actionType.value,
      'old_value': oldValue,
      'new_value': newValue,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert from JSON
  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as int?,
      entityType: EntityType.fromString(json['entity_type'] as String),
      entityId: json['entity_id'] as int,
      actionType: ActionType.fromString(json['action_type'] as String),
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Copy with method for immutability
  ActivityLogModel copyWith({
    int? id,
    EntityType? entityType,
    int? entityId,
    ActionType? actionType,
    String? oldValue,
    String? newValue,
    String? description,
    DateTime? createdAt,
    bool clearOldValue = false,
    bool clearNewValue = false,
    bool clearDescription = false,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      actionType: actionType ?? this.actionType,
      oldValue: clearOldValue ? null : (oldValue ?? this.oldValue),
      newValue: clearNewValue ? null : (newValue ?? this.newValue),
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool get hasOldValue => oldValue != null && oldValue!.isNotEmpty;
  bool get hasNewValue => newValue != null && newValue!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasValueChange => hasOldValue || hasNewValue;

  // Get formatted description
  String getFormattedDescription() {
    if (hasDescription) return description!;

    // Generate default description based on action type
    final entityName = entityType.displayName;
    final actionName = actionType.displayName;

    if (hasValueChange) {
      if (hasOldValue && hasNewValue) {
        return '$entityName $actionName from "$oldValue" to "$newValue"';
      } else if (hasNewValue) {
        return '$entityName $actionName to "$newValue"';
      } else if (hasOldValue) {
        return '$entityName $actionName from "$oldValue"';
      }
    }

    return '$entityName $actionName';
  }

  // Validation
  bool isValid() {
    return entityId > 0;
  }

  String? validate() {
    if (entityId <= 0) {
      return 'Invalid entity ID';
    }
    return null;
  }

  @override
  String toString() {
    return 'ActivityLogModel(id: $id, entityType: ${entityType.value}, entityId: $entityId, actionType: ${actionType.value}, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityLogModel &&
        other.id == id &&
        other.entityType == entityType &&
        other.entityId == entityId &&
        other.actionType == actionType &&
        other.oldValue == oldValue &&
        other.newValue == newValue &&
        other.description == description &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        entityType.hashCode ^
        entityId.hashCode ^
        actionType.hashCode ^
        oldValue.hashCode ^
        newValue.hashCode ^
        description.hashCode ^
        createdAt.hashCode;
  }
}

/// Entity Type Enum
enum EntityType {
  board('board'),
  list('list'),
  card('card'),
  checklist('checklist'),
  comment('comment'),
  attachment('attachment'),
  label('label');

  final String value;
  const EntityType(this.value);

  static EntityType fromString(String value) {
    return EntityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EntityType.card,
    );
  }

  String get displayName {
    switch (this) {
      case EntityType.board:
        return 'Board';
      case EntityType.list:
        return 'List';
      case EntityType.card:
        return 'Card';
      case EntityType.checklist:
        return 'Checklist';
      case EntityType.comment:
        return 'Comment';
      case EntityType.attachment:
        return 'Attachment';
      case EntityType.label:
        return 'Label';
    }
  }
}

/// Action Type Enum
enum ActionType {
  created('created'),
  updated('updated'),
  deleted('deleted'),
  moved('moved'),
  archived('archived'),
  restored('restored'),
  completed('completed'),
  uncompleted('uncompleted');

  final String value;
  const ActionType(this.value);

  static ActionType fromString(String value) {
    return ActionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActionType.updated,
    );
  }

  String get displayName {
    switch (this) {
      case ActionType.created:
        return 'created';
      case ActionType.updated:
        return 'updated';
      case ActionType.deleted:
        return 'deleted';
      case ActionType.moved:
        return 'moved';
      case ActionType.archived:
        return 'archived';
      case ActionType.restored:
        return 'restored';
      case ActionType.completed:
        return 'completed';
      case ActionType.uncompleted:
        return 'uncompleted';
    }
  }

  // Get icon for action type
  String get icon {
    switch (this) {
      case ActionType.created:
        return '➕';
      case ActionType.updated:
        return '✏️';
      case ActionType.deleted:
        return '🗑️';
      case ActionType.moved:
        return '↔️';
      case ActionType.archived:
        return '📦';
      case ActionType.restored:
        return '♻️';
      case ActionType.completed:
        return '✅';
      case ActionType.uncompleted:
        return '⭕';
    }
  }
}
