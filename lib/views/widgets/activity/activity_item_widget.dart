import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/activity_log_model.dart';
import '../../../core/localization/local_keys.dart';

/// Single Activity Item Widget
/// Displays a single activity log entry with icon and details
class ActivityItemWidget extends StatelessWidget {
  final ActivityLogModel activity;

  const ActivityItemWidget({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: ValueKey('activity_${activity.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getActionColor(theme).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActionIcon(),
              size: 18,
              color: _getActionColor(theme),
            ),
          ),
          const SizedBox(width: 12),

          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action description
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: _getActionText(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: ' ${_getEntityTypeText()}',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Old/New values if available
                if (activity.oldValue != null || activity.newValue != null) ...[
                  const SizedBox(height: 4),
                  _buildValueChanges(theme),
                ],

                // Description if available
                if (activity.description != null && activity.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],

                // Timestamp
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(activity.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueChanges(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.oldValue != null)
            Row(
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 14,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    activity.oldValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (activity.oldValue != null && activity.newValue != null)
            const SizedBox(height: 4),
          if (activity.newValue != null)
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 14,
                  color: Colors.green.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    activity.newValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getActionIcon() {
    switch (activity.actionType) {
      case ActionType.created:
        return Icons.add_circle_outline;
      case ActionType.updated:
        return Icons.edit_outlined;
      case ActionType.deleted:
        return Icons.delete_outline;
      case ActionType.moved:
        return Icons.swap_horiz;
      case ActionType.archived:
        return Icons.archive_outlined;
      case ActionType.restored:
        return Icons.restore;
      case ActionType.completed:
        return Icons.check_circle_outline;
      case ActionType.uncompleted:
        return Icons.radio_button_unchecked;
    }
  }

  Color _getActionColor(ThemeData theme) {
    switch (activity.actionType) {
      case ActionType.created:
        return Colors.green;
      case ActionType.updated:
        return Colors.blue;
      case ActionType.deleted:
        return Colors.red;
      case ActionType.moved:
        return Colors.purple;
      case ActionType.archived:
        return Colors.orange;
      case ActionType.restored:
        return Colors.teal;
      case ActionType.completed:
        return Colors.green;
      case ActionType.uncompleted:
        return Colors.grey;
    }
  }

  String _getActionText() {
    switch (activity.actionType) {
      case ActionType.created:
        return LocalKeys.actionCreated.tr;
      case ActionType.updated:
        return LocalKeys.actionUpdated.tr;
      case ActionType.deleted:
        return LocalKeys.actionDeleted.tr;
      case ActionType.moved:
        return LocalKeys.actionMoved.tr;
      case ActionType.archived:
        return LocalKeys.actionArchived.tr;
      case ActionType.restored:
        return LocalKeys.actionRestored.tr;
      case ActionType.completed:
        return LocalKeys.actionCompleted.tr;
      case ActionType.uncompleted:
        return LocalKeys.actionUncompleted.tr;
    }
  }

  String _getEntityTypeText() {
    switch (activity.entityType) {
      case EntityType.board:
        return LocalKeys.entityBoard.tr;
      case EntityType.list:
        return LocalKeys.entityList.tr;
      case EntityType.card:
        return LocalKeys.entityCard.tr;
      case EntityType.checklist:
        return LocalKeys.entityChecklist.tr;
      case EntityType.comment:
        return LocalKeys.entityComment.tr;
      case EntityType.attachment:
        return LocalKeys.entityAttachment.tr;
      case EntityType.label:
        return LocalKeys.entityLabel.tr;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return timeago.format(dateTime, locale: Get.locale?.languageCode ?? 'en');
  }
}
