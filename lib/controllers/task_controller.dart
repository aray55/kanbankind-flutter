import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/services/dialog_service.dart';
import '../core/localization/local_keys.dart';
import '../models/task_model.dart';
import '../core/enums/task_status.dart';
import '../data/repository/task_repository.dart';
import '../core/services/task_movement_service.dart';

class TaskController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();
  final TaskMovementService _taskMovementService = TaskMovementService();

  final RxList<Task> todoTasks = <Task>[].obs;
  final RxList<Task> inProgressTasks = <Task>[].obs;
  final RxList<Task> doneTasks = <Task>[].obs;

  final RxBool isLoading = false.obs;
  final ScrollController scrollController = ScrollController();
  Timer? _scrollTimer;
  bool isDragging = false;
  late DialogService dialogService;

  @override
  void onInit() {
    super.onInit();
    dialogService = Get.find<DialogService>();
    loadAllTasks();
    
  }

  Future<void> loadAllTasks() async {
    try {
      isLoading.value = true;

      // First, evaluate and move tasks automatically
      await _evaluateAndMoveTasksAutomatically();

      final todoList = await _taskRepository.getTodoTasks();
      final inProgressList = await _taskRepository.getInProgressTasks();
      final doneList = await _taskRepository.getDoneTasks();

      todoTasks.assignAll(todoList);
      inProgressTasks.assignAll(inProgressList);
      doneTasks.assignAll(doneList);
    } catch (e) {
      dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: LocalKeys.failedToLoadTasks.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Task> addTask(Task task) async {
    try {
      final taskId = await _taskRepository.createTask(task);
      // Create a new task object with the returned ID
      final createdTask = task.copyWith(id: taskId);

      // Reload all tasks to ensure the UI is in sync
      await loadAllTasks();
      dialogService.showSuccessSnackbar(
        title: LocalKeys.success.tr,
        message: LocalKeys.taskAddedSuccessfully.tr,
      );

      return createdTask;
    } catch (e) {
      dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: LocalKeys.failedToAddTask.tr,
      );
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final success = await _taskRepository.updateTask(task);
      if (success) {
        // Check if the task needs automatic movement after update
        final movedTask = await _taskMovementService.evaluateAndMoveTask(task);
        if (movedTask != null) {
          dialogService.showSuccessSnackbar(
            title: LocalKeys.automaticMove.tr,
            message: LocalKeys.taskMovedToStatus.tr,
          );
        }

        await loadAllTasks(); // Refresh all lists
        dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.taskUpdatedSuccessfully.tr,
        );
      }
    } catch (e) {
      dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: LocalKeys.failedToUpdateTask.tr,
      );
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final success = await _taskRepository.deleteTask(taskId);
      if (success) {
        todoTasks.removeWhere((task) => task.id == taskId);
        inProgressTasks.removeWhere((task) => task.id == taskId);
        doneTasks.removeWhere((task) => task.id == taskId);
        dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.taskDeletedSuccessfully.tr,
        );
      }
    } catch (e) {
      dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: LocalKeys.failedToDeleteTask.tr,
      );
    }
  }

  Future<void> moveTask(Task task, TaskStatus newStatus) async {
    try {
      final success = await _taskRepository.moveTaskToStatus(
        task.id!,
        newStatus,
      );
      if (success) {
        // Instead of manually manipulating the lists, just reload them from the source of truth.
        await loadAllTasks();
        dialogService.showSuccessSnackbar(
          title: LocalKeys.success.tr,
          message: LocalKeys.taskMovedToStatus.trParams(
            {
              'status': newStatus.name,
            },
          ),
        );
      }
    } catch (e) {
      dialogService.showErrorSnackbar(
        title: LocalKeys.error.tr,
        message: LocalKeys.failedToMoveTask.tr,
      );
    }
  }

  void refreshTasks() {
    loadAllTasks();
  }

  /// Automatically evaluates and moves tasks based on due dates and checklist completion
  Future<void> _evaluateAndMoveTasksAutomatically() async {
    try {
      final movedTasks = await _taskMovementService
          .evaluateAndMoveTasksAutomatically();
      if (movedTasks.isNotEmpty) {
        dialogService.showSuccessSnackbar(
          title: LocalKeys.automaticMove.tr,
          message: LocalKeys.taskMovedToStatusAutomatically.trParams(
            {
              'status': movedTasks.first.status.name,
            },
          ),
        );
      }
    } catch (e) {
      // Silent fail for automatic movement
    }
  }

  /// Evaluates a specific task for automatic movement
  Future<Task?> evaluateTaskForMovement(Task task) async {
    return await _taskMovementService.evaluateAndMoveTask(task);
  }

  // Auto-scroll logic based on pointer position
  void handlePointerMove(PointerMoveEvent event) {
    if (!isDragging) return;

    const double hotZoneWidth = 50.0;
    const double scrollSpeed = 10.0;
    final screenWidth = Get.width;
    final position = event.position.dx;

    // Right hot zone
    if (position > screenWidth - hotZoneWidth) {
      if (scrollController.position.pixels <
          scrollController.position.maxScrollExtent) {
        _startAutoScroll(scrollSpeed);
      }
    }
    // Left hot zone
    else if (position < hotZoneWidth) {
      if (scrollController.position.pixels >
          scrollController.position.minScrollExtent) {
        _startAutoScroll(-scrollSpeed);
      }
    }
    // Outside hot zones
    else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double velocity) {
    if (_scrollTimer == null ||
        (_scrollTimer != null && !_scrollTimer!.isActive)) {
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        final newOffset = scrollController.offset + velocity;
        if (newOffset >= scrollController.position.minScrollExtent &&
            newOffset <= scrollController.position.maxScrollExtent) {
          scrollController.jumpTo(newOffset);
        } else {
          _stopAutoScroll();
        }
      });
    }
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void handleDragStart() {
    isDragging = true;
  }

  void handleDragEnd() {
    isDragging = false;
    _stopAutoScroll();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _stopAutoScroll();
    super.onClose();
  }
}
