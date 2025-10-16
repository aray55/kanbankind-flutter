import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/comment_controller.dart';
import '../../../models/comment_model.dart';
import '../../../core/localization/local_keys.dart';
import '../../components/empty_state.dart';
import 'comment_widget.dart';
import 'add_comment_widget.dart';

/// Comments List Widget
/// Displays all comments for a card with add comment functionality
class CommentsListWidget extends StatelessWidget {
  final int cardId;
  final bool showAddComment;
  final bool showHeader;

  const CommentsListWidget({
    Key? key,
    required this.cardId,
    this.showAddComment = true,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final theme = Theme.of(context);

    // Load comments for this card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentController.loadCommentsForCard(cardId, showLoading: false);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalKeys.comments.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final count = commentController.getCommentCountForCard(cardId);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
        ],

        // Add Comment Section
        if (showAddComment)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AddCommentWidget(cardId: cardId),
          ),

        // Comments List
        Obx(() {
          final comments = commentController.getCommentsForCard(cardId);

          if (commentController.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (comments.isEmpty) {
            return EmptyState(
              icon: Icons.comment_outlined,
              title: LocalKeys.noComments.tr,
              subtitle: LocalKeys.writeComment.tr,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return CommentWidget(
                key: ValueKey('comment_widget_${comment.id}'),
                comment: comment,
                onEdit: () => _showEditCommentDialog(context, comment),
                onDelete: () => _confirmDeleteComment(context, comment),
              );
            },
          );
        }),
      ],
    );
  }

  void _showEditCommentDialog(BuildContext context, CommentModel comment) {
    final controller = TextEditingController(text: comment.content);
    final commentController = Get.find<CommentController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.editComment.tr),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: LocalKeys.commentPlaceholder.tr,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalKeys.cancel.tr),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                commentController.updateCommentContent(
                  comment.id!,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: Text(LocalKeys.update.tr),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, CommentModel comment) {
    final commentController = Get.find<CommentController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.deleteComment.tr),
        content: Text(LocalKeys.confirmDeleteComment.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalKeys.cancel.tr),
          ),
          FilledButton(
            onPressed: () {
              commentController.deleteComment(comment.id!);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(LocalKeys.delete.tr),
          ),
        ],
      ),
    );
  }
}
