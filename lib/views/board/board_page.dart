import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/components/responsive_app_bar.dart';
import 'package:kanbankit/views/widgets/language_switcher.dart';
import 'package:kanbankit/views/components/theme_switcher.dart';
import '../../controllers/board_controller.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
import '../../core/themes/app_colors.dart' show AppColors;
import '../components/icon_buttons/app_icon_button.dart';
import '../components/icon_buttons/icon_button_style.dart';
import '../components/icon_buttons/icon_button_variant.dart';
import '../widgets/enhanced_task_editor.dart' show EnhancedTaskEditor;
import '../widgets/task_editor.dart';
import '../components/responsive_board_layout.dart';

class BoardPage extends GetView<BoardController> {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: LocalKeys.appName.tr,
        showLogo: true,
        logoSize: 32,

        // backgroundColor:AppColors.surface,
        actions: [
          AppIconButton(
            style: AppIconButtonStyle.plain,
            variant: AppIconButtonVariant.values[0],
            child: const Icon(Icons.language),
            onPressed: () => _showLanguageSwitcher(context),
          ),
          const ThemeSwitcher(isCompact: true),
          AppIconButton(
            style: AppIconButtonStyle.plain,
            variant: AppIconButtonVariant.values[1],
            child: const Icon(Icons.refresh),
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
      builder: (context) =>
          EnhancedTaskEditor(onTaskSaved: (task) => controller.addTask(task)),
    );
  }

  void _showLanguageSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSwitcher(),
    );
  }
}
