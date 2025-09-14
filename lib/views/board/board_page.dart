import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/components/responsive_app_bar.dart';
import 'package:kanbankit/views/widgets/language_switcher.dart';
import '../../controllers/board_controller.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
import '../widgets/task_editor.dart';
import '../components/responsive_board_layout.dart';

class BoardPage extends GetView<BoardController> {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: LocalKeys.appName.tr,
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSwitcher(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshTasks(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Listener(
          onPointerMove: controller.handlePointerMove,
          child: ResponsiveBoardLayout(
            todoTasks: controller.todoTasks,
            inProgressTasks: controller.inProgressTasks,
            doneTasks: controller.doneTasks,
            onTaskMoved: controller.moveTask,
            onTaskDeleted: controller.deleteTask,
            onTaskUpdated: controller.updateTask,
            scrollController: controller.scrollController,
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskEditor(context),
        tooltip: LocalKeys.addTask.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaskEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskEditor(
        onTaskSaved: (task) => controller.addTask(task),
      ),
    );
  }

  void _showLanguageSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSwitcher(),
    );
  }
}
