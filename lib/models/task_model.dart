import '../core/enums/task_status.dart';
import 'checklist_item_model.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int priority; // 1 = high, 2 = medium, 3 = low
  final List<ChecklistItem> checklistItems;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.priority = 2,
    this.checklistItems = const [],
    this.updatedAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    List<ChecklistItem>? checklistItems,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      checklistItems: checklistItems ?? this.checklistItems,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status.value,
      'created_at': createdAt.millisecondsSinceEpoch,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
    
    // Only include id if it's not null (for updates)
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: TaskStatus.fromString(map['status'] ?? 'todo'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      dueDate: map['due_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'])
          : null,
      priority: map['priority']?.toInt() ?? 2,
      // Note: checklistItems are loaded separately via TaskDao
      checklistItems: const [],
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  // Helper methods for checklist functionality
  bool get hasChecklistItems => checklistItems.isNotEmpty;
  
  int get totalChecklistItems => checklistItems.length;
  
  int get completedChecklistItems => 
      checklistItems.where((item) => item.isDone).length;
  
  double get checklistProgress => 
      totalChecklistItems > 0 ? completedChecklistItems / totalChecklistItems : 0.0;
  
  bool get isChecklistCompleted => 
      totalChecklistItems > 0 && completedChecklistItems == totalChecklistItems;
  
  String get checklistProgressText => 
      '$completedChecklistItems/$totalChecklistItems';


  @override
  String toString() {
    return 'Task{id: $id, title: $title, status: $status, priority: $priority, checklistItems: ${checklistItems.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        dueDate.hashCode ^
        priority.hashCode ^
        updatedAt.hashCode;
  }
}
