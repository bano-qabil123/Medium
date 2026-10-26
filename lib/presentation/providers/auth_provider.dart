import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/remote/supabase_client.dart';
import '../../data/models/user_model.dart';

// Supabase Client Provider - Lazy initialization
final supabaseClientProvider = Provider<SupabaseClientService>((ref) {
  return SupabaseClientService();
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

// Auth State Provider - Stream-based for realtime updates
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateStream;
});

// Current User Provider - Sync access to current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseClientProvider).currentUser;
});

// Is Authenticated Provider - Sync check
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Current User Profile Provider - Async load with caching
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getUserProfile(user.id);
});

// Auth Controller Provider - State management
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;
  
  AuthController(this._authRepository) : super(const AsyncValue.data(null));
  
  Future<void> initialize() async {
    try {
      // Initialize Supabase (already done in constructor)
      final user = _authRepository.currentUser;
      if (user != null) {
        final profile = await _authRepository.getUserProfile(user.id);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
        username: username,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> refreshProfile() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final profile = await _authRepository.getUserProfile(user.id);
        state = AsyncValue.data(profile);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
