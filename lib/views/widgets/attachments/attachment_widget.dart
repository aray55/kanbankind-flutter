import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/attachment_model.dart';
import '../../../core/localization/local_keys.dart';

/// Single Attachment Widget
/// Displays a single attachment with preview and actions
class AttachmentWidget extends StatelessWidget {
  final AttachmentModel attachment;
  final VoidCallback? onView;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final bool showActions;

  const AttachmentWidget({
    Key? key,
    required this.attachment,
    this.onView,
    this.onDownload,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: ValueKey('attachment_${attachment.id}'),
      margin: const EdgeInsets.only(bottom: 12),
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
          // Preview or Icon
          if (attachment.isImage && attachment.fileExists)
            _buildImagePreview(context)
          else
            _buildFileIcon(context),

          // File info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File name
                Text(
                  attachment.fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // File size and type
                Row(
                  children: [
                    Icon(
                      _getFileTypeIcon(),
                      size: 14,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attachment.formattedFileSize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    if (attachment.fileType != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getFileTypeColor(theme).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getFileTypeLabel(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: _getFileTypeColor(theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Actions
                if (showActions) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onView != null)
                        TextButton.icon(
                          onPressed: onView,
                          icon: const Icon(Icons.visibility, size: 16),
                          label: Text(LocalKeys.viewFile.tr),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                      if (onDownload != null) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Icons.download, size: 16),
                          label: Text(LocalKeys.downloadFile.tr),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          tooltip: LocalKeys.deleteAttachment.tr,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: Image.file(
        File(attachment.filePath),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFileIcon(context);
        },
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _getFileTypeColor(theme).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Center(
        child: Icon(
          _getFileTypeIcon(),
          size: 48,
          color: _getFileTypeColor(theme),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    if (attachment.isImage) return Icons.image;
    if (attachment.isDocument) return Icons.description;
    if (attachment.isVideo) return Icons.videocam;
    if (attachment.isAudio) return Icons.audiotrack;
    return Icons.attach_file;
  }

  Color _getFileTypeColor(ThemeData theme) {
    if (attachment.isImage) return Colors.blue;
    if (attachment.isDocument) return Colors.orange;
    if (attachment.isVideo) return Colors.purple;
    if (attachment.isAudio) return Colors.green;
    return theme.colorScheme.primary;
  }

  String _getFileTypeLabel() {
    if (attachment.isImage) return LocalKeys.images.tr;
    if (attachment.isDocument) return LocalKeys.documents.tr;
    if (attachment.isVideo) return LocalKeys.videos.tr;
    if (attachment.isAudio) return LocalKeys.audio.tr;
    return LocalKeys.other.tr;
  }
}
