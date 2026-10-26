import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/bookmark_model.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/bookmark_provider.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_card.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final bookmarksAsync = ref.watch(bookmarkProvider);

    if (user == null) {
      return MainLayout(
        title: 'My Bookmarks',
        child: AppEmptyState(
          icon: Icons.bookmark_border,
          title: 'Sign In Required',
          message: 'Please sign in to view your bookmarks',
          action: AppButton(
            text: 'Sign In',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
    }

    return MainLayout(
      title: 'My Bookmarks',
      child: bookmarksAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(bookmarkProvider),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return AppEmptyState(
              icon: Icons.bookmark_border,
              title: 'No Bookmarks Yet',
              message: 'Start saving articles to read later by tapping the bookmark icon',
              action: AppButtonSecondary(
                text: 'Browse Articles',
                onPressed: () => context.go('/'),
              ),
            );
          }

          return _BookmarksList(bookmarks: bookmarks);
        },
      ),
    );
  }
}

class _BookmarksList extends ConsumerWidget {
  final List<BookmarkModel> bookmarks;

  const _BookmarksList({required this.bookmarks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sort by created date (newest first)
    final sortedBookmarks = [...bookmarks]..sort((a, b) => 
      b.createdAt?.compareTo(a.createdAt ?? DateTime(1970)) ?? 1
    );

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: sortedBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = sortedBookmarks[index];
        return _BookmarkCard(bookmark: bookmark);
      },
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  final BookmarkModel bookmark;

  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(bookmark.articleId));

    return articleAsync.when(
      loading: () => const AppCardShimmer(),
      error: (error, stack) => AppCard(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Article not found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            AppButtonSecondary(
              text: 'Remove Bookmark',
              onPressed: () => _removeBookmark(context, ref),
            ),
          ],
        ),
      ),
      data: (article) => ArticleCard(
        key: ValueKey('bookmarked-${bookmark.articleId}'),
        article: article.copyWith(isBookmarked: true),
        showActions: true,
        onTap: () => context.push('/article/${article.id}'),
      ),
    );
  }

  void _removeBookmark(BuildContext context, WidgetRef ref) {
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
    bookmarkNotifier.toggleBookmark(bookmark.articleId);
  }
}

class AppCardShimmer extends StatelessWidget {
  const AppCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Container(
            width: double.infinity * 0.8,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXSmall),
          Container(
            width: double.infinity * 0.6,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
        ],
      ),
    );
  }
}
