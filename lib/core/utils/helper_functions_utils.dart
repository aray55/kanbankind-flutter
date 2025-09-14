import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

import '../enums/task_status.dart' show TaskStatus;

class HelperFunctionsUtils {
  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.red;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  static String getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return LocalKeys.todo.tr;
      case TaskStatus.inProgress:
        return LocalKeys.inProgress.tr;
      case TaskStatus.done:
        return LocalKeys.done.tr;
    }
  }

  static Color getDueDateColor(DateTime dueDate) {
    if (dueDate.isBefore(DateTime.now())) {
      return Colors.red;
    } else if (dueDate.isAtSameMomentAs(DateTime.now())) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
