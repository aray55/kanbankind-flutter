import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../core/enums/task_status.dart';
import '../../controllers/checklist_controller.dart';
import '../../controllers/board_controller.dart';

class TaskEditorController extends GetxController
    with GetTickerProviderStateMixin {
  var selectedStatus = TaskStatus.todo.obs;
  var selectedPriority = 2.obs;
  var dueDate = Rxn<DateTime>();

  var tempChecklistItems = <String>[].obs;
  final checklistItemController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Task? editingTask;

  TabController? _tabController;
  TabController get tabController => _tabController!;
  var currentTabIndex = 0.obs;

  void setEditingTask(Task? task) {
    editingTask = task;
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description;
      selectedStatus.value = task.status;
      selectedPriority.value = task.priority;
      dueDate.value = task.dueDate;
    } else {
      // Reset form for new task
      resetForm();
    }
  }

  void initTabController() {
    // Dispose existing controller if it exists
    _tabController?.dispose();

    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      currentTabIndex.value = _tabController!.index;
    });

    // Reset to first tab
    currentTabIndex.value = 0;
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedStatus.value = TaskStatus.todo;
    selectedPriority.value = 2;
    dueDate.value = null;
    tempChecklistItems.clear();
    checklistItemController.clear();
    currentTabIndex.value = 0;
  }

  void addTempChecklistItem(String text) {
    if (text.trim().isEmpty) return;
    tempChecklistItems.add(text.trim());
    checklistItemController.clear();
  }

  void removeTempChecklistItem(int index) {
    tempChecklistItems.removeAt(index);
  }

  void clearDueDate() => dueDate.value = null;
  void setDueDate(DateTime? date) => dueDate.value = date;

  Future<Task> saveTask() async {
    try {
      print('DEBUG: Starting saveTask');
      print('DEBUG: Title: "${titleController.text}"');
      print('DEBUG: Description: "${descriptionController.text}"');
      print('DEBUG: Form key exists: ${formKey.currentState != null}');

      // Validate form before saving
      if (formKey.currentState?.validate() != true) {
        print('DEBUG: Form validation failed');
        print('DEBUG: Title isEmpty: ${titleController.text.trim().isEmpty}');
        throw Exception('Please fill in all required fields');
      }

      print('DEBUG: Form validation passed');

      final task = Task(
        id: editingTask?.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        status: selectedStatus.value,
        priority: selectedPriority.value,
        dueDate: dueDate.value,
        createdAt: editingTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('DEBUG: Task object created: ${task.title}');

      final boardController = Get.find<BoardController>();
      if (editingTask?.id == null) {
        print('DEBUG: Creating new task');
        // Creating a new task
        final createdTask = await boardController.addTask(task);
        print('DEBUG: Task created with ID: ${createdTask.id}');

        if (tempChecklistItems.isNotEmpty && createdTask.id != null) {
          print('DEBUG: Adding checklist items');
          final checklistController = Get.find<ChecklistController>();
          await checklistController.createMultipleItems(
            taskId: createdTask.id!,
            titles: tempChecklistItems,
          );

          // Clear temporary items after successful creation
          tempChecklistItems.clear();

          // Refresh the board to show updated task with checklist items
          await boardController.loadAllTasks();
        }
        return createdTask;
      } else {
        print('DEBUG: Updating existing task');
        // Updating an existing task
        await boardController.updateTask(task);

        // Also handle any new checklist items for existing tasks
        if (tempChecklistItems.isNotEmpty && editingTask?.id != null) {
          print('DEBUG: Adding checklist items to existing task');
          final checklistController = Get.find<ChecklistController>();
          await checklistController.createMultipleItems(
            taskId: editingTask!.id!,
            titles: tempChecklistItems,
          );

          // Clear temporary items after successful creation
          tempChecklistItems.clear();

          // Refresh the board to show updated task with checklist items
          await boardController.loadAllTasks();
        }

        return task;
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error in saveTask: $e');
      print('DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  void onClose() {
    _tabController?.dispose();
    checklistItemController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
