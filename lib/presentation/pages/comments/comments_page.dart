import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/comment_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_bar.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/comments/comment_input.dart';
import 'package:medium_clone/presentation/widgets/comments/comment_list.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final String articleId;
  
  const CommentsPage({
    super.key,
    required this.articleId,
  });
  
  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  String? _replyingToCommentId;
  String? _replyingToUser;
  
  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Comments',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Article info
          articleAsync.when(
            loading: () => const AppLoadingShimmer.articleCard(),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading article',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            data: (article) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (article.coverImageUrl != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(article.coverImageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${article.author?.fullName ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Comments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(commentsProvider(widget.articleId).notifier).refresh();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: CommentList(
                  articleId: widget.articleId,
                  onReplyPressed: () {
                    setState(() {
                      _replyingToCommentId = null;
                      _replyingToUser = null;
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Comment input
          CommentInput(
            articleId: widget.articleId,
            parentId: _replyingToCommentId,
            replyToUser: _replyingToUser,
            onSubmitted: () {
              setState(() {
                _replyingToCommentId = null;
                _replyingToUser = null;
              });
            },
            onCancelled: () {
              setState(() {
                _replyingToCommentId = null;
                _replyingToUser = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
