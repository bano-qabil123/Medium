import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/api_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/user_model.dart';

class AuthRepository {
  final SupabaseClientService _supabaseClient;
  
  AuthRepository(this._supabaseClient);
  
  /// Get current user
  User? get currentUser => _supabaseClient.currentUser;
  
  /// Get current session
  Session? get currentSession => _supabaseClient.currentSession;
  
  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Get auth state stream
  Stream<AuthState> get authStateStream => _supabaseClient.authStateStream;
  
  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    try {
      final user = await _supabaseClient.signUp(
        email: email,
        password: password,
      );
      
      // Create profile in database
      if (user != null) {
        await _createProfile(user.id, email, displayName, username);
      }
      
      return await getUserProfile(user.id);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign in with email and password
  Future<UserModel> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _supabaseClient.signInWithPassword(
        email: email,
        password: password,
      );
      
      return await getUserProfile(user.id);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _supabaseClient.signInWithGoogle();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.signOut();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.resetPassword(email);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.updatePassword(newPassword);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get user profile
  Future<UserModel> getUserProfile(String userId) async {
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
          message: 'User profile not found',
          code: 'profile_not_found',
        );
      }
      
      return UserModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Create user profile
  Future<UserModel> _createProfile(
    String userId, 
    String email, 
    String? displayName, 
    String? username,
  ) async {
    try {
      final profileData = {
        'id': userId,
        'username': username ?? email.split('@')[0],
        'display_name': displayName ?? email.split('@')[0],
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .upsert(profileData)
          .select()
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return UserModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? displayName,
    String? bio,
    String? website,
    String? twitterHandle,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (website != null) updates['website'] = website;
      if (twitterHandle != null) updates['twitter_handle'] = twitterHandle;
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return UserModel.fromSupabase(response.data);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Upload avatar
  Future<String> uploadAvatar(String userId, List<int> bytes) async {
    try {
      final path = 'avatars/$userId.jpg';
      final url = await _supabaseClient.uploadFile(
        bucket: AppConstants.avatarsBucket,
        path: path,
        bytes: bytes,
        contentType: 'image/jpeg',
        upsert: true,
      );
      
      // Update profile with new avatar URL
      await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .update({'avatar_url': url})
          .eq('id', userId)
          .execute();
      
      return url;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Delete avatar
  Future<void> deleteAvatar(String userId) async {
    try {
      final path = 'avatars/$userId.jpg';
      await _supabaseClient.deleteFile(
        AppConstants.avatarsBucket,
        path,
      );
      
      // Update profile to remove avatar URL
      await _supabaseClient.client
          .from(ApiConstants.profilesTable)
          .update({'avatar_url': null})
          .eq('id', userId)
          .execute();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
}
