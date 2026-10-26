import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/comment_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/comments/comment_item.dart';

class CommentList extends ConsumerWidget {
  final String articleId;
  final bool showReplyInput;
  final String? parentId;
  final VoidCallback? onReplyPressed;
  
  const CommentList({
    super.key,
    required this.articleId,
    this.showReplyInput = true,
    this.parentId,
    this.onReplyPressed,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(articleId));
    final currentUserId = ref.watch(currentUserProvider)?.id;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments list
        commentsAsync.when(
          loading: () => const AppLoadingShimmer.list(),
          error: (error, stack) => AppEmptyState(
            icon: Icons.error_outline,
            title: 'Error loading comments',
            message: error.toString(),
            action: AppButton(
              text: 'Retry',
              onPressed: () => ref.read(commentsProvider(articleId).notifier).refresh(),
            ),
          ),
          data: (comments) {
            if (comments.isEmpty) {
              return AppEmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No comments yet',
                message: 'Be the first to comment on this article',
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final isCurrentUser = comment.userId == currentUserId;
                
                return CommentItem(
                  key: ValueKey('comment_${comment.id}'),
                  comment: comment,
                  showActions: true,
                  onReply: () => onReplyPressed?.call(),
                  onEdit: isCurrentUser 
                      ? () => _showEditDialog(context, ref, comment)
                      : null,
                  onDelete: isCurrentUser 
                      ? () => _showDeleteDialog(context, ref, comment.id)
                      : null,
                  onClap: () => ref.read(commentControllerProvider.notifier).clapComment(comment.id),
                );
              },
            );
          },
        ),
        
        // Load more indicator
        Consumer(
          builder: (context, ref, child) {
            final notifier = ref.read(commentsProvider(articleId).notifier);
            if (notifier.hasMore && !notifier.isLoading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AppButton(
                    text: 'Load more comments',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => notifier.loadMore(),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
  
  Future<void> _showEditDialog(
    BuildContext context, 
    WidgetRef ref, 
    CommentModel comment,
  ) async {
    final textController = TextEditingController(text: comment.content);
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your comment',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              
              try {
                await ref.read(commentControllerProvider.notifier).updateComment(
                  commentId: comment.id,
                  content: textController.text.trim(),
                );
                Navigator.of(context).pop();
                ref.read(commentsProvider(articleId).notifier).refresh();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showDeleteDialog(
    BuildContext context, 
    WidgetRef ref, 
    String commentId,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(commentControllerProvider.notifier).deleteComment(commentId);
                Navigator.of(context).pop();
                ref.read(commentsProvider(articleId).notifier).refresh();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
