// Helper class for checklist progress
class ChecklistProgress {
  final int total;
  final int completed;
  final double percentage;

  ChecklistProgress({
    required this.total,
    required this.completed,
    required this.percentage,
  });

  bool get isCompleted => total > 0 && completed == total;
  bool get hasItems => total > 0;
  int get remaining => total - completed;

  @override
  String toString() {
    return 'ChecklistProgress{total: $total, completed: $completed, percentage: ${(percentage * 100).toStringAsFixed(1)}%}';
  }
}