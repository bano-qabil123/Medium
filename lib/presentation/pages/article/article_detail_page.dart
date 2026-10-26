import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/core/utils/helpers.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/comment/comment_section.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  final String articleId;
  
  const ArticleDetailPage({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load article when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleDetailProvider(widget.articleId).future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    final currentUser = ref.watch(currentUserProvider);
    
    return MainLayout(
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show article menu
          },
        ),
      ],
      floatingActionButton: currentUser != null 
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Show comment input
              },
              child: const Icon(Icons.edit),
            )
          : null,
      child: CustomScrollView(
        slivers: [
          // Article Header
          SliverToBoxAdapter(
            child: articleAsync.when(
              loading: () => const AppLoading(),
              error: (error, stack) => AppEmptyStateError(
                message: error.toString(),
                onRetry: () => ref.refresh(articleDetailProvider(widget.articleId)),
              ),
              data: (article) => _buildArticleHeader(context, article),
            ),
          ),
          
          // Article Content
          SliverToBoxAdapter(
            child: articleAsync.when(
              loading: () => const SizedBox(height: 200),
              error: (error, stack) => const SizedBox(),
              data: (article) => _buildArticleContent(context, article),
            ),
          ),
          
          // Comments
          SliverToBoxAdapter(
            child: articleAsync.when(
              loading: () => const SizedBox(),
              error: (error, stack) => const SizedBox(),
              data: (article) => CommentSection(articleId: article.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleHeader(BuildContext context, ArticleModel article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image
        if (article.hasCoverImage) ...[
          Container(
            width: double.infinity,
            height: AppDimensions.coverImageHeight * 1.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(article.coverImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
        ],
        
        // Article Info
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
                      .map((tag) => AppChip(
                            label: tag,
                            backgroundColor: AppColors.primaryLight,
                            labelColor: AppColors.primary,
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
              ],
              
              // Title
              Text(
                article.title,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Author Info
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/profile/${article.author?.username}'),
                    child: Row(
                      children: [
                        AppAvatar(
                          imageUrl: article.author?.avatarUrl,
                          name: article.author?.fullName,
                          size: AppDimensions.avatarSizeMedium,
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.author?.fullName ?? 'Unknown Author',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              article.publishedAt?.format() ?? article.createdAt?.format() ?? '',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Follow button
                  AppButtonSecondary(
                    text: 'Follow',
                    onPressed: () {
                      // TODO: Follow author
                    },
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Stats
              Row(
                children: [
                  _buildStat(Icons.access_time, '${article.readTimeMinutes} min read'),
                  const SizedBox(width: AppDimensions.spacingLarge),
                  _buildStat(Icons.remove_red_eye_outlined, Helpers.formatShortNumber(article.views)),
                  const SizedBox(width: AppDimensions.spacingLarge),
                  _buildStat(Icons.favorite_outline, Helpers.formatShortNumber(article.likesCount)),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Actions
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_outline,
                    label: 'Like',
                    count: article.likesCount,
                    isActive: article.isLiked,
                    onPressed: () {
                      ref.read(articleControllerProvider.notifier).likeArticle(article.id);
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  _buildActionButton(
                    icon: Icons.bookmark_outline,
                    label: 'Save',
                    isActive: article.isBookmarked,
                    onPressed: () {
                      ref.read(articleControllerProvider.notifier).bookmarkArticle(article.id);
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: () {
                      // TODO: Share article
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingMedium),
              const AppDivider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(BuildContext context, ArticleModel article) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Excerpt
          if (article.excerpt != null) ...[
            Text(
              article.excerpt!,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],
          
          // Content
          MarkdownBody(
            data: article.content,
            styleSheet: MarkdownStyleSheet(
              h1: AppTypography.headlineLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              h2: AppTypography.headlineMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              h3: AppTypography.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              p: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                height: 1.6,
              ),
              strong: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              em: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                fontStyle: FontStyle.italic,
              ),
              code: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                backgroundColor: AppColors.greyLight,
                fontFamily: 'monospace',
              ),
              codeblockPadding: const EdgeInsets.all(AppDimensions.paddingSmall),
              codeblockDecoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              blockquote: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                borderLeft: BorderSide(color: AppColors.primary, width: 4),
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              ),
              blockquotePadding: const EdgeInsets.all(AppDimensions.paddingMedium),
              link: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              listItem: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                height: 1.6,
              ),
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                // TODO: Open link
              }
            },
            imageBuilder: (uri, title, alt) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Image.network(
                    uri.toString(),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 200,
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
                      height: 200,
                      color: AppColors.greyLight,
                      child: const Center(
                        child: Icon(Icons.error, color: AppColors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Article Footer
          Column(
            children: [
              const AppDivider(),
              const SizedBox(height: AppDimensions.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: AppButtonSecondary(
                      text: 'Like',
                      onPressed: () {
                        ref.read(articleControllerProvider.notifier).likeArticle(article.id);
                      },
                      leadingIcon: Icon(
                        article.isLiked ? Icons.favorite : Icons.favorite_outline,
                        color: article.isLiked ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: AppButton(
                      text: 'Follow',
                      onPressed: () {
                        // TODO: Follow author
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingXLarge),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
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
    bool isActive = false,
    VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.grey,
        size: AppDimensions.iconSmall,
      ),
      label: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: isActive ? AppColors.primary : AppColors.grey,
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
