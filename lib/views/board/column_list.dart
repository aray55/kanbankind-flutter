import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/widgets/enhanced_task_card.dart';
import '../../controllers/board_controller.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
import '../../core/utils/helper_functions_utils.dart' show HelperFunctionsUtils;
import '../../models/task_model.dart';
import '../../core/enums/task_status.dart';
import '../components/empty_state.dart' show EmptyState;
import '../widgets/task_card.dart';
import '../widgets/responsive_text.dart';

class ColumnList extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final TaskStatus status;
  final Function(Task, TaskStatus) onTaskMoved;
  final Function(int) onTaskDeleted;
  final Function(Task) onTaskUpdated;

  const ColumnList({
    super.key,
    required this.title,
    required this.tasks,
    required this.status,
    required this.onTaskMoved,
    required this.onTaskDeleted,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: HelperFunctionsUtils.getStatusColor(status),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: KanbanColumnTitle(
                    title: title.tr,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                final task = details.data;
                if (task.status != status) {
                  onTaskMoved(task, status);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: tasks.isEmpty
                      ? EmptyState(
                          title: LocalKeys.noTasks.tr,
                          icon: Icons.task_outlined,
                          actionText: LocalKeys.addTask.tr,
                          onActionPressed: null,
                          subtitle: LocalKeys.noTaskAvailable.tr,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final boardController = Get.find<BoardController>();
                            return Draggable<Task>(
                              data: tasks[index],
                              onDragStarted: boardController.handleDragStart,
                              onDragEnd: (details) =>
                                  boardController.handleDragEnd(),
                              feedback: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(8.0),
                                child: SizedBox(
                                  width: 250,
                                  child: EnhancedTaskCard(
                                    task: tasks[index],
                                    onDeleted: onTaskDeleted,
                                    onUpdated: onTaskUpdated,
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: EnhancedTaskCard(
                                  task: tasks[index],
                                  onDeleted: onTaskDeleted,
                                  onUpdated: onTaskUpdated,
                                ),
                              ),
                              child: EnhancedTaskCard(
                                task: tasks[index],
                                onDeleted: onTaskDeleted,
                                onUpdated: onTaskUpdated,
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
