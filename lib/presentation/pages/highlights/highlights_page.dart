import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/user_highlight_model.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/highlight_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class HighlightsPage extends ConsumerWidget {
  const HighlightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final highlightsAsync = ref.watch(userHighlightsProvider);

    if (user == null) {
      return MainLayout(
        title: 'My Highlights',
        child: AppEmptyState(
          icon: Icons.bookmark_border,
          title: 'Sign In Required',
          message: 'Please sign in to view your highlights',
          action: AppButton(
            text: 'Sign In',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
    }

    return MainLayout(
      title: 'My Highlights',
      child: highlightsAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(userHighlightsProvider),
        ),
        data: (highlights) {
          if (highlights.isEmpty) {
            return AppEmptyState(
              icon: Icons.highlight_alt,
              title: 'No Highlights Yet',
              message: 'Start highlighting interesting text in articles to save them here',
              action: AppButtonSecondary(
                text: 'Browse Articles',
                onPressed: () => context.go('/'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final highlight = highlights[index];
              return _HighlightCard(highlight: highlight);
            },
          );
        },
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final HighlightModel highlight;

  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        key: ValueKey('highlight-${highlight.id}'),
        elevation: AppDimensions.cardElevation,
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: () {
            // TODO: Navigate to article with highlight focused
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight color indicator
                Container(
                  width: 24,
                  height: 4,
                  decoration: BoxDecoration(
                    color: highlight.colorValue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Highlighted text
                Text(
                  highlight.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Article info
                Row(
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      size: AppDimensions.iconSmall,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: AppDimensions.spacingXSmall),
                    Expanded(
                      child: Text(
                        'From: Article ${highlight.articleId.substring(0, 8)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                
                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: AppDimensions.iconSmall,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: AppDimensions.spacingXSmall),
                    Text(
                      highlight.createdAt?.format() ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to format date
extension on DateTime {
  String format() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).ceil()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).ceil()} months ago';
    } else {
      return '${(difference.inDays / 365).ceil()} years ago';
    }
  }
}
