import 'dart:io';
import '../../models/attachment_model.dart';
import '../database/attachment_dao.dart';

/// Attachment Repository
/// Business logic layer for attachments
class AttachmentRepository {
  final AttachmentDao _attachmentDao = AttachmentDao();

  // Create a new attachment
  Future<AttachmentModel?> createAttachment(AttachmentModel attachment) async {
    try {
      // Validate attachment
      final validationError = attachment.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Check if file exists
      if (!File(attachment.filePath).existsSync()) {
        throw Exception('File does not exist at path: ${attachment.filePath}');
      }

      final id = await _attachmentDao.createAttachment(attachment);
      if (id > 0) {
        return attachment.copyWith(id: id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get attachment by ID
  Future<AttachmentModel?> getAttachmentById(int id) async {
    try {
      return await _attachmentDao.getAttachmentById(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all attachments for a card
  Future<List<AttachmentModel>> getAttachmentsByCardId(int cardId) async {
    try {
      return await _attachmentDao.getAttachmentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Get attachments by type
  Future<List<AttachmentModel>> getAttachmentsByType({
    required int cardId,
    required String fileType,
  }) async {
    try {
      return await _attachmentDao.getAttachmentsByType(
        cardId: cardId,
        fileType: fileType,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get image attachments
  Future<List<AttachmentModel>> getImageAttachments(int cardId) async {
    try {
      return await _attachmentDao.getImageAttachments(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Get document attachments
  Future<List<AttachmentModel>> getDocumentAttachments(int cardId) async {
    try {
      return await _attachmentDao.getDocumentAttachments(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Get all active attachments
  Future<List<AttachmentModel>> getAllActiveAttachments() async {
    try {
      return await _attachmentDao.getAllActiveAttachments();
    } catch (e) {
      rethrow;
    }
  }

  // Get deleted attachments for a card
  Future<List<AttachmentModel>> getDeletedAttachmentsByCardId(int cardId) async {
    try {
      return await _attachmentDao.getDeletedAttachmentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Update attachment
  Future<bool> updateAttachment(AttachmentModel attachment) async {
    try {
      // Validate attachment
      final validationError = attachment.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      if (attachment.id == null) {
        throw Exception('Attachment ID cannot be null for update');
      }

      final result = await _attachmentDao.updateAttachment(attachment);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Update attachment thumbnail
  Future<bool> updateAttachmentThumbnail(int id, String thumbnailPath) async {
    try {
      final attachment = await _attachmentDao.getAttachmentById(id);
      if (attachment == null) {
        throw Exception('Attachment not found');
      }

      final updatedAttachment = attachment.copyWith(thumbnailPath: thumbnailPath);
      return await updateAttachment(updatedAttachment);
    } catch (e) {
      rethrow;
    }
  }

  // Delete attachment (soft delete)
  Future<bool> deleteAttachment(int id) async {
    try {
      final result = await _attachmentDao.softDeleteAttachment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Restore deleted attachment
  Future<bool> restoreAttachment(int id) async {
    try {
      final result = await _attachmentDao.restoreAttachment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Permanently delete attachment (also deletes file)
  Future<bool> permanentlyDeleteAttachment(int id, {bool deleteFile = true}) async {
    try {
      final attachment = await _attachmentDao.getAttachmentById(id);
      if (attachment != null && deleteFile) {
        // Delete physical file
        final file = File(attachment.filePath);
        if (file.existsSync()) {
          await file.delete();
        }

        // Delete thumbnail if exists
        if (attachment.hasThumbnail) {
          final thumbnail = File(attachment.thumbnailPath!);
          if (thumbnail.existsSync()) {
            await thumbnail.delete();
          }
        }
      }

      final result = await _attachmentDao.permanentlyDeleteAttachment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Delete all attachments for a card
  Future<bool> deleteAllAttachmentsForCard(int cardId) async {
    try {
      final result = await _attachmentDao.softDeleteAllAttachmentsForCard(cardId);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Permanently delete all attachments for a card
  Future<bool> permanentlyDeleteAllAttachmentsForCard(
    int cardId, {
    bool deleteFiles = true,
  }) async {
    try {
      if (deleteFiles) {
        final attachments = await _attachmentDao.getAttachmentsByCardId(cardId);
        for (final attachment in attachments) {
          await permanentlyDeleteAttachment(attachment.id!, deleteFile: true);
        }
        return true;
      } else {
        final result = await _attachmentDao.permanentlyDeleteAllAttachmentsForCard(cardId);
        return result > 0;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Count attachments for a card
  Future<int> countAttachmentsByCardId(int cardId) async {
    try {
      return await _attachmentDao.countAttachmentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Count attachments by type
  Future<int> countAttachmentsByType({
    required int cardId,
    required String fileType,
  }) async {
    try {
      return await _attachmentDao.countAttachmentsByType(
        cardId: cardId,
        fileType: fileType,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get total size of attachments
  Future<int> getTotalSizeByCardId(int cardId) async {
    try {
      return await _attachmentDao.getTotalSizeByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Get formatted total size
  Future<String> getFormattedTotalSize(int cardId) async {
    try {
      final totalBytes = await getTotalSizeByCardId(cardId);
      
      const units = ['B', 'KB', 'MB', 'GB'];
      int unitIndex = 0;
      double size = totalBytes.toDouble();

      while (size >= 1024 && unitIndex < units.length - 1) {
        size /= 1024;
        unitIndex++;
      }

      return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
    } catch (e) {
      rethrow;
    }
  }

  // Check if card has attachments
  Future<bool> cardHasAttachments(int cardId) async {
    try {
      final count = await countAttachmentsByCardId(cardId);
      return count > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Search attachments
  Future<List<AttachmentModel>> searchAttachments(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await _attachmentDao.searchAttachments(query);
    } catch (e) {
      rethrow;
    }
  }

  // Get recent attachments
  Future<List<AttachmentModel>> getRecentAttachments({int limit = 10}) async {
    try {
      return await _attachmentDao.getRecentAttachments(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get attachments by date range
  Future<List<AttachmentModel>> getAttachmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _attachmentDao.getAttachmentsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get attachments with thumbnails
  Future<List<AttachmentModel>> getAttachmentsWithThumbnails(int cardId) async {
    try {
      return await _attachmentDao.getAttachmentsWithThumbnails(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Batch create attachments
  Future<bool> batchCreateAttachments(List<AttachmentModel> attachments) async {
    try {
      // Validate all attachments
      for (final attachment in attachments) {
        final validationError = attachment.validate();
        if (validationError != null) {
          throw Exception('Invalid attachment: $validationError');
        }
      }

      await _attachmentDao.batchInsertAttachments(attachments);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Batch delete attachments
  Future<bool> batchDeleteAttachments(List<int> attachmentIds) async {
    try {
      await _attachmentDao.batchDeleteAttachments(attachmentIds);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Get attachment statistics for a card
  Future<Map<String, dynamic>> getAttachmentStats(int cardId) async {
    try {
      final allAttachments = await _attachmentDao.getAttachmentsByCardId(cardId);
      final deletedAttachments = await _attachmentDao.getDeletedAttachmentsByCardId(cardId);
      final totalSize = await _attachmentDao.getTotalSizeByCardId(cardId);
      
      final imageCount = await _attachmentDao.countAttachmentsByType(
        cardId: cardId,
        fileType: 'image',
      );
      final documentCount = await _attachmentDao.countAttachmentsByType(
        cardId: cardId,
        fileType: 'document',
      );

      return {
        'total': allAttachments.length,
        'deleted': deletedAttachments.length,
        'active': allAttachments.length,
        'totalSize': totalSize,
        'images': imageCount,
        'documents': documentCount,
      };
    } catch (e) {
      rethrow;
    }
  }
}
