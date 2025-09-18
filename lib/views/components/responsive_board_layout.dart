import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
import '../../core/utils/logger/app_logger.dart';
import '../../models/task_model.dart';
import '../../core/enums/task_status.dart';
import '../board/column_list.dart';

class ResponsiveBoardLayout extends StatelessWidget {
  final List<Task> todoTasks;
  final List<Task> inProgressTasks;
  final List<Task> doneTasks;
  final Function(Task, TaskStatus) onTaskMoved;
  final Function(int) onTaskDeleted;
  final Function(Task) onTaskUpdated;
  final ScrollController scrollController;

  const ResponsiveBoardLayout({
    super.key,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.doneTasks,
    required this.onTaskMoved,
    required this.onTaskDeleted,
    required this.onTaskUpdated,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Determine layout based on screen size
        // Use a scrollable layout for tablets and phones
        if (screenWidth < 900) {
          AppLogger.debug('Screen width: $screenWidth');
          return _buildScrollableLayout(context);
        }
        // Use a desktop layout for wider screens
        else {
          AppLogger.debug('Screen width: $screenWidth');
          return _buildDesktopLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildScrollableLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate column width based on screen size
    // For very small screens (< 400px), use smaller columns
    // For medium screens (400-600px), use medium columns
    // For larger screens (600-900px), use larger columns
    double columnWidth;
    if (screenWidth < 400) {
      columnWidth = 280; // Minimum width to prevent overflow
    } else if (screenWidth < 600) {
      columnWidth = 300;
    } else {
      columnWidth = 320;
    }
    
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Row(
          children: [
            SizedBox(
              width: columnWidth,
              child: ColumnList(
                title: TaskStatus.todo.displayName,
                tasks: todoTasks,
                status: TaskStatus.todo,
                onTaskMoved: onTaskMoved,
                onTaskDeleted: onTaskDeleted,
                onTaskUpdated: onTaskUpdated,
              ),
            ),
            const VerticalDivider(width: 1),
            SizedBox(
              width: columnWidth,
              child: ColumnList(
                title: TaskStatus.inProgress.displayName,
                tasks: inProgressTasks,
                status: TaskStatus.inProgress,
                onTaskMoved: onTaskMoved,
                onTaskDeleted: onTaskDeleted,
                onTaskUpdated: onTaskUpdated,
              ),
            ),
            const VerticalDivider(width: 1),
            SizedBox(
              width: columnWidth,
              child: ColumnList(
                title: TaskStatus.done.displayName,
                tasks: doneTasks,
                status: TaskStatus.done,
                onTaskMoved: onTaskMoved,
                onTaskDeleted: onTaskDeleted,
                onTaskUpdated: onTaskUpdated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth,
      child: Row(
        children: [
          Expanded(
            child: ColumnList(
              title: LocalKeys.todo.tr,
              tasks: todoTasks,
              status: TaskStatus.todo,
              onTaskMoved: onTaskMoved,
              onTaskDeleted: onTaskDeleted,
              onTaskUpdated: onTaskUpdated,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ColumnList(
              title: LocalKeys.inProgress.tr,
              tasks: inProgressTasks,
              status: TaskStatus.inProgress,
              onTaskMoved: onTaskMoved,
              onTaskDeleted: onTaskDeleted,
              onTaskUpdated: onTaskUpdated,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ColumnList(
              title: LocalKeys.done.tr,
              tasks: doneTasks,
              status: TaskStatus.done,
              onTaskMoved: onTaskMoved,
              onTaskDeleted: onTaskDeleted,
              onTaskUpdated: onTaskUpdated,
            ),
          ),
        ],
      ),
    );
  }
}
