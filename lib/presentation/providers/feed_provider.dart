import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/constants/app_constants.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/repositories/article_repository.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/tag_provider.dart';
import 'package:medium_clone/presentation/providers/article_view_provider.dart';

/// Feed type enum
enum FeedType {
  trending,      // Most claps in last 7 days
  latest,        // Newest articles
  following,     // Articles from followed authors
  bookmarks,     // User's bookmarked articles
  personal,      // Personalized feed (mix of above)
}

/// Feed filter options
class FeedFilter {
  final FeedType type;
  final String? tag;
  final String? searchQuery;
  final bool onlyFollowing;

  const FeedFilter({
    this.type = FeedType.personal,
    this.tag,
    this.searchQuery,
    this.onlyFollowing = false,
  });

  FeedFilter copyWith({
    FeedType? type,
    String? tag,
    String? searchQuery,
    bool? onlyFollowing,
  }) {
    return FeedFilter(
      type: type ?? this.type,
      tag: tag ?? this.tag,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyFollowing: onlyFollowing ?? this.onlyFollowing,
    );
  }
}

/// Feed Notifier - Manages the personalized feed algorithm
class FeedNotifier extends StateNotifier<AsyncValue<List<ArticleModel>>> {
  final ArticleRepository _articleRepository;
  final Ref _ref;
  
  FeedFilter _filter = const FeedFilter();
  int _page = 0;
  bool _hasMore = true;
  final List<ArticleModel> _cachedArticles = [];
  
  FeedNotifier(this._articleRepository, this._ref) 
      : super(const AsyncValue.data([]));

  FeedFilter get filter => _filter;
  bool get hasMore => _hasMore;

  /// Set feed filter
  void setFilter(FeedFilter filter) {
    _filter = filter;
    _page = 0;
    _hasMore = true;
    _cachedArticles.clear();
    _loadFeed();
  }

  /// Load feed based on current filter
  Future<void> _loadFeed() async {
    if (!_hasMore) return;
    
    try {
      if (_page == 0) {
        state = const AsyncValue.loading();
      }
      
      List<ArticleModel> articles = [];
      
      switch (_filter.type) {
        case FeedType.trending:
          articles = await _getTrendingArticles();
          break;
        case FeedType.latest:
          articles = await _getLatestArticles();
          break;
        case FeedType.following:
          articles = await _getFollowingArticles();
          break;
        case FeedType.bookmarks:
          articles = await _getBookmarkedArticles();
          break;
        case FeedType.personal:
        default:
          articles = await _getPersonalizedFeed();
          break;
      }
      
      _hasMore = articles.length == AppConstants.defaultPageSize;
      _page++;
      
      if (_page == 1) {
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

  /// Get trending articles (most claps in last 7 days)
  Future<List<ArticleModel>> _getTrendingArticles() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final response = await _articleRepository.getArticles(
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
        orderBy: 'claps_count',
        orderDirection: 'desc',
        startDate: sevenDaysAgo,
        tag: _filter.tag,
        searchQuery: _filter.searchQuery,
      );
      
      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get latest articles (newest first)
  Future<List<ArticleModel>> _getLatestArticles() async {
    try {
      final response = await _articleRepository.getArticles(
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
        orderBy: 'published_at',
        orderDirection: 'desc',
        tag: _filter.tag,
        searchQuery: _filter.searchQuery,
      );
      
      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get articles from followed authors
  Future<List<ArticleModel>> _getFollowingArticles() async {
    try {
      // Get current user
      final user = _ref.read(currentUserProvider).valueOrNull;
      if (user == null) return [];
      
      // Get followed authors
      final followedAuthors = await _articleRepository.getFollowedAuthors(user.id);
      
      if (followedAuthors.isEmpty) {
        // If no followed authors, show trending instead
        return await _getTrendingArticles();
      }
      
      final response = await _articleRepository.getArticles(
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
        authorIds: followedAuthors.map((u) => u.id).toList(),
        orderBy: 'published_at',
        orderDirection: 'desc',
        tag: _filter.tag,
        searchQuery: _filter.searchQuery,
      );
      
      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get bookmarked articles
  Future<List<ArticleModel>> _getBookmarkedArticles() async {
    try {
      // Get current user
      final user = _ref.read(currentUserProvider).valueOrNull;
      if (user == null) return [];
      
      // Get bookmarked article IDs
      final bookmarkedIds = await _articleRepository.getBookmarkedArticleIds(user.id);
      
      if (bookmarkedIds.isEmpty) return [];
      
      final response = await _articleRepository.getArticlesByIds(
        bookmarkedIds,
        limit: AppConstants.defaultPageSize,
        offset: _page * AppConstants.defaultPageSize,
      );
      
      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get personalized feed (mix of algorithms)
  Future<List<ArticleModel>> _getPersonalizedFeed() async {
    try {
      final user = _ref.read(currentUserProvider).valueOrNull;
      
      if (user == null) {
        // For anonymous users, show trending
        return await _getTrendingArticles();
      }
      
      // Get followed tags
      final followedTagsAsync = _ref.read(followedTagsProvider);
      final followedTags = await followedTagsAsync.future;
      
      // Get followed authors
      final followedAuthors = await _articleRepository.getFollowedAuthors(user.id);
      
      // Personalized algorithm weights
      // 50% from followed authors
      // 30% from followed tags
      // 20% trending
      
      final batchSize = (AppConstants.defaultPageSize * 1.5).ceil();
      
      // Get articles from followed authors (50%)
      final fromAuthors = followedAuthors.isNotEmpty
          ? await _articleRepository.getArticles(
              limit: (batchSize * 0.5).ceil(),
              offset: 0,
              authorIds: followedAuthors.map((u) => u.id).toList(),
              orderBy: 'published_at',
              orderDirection: 'desc',
            )
          : [];
      
      // Get articles from followed tags (30%)
      final fromTags = followedTags.isNotEmpty
          ? await _articleRepository.getArticlesByTags(
              followedTags.map((t) => t.id).toList(),
              limit: (batchSize * 0.3).ceil(),
              offset: 0,
            )
          : [];
      
      // Get trending articles (20%)
      final trending = await _getTrendingArticles();
      
      // Combine and deduplicate
      final allArticles = [...fromAuthors, ...fromTags, ...trending];
      final uniqueArticles = _removeDuplicates(allArticles);
      
      // Sort by published date (newest first)
      uniqueArticles.sort((a, b) => 
        b.publishedAt?.compareTo(a.publishedAt ?? DateTime(1970)) ?? 1
      );
      
      return uniqueArticles.take(AppConstants.defaultPageSize).toList();
    } catch (e) {
      // Fallback to trending
      return await _getTrendingArticles();
    }
  }

  /// Remove duplicate articles
  List<ArticleModel> _removeDuplicates(List<ArticleModel> articles) {
    final seenIds = <String>{};
    return articles.where((article) => seenIds.add(article.id)).toList();
  }

  /// Load more articles
  Future<void> loadMore() async {
    _page++;
    await _loadFeed();
  }

  /// Refresh feed
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    await _loadFeed();
  }

  /// Load initial feed
  Future<void> loadInitial() async {
    await _loadFeed();
  }
}

/// Feed Provider
final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<ArticleModel>>>((ref) {
  final notifier = FeedNotifier(
    ref.read(articleRepositoryProvider),
    ref,
  );
  notifier.loadInitial();
  return notifier;
});

/// Feed Filter Provider
final feedFilterProvider = StateProvider<FeedFilter>((ref) => const FeedFilter());

/// Trending Articles Provider (standalone)
final trendingArticlesProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final repository = ref.read(articleRepositoryProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return await repository.getArticles(
    limit: AppConstants.defaultPageSize,
    offset: 0,
    orderBy: 'claps_count',
    orderDirection: 'desc',
    startDate: sevenDaysAgo,
  );
});

/// Latest Articles Provider (standalone)
final latestArticlesProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final repository = ref.read(articleRepositoryProvider);
  
  return await repository.getArticles(
    limit: AppConstants.defaultPageSize,
    offset: 0,
    orderBy: 'published_at',
    orderDirection: 'desc',
  );
});

/// Extension methods for ArticleRepository
class ArticleRepository {
  final SupabaseClient _supabase;

  ArticleRepository(this._supabase);

  Future<List<ArticleModel>> getArticles({
    int limit = 20,
    int offset = 0,
    String? orderBy,
    String? orderDirection,
    DateTime? startDate,
    DateTime? endDate,
    String? tag,
    String? searchQuery,
    List<String>? authorIds,
  }) async {
    try {
      var query = _supabase
          .from('articles')
          .select('*, author:users(*)')
          .limit(limit)
          .offset(offset);

      if (orderBy != null) {
        query = query.order(orderBy, ascending: orderDirection == 'asc');
      }

      if (startDate != null) {
        query = query.gte('published_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('published_at', endDate.toIso8601String());
      }

      if (tag != null) {
        // Filter by tag
        final tagResponse = await _supabase
            .from('article_tags')
            .select('article_id')
            .eq('tag_id', tag);
        
        final articleIds = (tagResponse as List)
            .map((json) => json['article_id'] as String)
            .toList();
        
        query = query.in_('id', articleIds);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('title,content,excerpt', searchQuery);
      }

      if (authorIds != null && authorIds.isNotEmpty) {
        query = query.in_('author_id', authorIds);
      }

      final response = await query;

      return (response as List)
          .map((json) => ArticleModel.fromSupabase(
            json,
            author: json['author'] != null 
                ? UserModel.fromSupabase(json['author'] as Map<String, dynamic>) 
                : null,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ArticleModel>> getArticlesByIds(List<String> ids, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('articles')
          .select('*, author:users(*)')
          .in_('id', ids)
          .limit(limit)
          .offset(offset);

      return (response as List)
          .map((json) => ArticleModel.fromSupabase(
            json,
            author: json['author'] != null 
                ? UserModel.fromSupabase(json['author'] as Map<String, dynamic>) 
                : null,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ArticleModel>> getArticlesByTags(List<String> tagIds, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('article_tags')
          .select('articles(*), users(*)')
          .in_('tag_id', tagIds)
          .limit(limit)
          .offset(offset);

      return (response as List)
          .map((json) => ArticleModel.fromSupabase(
            json['articles'] as Map<String, dynamic>,
            author: json['users'] != null 
                ? UserModel.fromSupabase(json['users'] as Map<String, dynamic>) 
                : null,
          ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getFollowedAuthors(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select('following:users(*)')
          .eq('follower_id', userId);

      return (response as List)
          .map((json) => UserModel.fromSupabase(json['following'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getBookmarkedArticleIds(String userId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select('article_id')
          .eq('user_id', userId);

      return (response as List)
          .map((json) => json['article_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
