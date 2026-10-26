import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/core/utils/helpers.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';
import 'package:medium_clone/presentation/widgets/article/clap_button.dart';
import 'package:medium_clone/presentation/widgets/article/bookmark_button.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final bool showAuthor;
  final bool showExcerpt;
  final bool showStats;
  final bool showActions;
  final VoidCallback? onTap;
  final bool usePremiumTypography;
  
  const ArticleCard({
    super.key,
    required this.article,
    this.showAuthor = true,
    this.showExcerpt = true,
    this.showStats = true,
    this.showActions = true,
    this.onTap,
    this.usePremiumTypography = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Card(
        key: ValueKey('article-card-${article.id}'),
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap ?? () => context.push('/article/${article.id}'),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image - Use CachedNetworkImage with better settings
              if (article.hasCoverImage) ...[
                _buildCoverImage(context),
                const SizedBox(height: AppDimensions.spacingMedium),
              ],
              
              // Content with premium typography
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: _buildContent(context),
              ),
              
              // Actions at bottom
              if (showActions) ...[
                const SizedBox(height: AppDimensions.spacingMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: _buildActions(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusMedium),
      ),
      child: CachedNetworkImage(
        key: ValueKey('cover-${article.coverImage}'),
        imageUrl: article.coverImage,
        width: double.infinity,
        height: AppDimensions.coverImageHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: AppDimensions.coverImageHeight,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: AppDimensions.iconXLarge,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: AppDimensions.coverImageHeight,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: AppDimensions.iconXLarge,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        fadeInImage: true,
        fadeInDuration: const Duration(milliseconds: 300),
        cacheKey: article.coverImage,
        maxHeightDiskCache: 300,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final titleStyle = usePremiumTypography
        ? Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          )
        : Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          );

    final bodyStyle = usePremiumTypography
        ? Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with premium typography
        Text(
          article.title,
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppDimensions.spacingSmall),
        
        // Excerpt
        if (showExcerpt && article.excerpt != null && article.excerpt!.isNotEmpty) ...[
          Text(
            article.excerpt!,
            style: bodyStyle?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
        ],
        
        // Stats and Author
        Row(
          children: [
            if (showAuthor && article.author != null) ...[
              AppAvatar(
                key: ValueKey('author-${article.authorId}'),
                imageUrl: article.author?.avatarUrl,
                name: article.author?.displayName,
                size: AppDimensions.avatarSizeSmall,
              ),
              const SizedBox(width: AppDimensions.spacingSmall),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name
                  if (showAuthor && article.author != null) ...[
                    Text(
                      article.author?.displayName ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Stats
                  if (showStats) ...[
                    const SizedBox(height: AppDimensions.spacingXSmall - 4),
                    Row(
                      children: [
                        Text(
                          Helpers.formatShortNumber(article.clapsCount),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingXSmall),
                        Text(
                          '${article.readTimeMinutes} min read',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spacingSmall),
        
        // Tags
        if (article.tags.isNotEmpty && showAuthor) ...[
          Wrap(
            spacing: AppDimensions.spacingXSmall,
            runSpacing: AppDimensions.spacingXSmall,
            children: article.tags
                .take(3)
                .map((tag) => AppChip(
                      key: ValueKey('tag-$tag'),
                      label: tag,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      onPressed: () => context.push('/tag/$tag'),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        ClapButton(
          key: ValueKey('clap-${article.id}'),
          articleId: article.id,
          showCount: true,
          size: AppDimensions.buttonHeightSmall,
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          activeIconColor: AppColors.clapsColorHighlight,
          countColor: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        BookmarkButton(
          key: ValueKey('bookmark-${article.id}'),
          articleId: article.id,
          showText: false,
          iconSize: AppDimensions.iconMedium,
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          activeIconColor: AppColors.primary,
        ),
      ],
    );
  }
}

/// Compact article card for lists
class ArticleCardCompact extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback? onTap;

  const ArticleCardCompact({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListTile(
        key: ValueKey('article-compact-${article.id}'),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingSmall),
        leading: article.hasCoverImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                child: CachedNetworkImage(
                  key: ValueKey('compact-cover-${article.coverImage}'),
                  imageUrl: article.coverImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Icon(Icons.image_outlined, size: 24),
                  ),
                  fadeInImage: true,
                  fadeInDuration: const Duration(milliseconds: 200),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                ),
                child: Center(
                  child: Icon(
                    Icons.article_outlined,
                    size: AppDimensions.iconMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
        title: Text(
          article.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.author?.displayName ?? 'Unknown',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  Helpers.formatShortNumber(article.clapsCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXSmall),
                Text(
                  '${article.readTimeMinutes} min read',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () => context.push('/article/${article.id}'),
      ),
    );
  }
}

/// Article card shimmer for loading states
class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: AppDimensions.articleImageHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Container(
            width: double.infinity * 0.8,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Container(
            width: double.infinity * 0.6,
            height: AppDimensions.buttonHeightSmall - 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Row(
            children: [
              Container(
                width: AppDimensions.avatarSizeSmall,
                height: AppDimensions.avatarSizeSmall,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall - 4),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
