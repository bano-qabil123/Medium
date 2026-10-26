import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/tag_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/tag_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class TagPage extends ConsumerWidget {
  final String tagId;
  final String tagName;

  const TagPage({
    super.key,
    required this.tagId,
    required this.tagName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagAsync = ref.watch(allTagsProvider);
    final articlesAsync = ref.watch(articleTagsProvider(tagId));

    return MainLayout(
      title: tagName,
      showBackButton: true,
      child: tagAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(allTagsProvider),
        ),
        data: (tags) {
          final tag = tags.firstWhere(
            (t) => t.id == tagId || t.slug == tagId || t.name.toLowerCase() == tagName.toLowerCase(),
            orElse: () => TagModel(id: tagId, name: tagName, slug: tagName.toLowerCase()),
          );

          return Column(
            children: [
              // Tag header
              _TagHeader(tag: tag),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Follow button
              _FollowTagButton(tagId: tag.id),
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Articles list
              Expanded(
                child: articlesAsync.when(
                  loading: () => const Center(child: AppLoading()),
                  error: (error, stack) => AppEmptyStateError(
                    message: error.toString(),
                    onRetry: () => ref.refresh(articleTagsProvider(tagId)),
                  ),
                  data: (articleIds) {
                    if (articleIds.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.article_outlined,
                        title: 'No Articles',
                        message: 'No articles have been tagged with ${tag.name} yet',
                      );
                    }

                    return _ArticlesList(articleIds: articleIds);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TagHeader extends StatelessWidget {
  final TagModel tag;

  const _TagHeader({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '#${tag.name}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (tag.description != null && tag.description!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            tag.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _FollowTagButton extends ConsumerWidget {
  final String tagId;

  const _FollowTagButton({required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = ref.watch(isFollowingTagProvider(tagId));
    final followNotifier = ref.read(tagFollowProvider(tagId).notifier);

    return AppButton(
      text: isFollowing ? 'Following' : 'Follow Tag',
      onPressed: () => followNotifier.toggleFollow(),
      backgroundColor: isFollowing ? AppColors.surfaceVariant : AppColors.primary,
      foregroundColor: isFollowing ? AppColors.onSurface : AppColors.onPrimary,
    );
  }
}

class _ArticlesList extends ConsumerWidget {
  final List<String> articleIds;

  const _ArticlesList({required this.articleIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: articleIds.length,
      itemBuilder: (context, index) {
        final articleId = articleIds[index];
        final articleAsync = ref.watch(articleDetailProvider(articleId));

        return articleAsync.when(
          loading: () => const ArticleCardShimmer(),
          error: (error, stack) => const SizedBox(),
          data: (article) => ArticleCard(
            key: ValueKey('tag-article-$articleId'),
            article: article,
            onTap: () => context.push('/article/$articleId'),
          ),
        );
      },
    );
  }
}

class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
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
