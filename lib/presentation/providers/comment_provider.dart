import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/constants/app_constants.dart';
import 'package:medium_clone/data/models/comment_model.dart';
import 'package:medium_clone/data/repositories/comment_repository.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Comment Repository Provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(supabaseClientProvider));
});

// Comments Provider
final commentsProvider = StateNotifierProviderFamily<CommentsNotifier, AsyncValue<List<CommentModel>>, String>((ref, articleId) {
  return CommentsNotifier(ref.watch(commentRepositoryProvider), articleId);
});

// Comment Controller Provider
final commentControllerProvider = StateNotifierProvider<CommentController, AsyncValue<CommentModel?>>((ref) {
  return CommentController(ref.watch(commentRepositoryProvider));
});

class CommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final CommentRepository _commentRepository;
  final String _articleId;
  
  int _page = 0;
  bool _hasMore = true;
  String? _parentId;
  
  CommentsNotifier(this._commentRepository, this._articleId) : super(const AsyncValue.data([]));
  
  Future<void> loadComments({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
    }
    
    if (!_hasMore && !refresh) return;
    
    try {
      if (refresh) {
        state = const AsyncValue.loading();
      }
      
      final comments = await _commentRepository.getComments(
        articleId: _articleId,
        parentId: _parentId,
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
      );
      
      _hasMore = comments.length == AppConstants.defaultPageSize;
      _page++;
      
      if (refresh) {
        state = AsyncValue.data(comments);
      } else {
        state = AsyncValue.data([...state.valueOrNull ?? [], ...comments]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore) return;
    await loadComments();
  }
  
  Future<void> refresh() async {
    await loadComments(refresh: true);
  }
  
  void filterByParent(String? parentId) {
    _parentId = parentId;
    _page = 0;
    _hasMore = true;
    loadComments(refresh: true);
  }
  
  bool get hasMore => _hasMore;
  bool get isLoading => state.isLoading;
}

class CommentController extends StateNotifier<AsyncValue<CommentModel?>> {
  final CommentRepository _commentRepository;
  
  CommentController(this._commentRepository) : super(const AsyncValue.data(null));
  
  Future<void> createComment({
    required String articleId,
    required String content,
    String? parentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final comment = await _commentRepository.createComment(
        articleId: articleId,
        content: content,
        parentId: parentId,
      );
      state = AsyncValue.data(comment);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    try {
      final comment = await _commentRepository.updateComment(
        commentId: commentId,
        content: content,
      );
      state = AsyncValue.data(comment);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> deleteComment(String commentId) async {
    state = const AsyncValue.loading();
    try {
      await _commentRepository.deleteComment(commentId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> clapComment(String commentId) async {
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) return;
      
      final isClapped = await _commentRepository.clapComment(commentId);
      state = AsyncValue.data(currentState.copyWith(isClapped: isClapped));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  void clear() {
    state = const AsyncValue.data(null);
  }
}
