import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/article_model.dart';
import '../../providers/article_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/layout/main_layout.dart';
import '../../widgets/comment/comment_section.dart';

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
    // Pre-load article data
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
      actions: const [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: null, // TODO: Show article menu
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
        // Use const constructors for Sliver widgets
        slivers: [
          // Article Header - Use SliverToBoxAdapter for non-scrolling content
          SliverToBoxAdapter(
            child: articleAsync.when(
              loading: () => const Center(child: AppLoading()),
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
              loading: () => const SizedBox(height: 400),
              error: (error, stack) => const SizedBox(),
              data: (article) => _buildArticleContent(context, article),
            ),
          ),
          
          // Comments Section
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
    // Use RepaintBoundary to isolate header repaints
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image with CachedNetworkImage
          if (article.hasCoverImage) ...[
            _buildCoverImage(article.coverImage),
            const SizedBox(height: 16),
          ],
          
          // Article Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                if (article.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: article.tags
                        .map((tag) => AppChip(
                              key: ValueKey('tag-$tag'),
                              label: tag,
                              backgroundColor: AppColors.primaryLight,
                              labelColor: AppColors.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Title
                Text(
                  article.title,
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Author Info
                _buildAuthorInfo(context, article),
                
                const SizedBox(height: 24),
                
                // Stats
                _buildStats(article),
                
                const SizedBox(height: 24),
                
                // Actions
                _buildActions(context, article),
                
                const SizedBox(height: 16),
                const AppDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: double.infinity,
        height: 250,
        color: AppColors.greyLight,
        child: const Center(child: AppLoadingSmall()),
      ),
      errorWidget: (context, url, error) => Container(
        width: double.infinity,
        height: 250,
        color: AppColors.greyLight,
        child: const Center(child: Icon(Icons.error, color: AppColors.grey)),
      ),
      fadeInImage: true,
      fadeInDuration: const Duration(milliseconds: 300),
      cacheKey: imageUrl,
    );
  }

  Widget _buildAuthorInfo(BuildContext context, ArticleModel article) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile/${article.author?.username}'),
          child: AppAvatar(
            key: ValueKey('author-${article.authorId}'),
            imageUrl: article.author?.avatarUrl,
            name: article.author?.fullName,
            size: 48,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ArticleModel article) {
    return Row(
      children: [
        _buildStat(Icons.access_time, '${article.readTimeMinutes} min read'),
        const SizedBox(width: 24),
        _buildStat(Icons.remove_red_eye_outlined, Helpers.formatShortNumber(article.views)),
        const SizedBox(width: 24),
        _buildStat(Icons.favorite_outline, Helpers.formatShortNumber(article.likesCount)),
      ],
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
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

  Widget _buildActions(BuildContext context, ArticleModel article) {
    return Row(
      children: [
        _buildActionButton(
          icon: article.isLiked ? Icons.favorite : Icons.favorite_outline,
          label: article.isLiked ? 'Liked' : 'Like',
          count: article.likesCount,
          isActive: article.isLiked,
          onPressed: () {
            ref.read(articleControllerProvider.notifier).likeArticle(article.id);
          },
        ),
        const SizedBox(width: 24),
        _buildActionButton(
          icon: article.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
          label: article.isBookmarked ? 'Saved' : 'Save',
          isActive: article.isBookmarked,
          onPressed: () {
            ref.read(articleControllerProvider.notifier).bookmarkArticle(article.id);
          },
        ),
        const SizedBox(width: 24),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onPressed: () {
            // TODO: Share article
          },
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
        size: 16,
      ),
      label: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: isActive ? AppColors.primary : AppColors.grey,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context, ArticleModel article) {
    // Use RepaintBoundary to isolate content repaints
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 24),
            ],
            
            // Content with Markdown
            _buildMarkdownContent(article.content),
            
            const SizedBox(height: 32),
            
            // Article Footer
            Column(
              children: [
                const AppDivider(),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 16),
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
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    return MarkdownBody(
      data: content,
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
        codeblockPadding: const EdgeInsets.all(8),
        codeblockDecoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquote: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSurface,
          borderLeft: BorderSide(color: AppColors.primary, width: 4),
          padding: const EdgeInsets.all(16),
        ),
        blockquotePadding: const EdgeInsets.all(16),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: uri.toString(),
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
            ),
          ),
        );
      },
    );
  }
}
