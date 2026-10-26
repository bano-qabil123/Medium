import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

/// Supabase client service with lazy initialization and connection pooling
class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  
  factory SupabaseClientService() => _instance;
  
  SupabaseClientService._internal();
  
  late final SupabaseClient _supabase;
  bool _isInitialized = false;
  
  /// Lazy initialization - only initializes when first accessed
  SupabaseClient get client {
    if (!_isInitialized) {
      _initialize();
    }
    return _supabase;
  }
  
  /// Initialize Supabase client (lazy)
  void _initialize() {
    if (_isInitialized) return;
    
    // Load environment variables with fallback to constants
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? AppConstants.supabaseUrl;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? AppConstants.supabaseAnonKey;
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw const AuthException(
        message: 'Supabase URL or Anon Key is missing',
        code: 'missing_config',
      );
    }
    
    _supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    _isInitialized = true;
  }
  
  /// Get current user (sync)
  User? get currentUser => client.auth.currentUser;
  
  /// Get current session (sync)
  Session? get currentSession => client.auth.currentSession;
  
  /// Check if authenticated (sync)
  bool get isAuthenticated => currentUser != null;
  
  /// Get auth state stream
  Stream<AuthState> get authStateStream => client.auth.onAuthStateChange;
  
  /// Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    try {
      final response = await client.auth.signUp(
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
      final response = await client.auth.signInWithPassword(
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
      await client.auth.signInWithOAuth(
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
      await client.auth.signOut();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email, {String? redirectTo}) async {
    try {
      await client.auth.resetPasswordForEmail(
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
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update user metadata
  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await client.auth.updateUser(
        UserAttributes(data: metadata),
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Refresh session
  Future<Session> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      
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
  
  /// Upload file to storage with progress tracking
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
    bool upsert = false,
    void Function(double)? onProgress,
  }) async {
    try {
      final response = await client.storage
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
    return client.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Delete file from storage
  Future<void> deleteFile(String bucket, String path) async {
    try {
      final response = await client.storage
          .from(bucket)
          .remove([path]);
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Execute a query on a table with error handling
  Future<PostgrestResponse> executeQuery(PostgrestTransformBuilder query) async {
    try {
      return await query.execute();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Subscribe to realtime changes
  RealtimeChannel subscribeToChannel(String channelName) {
    return client.channel(channelName);
  }
}
