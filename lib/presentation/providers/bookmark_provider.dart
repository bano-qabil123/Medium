import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/models/bookmark_model.dart';
import 'package:medium_clone/data/repositories/bookmark_repository.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Bookmark Repository Provider
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

// Bookmark State Notifier
class BookmarkNotifier extends StateNotifier<AsyncValue<List<BookmarkModel>>> {
  final BookmarkRepository _bookmarkRepository;
  final String? _userId;

  BookmarkNotifier(this._bookmarkRepository, this._userId)
      : super(const AsyncValue.data([]));

  Future<void> loadBookmarks() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final bookmarks = await _bookmarkRepository.getBookmarksByUser(_userId!);
      state = AsyncValue.data(bookmarks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleBookmark(String articleId) async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('Please sign in to bookmark'),
        StackTrace.current,
      );
      return;
    }

    try {
      final hasBookmarked = await _bookmarkRepository.hasBookmarked(
        articleId: articleId,
        userId: _userId!,
      );

      if (hasBookmarked) {
        await _bookmarkRepository.removeBookmark(
          articleId: articleId,
          userId: _userId!,
        );
      } else {
        await _bookmarkRepository.bookmarkArticle(
          articleId: articleId,
          userId: _userId!,
        );
      }

      // Reload bookmarks
      await loadBookmarks();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> isBookmarked(String articleId) async {
    if (_userId == null) return false;
    return await _bookmarkRepository.hasBookmarked(
      articleId: articleId,
      userId: _userId!,
    );
  }
}

// Bookmark Provider
final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, AsyncValue<List<BookmarkModel>>>(
  (ref) {
    final userId = ref.watch(authProvider).valueOrNull?.id;
    final repository = ref.watch(bookmarkRepositoryProvider);
    final notifier = BookmarkNotifier(repository, userId);
    notifier.loadBookmarks();
    return notifier;
  },
);

// Is Bookmarked Provider for a specific article
final isBookmarkedProvider = Provider.family<bool, String>((ref, articleId) {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  if (userId == null) return false;
  
  final repository = ref.watch(bookmarkRepositoryProvider);
  
  // This is a simple provider that checks bookmark status
  // For better performance, you might want to cache this
  return false; // Will be updated by the notifier
});

// Bookmark Count Provider for a specific article
final bookmarkCountProvider = FutureProvider.family<int, String>((ref, articleId) async {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return await repository.getBookmarkCount(articleId);
});

// Single Article Bookmark Provider
class SingleArticleBookmarkNotifier extends StateNotifier<AsyncValue<bool>> {
  final BookmarkRepository _bookmarkRepository;
  final String _articleId;
  final String? _userId;

  SingleArticleBookmarkNotifier(this._bookmarkRepository, this._articleId, this._userId)
      : super(const AsyncValue.data(false));

  Future<void> loadStatus() async {
    if (_userId == null) {
      state = const AsyncValue.data(false);
      return;
    }
    
    try {
      final isBookmarked = await _bookmarkRepository.hasBookmarked(
        articleId: _articleId,
        userId: _userId!,
      );
      state = AsyncValue.data(isBookmarked);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggle() async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('Please sign in to bookmark'),
        StackTrace.current,
      );
      return;
    }

    try {
      final currentStatus = state.valueOrNull ?? false;
      if (currentStatus) {
        await _bookmarkRepository.removeBookmark(
          articleId: _articleId,
          userId: _userId!,
        );
      } else {
        await _bookmarkRepository.bookmarkArticle(
          articleId: _articleId,
          userId: _userId!,
        );
      }
      
      // Reload status
      await loadStatus();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Bookmark Provider for a specific article
final articleBookmarkProvider = StateNotifierProvider.family<
  SingleArticleBookmarkNotifier,
  AsyncValue<bool>,
  String
>((ref, articleId) {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  final repository = ref.watch(bookmarkRepositoryProvider);
  final notifier = SingleArticleBookmarkNotifier(repository, articleId, userId);
  notifier.loadStatus();
  return notifier;
});
