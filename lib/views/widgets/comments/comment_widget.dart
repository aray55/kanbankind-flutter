import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/comment_model.dart';
import '../../../core/localization/local_keys.dart';

/// Single Comment Widget
/// Displays a single comment with edit/delete options
class CommentWidget extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const CommentWidget({
    Key? key,
    required this.comment,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      key: ValueKey('comment_${comment.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with timestamp and actions
          Row(
            children: [
              // Avatar placeholder
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              
              // Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    if (comment.isEdited)
                      Text(
                        LocalKeys.editedComment.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Actions
              if (showActions && !comment.isDeleted) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                  tooltip: LocalKeys.editComment.tr,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: onDelete,
                  tooltip: LocalKeys.deleteComment.tr,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Comment content
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    return timeago.format(dateTime, locale: Get.locale?.languageCode ?? 'en');
  }
}
