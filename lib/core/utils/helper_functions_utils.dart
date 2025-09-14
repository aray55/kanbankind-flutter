import 'package:flutter/material.dart';

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
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
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
