import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/clap_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClapButton extends ConsumerStatefulWidget {
  final String articleId;
  final bool showCount;
  final double size;
  final Color? iconColor;
  final Color? activeIconColor;
  final Color? countColor;

  const ClapButton({
    super.key,
    required this.articleId,
    this.showCount = true,
    this.size = 40,
    this.iconColor,
    this.activeIconColor,
    this.countColor,
  });

  @override
  ConsumerState<ClapButton> createState() => _ClapButtonState();
}

class _ClapButtonState extends ConsumerState<ClapButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  final List<Widget> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _colorAnimation = ColorTween(
      begin: widget.iconColor ?? AppColors.clapsColor,
      end: widget.activeIconColor ?? AppColors.clapsColorHighlight,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.reset();
    _controller.forward();
    
    // Create particles
    setState(() {
      _particles.clear();
      for (int i = 0; i < 5; i++) {
        _particles.add(_buildParticle());
      }
    });
    
    // Clear particles after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  Widget _buildParticle() {
    final size = _random.nextDouble() * 8 + 4;
    final offsetX = _random.nextDouble() * 40 - 20;
    final offsetY = _random.nextDouble() * 40 - 20;
    final duration = _random.nextInt(400) + 400;
    
    return Positioned(
      left: widget.size / 2 + offsetX,
      top: widget.size / 2 + offsetY,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.clapsColorHighlight.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ).animate().fadeIn(duration: Duration(milliseconds: duration));
    );
  }

  @override
  Widget build(BuildContext context) {
    final clapCount = ref.watch(clapCountProvider(widget.articleId));
    final hasClapped = ref.watch(hasClappedProvider(widget.articleId));
    final clapNotifier = ref.read(clapProvider(widget.articleId).notifier);

    return GestureDetector(
      onTap: () {
        clapNotifier.toggleClap();
        _triggerAnimation();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Particles
          ..._particles,
          
          // Main button
          AnimatedBuilder(
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
                  hasClapped ? Icons.favorite : Icons.favorite_border,
                  size: widget.size * 0.6,
                  color: _colorAnimation.value,
                ),
                if (widget.showCount && clapCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    clapCount.formatCount(),
                    style: TextStyle(
                      fontSize: widget.size * 0.45,
                      fontWeight: FontWeight.w600,
                      color: widget.countColor ?? AppColors.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to format count (e.g., 1.2K, 1.5M)
extension on int {
  String formatCount() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

class FloatingClapButton extends ConsumerStatefulWidget {
  final String articleId;
  final double size;

  const FloatingClapButton({
    super.key,
    required this.articleId,
    this.size = 56,
  });

  @override
  ConsumerState<FloatingClapButton> createState() => _FloatingClapButtonState();
}

class _FloatingClapButtonState extends ConsumerState<FloatingClapButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<Widget> _particles = [];
  final Random _random = Random();
  int _clapCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.reset();
    _controller.forward();
    
    setState(() {
      _clapCount++;
      _particles.clear();
      for (int i = 0; i < 10; i++) {
        _particles.add(_buildParticle());
      }
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  Widget _buildParticle() {
    final size = _random.nextDouble() * 6 + 4;
    final offsetX = _random.nextDouble() * 60 - 30;
    final offsetY = _random.nextDouble() * 60 - 30;
    final duration = _random.nextInt(500) + 300;
    
    return Positioned(
      left: widget.size / 2 + offsetX,
      top: widget.size / 2 + offsetY,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.clapsColorHighlight.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ).animate().fadeOut(duration: Duration(milliseconds: duration));
    );
  }

  @override
  Widget build(BuildContext context) {
    final clapCount = ref.watch(clapCountProvider(widget.articleId));
    final hasClapped = ref.watch(hasClappedProvider(widget.articleId));
    final clapNotifier = ref.read(clapProvider(widget.articleId).notifier);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Particles
        ..._particles,
        
        // Floating Action Button
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: FloatingActionButton(
            onPressed: () {
              clapNotifier.toggleClap();
              _triggerAnimation();
            },
            backgroundColor: hasClapped 
                ? AppColors.clapsColorHighlight 
                : AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  hasClapped ? Icons.favorite : Icons.favorite_border,
                  size: widget.size * 0.5,
                ),
                if (clapCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        clapCount.formatCount(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ClapAnimationOverlay extends StatelessWidget {
  final String articleId;
  final Widget child;

  const ClapAnimationOverlay({
    super.key,
    required this.articleId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final hasClapped = ref.watch(hasClappedProvider(articleId));
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: hasClapped
              ? Stack(
                  key: ValueKey('clapped_$articleId'),
                  children: [
                    child!,
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.clapsColorHighlight,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).animate().fadeOut(
                          duration: const Duration(milliseconds: 1000),
                        ),
                      ),
                    ),
                  ],
                )
              : child!,
        );
      },
      child: child,
    );
  }
}
