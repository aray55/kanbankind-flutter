import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/utils/date_utils.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

enum DueDateStatus { completed, overdue, dueSoon, dueToday, upcoming }

class CardDueDateWidget extends StatelessWidget {
  final DateTime? dueDate;
  final bool isCompleted;
  final bool showStatus;
  final bool compact;

  const CardDueDateWidget({
    Key? key,
    this.dueDate,
    this.isCompleted = false,
    this.showStatus = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dueDate == null) return const SizedBox.shrink();

    final status = _getDueDateStatus();
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: compact 
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: statusInfo.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon, 
            size: compact ? 10 : 12, 
            color: statusInfo.iconColor,
          ),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: AppText(
              compact 
                ? AppDateUtils.formatDate(dueDate!) // Shorter format for compact mode
                : AppDateUtils.formatDateTime(dueDate!),
              variant: AppTextVariant.small,
              color: statusInfo.textColor,
              fontWeight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showStatus && statusInfo.statusText != null && !compact) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: statusInfo.statusBadgeColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: AppText(
                  statusInfo.statusText!,
                  variant: AppTextVariant.small,
                  color: statusInfo.statusTextColor,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DueDateStatus _getDueDateStatus() {
    if (isCompleted) return DueDateStatus.completed;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final difference = dueDateOnly.difference(today).inDays;

    if (difference < 0) {
      return DueDateStatus.overdue;
    } else if (difference == 0) {
      return DueDateStatus.dueToday;
    } else if (difference <= 1) {
      return DueDateStatus.dueSoon;
    } else {
      return DueDateStatus.upcoming;
    }
  }

  _StatusInfo _getStatusInfo(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.completed:
        return _StatusInfo(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          borderColor: Colors.green.withValues(alpha: 0.3),
          icon: Icons.check_circle,
          iconColor: Colors.green.withValues(alpha: 0.7),
          textColor: Colors.green.withValues(alpha: 0.8),
          statusText: LocalKeys.dueDateComplete.tr,
          statusBadgeColor: Colors.green,
          statusTextColor: Colors.white,
        );
      case DueDateStatus.overdue:
        return _StatusInfo(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          borderColor: Colors.red.withValues(alpha: 0.4),
          icon: Icons.warning,
          iconColor: Colors.red.withValues(alpha: 0.7),
          textColor: Colors.red.withValues(alpha: 0.8),
          statusText: LocalKeys.dueDateOverdue.tr,
          statusBadgeColor: Colors.red,
          statusTextColor: Colors.white,
        );
      case DueDateStatus.dueToday:
        return _StatusInfo(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          borderColor: Colors.orange.withValues(alpha: 0.4),
          icon: Icons.today,
          iconColor: Colors.orange.withValues(alpha: 0.7),
          textColor: Colors.orange.withValues(alpha: 0.8),
          statusText: LocalKeys.dueDateDueToday.tr,
          statusBadgeColor: Colors.orange,
          statusTextColor: Colors.white,
        );
      case DueDateStatus.dueSoon:
        return _StatusInfo(
          backgroundColor: Colors.amber.withValues(alpha: 0.1),
          borderColor: Colors.amber.withValues(alpha: 0.4),
          icon: Icons.schedule,
          iconColor: Colors.amber.withValues(alpha: 0.7),
          textColor: Colors.amber.withValues(alpha: 0.8),
          statusText: LocalKeys.dueDateDueSoon.tr,
          statusBadgeColor: Colors.amber[600]!,
          statusTextColor: Colors.white,
        );
      case DueDateStatus.upcoming:
        return _StatusInfo(
          backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
          borderColor: Colors.blueGrey.withValues(alpha: 0.3),
          icon: Icons.event,
          iconColor: Colors.blueGrey.withValues(alpha: 0.7),
          textColor: Colors.blueGrey.withValues(alpha: 0.8),
          statusText: null,
          statusBadgeColor: Colors.transparent,
          statusTextColor: Colors.transparent,
        );
    }
  }
}

class _StatusInfo {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String? statusText;
  final Color statusBadgeColor;
  final Color statusTextColor;

  _StatusInfo({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    this.statusText,
    required this.statusBadgeColor,
    required this.statusTextColor,
  });
}
