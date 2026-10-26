import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/datasources/local/cache_service.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';

/// Offline mode provider
final isOfflineProvider = StateProvider<bool>((ref) => false);

/// Offline articles provider
final offlineArticlesProvider = Provider<List<ArticleModel>>((ref) {
  return CacheService.getAllArticles();
});

/// Offline mode notifier
class OfflineNotifier extends StateNotifier<bool> {
  OfflineNotifier() : super(false);

  void setOffline(bool isOffline) {
    state = isOffline;
  }

  void toggle() {
    state = !state;
  }
}

/// Offline provider
final offlineProvider = StateNotifierProvider<OfflineNotifier, bool>((ref) {
  return OfflineNotifier();
});

/// Cache status provider
final cacheStatusProvider = Provider<Map<String, int>>((ref) {
  return CacheService.getCacheStats();
});

/// Cached article provider
final cachedArticleProvider = Provider.family<ArticleModel?, String>((ref, articleId) {
  return CacheService.getCachedArticleWithAuthor(articleId);
});

/// Sync service to keep cache updated
class SyncService {
  final Ref _ref;

  SyncService(this._ref);

  /// Sync articles from network to cache
  Future<void> syncArticles() async {
    try {
      // Get trending articles
      final trendingAsync = _ref.read(trendingArticlesProvider);
      final trendingIds = await trendingAsync.future;
      
      // Cache them
      for (final articleId in trendingIds) {
        final articleAsync = _ref.read(articleDetailProvider(articleId));
        final article = await articleAsync.future;
        if (article != null) {
          await CacheService.cacheArticleWithAuthor(article, article.author);
        }
      }
    } catch (e) {
      // Silently fail - we don't want to show errors during sync
    }
  }

  /// Sync user's articles
  Future<void> syncUserArticles(String userId) async {
    try {
      // Get user articles
      final userArticlesAsync = _ref.read(userArticlesProvider(userId));
      final articles = await userArticlesAsync.future;
      
      // Cache them
      await CacheService.cacheArticles(articles);
    } catch (e) {
      // Silently fail
    }
  }

  /// Sync followed tags articles
  Future<void> syncFollowedTags() async {
    try {
      // Get followed tags
      final followedTagsAsync = _ref.read(followedTagsProvider);
      final tags = await followedTagsAsync.future;
      
      // Get articles for each tag
      for (final tag in tags) {
        final articlesAsync = _ref.read(articleTagsProvider(tag.id));
        final articleIds = await articlesAsync.future;
        
        for (final articleId in articleIds) {
          final articleAsync = _ref.read(articleDetailProvider(articleId));
          final article = await articleAsync.future;
          if (article != null) {
            await CacheService.cacheArticleWithAuthor(article, article.author);
          }
        }
      }
    } catch (e) {
      // Silently fail
    }
  }
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

/// Auto-sync on app start
final autoSyncProvider = FutureProvider<void>((ref) async {
  final syncService = ref.read(syncServiceProvider);
  
  // Only sync if we have network
  final isOffline = ref.read(isOfflineProvider);
  if (!isOffline) {
    await syncService.syncArticles();
  }
});
