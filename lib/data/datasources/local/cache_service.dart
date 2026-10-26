import 'package:hive_flutter/hive_flutter.dart';
import 'package:medium_clone/data/datasources/local/article_cache.dart';
import 'package:medium_clone/data/datasources/local/user_cache.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/models/user_model.dart';

/// Service to manage all local caching
class CacheService {
  /// Initialize all caches
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ArticleModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    
    // Initialize caches
    await articleCache.init();
    await userCache.init();
  }

  /// Close all caches
  static Future<void> close() async {
    await articleCache.close();
    await userCache.close();
  }

  /// Clear all caches
  static Future<void> clearAll() async {
    await articleCache.clearAll();
    await userCache.clearAll();
  }

  /// Save article and author to cache
  static Future<void> cacheArticleWithAuthor(ArticleModel article, UserModel? author) async {
    await articleCache.saveArticle(article);
    if (author != null) {
      await userCache.saveUser(author);
    }
  }

  /// Get article from cache with author
  static ArticleModel? getCachedArticleWithAuthor(String articleId) {
    final article = articleCache.getArticle(articleId);
    if (article == null) return null;
    
    // Try to get author from cache
    final author = userCache.getUser(article.authorId);
    return article.copyWith(author: author);
  }

  /// Cache multiple articles
  static Future<void> cacheArticles(List<ArticleModel> articles) async {
    for (final article in articles) {
      await articleCache.saveArticle(article);
      if (article.author != null) {
        await userCache.saveUser(article.author!);
      }
    }
  }

  /// Get cached articles for user
  static List<ArticleModel> getCachedArticlesForUser(String userId) {
    final allArticles = articleCache.getAllArticles();
    return allArticles.where((article) => article.authorId == userId).toList();
  }

  /// Get cached articles by tag
  static List<ArticleModel> getCachedArticlesByTag(String tag) {
    final allArticles = articleCache.getAllArticles();
    return allArticles.where((article) => article.tags.contains(tag)).toList();
  }

  /// Check if we have cached data
  static bool hasCachedData() {
    return articleCache.getArticleCount() > 0 || userCache.getUserCount() > 0;
  }

  /// Get cache stats
  static Map<String, int> getCacheStats() {
    return {
      'articles': articleCache.getArticleCount(),
      'users': userCache.getUserCount(),
    };
  }
}
