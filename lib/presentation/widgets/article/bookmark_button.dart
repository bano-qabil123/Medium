import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/bookmark_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookmarkButton extends ConsumerStatefulWidget {
  final String articleId;
  final bool showText;
  final double iconSize;
  final Color? iconColor;
  final Color? activeIconColor;
  final Color? textColor;

  const BookmarkButton({
    super.key,
    required this.articleId,
    this.showText = false,
    this.iconSize = 24,
    this.iconColor,
    this.activeIconColor,
    this.textColor,
  });

  @override
  ConsumerState<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<BookmarkButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(articleBookmarkProvider(widget.articleId));
    final bookmarkNotifier = ref.read(articleBookmarkProvider(widget.articleId).notifier);

    final isBookmarked = bookmarkState.valueOrNull ?? false;

    return GestureDetector(
      onTap: () async {
        await bookmarkNotifier.toggle();
        _triggerAnimation();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: widget.iconSize,
              color: isBookmarked
                  ? widget.activeIconColor ?? AppColors.primary
                  : widget.iconColor ?? AppColors.onSurfaceVariant,
            ),
            if (widget.showText) ...[
              const SizedBox(width: 8),
              Text(
                isBookmarked ? 'Saved' : 'Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor ?? AppColors.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FloatingBookmarkButton extends ConsumerStatefulWidget {
  final String articleId;
  final double size;

  const FloatingBookmarkButton({
    super.key,
    required this.articleId,
    this.size = 56,
  });

  @override
  ConsumerState<FloatingBookmarkButton> createState() => _FloatingBookmarkButtonState();
}

class _FloatingBookmarkButtonState extends ConsumerState<FloatingBookmarkButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(articleBookmarkProvider(widget.articleId));
    final bookmarkNotifier = ref.read(articleBookmarkProvider(widget.articleId).notifier);

    final isBookmarked = bookmarkState.valueOrNull ?? false;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: FloatingActionButton(
        onPressed: () async {
          await bookmarkNotifier.toggle();
          _triggerAnimation();
        },
        backgroundColor: isBookmarked ? AppColors.primary : AppColors.surface,
        foregroundColor: isBookmarked ? AppColors.onPrimary : AppColors.onSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}

class BookmarkIcon extends ConsumerWidget {
  final String articleId;
  final double size;
  final Color? color;
  final Color? activeColor;

  const BookmarkIcon({
    super.key,
    required this.articleId,
    this.size = 24,
    this.color,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(articleBookmarkProvider(articleId));
    final isBookmarked = bookmarkState.valueOrNull ?? false;

    return Icon(
      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      size: size,
      color: isBookmarked ? (activeColor ?? AppColors.primary) : (color ?? AppColors.onSurfaceVariant),
    );
  }
}
