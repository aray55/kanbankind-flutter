class ChecklistItem {
  final int? id;
  final int taskId;
  final String title;
  final bool isDone;
  final int position;
  final DateTime createdAt;

  ChecklistItem({
    this.id,
    required this.taskId,
    required this.title,
    this.isDone = false,
    this.position = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from database map
  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      title: map['title'] as String,
      isDone: (map['is_done'] as int) == 1,
      position: map['position'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_done': isDone ? 1 : 0,
      'position': position,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Convert to map without id (for inserts)
  Map<String, dynamic> toMapWithoutId() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Copy with method for immutable updates
  ChecklistItem copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isDone,
    int? position,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ChecklistItem{id: $id, taskId: $taskId, title: $title, isDone: $isDone, position: $position, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItem &&
        other.id == id &&
        other.taskId == taskId &&
        other.title == title &&
        other.isDone == isDone &&
        other.position == position &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        title.hashCode ^
        isDone.hashCode ^
        position.hashCode ^
        createdAt.hashCode;
  }
}
