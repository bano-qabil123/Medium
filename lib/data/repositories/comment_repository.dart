import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/api_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/comment_model.dart';
import 'package:medium_clone/data/models/user_model.dart';

class CommentRepository {
  final SupabaseClientService _supabaseClient;
  
  CommentRepository(this._supabaseClient);
  
  /// Get comments for an article
  Future<List<CommentModel>> getComments({
    required String articleId,
    String? parentId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      
      PostgrestTransformBuilder query = _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('article_id', articleId)
          .eq('status', 'approved')
          .order('created_at', ascending: false)
          .limit(limit)
          .offset(offset);
      
      if (parentId != null) {
        query = query.eq('parent_id', parentId);
      } else {
        query = query.is_('parent_id', null);
      }
      
      final response = await query.execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      final comments = (response.data as List<dynamic>? ?? [])
          .map((json) => CommentModel.fromSupabase(
            json,
            user: json[ApiConstants.profilesTable] != null
                ? UserModel.fromSupabase(json[ApiConstants.profilesTable])
                : null,
          ))
          .toList();
      
      // Check if user has clapped each comment
      if (userId != null) {
        final commentIds = comments.map((c) => c.id).toList();
        
        if (commentIds.isNotEmpty) {
          final clapsResponse = await _supabaseClient.client
              .from(ApiConstants.clapsTable)
              .select('comment_id')
              .eq('user_id', userId)
              .in_('comment_id', commentIds)
              .execute();
          
          if (clapsResponse.error == null) {
            final clappedCommentIds = (clapsResponse.data as List<dynamic>? ?? [])
                .map((clap) => clap['comment_id'] as String)
                .toSet();
            
            return comments.map((comment) => comment.copyWith(
              isClapped: clappedCommentIds.contains(comment.id),
            )).toList();
          }
        }
      }
      
      return comments;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get comment by ID
  Future<CommentModel> getCommentById(String commentId) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('id', commentId)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'Comment not found',
          code: 'comment_not_found',
        );
      }
      
      return CommentModel.fromSupabase(
        response.data,
        user: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Create comment
  Future<CommentModel> createComment({
    required String articleId,
    required String content,
    String? parentId,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Verify article exists and is published
      final articleResponse = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('id, status')
          .eq('id', articleId)
          .single()
          .execute();
      
      if (articleResponse.error != null) {
        throw exceptionFromSupabaseError(articleResponse.error);
      }
      
      if (articleResponse.data == null) {
        throw const NotFoundException(
          message: 'Article not found',
          code: 'article_not_found',
        );
      }
      
      if (articleResponse.data['status'] != 'published') {
        throw const UnauthorizedException(
          message: 'Cannot comment on unpublished articles',
          code: 'article_not_published',
        );
      }
      
      final commentData = {
        'article_id': articleId,
        'user_id': userId,
        'parent_id': parentId,
        'content': content,
        'status': 'pending', // Will be approved automatically for now
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .insert(commentData)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return CommentModel.fromSupabase(
        response.data,
        user: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update comment
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Verify comment exists and belongs to user
      final existingComment = await getCommentById(commentId);
      if (existingComment.userId != userId) {
        throw const UnauthorizedException(
          message: 'You can only update your own comments',
          code: 'unauthorized_update',
        );
      }
      
      final response = await _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return CommentModel.fromSupabase(
        response.data,
        user: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Verify comment exists and belongs to user
      final existingComment = await getCommentById(commentId);
      if (existingComment.userId != userId) {
        throw const UnauthorizedException(
          message: 'You can only delete your own comments',
          code: 'unauthorized_delete',
        );
      }
      
      await _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .delete()
          .eq('id', commentId)
          .execute();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Clap comment
  Future<bool> clapComment(String commentId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Check if already clapped
      final existingClap = await _supabaseClient.client
          .from(ApiConstants.clapsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle()
          .execute();
      
      if (existingClap.data != null) {
        // Remove clap
        await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .delete()
            .eq('id', existingClap.data['id'])
            .execute();
        return false;
      } else {
        // Add clap
        await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .insert({
              'user_id': userId,
              'comment_id': commentId,
            })
            .execute();
        return true;
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get comment count for an article
  Future<int> getCommentCount(String articleId) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.commentsTable)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('article_id', articleId)
          .eq('status', 'approved')
          .is_('parent_id', null)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return response.count ?? 0;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
}
