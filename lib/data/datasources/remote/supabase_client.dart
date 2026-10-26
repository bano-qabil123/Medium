import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/app_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  
  factory SupabaseClientService() => _instance;
  
  SupabaseClientService._internal();
  
  late final SupabaseClient _supabase;
  
  SupabaseClient get client => _supabase;
  
  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? AppConstants.supabaseUrl;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? AppConstants.supabaseAnonKey;
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw const AuthException(
        message: 'Supabase URL or Anon Key is missing',
        code: 'missing_config',
      );
    }
    
    _supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    // Enable offline persistence
    await _supabase.initialize();
  }
  
  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;
  
  /// Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        options: AuthOptions(
          redirectTo: redirectTo,
        ),
      );
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.user == null) {
        throw const AuthException(
          message: 'User not created',
          code: 'user_not_created',
        );
      }
      
      return response.user!;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign in with email and password
  Future<User> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.user == null) {
        throw const AuthException(
          message: 'User not found',
          code: 'user_not_found',
        );
      }
      
      return response.user!;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle({String? redirectTo}) async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        options: AuthOptions(
          redirectTo: redirectTo ?? AppConstants.webRedirectUrl,
        ),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email, {String? redirectTo}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        options: AuthOptions(
          redirectTo: redirectTo,
        ),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update user metadata
  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Refresh session
  Future<Session> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.session == null) {
        throw const AuthException(
          message: 'Session not refreshed',
          code: 'session_not_refreshed',
        );
      }
      
      return response.session!;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get auth state stream
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
  
  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
    bool upsert = false,
  }) async {
    try {
      final response = await _supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            options: FileOptions(
              contentType: contentType,
              upsert: upsert,
            ),
          );
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return getPublicUrl(bucket, path);
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get public URL for a file
  String getPublicUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Delete file from storage
  Future<void> deleteFile(String bucket, String path) async {
    try {
      final response = await _supabase.storage
          .from(bucket)
          .remove([path]);
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Execute a query on a table
  Future<PostgrestResponse> executeQuery(PostgrestTransformBuilder query) async {
    try {
      return await query.execute();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Subscribe to realtime changes
  RealtimeChannel subscribeToChannel(String channelName) {
    return _supabase.channel(channelName);
  }
}
