import '../../models/comment_model.dart';
import '../database/comment_dao.dart';

/// Comment Repository
/// Business logic layer for comments
class CommentRepository {
  final CommentDao _commentDao = CommentDao();

  // Create a new comment
  Future<CommentModel?> createComment(CommentModel comment) async {
    try {
      // Validate comment
      final validationError = comment.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      final id = await _commentDao.createComment(comment);
      if (id > 0) {
        return comment.copyWith(id: id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get comment by ID
  Future<CommentModel?> getCommentById(int id) async {
    try {
      return await _commentDao.getCommentById(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all comments for a card
  Future<List<CommentModel>> getCommentsByCardId(int cardId) async {
    try {
      return await _commentDao.getCommentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Get all active comments
  Future<List<CommentModel>> getAllActiveComments() async {
    try {
      return await _commentDao.getAllActiveComments();
    } catch (e) {
      rethrow;
    }
  }

  // Get deleted comments for a card
  Future<List<CommentModel>> getDeletedCommentsByCardId(int cardId) async {
    try {
      return await _commentDao.getDeletedCommentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Update comment
  Future<bool> updateComment(CommentModel comment) async {
    try {
      // Validate comment
      final validationError = comment.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      if (comment.id == null) {
        throw Exception('Comment ID cannot be null for update');
      }

      final result = await _commentDao.updateComment(comment);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Update comment content
  Future<bool> updateCommentContent(int id, String newContent) async {
    try {
      if (newContent.trim().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }

      final comment = await _commentDao.getCommentById(id);
      if (comment == null) {
        throw Exception('Comment not found');
      }

      final updatedComment = comment.copyWith(
        content: newContent,
        updatedAt: DateTime.now(),
      );

      return await updateComment(updatedComment);
    } catch (e) {
      rethrow;
    }
  }

  // Delete comment (soft delete)
  Future<bool> deleteComment(int id) async {
    try {
      final result = await _commentDao.softDeleteComment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Restore deleted comment
  Future<bool> restoreComment(int id) async {
    try {
      final result = await _commentDao.restoreComment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Permanently delete comment
  Future<bool> permanentlyDeleteComment(int id) async {
    try {
      final result = await _commentDao.permanentlyDeleteComment(id);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Delete all comments for a card
  Future<bool> deleteAllCommentsForCard(int cardId) async {
    try {
      final result = await _commentDao.softDeleteAllCommentsForCard(cardId);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Permanently delete all comments for a card
  Future<bool> permanentlyDeleteAllCommentsForCard(int cardId) async {
    try {
      final result = await _commentDao.permanentlyDeleteAllCommentsForCard(cardId);
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Count comments for a card
  Future<int> countCommentsByCardId(int cardId) async {
    try {
      return await _commentDao.countCommentsByCardId(cardId);
    } catch (e) {
      rethrow;
    }
  }

  // Check if card has comments
  Future<bool> cardHasComments(int cardId) async {
    try {
      final count = await countCommentsByCardId(cardId);
      return count > 0;
    } catch (e) {
      rethrow;
    }
  }

  // Search comments
  Future<List<CommentModel>> searchComments(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await _commentDao.searchComments(query);
    } catch (e) {
      rethrow;
    }
  }

  // Get recent comments
  Future<List<CommentModel>> getRecentComments({int limit = 10}) async {
    try {
      return await _commentDao.getRecentComments(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get comments by date range
  Future<List<CommentModel>> getCommentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _commentDao.getCommentsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Duplicate comment
  Future<CommentModel?> duplicateComment(int commentId, int newCardId) async {
    try {
      final originalComment = await _commentDao.getCommentById(commentId);
      if (originalComment == null) {
        throw Exception('Original comment not found');
      }

      final duplicatedComment = CommentModel(
        cardId: newCardId,
        content: originalComment.content,
      );

      return await createComment(duplicatedComment);
    } catch (e) {
      rethrow;
    }
  }

  // Batch create comments
  Future<bool> batchCreateComments(List<CommentModel> comments) async {
    try {
      // Validate all comments
      for (final comment in comments) {
        final validationError = comment.validate();
        if (validationError != null) {
          throw Exception('Invalid comment: $validationError');
        }
      }

      await _commentDao.batchInsertComments(comments);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Batch delete comments
  Future<bool> batchDeleteComments(List<int> commentIds) async {
    try {
      await _commentDao.batchDeleteComments(commentIds);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Get comment statistics for a card
  Future<Map<String, dynamic>> getCommentStats(int cardId) async {
    try {
      final allComments = await _commentDao.getCommentsByCardId(cardId);
      final deletedComments = await _commentDao.getDeletedCommentsByCardId(cardId);

      return {
        'total': allComments.length,
        'deleted': deletedComments.length,
        'active': allComments.length,
      };
    } catch (e) {
      rethrow;
    }
  }
}
