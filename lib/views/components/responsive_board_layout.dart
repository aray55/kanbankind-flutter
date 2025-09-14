import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
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
          return _buildScrollableLayout(context);
        }
        // Use a desktop layout for wider screens
        else {
          return _buildDesktopLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildScrollableLayout(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Row(
          children: [
            SizedBox(
              width: 250,
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
              width: 250,
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
              width: 250,
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
