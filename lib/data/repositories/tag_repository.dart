import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/api_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/tag_model.dart';

class TagRepository {
  final SupabaseClientService _supabaseClient;
  
  TagRepository(this._supabaseClient);
  
  /// Get all tags
  Future<List<TagModel>> getAllTags({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      
      PostgrestTransformBuilder query = _supabaseClient.client
          .from(ApiConstants.tagsTable)
          .select('*, ${ApiConstants.articleTagsTable}(article_id)')
          .order('articles_count', ascending: false)
          .limit(limit)
          .offset(offset);
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.*$searchQuery*,slug.ilike.*$searchQuery*');
      }
      
      final response = await query.execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      final tags = (response.data as List<dynamic>? ?? [])
          .map((json) => TagModel.fromSupabase(json))
          .toList();
      
      // Check if user is following each tag
      if (userId != null) {
        final tagIds = tags.map((t) => t.id).toList();
        
        if (tagIds.isNotEmpty) {
          // Note: This assumes you have a user_tags table for following tags
          // For now, we'll just return the tags without follow status
          // You can implement this later
        }
      }
      
      return tags;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get tag by ID
  Future<TagModel> getTagById(String tagId) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.tagsTable)
          .select()
          .eq('id', tagId)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'Tag not found',
          code: 'tag_not_found',
        );
      }
      
      return TagModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get tag by slug
  Future<TagModel> getTagBySlug(String slug) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.tagsTable)
          .select()
          .eq('slug', slug)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'Tag not found',
          code: 'tag_not_found',
        );
      }
      
      return TagModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get popular tags
  Future<List<TagModel>> getPopularTags({int limit = 10}) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.tagsTable)
          .select()
          .order('articles_count', ascending: false)
          .limit(limit)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return (response.data as List<dynamic>? ?? [])
          .map((json) => TagModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get trending tags
  Future<List<TagModel>> getTrendingTags({int limit = 10}) async {
    try {
      // Get tags with most recent articles
      final response = await _supabaseClient.client
          .from(ApiConstants.tagsTable)
          .select('*, ${ApiConstants.articleTagsTable}(created_at)')
          .order('${ApiConstants.articleTagsTable}.created_at', ascending: false)
          .limit(limit)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      // Group by tag and count
      final tagMap = <String, TagModel>{};
      for (final json in (response.data as List<dynamic>? ?? [])) {
        final tag = TagModel.fromSupabase(json);
        if (tagMap.containsKey(tag.id)) {
          // Increment count if already exists
          tagMap[tag.id] = tagMap[tag.id]!.copyWith(
            articlesCount: tagMap[tag.id]!.articlesCount + 1,
          );
        } else {
          tagMap[tag.id] = tag;
        }
      }
      
      // Sort by count and return
      return tagMap.values
          .toList()
          ..sort((a, b) => b.articlesCount.compareTo(a.articlesCount));
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Follow a tag
  Future<bool> followTag(String tagId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Check if already following
      final existingFollow = await _supabaseClient.client
          .from('user_tags')
          .select('id')
          .eq('user_id', userId)
          .eq('tag_id', tagId)
          .maybeSingle()
          .execute();
      
      if (existingFollow.data != null) {
        // Unfollow
        await _supabaseClient.client
            .from('user_tags')
            .delete()
            .eq('id', existingFollow.data['id'])
            .execute();
        return false;
      } else {
        // Follow
        await _supabaseClient.client
            .from('user_tags')
            .insert({
              'user_id': userId,
              'tag_id': tagId,
            })
            .execute();
        return true;
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get articles by tag
  Future<List<dynamic>> getArticlesByTag(String tagId, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.articleTagsTable)
          .select('${ApiConstants.articlesTable}(*), ${ApiConstants.profilesTable}(*)')
          .eq('tag_id', tagId)
          .order('${ApiConstants.articlesTable}.published_at', ascending: false)
          .limit(limit)
          .offset(offset)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return response.data as List<dynamic>? ?? [];
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
}
