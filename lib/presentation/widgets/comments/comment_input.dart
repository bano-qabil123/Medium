import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/providers/comment_provider.dart';

class CommentInput extends ConsumerStatefulWidget {
  final String articleId;
  final String? parentId;
  final String? replyToUser;
  final VoidCallback? onSubmitted;
  final VoidCallback? onCancelled;
  
  const CommentInput({
    super.key,
    required this.articleId,
    this.parentId,
    this.replyToUser,
    this.onSubmitted,
    this.onCancelled,
  });
  
  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.replyToUser != null) {
      _controller.text = '@${widget.replyToUser} ';
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Sign in to comment',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to login
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      child: Column(
        children: [
          if (widget.replyToUser != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Replying to @${widget.replyToUser}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: currentUser.avatarUrl != null 
                    ? NetworkImage(currentUser.avatarUrl!)
                    : null,
                child: currentUser.avatarUrl == null 
                    ? Text(
                        currentUser.initials,
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _isSubmitting ? null : _submitComment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancelled != null)
                TextButton(
                  onPressed: widget.onCancelled,
                  child: const Text('Cancel'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSubmitting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(commentControllerProvider.notifier).createComment(
        articleId: widget.articleId,
        content: _controller.text.trim(),
        parentId: widget.parentId,
      );
      
      _controller.clear();
      widget.onSubmitted?.call();
      
      // Refresh comments
      ref.read(commentsProvider(widget.articleId).notifier).refresh();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
