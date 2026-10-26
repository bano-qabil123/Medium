import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/comment_provider.dart';
import '../common/app_loading.dart';
import '../common/app_empty_state.dart';
import 'comment_card.dart';
import 'comment_input.dart';

/// Optimized comment section with ListView.builder
class CommentSection extends ConsumerWidget {
  final String articleId;
  
  const CommentSection({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(articleId));
    
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
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
          
          const SizedBox(height: 16),
          
          // Comment Input with RepaintBoundary
          RepaintBoundary(
            child: CommentInput(articleId: articleId),
          ),
          
          const SizedBox(height: 24),
          
          // Comments List with ListView.builder
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: AppLoading()),
              error: (error, stack) => AppEmptyStateError(
                message: error.toString(),
                onRetry: () => ref.read(commentsProvider(articleId).notifier).refresh(),
              ),
              data: (comments) {
                if (comments.isEmpty) {
                  return const AppEmptyStateNoComments(
                    isCurrentUser: true,
                  );
                }
                
                // Use ListView.builder for smooth scrolling
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    // Use RepaintBoundary to isolate each comment
                    return RepaintBoundary(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index == comments.length - 1 ? 0 : 16,
                        ),
                        child: CommentCard(
                          key: ValueKey(comments[index].id),
                          comment: comments[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
