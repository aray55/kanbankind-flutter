import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/attachment_model.dart';
import '../../../core/localization/local_keys.dart';

/// File Viewer Screen
/// Full screen viewer for attachments with download and share options
class FileViewerScreen extends StatelessWidget {
  final AttachmentModel attachment;

  const FileViewerScreen({
    Key? key,
    required this.attachment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          attachment.fileName,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadFile(context),
            tooltip: LocalKeys.downloadFile.tr,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareFile(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: _buildFileContent(context, theme),
      ),
      bottomNavigationBar: _buildBottomInfo(theme),
    );
  }

  Widget _buildFileContent(BuildContext context, ThemeData theme) {
    if (attachment.isImage && attachment.fileExists) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          File(attachment.filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(theme);
          },
        ),
      );
    }

    // For non-image files, show icon and details
    return _buildFileIcon(theme);
  }

  Widget _buildFileIcon(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getFileTypeIcon(),
          size: 120,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 24),
        Text(
          attachment.fileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          attachment.formattedFileSize,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _openFile(),
          icon: const Icon(Icons.open_in_new),
          label: Text(LocalKeys.viewFile.tr),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unable to load file',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '${LocalKeys.fileType.tr}: ${_getFileTypeLabel()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  attachment.formattedFileSize,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
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

  String _getFileTypeLabel() {
    if (attachment.isImage) return LocalKeys.images.tr;
    if (attachment.isDocument) return LocalKeys.documents.tr;
    if (attachment.isVideo) return LocalKeys.videos.tr;
    if (attachment.isAudio) return LocalKeys.audio.tr;
    return LocalKeys.other.tr;
  }

  void _downloadFile(BuildContext context) {
    // TODO: Implement download functionality
    Get.snackbar(
      LocalKeys.downloadFile.tr,
      attachment.fileName,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareFile(BuildContext context) {
    // TODO: Implement share functionality
    Get.snackbar(
      'Share',
      attachment.fileName,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openFile() {
    // TODO: Implement open with external app
    Get.snackbar(
      LocalKeys.viewFile.tr,
      attachment.fileName,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
