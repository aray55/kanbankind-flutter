import 'package:get/get.dart';
import '../data/repository/comment_repository.dart';
import '../models/comment_model.dart';
import '../core/services/dialog_service.dart';
import '../controllers/activity_log_controller.dart';
import '../models/activity_log_model.dart';

/// Comment Controller
/// Manages comment state and operations using GetX
class CommentController extends GetxController {
  final CommentRepository _commentRepository = CommentRepository();
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
  final RxList<CommentModel> _comments = <CommentModel>[].obs;
  final RxMap<int, List<CommentModel>> _commentsByCard = <int, List<CommentModel>>{}.obs;
  final RxList<CommentModel> _deletedComments = <CommentModel>[].obs;

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;

  // Statistics
  final RxMap<int, int> _commentCountByCard = <int, int>{}.obs;

  // Getters
  List<CommentModel> get comments => _comments;
  Map<int, List<CommentModel>> get commentsByCard => _commentsByCard;
  List<CommentModel> get deletedComments => _deletedComments;
  
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  
  Map<int, int> get commentCountByCard => _commentCountByCard;

  // Get comments for a specific card
  List<CommentModel> getCommentsForCard(int cardId) {
    return _commentsByCard[cardId] ?? [];
  }

  // Get comment count for a card
  int getCommentCountForCard(int cardId) {
    return _commentCountByCard[cardId] ?? 0;
  }

  // Create a new comment
  Future<bool> createComment({
    required int cardId,
    required String content,
  }) async {
    try {
      _isCreating.value = true;

      final comment = CommentModel(
        cardId: cardId,
        content: content,
      );

      final createdComment = await _commentRepository.createComment(comment);
      
      if (createdComment != null) {
        // Add to main list
        _comments.insert(0, createdComment);
        
        // Update card-specific list
        if (!_commentsByCard.containsKey(cardId)) {
          _commentsByCard[cardId] = [];
        }
        _commentsByCard[cardId]!.insert(0, createdComment);
        
        // Update count
        _commentCountByCard[cardId] = (_commentCountByCard[cardId] ?? 0) + 1;
        
        // Log activity
        _activityLogController?.logCommentActivity(
          commentId: createdComment.id!,
          actionType: ActionType.created,
          description: 'Added a comment',
        );
        
        
        _dialogService.showSuccess('Comment added successfully');
        return true;
      }
      
      _dialogService.showError('Failed to add comment');
      return false;
    } catch (e) {
      _dialogService.showError('Error adding comment: ${e.toString()}');
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Load comments for a card
  Future<void> loadCommentsForCard(int cardId, {bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final comments = await _commentRepository.getCommentsByCardId(cardId);
      
      // Update card-specific list
      _commentsByCard[cardId] = comments;
      
      // Update count
      _commentCountByCard[cardId] = comments.length;
      
      // Update main list with unique comments
      for (final comment in comments) {
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index == -1) {
          _comments.add(comment);
        } else {
          _comments[index] = comment;
        }
      }
    } catch (e) {
      _dialogService.showError('Error loading comments: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Load all active comments
  Future<void> loadAllComments({bool showLoading = true}) async {
    try {
      if (showLoading) _isLoading.value = true;

      final comments = await _commentRepository.getAllActiveComments();
      _comments.assignAll(comments);
      
      // Group by card
      _commentsByCard.clear();
      _commentCountByCard.clear();
      
      for (final comment in comments) {
        if (!_commentsByCard.containsKey(comment.cardId)) {
          _commentsByCard[comment.cardId] = [];
        }
        _commentsByCard[comment.cardId]!.add(comment);
        _commentCountByCard[comment.cardId] = (_commentCountByCard[comment.cardId] ?? 0) + 1;
      }
    } catch (e) {
      _dialogService.showError('Error loading comments: ${e.toString()}');
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  // Update comment content
  Future<bool> updateCommentContent(int commentId, String newContent) async {
    try {
      _isUpdating.value = true;

      final success = await _commentRepository.updateCommentContent(commentId, newContent);
      
      if (success) {
        // Update in main list
        final index = _comments.indexWhere((c) => c.id == commentId);
        String? oldContent;
        if (index != -1) {
          oldContent = _comments[index].content;
          final updatedComment = _comments[index].copyWith(
            content: newContent,
            updatedAt: DateTime.now(),
          );
          _comments[index] = updatedComment;
          
          // Update in card-specific list
          final cardId = _comments[index].cardId;
          final cardIndex = _commentsByCard[cardId]?.indexWhere((c) => c.id == commentId);
          if (cardIndex != null && cardIndex != -1) {
            _commentsByCard[cardId]![cardIndex] = updatedComment;
          }
        }
        
        // Log activity
        _activityLogController?.logCommentActivity(
          commentId: commentId,
          actionType: ActionType.updated,
          oldValue: oldContent,
          newValue: newContent,
          description: 'Updated a comment',
        );
        
        _dialogService.showSuccess('Comment updated successfully');
        return true;
      }
      
      _dialogService.showError('Failed to update comment');
      return false;
    } catch (e) {
      _dialogService.showError('Error updating comment: ${e.toString()}');
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Delete comment (soft delete)
  Future<bool> deleteComment(int commentId) async {
    try {
      _isDeleting.value = true;

      final success = await _commentRepository.deleteComment(commentId);
      
      if (success) {
        // Find and remove from main list
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final comment = _comments[index];
          _comments.removeAt(index);
          
          // Remove from card-specific list
          final cardId = comment.cardId;
          _commentsByCard[cardId]?.removeWhere((c) => c.id == commentId);
          
          // Update count
          if (_commentCountByCard[cardId] != null && _commentCountByCard[cardId]! > 0) {
            _commentCountByCard[cardId] = _commentCountByCard[cardId]! - 1;
          }
          
          // Add to deleted list
          _deletedComments.add(comment.copyWith(deletedAt: DateTime.now()));
          
          // Log activity
          _activityLogController?.logCommentActivity(
            commentId: commentId,
            actionType: ActionType.deleted,
            description: 'Deleted a comment',
          );
        }
        
        _dialogService.showSuccess('Comment deleted successfully');
        return true;
      }
      
      _dialogService.showError('Failed to delete comment');
      return false;
    } catch (e) {
      _dialogService.showError('Error deleting comment: ${e.toString()}');
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Restore deleted comment
  Future<bool> restoreComment(int commentId) async {
    try {
      _isUpdating.value = true;

      final success = await _commentRepository.restoreComment(commentId);
      
      if (success) {
        // Remove from deleted list
        final deletedIndex = _deletedComments.indexWhere((c) => c.id == commentId);
        if (deletedIndex != -1) {
          final comment = _deletedComments[deletedIndex].copyWith(
            deletedAt: null,
            clearDeletedAt: true,
          );
          _deletedComments.removeAt(deletedIndex);
          
          // Add back to main list
          _comments.insert(0, comment);
          
          // Add back to card-specific list
          final cardId = comment.cardId;
          if (!_commentsByCard.containsKey(cardId)) {
            _commentsByCard[cardId] = [];
          }
          _commentsByCard[cardId]!.insert(0, comment);
          
          // Update count
          _commentCountByCard[cardId] = (_commentCountByCard[cardId] ?? 0) + 1;
        }
        
        _dialogService.showSuccess('Comment restored successfully');
        return true;
      }
      
      _dialogService.showError('Failed to restore comment');
      return false;
    } catch (e) {
      _dialogService.showError('Error restoring comment: ${e.toString()}');
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  // Permanently delete comment
  Future<bool> permanentlyDeleteComment(int commentId) async {
    try {
      _isDeleting.value = true;

      final success = await _commentRepository.permanentlyDeleteComment(commentId);
      
      if (success) {
        // Remove from deleted list
        _deletedComments.removeWhere((c) => c.id == commentId);
        
        _dialogService.showSuccess('Comment permanently deleted');
        return true;
      }
      
      _dialogService.showError('Failed to permanently delete comment');
      return false;
    } catch (e) {
      _dialogService.showError('Error permanently deleting comment: ${e.toString()}');
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Load deleted comments for a card
  Future<void> loadDeletedCommentsForCard(int cardId) async {
    try {
      _isLoading.value = true;

      final comments = await _commentRepository.getDeletedCommentsByCardId(cardId);
      _deletedComments.assignAll(comments);
    } catch (e) {
      _dialogService.showError('Error loading deleted comments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search comments
  Future<void> searchComments(String query) async {
    try {
      _isLoading.value = true;

      if (query.trim().isEmpty) {
        await loadAllComments(showLoading: false);
        return;
      }

      final results = await _commentRepository.searchComments(query);
      _comments.assignAll(results);
    } catch (e) {
      _dialogService.showError('Error searching comments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Get recent comments
  Future<void> loadRecentComments({int limit = 10}) async {
    try {
      _isLoading.value = true;

      final comments = await _commentRepository.getRecentComments(limit: limit);
      _comments.assignAll(comments);
    } catch (e) {
      _dialogService.showError('Error loading recent comments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if card has comments
  Future<bool> cardHasComments(int cardId) async {
    try {
      return await _commentRepository.cardHasComments(cardId);
    } catch (e) {
      return false;
    }
  }

  // Get comment statistics for a card
  Future<Map<String, dynamic>> getCommentStats(int cardId) async {
    try {
      return await _commentRepository.getCommentStats(cardId);
    } catch (e) {
      return {'total': 0, 'deleted': 0, 'active': 0};
    }
  }
  

  // Clear all comments (for logout or reset)
  void clearComments() {
    _comments.clear();
    _commentsByCard.clear();
    _deletedComments.clear();
    _commentCountByCard.clear();
  }

  @override
  void onClose() {
    clearComments();
    super.onClose();
  }
}
