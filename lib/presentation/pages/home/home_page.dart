import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../providers/auth_provider.dart';
import '../../providers/article_provider.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/article/article_card.dart';
import '../../widgets/layout/main_layout.dart';
import '../../routes/app_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(articlesFeedProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await ref.read(articlesFeedProvider.notifier).loadMore();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(articlesFeedProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    return MainLayout(
      title: 'Medium Clone',
      showSearch: true,
      onSearchPressed: () {
        // TODO: Navigate to search
      },
      onNotificationPressed: () {
        // TODO: Navigate to notifications
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.articleEditor),
        child: const Icon(Icons.add),
      ),
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
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
              return AppEmptyStateNoArticles(
                isCurrentUser: true,
                onCreateArticle: () => context.push(AppRoutes.articleEditor),
              );
            }
            
            // Use ListView.builder for smooth scrolling
            // itemExtent is not used because articles have variable heights
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length + (ref.read(articlesFeedProvider.notifier).hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  // Loading indicator at bottom
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: AppLoadingSmall()),
                  );
                }
                
                // Use RepaintBoundary to isolate article card repaints
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ArticleCard(
                      key: ValueKey(articles[index].id),
                      article: articles[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
