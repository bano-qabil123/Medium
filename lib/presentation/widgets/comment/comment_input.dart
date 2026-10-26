import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../common/app_avatar.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

/// Optimized comment input with proper state management
class CommentInput extends ConsumerStatefulWidget {
  final String? articleId;
  final String? parentId;
  final VoidCallback? onCommentPosted;
  
  const CommentInput({
    super.key,
    this.articleId,
    this.parentId,
    this.onCommentPosted,
  });

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handlePostComment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_commentController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (widget.articleId != null) {
        await ref.read(commentControllerProvider.notifier).createComment(
          articleId: widget.articleId!,
          content: _commentController.text.trim(),
          parentId: widget.parentId,
        );
        
        // Clear comment and notify parent
        _commentController.clear();
        widget.onCommentPosted?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    
    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const AppAvatarSmall(
              imageUrl: null,
              name: 'Guest',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sign in to comment',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ),
            AppButton(
              text: 'Sign In',
              onPressed: () => context.push('/login'),
              fullWidth: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: BorderSide(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            AppAvatarSmall(
              imageUrl: currentUser.avatarUrl,
              name: currentUser.fullName,
            ),
            const SizedBox(width: 12),
            
            // Comment Input
            Expanded(
              child: Column(
                children: [
                  AppTextField(
                    controller: _commentController,
                    hintText: widget.parentId != null ? 'Reply...' : 'Add a comment...',
                    maxLines: 3,
                    minLines: 1,
                    validator: (value) => Validators.validateComment(value),
                    autofocus: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Post Button
            const SizedBox(width: 8),
            AppButtonIcon(
              icon: _isLoading 
                  ? const AppLoadingSmall(color: Colors.white)
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _handlePostComment,
              fullWidth: false,
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}
