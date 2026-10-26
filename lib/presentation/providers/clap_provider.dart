import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/models/clap_model.dart';
import 'package:medium_clone/data/repositories/clap_repository.dart';
import 'package:vibration/vibration.dart';

// Clap Repository Provider
final clapRepositoryProvider = Provider<ClapRepository>((ref) {
  return ClapRepository();
});

// Clap State Notifier
class ClapNotifier extends StateNotifier<AsyncValue<ClapModel?>> {
  final ClapRepository _clapRepository;
  final String _articleId;
  final String? _userId;

  ClapNotifier(this._clapRepository, this._articleId, this._userId)
      : super(const AsyncValue.data(null));

  int _clapCount = 0;
  bool _hasClapped = false;

  int get clapCount => _clapCount;
  bool get hasClapped => _hasClapped;

  Future<void> loadClapStatus() async {
    try {
      final count = await _clapRepository.getClapCount(_articleId);
      if (_userId != null) {
        final hasClapped = await _clapRepository.hasClapped(
          articleId: _articleId,
          userId: _userId!,
        );
        _hasClapped = hasClapped;
      }
      _clapCount = count;
      state = AsyncValue.data(null); // Reset to data state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleClap() async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('Please sign in to clap'),
        StackTrace.current,
      );
      return;
    }

    try {
      if (_hasClapped) {
        // Remove clap
        await _clapRepository.unclapArticle(
          articleId: _articleId,
          userId: _userId!,
        );
        _hasClapped = false;
        _clapCount = (_clapCount - 1).clamp(0, _clapCount);
      } else {
        // Add clap
        await _clapRepository.clapArticle(
          articleId: _articleId,
          userId: _userId!,
          count: 1,
        );
        _hasClapped = true;
        _clapCount++;
        
        // Haptic feedback
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 50, amplitude: 128);
        }
      }
      state = AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addMultipleClaps(int count) async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('Please sign in to clap'),
        StackTrace.current,
      );
      return;
    }

    try {
      await _clapRepository.clapArticle(
        articleId: _articleId,
        userId: _userId!,
        count: count,
      );
      _hasClapped = true;
      _clapCount += count;
      
      // Haptic feedback for multiple claps
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100, amplitude: 128);
      }
      
      state = AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Clap Provider for a specific article
final clapProvider = StateNotifierProvider.family<ClapNotifier, AsyncValue<ClapModel?>, String>(
  (ref, articleId) {
    final userId = ref.watch(authProvider).valueOrNull?.id;
    final repository = ref.watch(clapRepositoryProvider);
    final notifier = ClapNotifier(repository, articleId, userId);
    notifier.loadClapStatus();
    return notifier;
  },
);

// Clap Count Provider for a specific article
final clapCountProvider = Provider.family<int, String>((ref, articleId) {
  final clapState = ref.watch(clapProvider(articleId));
  return clapState.when(
    data: (_) {
      final notifier = ref.read(clapProvider(articleId).notifier);
      return notifier.clapCount;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Has Clapped Provider for a specific article
final hasClappedProvider = Provider.family<bool, String>((ref, articleId) {
  final clapState = ref.watch(clapProvider(articleId));
  return clapState.when(
    data: (_) {
      final notifier = ref.read(clapProvider(articleId).notifier);
      return notifier.hasClapped;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

// Clap Animation Controller
class ClapAnimationController {
  final AnimationController _controller;
  final Animation<double> _scaleAnimation;
  final Animation<Color?> _colorAnimation;
  final List<AnimationController> _clapParticles = [];

  ClapAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
  })  : _controller = AnimationController(vsync: vsync, duration: duration),
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
        ),
        _colorAnimation = ColorTween(
          begin: const Color(0xFF292929),
          end: const Color(0xFF4A4A4A),
        ).animate(_controller);

  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<Color?> get colorAnimation => _colorAnimation;

  void forward() => _controller.forward();
  void reverse() => _controller.reverse();

  void triggerClapAnimation() {
    _controller.reset();
    _controller.forward();
    
    // Create particle animations
    for (int i = 0; i < 5; i++) {
      final particleController = AnimationController(
        vsync: _controller.vsync,
        duration: const Duration(milliseconds: 800),
      );
      _clapParticles.add(particleController);
      particleController.forward(from: 0);
    }
    
    // Clean up particles after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      for (final controller in _clapParticles) {
        controller.dispose();
      }
      _clapParticles.clear();
    });
  }

  void dispose() {
    _controller.dispose();
    for (final controller in _clapParticles) {
      controller.dispose();
    }
  }
}

// Clap Animation Provider
final clapAnimationProvider = StateNotifierProvider<ClapAnimationNotifier, bool>(
  (ref) => ClapAnimationNotifier(),
);

class ClapAnimationNotifier extends StateNotifier<bool> {
  ClapAnimationNotifier() : super(false);

  void triggerAnimation() {
    state = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      state = false;
    });
  }
}
