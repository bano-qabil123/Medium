import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vibration/vibration.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/feed_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class FeedPage extends ConsumerStatefulWidget {
  final FeedType initialFeedType;

  const FeedPage({
    super.key,
    this.initialFeedType = FeedType.personal,
  });

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late FeedType _currentFeedType;

  @override
  void initState() {
    super.initState();
    _currentFeedType = widget.initialFeedType;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).setFilter(
        FeedFilter(type: _currentFeedType),
      );
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _setFeedType(FeedType type) {
    setState(() => _currentFeedType = type);
    ref.read(feedProvider.notifier).setFilter(
      FeedFilter(type: type),
    );
  }

  Future<void> _onRefresh() async {
    // Trigger haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50, amplitude: 64);
    }
    
    await ref.read(feedProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await ref.read(feedProvider.notifier).loadMore();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(feedProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MainLayout(
      title: _getTitle(_currentFeedType),
      showBackButton: true,
      actions: [
        PopupMenuButton<FeedType>(
          icon: const Icon(Icons.filter_list_outlined),
          onSelected: _setFeedType,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: FeedType.personal,
              child: Text('Personalized'),
            ),
            const PopupMenuItem(
              value: FeedType.trending,
              child: Text('Trending'),
            ),
            const PopupMenuItem(
              value: FeedType.latest,
              child: Text('Latest'),
            ),
            if (isAuthenticated) ...[
              const PopupMenuItem(
                value: FeedType.following,
                child: Text('Following'),
              ),
              const PopupMenuItem(
                value: FeedType.bookmarks,
                child: Text('Bookmarks'),
              ),
            ],
          ],
        ),
      ],
      floatingActionButton: isAuthenticated
          ? FloatingActionButton(
              onPressed: () => context.push('/article/editor'),
              child: const Icon(Icons.add),
            )
          : null,
      child: Column(
        children: [
          // Feed type tabs
          _buildFeedTabs(),
          
          // Articles list
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const MaterialClassicHeader(),
              footer: const ClassicFooter(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: articlesAsync.when(
                loading: () => const Center(child: AppLoading()),
                error: (error, stack) => AppEmptyStateError(
                  message: error.toString(),
                  onRetry: _onRefresh,
                ),
                data: (articles) {
                  if (articles.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.article_outlined,
                      title: 'No Articles',
                      message: _getEmptyMessage(_currentFeedType),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    itemCount: articles.length + 
                        (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == articles.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Center(child: AppLoadingSmall()),
                        );
                      }

                      return RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMedium,
                          ),
                          child: ArticleCard(
                            key: ValueKey('feed-${articles[index].id}'),
                            article: articles[index],
                            onTap: () => context.push('/article/${articles[index].id}'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTabs() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Row(
          children: [
            _buildTab(FeedType.personal, 'For You'),
            const SizedBox(width: AppDimensions.spacingSmall),
            _buildTab(FeedType.trending, 'Trending'),
            const SizedBox(width: AppDimensions.spacingSmall),
            _buildTab(FeedType.latest, 'Latest'),
            if (ref.watch(isAuthenticatedProvider)) ...[
              const SizedBox(width: AppDimensions.spacingSmall),
              _buildTab(FeedType.following, 'Following'),
              const SizedBox(width: AppDimensions.spacingSmall),
              _buildTab(FeedType.bookmarks, 'Bookmarks'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTab(FeedType type, String label) {
    final isSelected = _currentFeedType == type;

    return GestureDetector(
      onTap: () => _setFeedType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getTitle(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return 'For You';
      case FeedType.trending:
        return 'Trending';
      case FeedType.latest:
        return 'Latest';
      case FeedType.following:
        return 'Following';
      case FeedType.bookmarks:
        return 'Bookmarks';
    }
  }

  String _getEmptyMessage(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return 'No articles to show. Try following some writers or tags.';
      case FeedType.trending:
        return 'No trending articles yet.';
      case FeedType.latest:
        return 'No new articles yet.';
      case FeedType.following:
        return 'No articles from followed writers. Start following some writers!';
      case FeedType.bookmarks:
        return 'No bookmarked articles. Save articles to read later!';
    }
  }
}
