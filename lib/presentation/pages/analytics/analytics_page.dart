import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/analytics_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final analyticsAsync = ref.watch(userAnalyticsProvider);

    if (user == null) {
      return MainLayout(
        title: 'Analytics',
        child: AppEmptyState(
          icon: Icons.analytics_outlined,
          title: 'Sign In Required',
          message: 'Please sign in to view your analytics',
          action: AppButton(
            text: 'Sign In',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
    }

    return MainLayout(
      title: 'Analytics',
      showBackButton: true,
      child: analyticsAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(userAnalyticsProvider),
        ),
        data: (analytics) => _buildAnalyticsContent(context, analytics),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, UserAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewCards(context, analytics),
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Stats Overview
          Text(
            'Your Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Article List
          _buildArticleList(context, analytics.articles),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Views Over Time Chart
          _buildViewsChart(context, analytics.viewsOverTime),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Top Articles
          Text(
            'Top Articles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          _buildTopArticles(context, analytics.topArticles),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, UserAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.article_outlined,
            value: analytics.totalArticles,
            label: 'Total Articles',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.remove_red_eye_outlined,
            value: analytics.totalViews,
            label: 'Total Views',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    int value,
    String label,
    Color color,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconLarge,
              color: color,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              value.formatNumber(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleList(BuildContext context, List<ArticleModel> articles) {
    if (articles.isEmpty) {
      return AppEmptyState(
        icon: Icons.article_outlined,
        title: 'No Articles Yet',
        message: 'Your articles will appear here once published',
        showIcon: false,
      );
    }

    return Column(
      children: articles.map((article) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
        child: _ArticleAnalyticsCard(article: article),
      )).toList(),
    );
  }

  Widget _buildViewsChart(BuildContext context, Map<String, int> viewsOverTime) {
    if (viewsOverTime.isEmpty) {
      return AppEmptyState(
        icon: Icons.analytics_outlined,
        title: 'No Data Yet',
        message: 'Views data will appear here once you have traffic',
        showIcon: false,
      );
    }

    // For now, just display the data as a simple bar chart
    // In production, use charts_flutter package for better visualization
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Views Over Time',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewsOverTime.entries.map((entry) {
                  final date = entry.key;
                  final views = entry.value;
                  final maxViews = viewsOverTime.values.reduce((a, b) => a > b ? a : b);
                  final height = (views / maxViews) * 150;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXSmall,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppDimensions.spacingXSmall),
                        Container(
                          width: 40,
                          height: height,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXSmall),
                        Text(
                          views.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopArticles(BuildContext context, List<ArticleModel> articles) {
    if (articles.isEmpty) {
      return AppEmptyState(
        icon: Icons.trending_up,
        title: 'No Top Articles Yet',
        message: 'Your most popular articles will appear here',
        showIcon: false,
      );
    }

    return Column(
      children: articles.asMap().entries.map((entry) {
        final index = entry.key;
        final article = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor(index),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              
              // Article info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${article.views} views • ${article.clapsCount} claps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.warning; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.orange[700]!; // Bronze
      default:
        return AppColors.primary;
    }
  }
}

class _ArticleAnalyticsCard extends StatelessWidget {
  final ArticleModel article;

  const _ArticleAnalyticsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Row(
                    children: [
                      _buildMiniStat(context, Icons.remove_red_eye_outlined, article.views),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      _buildMiniStat(context, Icons.favorite_outline, article.clapsCount),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      _buildMiniStat(context, Icons.comment_outlined, article.commentsCount),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingXSmall - 4),
        Text(
          value.formatNumber(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// Analytics model
class UserAnalytics {
  final int totalArticles;
  final int totalViews;
  final int totalClaps;
  final List<ArticleModel> articles;
  final List<ArticleModel> topArticles;
  final Map<String, int> viewsOverTime;

  const UserAnalytics({
    this.totalArticles = 0,
    this.totalViews = 0,
    this.totalClaps = 0,
    this.articles = const [],
    this.topArticles = const [],
    this.viewsOverTime = const {},
  });
}

// Extension for number formatting
extension on int {
  String formatNumber() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

// Analytics provider
final userAnalyticsProvider = FutureProvider<UserAnalytics>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.read(articleRepositoryProvider);
  
  // Get user articles
  final articles = await repository.getUserArticles(userId: user.id);
  
  // Calculate totals
  final totalViews = articles.fold<int>(0, (sum, article) => sum + article.views);
  final totalClaps = articles.fold<int>(0, (sum, article) => sum + article.clapsCount);
  
  // Sort by views (top articles)
  final topArticles = [...articles]..sort((a, b) => b.views.compareTo(a.views));
  
  // Get views over time (last 30 days)
  final viewsOverTime = _calculateViewsOverTime(articles);

  return UserAnalytics(
    totalArticles: articles.length,
    totalViews: totalViews,
    totalClaps: totalClaps,
    articles: articles,
    topArticles: topArticles.take(5).toList(),
    viewsOverTime: viewsOverTime,
  );
});

Map<String, int> _calculateViewsOverTime(List<ArticleModel> articles) {
  final Map<String, int> viewsByDay = {};
  final now = DateTime.now();
  
  for (int i = 29; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = '${date.month}/${date.day}';
    viewsByDay[dateStr] = 0;
  }
  
  // Add article views to the appropriate days
  for (final article in articles) {
    if (article.createdAt == null) continue;
    
    final daysAgo = now.difference(article.createdAt!).inDays;
    if (daysAgo <= 29) {
      final date = now.subtract(Duration(days: daysAgo));
      final dateStr = '${date.month}/${date.day}';
      viewsByDay[dateStr] = (viewsByDay[dateStr] ?? 0) + article.views;
    }
  }
  
  return viewsByDay;
}
