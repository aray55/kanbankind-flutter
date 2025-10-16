import 'package:get/get.dart';
import '../data/repository/attachment_repository.dart';
import '../models/attachment_model.dart';
import '../core/services/dialog_service.dart';
import '../controllers/activity_log_controller.dart';
import '../models/activity_log_model.dart';

/// Attachment Controller
/// Manages attachment state and operations using GetX
class AttachmentController extends GetxController {
  final AttachmentRepository _attachmentRepository = AttachmentRepository();
  final DialogService _dialogService = DialogService();
  
  // Activity log controller (lazy loaded)
  ActivityLogController? get _activityLogController {
    try {
      return Get.isRegistered<ActivityLogController>() 
          ? Get.find<ActivityLogController>() 
          : null;
    } catch (e) {
      return null;
    }
  }

  // Observable lists
  final RxList<AttachmentModel> _attachments = <AttachmentModel>[].obs;
  final RxMap<int, List<AttachmentModel>> _attachmentsByCard = <int, List<AttachmentModel>>{}.obs;
  final RxList<AttachmentModel> _deletedAttachments = <AttachmentModel>[].obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;

  // Statistics
  final RxMap<int, int> _attachmentCountByCard = <int, int>{}.obs;
  final RxMap<int, int> _totalSizeByCard = <int, int>{}.obs;

  // Getters
  List<AttachmentModel> get attachments => _attachments;
  Map<int, List<AttachmentModel>> get attachmentsByCard => _attachmentsByCard;
  List<AttachmentModel> get deletedAttachments => _deletedAttachments;
  
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  
  Map<int, int> get attachmentCountByCard => _attachmentCountByCard;
  Map<int, int> get totalSizeByCard => _totalSizeByCard;

  // Get attachments for a specific card
  List<AttachmentModel> getAttachmentsForCard(int cardId) {
    return _attachmentsByCard[cardId] ?? [];
  }

  // Get attachment count for a card
  int getAttachmentCountForCard(int cardId) {
    return _attachmentCountByCard[cardId] ?? 0;
  }

  // Get total size for a card
  int getTotalSizeForCard(int cardId) {
    return _totalSizeByCard[cardId] ?? 0;
  }

  // Get formatted total size for a card
  String getFormattedTotalSizeForCard(int cardId) {
    final totalBytes = getTotalSizeForCard(cardId);
    
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = totalBytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  // Create a new attachment
  Future<bool> createAttachment({
    required int cardId,
    required String fileName,
    required String filePath,
    int? fileSize,
    String? fileType,
    String? mimeType,
    String? thumbnailPath,
  }) async {
    try {
      _isUploading.value = true;

      final attachment = AttachmentModel(
        cardId: cardId,
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        fileType: fileType,
        mimeType: mimeType,
        thumbnailPath: thumbnailPath,
      );

      final createdAttachment = await _attachmentRepository.createAttachment(attachment);
      
      if (createdAttachment != null) {
        // Add to main list
        _attachments.insert(0, createdAttachment);
        
        // Update card-specific list
        if (!_attachmentsByCard.containsKey(cardId)) {
          _attachmentsByCard[cardId] = [];
        }
        _attachmentsByCard[cardId]!.insert(0, createdAttachment);
        
        // Update count
        _attachmentCountByCard[cardId] = (_attachmentCountByCard[cardId] ?? 0) + 1;
        
        // Update total size
        if (fileSize != null) {
          _totalSizeByCard[cardId] = (_totalSizeByCard[cardId] ?? 0) + fileSize;
        }
        
        // Log activity
        _activityLogController?.logAttachmentActivity(
          attachmentId: createdAttachment.id!,
          actionType: ActionType.created,
          description: 'Added attachment: $fileName',
        );
        
        _dialogService.showSuccess('Attachment added successfully');
        return true;
      }
      
      _dialogService.showError('Failed to add attachment');
      return false;
    } catch (e) {
      _dialogService.showError('Error adding attachment: ${e.toString()}');
      return false;
    } finally {
      _isUploading.value = false;
    }
  }

  // Load attachments for a card
  Future<void> loadAttachmentsForCard(int cardId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final attachments = await _attachmentRepository.getAttachmentsByCardId(cardId);
      
      // Update card-specific list
      _attachmentsByCard[cardId] = attachments;
      
      // Update count
      _attachmentCountByCard[cardId] = attachments.length;
      
      // Calculate total size
      int totalSize = 0;
      for (final attachment in attachments) {
        totalSize += attachment.fileSize ?? 0;
      }
      _totalSizeByCard[cardId] = totalSize;
      
      // Update main list with unique attachments
      for (final attachment in attachments) {
        final index = _attachments.indexWhere((a) => a.id == attachment.id);
        if (index == -1) {
          _attachments.add(attachment);
        } else {
          _attachments[index] = attachment;
        }
      }
    } catch (e) {
      _dialogService.showError('Error loading attachments: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load all active attachments
  Future<void> loadAllAttachments({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final attachments = await _attachmentRepository.getAllActiveAttachments();
      _attachments.assignAll(attachments);
      
      // Group by card
      _attachmentsByCard.clear();
      _attachmentCountByCard.clear();
      _totalSizeByCard.clear();
      
      for (final attachment in attachments) {
        if (!_attachmentsByCard.containsKey(attachment.cardId)) {
          _attachmentsByCard[attachment.cardId] = [];
        }
        _attachmentsByCard[attachment.cardId]!.add(attachment);
        _attachmentCountByCard[attachment.cardId] = (_attachmentCountByCard[attachment.cardId] ?? 0) + 1;
        _totalSizeByCard[attachment.cardId] = (_totalSizeByCard[attachment.cardId] ?? 0) + (attachment.fileSize ?? 0);
      }
    } catch (e) {
      _dialogService.showError('Error loading attachments: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load image attachments for a card
  Future<void> loadImageAttachments(int cardId) async {
    try {
      _isLoading.value = true;

      final attachments = await _attachmentRepository.getImageAttachments(cardId);
      _attachmentsByCard[cardId] = attachments;
    } catch (e) {
      _dialogService.showError('Error loading images: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load document attachments for a card
  Future<void> loadDocumentAttachments(int cardId) async {
    try {
      _isLoading.value = true;

      final attachments = await _attachmentRepository.getDocumentAttachments(cardId);
      _attachmentsByCard[cardId] = attachments;
    } catch (e) {
      _dialogService.showError('Error loading documents: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Update attachment thumbnail
  Future<bool> updateAttachmentThumbnail(int attachmentId, String thumbnailPath) async {
    try {
      _isUpdating.value = true;

      final success = await _attachmentRepository.updateAttachmentThumbnail(
        attachmentId,
        thumbnailPath,
      );
      
      if (success) {
        // Update in main list
        final index = _attachments.indexWhere((a) => a.id == attachmentId);
        if (index != -1) {
          final updatedAttachment = _attachments[index].copyWith(
            thumbnailPath: thumbnailPath,
          );
          _attachments[index] = updatedAttachment;
          
          // Update in card-specific list
          final cardId = _attachments[index].cardId;
          final cardIndex = _attachmentsByCard[cardId]?.indexWhere((a) => a.id == attachmentId);
          if (cardIndex != null && cardIndex != -1) {
            _attachmentsByCard[cardId]![cardIndex] = updatedAttachment;
          }
        }
        
        _dialogService.showSuccess('Thumbnail updated successfully');
        return true;
      }
      
      _dialogService.showError('Failed to update thumbnail');
      return false;
    } catch (e) {
      _dialogService.showError('Error updating thumbnail: ${e.toString()}');
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete attachment (soft delete)
  Future<bool> deleteAttachment(int attachmentId) async {
    try {
      _isDeleting.value = true;

      final success = await _attachmentRepository.deleteAttachment(attachmentId);
      
      if (success) {
        // Find and remove from main list
        final index = _attachments.indexWhere((a) => a.id == attachmentId);
        if (index != -1) {
          final attachment = _attachments[index];
          _attachments.removeAt(index);
          
          // Remove from card-specific list
          final cardId = attachment.cardId;
          _attachmentsByCard[cardId]?.removeWhere((a) => a.id == attachmentId);
          
          // Update count
          if (_attachmentCountByCard[cardId] != null && _attachmentCountByCard[cardId]! > 0) {
            _attachmentCountByCard[cardId] = _attachmentCountByCard[cardId]! - 1;
          }
          
          // Update total size
          if (attachment.fileSize != null && _totalSizeByCard[cardId] != null) {
            _totalSizeByCard[cardId] = _totalSizeByCard[cardId]! - attachment.fileSize!;
          }
          
          // Add to deleted list
          _deletedAttachments.add(attachment.copyWith(deletedAt: DateTime.now()));
          
          // Log activity
          _activityLogController?.logAttachmentActivity(
            attachmentId: attachmentId,
            actionType: ActionType.deleted,
            description: 'Deleted attachment: ${attachment.fileName}',
          );
        }
        
        _dialogService.showSuccess('Attachment deleted successfully');
        return true;
      }
      
      _dialogService.showError('Failed to delete attachment');
      return false;
    } catch (e) {
      _dialogService.showError('Error deleting attachment: ${e.toString()}');
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Restore deleted attachment
  Future<bool> restoreAttachment(int attachmentId) async {
    try {
      _isUpdating.value = true;

      final success = await _attachmentRepository.restoreAttachment(attachmentId);
      
      if (success) {
        // Remove from deleted list
        final deletedIndex = _deletedAttachments.indexWhere((a) => a.id == attachmentId);
        if (deletedIndex != -1) {
          final attachment = _deletedAttachments[deletedIndex].copyWith(
            deletedAt: null,
            clearDeletedAt: true,
          );
          _deletedAttachments.removeAt(deletedIndex);
          
          // Add back to main list
          _attachments.insert(0, attachment);
          
          // Add back to card-specific list
          final cardId = attachment.cardId;
          if (!_attachmentsByCard.containsKey(cardId)) {
            _attachmentsByCard[cardId] = [];
          }
          _attachmentsByCard[cardId]!.insert(0, attachment);
          
          // Update count
          _attachmentCountByCard[cardId] = (_attachmentCountByCard[cardId] ?? 0) + 1;
          
          // Update total size
          if (attachment.fileSize != null) {
            _totalSizeByCard[cardId] = (_totalSizeByCard[cardId] ?? 0) + attachment.fileSize!;
          }
        }
        
        _dialogService.showSuccess('Attachment restored successfully');
        return true;
      }
      
      _dialogService.showError('Failed to restore attachment');
      return false;
    } catch (e) {
      _dialogService.showError('Error restoring attachment: ${e.toString()}');
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Permanently delete attachment (also deletes file)
  Future<bool> permanentlyDeleteAttachment(int attachmentId, {bool deleteFile = true}) async {
    try {
      _isDeleting.value = true;

      final success = await _attachmentRepository.permanentlyDeleteAttachment(
        attachmentId,
        deleteFile: deleteFile,
      );
      
      if (success) {
        // Remove from deleted list
        _deletedAttachments.removeWhere((a) => a.id == attachmentId);
        
        _dialogService.showSuccess('Attachment permanently deleted');
        return true;
      }
      
      _dialogService.showError('Failed to permanently delete attachment');
      return false;
    } catch (e) {
      _dialogService.showError('Error permanently deleting attachment: ${e.toString()}');
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Load deleted attachments for a card
  Future<void> loadDeletedAttachmentsForCard(int cardId) async {
    try {
      _isLoading.value = true;

      final attachments = await _attachmentRepository.getDeletedAttachmentsByCardId(cardId);
      _deletedAttachments.assignAll(attachments);
    } catch (e) {
      _dialogService.showError('Error loading deleted attachments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search attachments
  Future<void> searchAttachments(String query) async {
    try {
      _isLoading.value = true;

      if (query.trim().isEmpty) {
        await loadAllAttachments(showLoading: false);
        return;
      }

      final results = await _attachmentRepository.searchAttachments(query);
      _attachments.assignAll(results);
    } catch (e) {
      _dialogService.showError('Error searching attachments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Get recent attachments
  Future<void> loadRecentAttachments({int limit = 10}) async {
    try {
      _isLoading.value = true;

      final attachments = await _attachmentRepository.getRecentAttachments(limit: limit);
      _attachments.assignAll(attachments);
    } catch (e) {
      _dialogService.showError('Error loading recent attachments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if card has attachments
  Future<bool> cardHasAttachments(int cardId) async {
    try {
      return await _attachmentRepository.cardHasAttachments(cardId);
    } catch (e) {
      return false;
    }
  }

  // Get attachment statistics for a card
  Future<Map<String, dynamic>> getAttachmentStats(int cardId) async {
    try {
      return await _attachmentRepository.getAttachmentStats(cardId);
    } catch (e) {
      return {
        'total': 0,
        'deleted': 0,
        'active': 0,
        'totalSize': 0,
        'images': 0,
        'documents': 0,
      };
    }
  }

  // Clear all attachments (for logout or reset)
  void clearAttachments() {
    _attachments.clear();
    _attachmentsByCard.clear();
    _deletedAttachments.clear();
    _attachmentCountByCard.clear();
    _totalSizeByCard.clear();
  }

  @override
  void onClose() {
    clearAttachments();
    super.onClose();
  }
}
