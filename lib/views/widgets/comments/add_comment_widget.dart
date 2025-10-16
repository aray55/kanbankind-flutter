import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/comment_controller.dart';
import '../../../core/localization/local_keys.dart';

/// Add Comment Widget
/// Input field for adding new comments
class AddCommentWidget extends StatefulWidget {
  final int cardId;

  const AddCommentWidget({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  State<AddCommentWidget> createState() => _AddCommentWidgetState();
}

class _AddCommentWidgetState extends State<AddCommentWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isExpanded
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: _isExpanded ? 3 : 1,
            decoration: InputDecoration(
              hintText: LocalKeys.writeComment.tr,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              prefixIcon: Icon(
                Icons.comment_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            onChanged: (value) {
              setState(() {});
            },
          ),

          // Actions (shown when expanded)
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      _focusNode.unfocus();
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Text(LocalKeys.cancel.tr),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => FilledButton.icon(
                        onPressed: _controller.text.trim().isEmpty ||
                                commentController.isCreating
                            ? null
                            : () => _addComment(commentController),
                        icon: commentController.isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send, size: 18),
                        label: Text(LocalKeys.post.tr),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addComment(CommentController commentController) async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final success = await commentController.createComment(
      cardId: widget.cardId,
      content: content,
    );

    if (success) {
      _controller.clear();
      _focusNode.unfocus();
      setState(() {
        _isExpanded = false;
      });
    }
  }
}
