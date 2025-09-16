import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../core/enums/task_status.dart';
import '../data/repository/task_repository.dart';

class BoardController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();

  final RxList<Task> todoTasks = <Task>[].obs;
  final RxList<Task> inProgressTasks = <Task>[].obs;
  final RxList<Task> doneTasks = <Task>[].obs;

  final RxBool isLoading = false.obs;
  final ScrollController scrollController = ScrollController();
  Timer? _scrollTimer;
  bool isDragging = false;

  @override
  void onInit() {
    super.onInit();
    loadAllTasks();
  }

  Future<void> loadAllTasks() async {
    try {
      isLoading.value = true;

      final todoList = await _taskRepository.getTodoTasks();
      final inProgressList = await _taskRepository.getInProgressTasks();
      final doneList = await _taskRepository.getDoneTasks();

      todoTasks.assignAll(todoList);
      inProgressTasks.assignAll(inProgressList);
      doneTasks.assignAll(doneList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tasks: $e');
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
      Get.snackbar('Success', 'Task added successfully');
      
      return createdTask;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final success = await _taskRepository.updateTask(task);
      if (success) {
        await loadAllTasks(); // Refresh all lists
        Get.snackbar('Success', 'Task updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final success = await _taskRepository.deleteTask(taskId);
      if (success) {
        todoTasks.removeWhere((task) => task.id == taskId);
        inProgressTasks.removeWhere((task) => task.id == taskId);
        doneTasks.removeWhere((task) => task.id == taskId);
        Get.snackbar('Success', 'Task deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task: $e');
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
        Get.snackbar('Success', 'Task moved to ${newStatus.displayName}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to move task: $e');
    }
  }

  void refreshTasks() {
    loadAllTasks();
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
