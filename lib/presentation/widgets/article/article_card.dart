import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_badge.dart';
import 'package:medium_clone/presentation/widgets/common/app_card.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final bool showAuthor;
  final bool showExcerpt;
  final bool showStats;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onAuthorPressed;
  
  const ArticleCard({
    super.key,
    required this.article,
    this.showAuthor = true,
    this.showExcerpt = true,
    this.showStats = true,
    this.showActions = true,
    this.onTap,
    this.onLikePressed,
    this.onBookmarkPressed,
    this.onAuthorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasBorder: true,
      onTap: onTap ?? () => context.push('/article/${article.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          if (article.hasCoverImage) ...[
            _buildCoverImage(context),
            const SizedBox(height: AppDimensions.spacingMedium),
          ],
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                if (article.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: AppDimensions.spacingSmall,
                    runSpacing: AppDimensions.spacingSmall,
                    children: article.tags
                        .take(3)
                        .map((tag) => AppChip(
                              label: tag,
                              backgroundColor: AppColors.primaryLight,
                              labelColor: AppColors.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
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
                
                const SizedBox(height: AppDimensions.spacingSmall),
                
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
                  const SizedBox(height: AppDimensions.spacingMedium),
                ],
                
                // Author and Stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showAuthor && article.author != null) ...[
                      GestureDetector(
                        onTap: onAuthorPressed ?? () => context.push('/profile/${article.author!.username}'),
                        child: Row(
                          children: [
                            AppAvatarSmall(
                              imageUrl: article.author!.avatarUrl,
                              name: article.author!.fullName,
                            ),
                            const SizedBox(width: AppDimensions.spacingSmall),
                            Text(
                              article.author!.fullName,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                    ],
                    
                    if (showStats) ...[
                      _buildStat(Icons.access_time, '${article.readTimeMinutes} min read'),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      _buildStat(Icons.remove_red_eye_outlined, Helpers.formatShortNumber(article.views)),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      _buildStat(Icons.favorite_outline, Helpers.formatShortNumber(article.likesCount)),
                    ],
                  ],
                ),
                
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Date
                Text(
                  article.publishedAt?.formatRelative() ?? article.createdAt?.formatRelative() ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                
                if (showActions) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  const AppDivider(),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: article.isLiked ? Icons.favorite : Icons.favorite_outline,
                        label: article.isLiked ? 'Liked' : 'Like',
                        count: article.likesCount,
                        onPressed: onLikePressed,
                        color: article.isLiked ? AppColors.error : null,
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      _buildActionButton(
                        icon: article.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        label: article.isBookmarked ? 'Saved' : 'Save',
                        onPressed: onBookmarkPressed,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusMedium),
      ),
      child: Image.network(
        article.coverImage,
        width: double.infinity,
        height: AppDimensions.coverImageHeight,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: AppDimensions.coverImageHeight,
            color: AppColors.greyLight,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: AppDimensions.coverImageHeight,
          color: AppColors.greyLight,
          child: const Center(
            child: Icon(Icons.error, color: AppColors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXSmall,
          color: AppColors.grey,
        ),
        const SizedBox(width: AppDimensions.spacingXSmall),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? count,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color ?? AppColors.grey,
        size: AppDimensions.iconSmall,
      ),
      label: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color ?? AppColors.grey,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall,
        ),
      ),
    );
  }
}

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
      article: article,
      showExcerpt: false,
      showStats: false,
      showActions: false,
      onTap: onTap,
    );
  }
}

class ArticleCardList extends StatelessWidget {
  final List<ArticleModel> articles;
  final bool showAuthor;
  final bool showExcerpt;
  final bool showStats;
  final bool showActions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? itemPadding;
  
  const ArticleCardList({
    super.key,
    required this.articles,
    this.showAuthor = true,
    this.showExcerpt = true,
    this.showStats = true,
    this.showActions = true,
    this.padding,
    this.itemPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spacingMedium),
        itemBuilder: (context, index) => ArticleCard(
          article: articles[index],
          showAuthor: showAuthor,
          showExcerpt: showExcerpt,
          showStats: showStats,
          showActions: showActions,
        ),
      ),
    );
  }
}
