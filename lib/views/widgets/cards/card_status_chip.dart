import 'package:flutter/material.dart';

class CardStatusChip extends StatelessWidget {
  final String status;
  final Color? color;

  const CardStatusChip({Key? key, required this.status, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color ?? _getStatusColor(status),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _getTextColor(color ?? _getStatusColor(status)),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    // Use the status string to determine color
    switch (status.toLowerCase()) {
      case 'backlog':
      case 'متأخر':
        return Colors.purple.shade300;
      case 'todo':
      case 'لتنفيذ':
        return Colors.grey.shade300;
      case 'in progress':
      case 'قيد التنفيذ':
        return Colors.blue.shade300;
      case 'blocked':
      case 'محظور':
        return Colors.red.shade300;
      case 'in review':
      case 'قيد المراجعة':
        return Colors.orange.shade300;
      case 'done':
      case 'منجز':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // Simple luminance calculation to determine if text should be black or white
    final luminance =
        (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
