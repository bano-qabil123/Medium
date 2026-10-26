import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/models/article_view_model.dart';
import 'package:medium_clone/data/repositories/article_view_repository.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Article View Repository Provider
final articleViewRepositoryProvider = Provider<ArticleViewRepository>((ref) {
  return ArticleViewRepository();
});

// Article View Notifier
class ArticleViewNotifier extends StateNotifier<AsyncValue<ArticleViewModel?>> {
  final ArticleViewRepository _repository;
  final String _articleId;
  final String? _userId;

  ArticleViewNotifier(this._repository, this._articleId, this._userId)
      : super(const AsyncValue.data(null));

  Future<void> trackView({String? referrer}) async {
    try {
      final view = await _repository.trackView(
        articleId: _articleId,
        userId: _userId,
        referrer: referrer,
      );
      state = AsyncValue.data(view);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<int> getViewCount() async {
    try {
      return await _repository.getViewCount(_articleId);
    } catch (e) {
      return 0;
    }
  }
}

// Article View Provider for a specific article
final articleViewProvider = StateNotifierProvider.family<
  ArticleViewNotifier,
  AsyncValue<ArticleViewModel?>,
  String
>((ref, articleId) {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  final repository = ref.watch(articleViewRepositoryProvider);
  final notifier = ArticleViewNotifier(repository, articleId, userId);
  
  // Track view when provider is created
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.trackView();
  });
  
  return notifier;
});

// View Count Provider for a specific article
final viewCountProvider = FutureProvider.family<int, String>((ref, articleId) async {
  final repository = ref.watch(articleViewRepositoryProvider);
  return await repository.getViewCount(articleId);
});

// Popular Articles Provider (most viewed)
final popularArticlesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(articleViewRepositoryProvider);
  final views = await repository.getPopularArticles(limit: 10);
  return views.map((v) => v.articleId).toList();
});

// Trending Articles Provider (most viewed in last 7 days)
final trendingArticlesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(articleViewRepositoryProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  
  // This would need to be implemented in the repository
  // For now, just return popular articles
  final views = await repository.getPopularArticles(limit: 10);
  return views.map((v) => v.articleId).toList();
});
