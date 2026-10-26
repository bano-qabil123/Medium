import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/core/utils/helpers.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/clap_provider.dart';
import 'package:medium_clone/presentation/providers/bookmark_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_divider.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

import 'package:medium_clone/presentation/widgets/article/clap_button.dart';
import 'package:medium_clone/presentation/widgets/article/bookmark_button.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  final String articleId;
  
  const ArticleDetailPage({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleDetailProvider(widget.articleId).future);
      // Load clap and bookmark status
      ref.read(clapProvider(widget.articleId));
      ref.read(articleBookmarkProvider(widget.articleId));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showAppBar) {
        setState(() => _showAppBar = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showAppBar) {
        setState(() => _showAppBar = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    final currentUser = ref.watch(currentUserProvider);
    
    return MainLayout(
      showBackButton: true,
      showAppBar: _showAppBar,
      actions: [
        IconButton(
          key: const ValueKey('article-menu-button'),
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showArticleMenu(context),
        ),
      ],
      floatingActionButton: currentUser != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingBookmarkButton(
                  key: ValueKey('bookmark-${widget.articleId}'),
                  articleId: widget.articleId,
                  size: 48,
                ),
                const SizedBox(width: 16),
                FloatingClapButton(
                  key: ValueKey('clap-${widget.articleId}'),
                  articleId: widget.articleId,
                  size: 56,
                ),
              ],
            )
          : FloatingClapButton(
              key: ValueKey('clap-${widget.articleId}'),
              articleId: widget.articleId,
              size: 56,
            ),
      child: articleAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, stack) => AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(articleDetailProvider(widget.articleId)),
        ),
        data: (article) => _buildContent(context, article),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticleModel article) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Article Header
        SliverToBoxAdapter(
          child: _buildArticleHeader(context, article),
        ),
        
        // Article Content
        SliverToBoxAdapter(
          child: _buildArticleContent(context, article),
        ),
        
        // Comments Section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.spacingMedium,
                ),
                child: Text(
                  'Comments (${article.commentsCount})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              // Navigation to comments page
              GestureDetector(
                onTap: () => context.push('/articles/${article.id}/comments'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View all comments',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const AppDivider(),
            ],
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildArticleHeader(BuildContext context, ArticleModel article) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          if (article.hasCoverImage) ...[
            _buildCoverImage(article.coverImage),
            const SizedBox(height: AppDimensions.spacingMedium),
          ],
          
          // Article Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
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
                              key: ValueKey('tag-$tag'),
                              label: tag,
                              backgroundColor: AppColors.primaryLight,
                              labelColor: AppColors.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                ],
                
                // Title with premium typography
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Author Info
                _buildAuthorInfo(context, article),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Stats with new metrics
                _buildStats(context, article),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Actions
                _buildActions(context, article),
                
                const SizedBox(height: AppDimensions.spacingMedium),
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
      key: ValueKey('cover-$imageUrl'),
      imageUrl: imageUrl,
      width: double.infinity,
      height: AppDimensions.coverImageHeight,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: double.infinity,
        height: AppDimensions.coverImageHeight,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Center(child: AppLoading()),
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
            size: AppDimensions.avatarSizeMedium,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.author?.fullName ?? 'Unknown Author',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                article.publishedAt?.format() ?? article.createdAt?.format() ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Follow button
        AppButtonSecondary(
          key: ValueKey('follow-${article.authorId}'),
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
    );
  }

  Widget _buildStats(BuildContext context, ArticleModel article) {
    return Row(
      children: [
        _buildStat(
          context,
          Icons.access_time,
          '${article.readTimeMinutes} min read',
        ),
        const SizedBox(width: AppDimensions.spacingLarge),
        _buildStat(
          context,
          Icons.remove_red_eye_outlined,
          Helpers.formatShortNumber(article.views),
        ),
        const SizedBox(width: AppDimensions.spacingLarge),
        // New claps count
        Consumer(
          builder: (context, ref, child) {
            final clapCount = ref.watch(clapCountProvider(article.id));
            return _buildStat(
              context,
              Icons.favorite_outline,
              Helpers.formatShortNumber(clapCount),
            );
          },
        ),
        const SizedBox(width: AppDimensions.spacingLarge),
        _buildStat(
          context,
          Icons.comment_outlined,
          Helpers.formatShortNumber(article.commentsCount),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.spacingXSmall),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ArticleModel article) {
    return Row(
      children: [
        // Clap button
        Consumer(
          builder: (context, ref, child) {
            final hasClapped = ref.watch(hasClappedProvider(article.id));
            final clapCount = ref.watch(clapCountProvider(article.id));
            
            return ClapButton(
              key: ValueKey('clap-btn-${article.id}'),
              articleId: article.id,
              showCount: true,
              size: AppDimensions.buttonHeightMedium,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              activeIconColor: AppColors.clapsColorHighlight,
              countColor: Theme.of(context).colorScheme.onSurface,
            );
          },
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        
        // Bookmark button
        BookmarkButton(
          key: ValueKey('bookmark-btn-${article.id}'),
          articleId: article.id,
          showText: false,
          iconSize: AppDimensions.iconMedium,
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          activeIconColor: AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        
        // Share button
        IconButton(
          key: const ValueKey('share-button'),
          icon: Icon(
            Icons.share_outlined,
            size: AppDimensions.iconMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () => _shareArticle(article),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(BuildContext context, ArticleModel article) {
    return RepaintBoundary(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Excerpt
              if (article.excerpt != null) ...[
                Text(
                  article.excerpt!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
              ],
              
              // Content with Markdown and premium typography
              _buildMarkdownContent(context, article.content),
              
              const SizedBox(height: AppDimensions.spacingXXLarge),
              
              // Article Footer
              _buildArticleFooter(context, article),
              
              const SizedBox(height: AppDimensions.spacingXXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ) ?? const TextStyle(),
        h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          height: 1.45,
        ) ?? const TextStyle(),
        h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ) ?? const TextStyle(),
        h4: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ) ?? const TextStyle(),
        h5: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ) ?? const TextStyle(),
        h6: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ) ?? const TextStyle(),
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.65,
        ) ?? const TextStyle(),
        strong: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle(),
        em: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontStyle: FontStyle.italic,
        ) ?? const TextStyle(),
        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          fontFamily: 'monospace',
        ) ?? const TextStyle(),
        codeblockPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        blockquote: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ) ?? const TextStyle(),
        blockquotePadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        blockquoteDecoration: BoxDecoration(
          border: Border.left(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        link: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ) ?? const TextStyle(),
        listItem: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.65,
        ) ?? const TextStyle(),
        horizontalRule: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        tableBorder: TableBorder.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        tableColumnWidth: const IntrinsicColumnWidth(),
        tablePadding: const EdgeInsets.all(AppDimensions.paddingSmall),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          // TODO: Open link
        }
      },
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLarge),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: CachedNetworkImage(
              key: ValueKey('markdown-img-${uri.toString()}'),
              imageUrl: uri.toString(),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(child: AppLoading()),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.error,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              fadeInImage: true,
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleFooter(BuildContext context, ArticleModel article) {
    return Column(
      children: [
        const AppDivider(),
        const SizedBox(height: AppDimensions.spacingLarge),
        Row(
          children: [
            Expanded(
              child: AppButtonSecondary(
                key: const ValueKey('like-button'),
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
                key: const ValueKey('follow-button'),
                text: 'Follow',
                onPressed: () {
                  // TODO: Follow author
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showArticleMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                context.pop();
                // TODO: Share article
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () {
                context.pop();
                // TODO: Report article
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copy link'),
              onTap: () {
                context.pop();
                // TODO: Copy link
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareArticle(ArticleModel article) {
    // TODO: Implement share functionality
    // Use share_plus package
  }
}

class Random {
  final _random = DateTime.now().millisecondsSinceEpoch;
  
  double nextDouble() {
    return ((_random + 1) % 1000) / 1000;
  }
  
  int nextInt(int max) {
    return (_random % max).abs();
  }
}
