import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesFeedProvider);
    final authState = ref.watch(authControllerProvider);
    
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
        onPressed: () => context.push('/article/editor'),
        child: const Icon(Icons.add),
      ),
      child: RefreshIndicator(
        onRefresh: () => ref.read(articlesFeedProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feed',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            articlesAsync.when(
              loading: () => SliverFillRemaining(
                child: Center(
                  child: AppLoading(label: 'Loading articles...'),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: AppEmptyStateError(
                  message: error.toString(),
                  onRetry: () => ref.read(articlesFeedProvider.notifier).refresh(),
                ),
              ),
              data: (articles) {
                if (articles.isEmpty) {
                  return SliverFillRemaining(
                    child: AppEmptyStateNoArticles(
                      isCurrentUser: false,
                      onCreateArticle: () => context.push('/article/editor'),
                    ),
                  );
                }
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = articles[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == articles.length - 1 
                              ? AppDimensions.paddingLarge 
                              : AppDimensions.paddingMedium,
                        ),
                        child: ArticleCard(article: article),
                      );
                    },
                    childCount: articles.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
