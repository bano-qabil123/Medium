import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/comment_model.dart';
import '../../providers/comment_provider.dart';
import '../common/app_avatar.dart';
import '../common/app_divider.dart';

/// Optimized comment card with RepaintBoundary
class CommentCard extends ConsumerWidget {
  final CommentModel comment;
  final bool showActions;
  final VoidCallback? onLikePressed;
  final VoidCallback? onReplyPressed;
  final VoidCallback? onAuthorPressed;
  
  const CommentCard({
    super.key,
    required this.comment,
    this.showActions = true,
    this.onLikePressed,
    this.onReplyPressed,
    this.onAuthorPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use RepaintBoundary to isolate comment repaints
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            _buildAuthorInfo(context),
            
            const SizedBox(height: 12),
            
            // Content
            Text(
              comment.content,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Actions
            if (showActions) _buildActions(context, ref),
            
            // Replies
            if (comment.hasReplies)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16 + 32 + 8, // avatar + spacing + padding
                  top: 16,
                ),
                child: _buildReplies(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onAuthorPressed ?? () {
            if (comment.user?.username != null) {
              context.push('/profile/${comment.user!.username}');
            }
          },
          child: AppAvatarSmall(
            imageUrl: comment.user?.avatarUrl,
            name: comment.user?.fullName,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.user?.fullName ?? 'Unknown User',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                comment.createdAt?.formatRelative() ?? '',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        if (showActions)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show comment menu
            },
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            splashRadius: 20,
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onLikePressed ?? () {
            ref.read(commentControllerProvider.notifier).likeComment(comment.id);
          },
          icon: Icon(
            comment.isLiked ? Icons.favorite : Icons.favorite_outline,
            size: 16,
            color: comment.isLiked ? AppColors.error : AppColors.grey,
          ),
          label: Text(
            comment.isLiked ? 'Liked' : 'Like',
            style: AppTypography.bodySmall.copyWith(
              color: comment.isLiked ? AppColors.error : AppColors.grey,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: onReplyPressed,
          icon: Icon(
            Icons.reply_outlined,
            size: 16,
            color: AppColors.grey,
          ),
          label: Text(
            'Reply',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.grey,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildReplies(BuildContext context) {
    return Column(
      children: comment.replies
          .map((reply) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CommentCard(
                  key: ValueKey(reply.id),
                  comment: reply,
                  showActions: true,
                ),
              ))
          .toList(),
    );
  }
}
