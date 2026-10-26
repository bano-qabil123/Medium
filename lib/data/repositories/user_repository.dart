import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/api_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/user_model.dart';

class UserRepository {
  final SupabaseClientService _supabaseClient;
  
  UserRepository(this._supabaseClient);
  
  /// Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'User not found',
          code: 'user_not_found',
        );
      }
      
      return UserModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get user by username
  Future<UserModel> getUserByUsername(String username) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .select()
          .eq('username', username)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'User not found',
          code: 'user_not_found',
        );
      }
      
      return UserModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Search users
  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .select()
          .or('username.ilike.*$query*,display_name.ilike.*$query*')
          .limit(limit)
          .offset(offset)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return (response.data as List<dynamic>? ?? [])
          .map((json) => UserModel.fromSupabase(json))
          .toList();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Follow a user
  Future<bool> followUser(String userId) async {
    try {
      final currentUserId = _supabaseClient.currentUser?.id;
      if (currentUserId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      if (currentUserId == userId) {
        throw const ConflictException(
          message: 'Cannot follow yourself',
          code: 'cannot_follow_self',
        );
      }
      
      // Check if already following
      final existingFollow = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle()
          .execute();
      
      if (existingFollow.data != null) {
        // Unfollow
        await _supabaseClient.client
            .from(ApiConstants.userFollowsTable)
            .delete()
            .eq('id', existingFollow.data['id'])
            .execute();
        
        // Decrement following count
        await _supabaseClient.client
            .from(ApiConstants.profilesTable)
            .update({'following_count': 'following_count - 1'})
            .eq('id', currentUserId)
            .execute();
        
        // Decrement followers count
        await _supabaseClient.client
            .from(ApiConstants.profilesTable)
            .update({'followers_count': 'followers_count - 1'})
            .eq('id', userId)
            .execute();
        
        return false;
      } else {
        // Follow
        await _supabaseClient.client
            .from(ApiConstants.userFollowsTable)
            .insert({
              'follower_id': currentUserId,
              'following_id': userId,
            })
            .execute();
        
        // Increment following count
        await _supabaseClient.client
            .from(ApiConstants.profilesTable)
            .update({'following_count': 'following_count + 1'})
            .eq('id', currentUserId)
            .execute();
        
        // Increment followers count
        await _supabaseClient.client
            .from(ApiConstants.profilesTable)
            .update({'followers_count': 'followers_count + 1'})
            .eq('id', userId)
            .execute();
        
        return true;
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Check if current user is following a user
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _supabaseClient.currentUser?.id;
      if (currentUserId == null) {
        return false;
      }
      
      final response = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle()
          .execute();
      
      return response.data != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Get user followers
  Future<List<UserModel>> getFollowers({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('${ApiConstants.profilesTable}(*)')
          .eq('following_id', userId)
          .limit(limit)
          .offset(offset)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return (response.data as List<dynamic>? ?? [])
          .map((json) => UserModel.fromSupabase(json[ApiConstants.profilesTable]))
          .toList();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get users that the current user is following
  Future<List<UserModel>> getFollowing({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUserId = userId ?? _supabaseClient.currentUser?.id;
      if (currentUserId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      final response = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('${ApiConstants.profilesTable}(*)')
          .eq('follower_id', currentUserId)
          .limit(limit)
          .offset(offset)
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return (response.data as List<dynamic>? ?? [])
          .map((json) => UserModel.fromSupabase(json[ApiConstants.profilesTable]))
          .toList();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Get article count
      final articlesResponse = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('author_id', userId)
          .execute();
      
      // Get follower count
      final followersResponse = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('following_id', userId)
          .execute();
      
      // Get following count
      final followingResponse = await _supabaseClient.client
          .from(ApiConstants.userFollowsTable)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('follower_id', userId)
          .execute();
      
      return {
        'articles': articlesResponse.count ?? 0,
        'followers': followersResponse.count ?? 0,
        'following': followingResponse.count ?? 0,
      };
    } catch (e) {
      return {
        'articles': 0,
        'followers': 0,
        'following': 0,
      };
    }
  }
  
  /// Get user bookmarks
  Future<List<dynamic>> getUserBookmarks({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUserId = userId ?? _supabaseClient.currentUser?.id;
      if (currentUserId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      final response = await _supabaseClient.client
          .from(ApiConstants.bookmarksTable)
          .select('${ApiConstants.articlesTable}(*), ${ApiConstants.profilesTable}(*)')
          .eq('user_id', currentUserId)
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
