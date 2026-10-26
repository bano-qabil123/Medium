import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/data/models/comment_model.dart';
import 'package:medium_clone/presentation/providers/comment_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: BorderSide(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
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
              const SizedBox(width: AppDimensions.spacingSmall),
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
                ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingSmall),
          
          // Content
          Text(
            comment.content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacingSmall),
          
          // Actions
          if (showActions)
            Row(
              children: [
                TextButton.icon(
                  onPressed: onLikePressed ?? () {
                    ref.read(commentControllerProvider.notifier).likeComment(comment.id);
                  },
                  icon: Icon(
                    comment.isLiked ? Icons.favorite : Icons.favorite_outline,
                    size: AppDimensions.iconSmall,
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
                      horizontal: AppDimensions.paddingXSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                TextButton.icon(
                  onPressed: onReplyPressed,
                  icon: Icon(
                    Icons.reply_outlined,
                    size: AppDimensions.iconSmall,
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
                      horizontal: AppDimensions.paddingXSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                  ),
                ),
              ],
            ),
          
          // Replies
          if (comment.hasReplies)
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.spacingMedium + AppDimensions.avatarSizeSmall + AppDimensions.spacingSmall,
                top: AppDimensions.spacingMedium,
              ),
              child: Column(
                children: comment.replies
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
                          child: CommentCard(
                            comment: reply,
                            showActions: true,
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
