import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/article_model.dart';
import '../common/app_avatar.dart';
import '../common/app_chip.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final bool showAuthor;
  final bool showExcerpt;
  final bool showStats;
  final bool showActions;
  
  const ArticleCard({
    super.key,
    required this.article,
    this.showAuthor = true,
    this.showExcerpt = true,
    this.showStats = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        child: InkWell(
          onTap: () => context.push('/article/${article.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image - Use CachedNetworkImage
              if (article.hasCoverImage) ...[
                _buildCoverImage(context),
                const SizedBox(height: 16),
              ],
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: article.coverImage,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 200,
          color: AppColors.greyLight,
          child: const Center(child: AppLoadingSmall()),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: 200,
          color: AppColors.greyLight,
          child: const Center(child: Icon(Icons.error, color: AppColors.grey)),
        ),
        fadeInImage: true,
        fadeInDuration: const Duration(milliseconds: 300),
        cacheKey: article.coverImage,
        maxHeightDiskCache: 300,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        if (article.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: article.tags
                .take(3)
                .map((tag) => AppChip(
                      key: ValueKey('tag-$tag'),
                      label: tag,
                      backgroundColor: AppColors.primaryLight,
                      labelColor: AppColors.primary,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        
        // Title
        Text(
          article.title,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 12),
        
        // Excerpt
        if (showExcerpt && article.excerpt != null) ...[
          Text(
            article.excerpt!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
        ],
        
        // Author and Stats
        _buildFooter(context),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showAuthor) ...[
          _buildAuthorInfo(context),
          const SizedBox(width: 16),
        ],
        
        if (showStats) ...[
          _buildStat(Icons.access_time, '${article.readTimeMinutes} min read'),
          const SizedBox(width: 16),
          _buildStat(Icons.remove_red_eye_outlined, Helpers.formatShortNumber(article.views)),
          const SizedBox(width: 16),
          _buildStat(Icons.favorite_outline, Helpers.formatShortNumber(article.likesCount)),
        ],
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      children: [
        AppAvatarSmall(
          imageUrl: article.author?.avatarUrl,
          name: article.author?.fullName,
        ),
        const SizedBox(width: 8),
        Text(
          article.author?.fullName ?? 'Unknown',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.grey,
          ),
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
    return ArticleCard(
      key: key,
      article: article,
      showExcerpt: false,
      showStats: false,
      showActions: false,
      onTap: onTap,
    );
  }
}

/// List of article cards with optimization
class ArticleCardList extends StatelessWidget {
  final List<ArticleModel> articles;
  final bool showAuthor;
  final bool showExcerpt;
  final bool showStats;
  final bool showActions;
  final EdgeInsetsGeometry? padding;
  
  const ArticleCardList({
    super.key,
    required this.articles,
    this.showAuthor = true,
    this.showExcerpt = true,
    this.showStats = true,
    this.showActions = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ArticleCard(
              key: ValueKey(articles[index].id),
              article: articles[index],
              showAuthor: showAuthor,
              showExcerpt: showExcerpt,
              showStats: showStats,
              showActions: showActions,
            ),
          ),
        );
      },
    );
  }
}
