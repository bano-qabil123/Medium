import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/comment_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/comment/comment_card.dart';
import 'package:medium_clone/presentation/widgets/comment/comment_input.dart';

class CommentSection extends ConsumerWidget {
  final String articleId;
  
  const CommentSection({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(articleId));
    
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Comments',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Comment Input
          const CommentInput(),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Comments List
          commentsAsync.when(
            loading: () => const AppLoading(),
            error: (error, stack) => AppEmptyStateError(
              message: error.toString(),
              onRetry: () => ref.read(commentsProvider(articleId).notifier).refresh(),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return AppEmptyStateNoComments(
                  isCurrentUser: true,
                );
              }
              
              return Column(
                children: [
                  ...comments.map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                        child: CommentCard(comment: comment),
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
