import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../controllers/attachment_controller.dart';
import '../../../models/attachment_model.dart';
import '../../../core/localization/local_keys.dart';
import '../../components/empty_state.dart';
import 'attachment_widget.dart';
import 'file_viewer_screen.dart';
import 'image_gallery_screen.dart';

/// Attachments List Widget
/// Displays all attachments for a card with add attachment functionality
class AttachmentsListWidget extends StatelessWidget {
  final int cardId;
  final bool showAddButton;
  final bool showHeader;

  const AttachmentsListWidget({
    Key? key,
    required this.cardId,
    this.showAddButton = true,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attachmentController = Get.find<AttachmentController>();
    final theme = Theme.of(context);

    // Load attachments for this card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attachmentController.loadAttachmentsForCard(cardId, showLoading: false);
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
                  Icons.attach_file,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalKeys.attachments.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final count = attachmentController.getAttachmentCountForCard(cardId);
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
                const Spacer(),
                // Total size
                Obx(() {
                  final size = attachmentController.getFormattedTotalSizeForCard(cardId);
                  if (size != '0.00 B') {
                    return Text(
                      size,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const Divider(height: 1),
        ],

        // Add Attachment Button
        if (showAddButton)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.attach_file),
                    label: Text(LocalKeys.addAttachment.tr),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: const Icon(Icons.image),
                  label: Text(LocalKeys.selectImage.tr),
                ),
              ],
            ),
          ),

        // Attachments List
        Obx(() {
          final attachments = attachmentController.getAttachmentsForCard(cardId);

          if (attachmentController.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (attachments.isEmpty) {
            return EmptyState(
              icon: Icons.attach_file,
              title: LocalKeys.noAttachments.tr,
              subtitle: LocalKeys.selectFile.tr,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              return AttachmentWidget(
                key: ValueKey('attachment_widget_${attachment.id}'),
                attachment: attachment,
                onView: () => _viewAttachment(context, attachment),
                onDelete: () => _confirmDeleteAttachment(context, attachment),
              );
            },
          );
        }),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final attachmentController = Get.find<AttachmentController>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await attachmentController.createAttachment(
          cardId: cardId,
          fileName: file.name,
          filePath: file.path!,
          fileSize: file.size,
          fileType: _determineFileType(file.extension),
          mimeType: file.extension,
        );
      }
    } catch (e) {
      Get.snackbar(
        LocalKeys.errorAddingAttachment.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final attachmentController = Get.find<AttachmentController>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await attachmentController.createAttachment(
          cardId: cardId,
          fileName: file.name,
          filePath: file.path!,
          fileSize: file.size,
          fileType: 'image',
          mimeType: file.extension,
        );
      }
    } catch (e) {
      Get.snackbar(
        LocalKeys.errorAddingAttachment.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _determineFileType(String? extension) {
    if (extension == null) return 'other';
    
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    final documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];
    final videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'];
    final audioExtensions = ['mp3', 'wav', 'ogg', 'flac', 'm4a'];

    if (imageExtensions.contains(extension.toLowerCase())) return 'image';
    if (documentExtensions.contains(extension.toLowerCase())) return 'document';
    if (videoExtensions.contains(extension.toLowerCase())) return 'video';
    if (audioExtensions.contains(extension.toLowerCase())) return 'audio';
    
    return 'other';
  }

  void _viewAttachment(BuildContext context, AttachmentModel attachment) {
    final attachmentController = Get.find<AttachmentController>();
    
    if (attachment.isImage) {
      // Get all images for this card
      final allAttachments = attachmentController.getAttachmentsForCard(cardId);
      final images = allAttachments.where((a) => a.isImage).toList();
      final initialIndex = images.indexWhere((a) => a.id == attachment.id);
      
      // Open image gallery
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageGalleryScreen(
            images: images,
            initialIndex: initialIndex >= 0 ? initialIndex : 0,
          ),
        ),
      );
    } else {
      // Open file viewer for non-image files
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewerScreen(
            attachment: attachment,
          ),
        ),
      );
    }
  }

  void _confirmDeleteAttachment(BuildContext context, AttachmentModel attachment) {
    final attachmentController = Get.find<AttachmentController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.deleteAttachment.tr),
        content: Text(LocalKeys.confirmDeleteAttachment.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalKeys.cancel.tr),
          ),
          FilledButton(
            onPressed: () {
              attachmentController.deleteAttachment(attachment.id!);
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
