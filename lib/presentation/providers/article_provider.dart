import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/article_repository.dart';

// Article Repository Provider
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.watch(supabaseClientProvider));
});

// Articles Feed Provider - Optimized with pagination
final articlesFeedProvider = StateNotifierProvider<ArticlesFeedNotifier, AsyncValue<List<ArticleModel>>>((ref) {
  return ArticlesFeedNotifier(ref.watch(articleRepositoryProvider));
});

// Article Detail Provider - Family provider for individual articles
final articleDetailProvider = FutureProviderFamily<ArticleModel, String>((ref, articleId) async {
  return ref.watch(articleRepositoryProvider).getArticleById(articleId);
});

// User Articles Provider - Family provider for user's articles
final userArticlesProvider = FutureProviderFamily<List<ArticleModel>, String>((ref, userId) async {
  return ref.watch(articleRepositoryProvider).getUserArticles(userId: userId);
});

// Article Controller Provider - For CRUD operations
final articleControllerProvider = StateNotifierProvider<ArticleController, AsyncValue<ArticleModel?>>((ref) {
  return ArticleController(ref.watch(articleRepositoryProvider));
});

/// Optimized feed notifier with pagination and caching
class ArticlesFeedNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final ArticleRepository _articleRepository;
  
  int _page = 0;
  bool _hasMore = true;
  String? _tag;
  String? _searchQuery;
  bool _onlyFollowing = false;
  
  // Cache for articles
  final List<ArticleModel> _cachedArticles = [];
  
  ArticlesFeedNotifier(this._articleRepository) : super(const AsyncValue.data([]));
  
  Future<void> loadArticles({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      _cachedArticles.clear();
    }
    
    if (!_hasMore && !refresh) return;
    
    try {
      if (refresh) {
        state = const AsyncValue.loading();
      }
      
      final articles = await _articleRepository.getArticlesFeed(
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
        tag: _tag,
        searchQuery: _searchQuery,
        onlyFollowing: _onlyFollowing,
      );
      
      _hasMore = articles.length == AppConstants.defaultPageSize;
      _page++;
      
      if (refresh) {
        _cachedArticles.clear();
        _cachedArticles.addAll(articles);
        state = AsyncValue.data(_cachedArticles);
      } else {
        _cachedArticles.addAll(articles);
        state = AsyncValue.data(_cachedArticles);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore) return;
    await loadArticles();
  }
  
  Future<void> refresh() async {
    await loadArticles(refresh: true);
  }
  
  void filterByTag(String? tag) {
    _tag = tag;
    _page = 0;
    _hasMore = true;
    _cachedArticles.clear();
    loadArticles(refresh: true);
  }
  
  void search(String? query) {
    _searchQuery = query;
    _page = 0;
    _hasMore = true;
    _cachedArticles.clear();
    loadArticles(refresh: true);
  }
  
  void toggleFollowingFilter() {
    _onlyFollowing = !_onlyFollowing;
    _page = 0;
    _hasMore = true;
    _cachedArticles.clear();
    loadArticles(refresh: true);
  }
  
  bool get hasMore => _hasMore;
  bool get isLoading => state.isLoading;
  List<ArticleModel> get cachedArticles => List.unmodifiable(_cachedArticles);
}

/// Article controller for CRUD operations
class ArticleController extends StateNotifier<AsyncValue<ArticleModel?>> {
  final ArticleRepository _articleRepository;
  
  ArticleController(this._articleRepository) : super(const AsyncValue.data(null));
  
  Future<void> createArticle({
    required String title,
    required String content,
    String? coverImageUrl,
    List<String>? tags,
    String status = 'draft',
    String visibility = 'public',
  }) async {
    state = const AsyncValue.loading();
    try {
      final article = await _articleRepository.createArticle(
        title: title,
        content: content,
        coverImageUrl: coverImageUrl,
        tags: tags,
        status: status,
        visibility: visibility,
      );
      state = AsyncValue.data(article);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> updateArticle({
    required String articleId,
    String? title,
    String? content,
    String? coverImageUrl,
    List<String>? tags,
    String? status,
    String? visibility,
  }) async {
    state = const AsyncValue.loading();
    try {
      final article = await _articleRepository.updateArticle(
        articleId: articleId,
        title: title,
        content: content,
        coverImageUrl: coverImageUrl,
        tags: tags,
        status: status,
        visibility: visibility,
      );
      state = AsyncValue.data(article);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> deleteArticle(String articleId) async {
    state = const AsyncValue.loading();
    try {
      await _articleRepository.deleteArticle(articleId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> likeArticle(String articleId) async {
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) return;
      
      final isLiked = await _articleRepository.likeArticle(articleId);
      state = AsyncValue.data(currentState.copyWith(isLiked: isLiked));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> bookmarkArticle(String articleId) async {
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) return;
      
      final isBookmarked = await _articleRepository.bookmarkArticle(articleId);
      state = AsyncValue.data(currentState.copyWith(isBookmarked: isBookmarked));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> loadArticle(String articleId) async {
    state = const AsyncValue.loading();
    try {
      final article = await _articleRepository.getArticleById(articleId);
      state = AsyncValue.data(article);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  void clear() {
    state = const AsyncValue.data(null);
  }
}
