import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

/// Custom page transitions for the app
class AppTransitions {
  /// Shared axis transition (Material Design)
  static PageTransitionsBuilder sharedAxis = SharedAxisPageTransitionsBuilder(
    transitionType: SharedAxisTransitionType.horizontal,
  );

  /// Cupertino-style transition (iOS)
  static PageTransitionsBuilder cupertino = const CupertinoPageTransitionsBuilder();

  /// Fade transition
  static PageTransitionsBuilder fade = const FadeUpwardsPageTransitionsBuilder(
    transitionDuration: Duration(milliseconds: 300),
  );

  /// Slide transition from right
  static PageTransitionsBuilder slideRight = const SlideTransitionBuilder(
    direction: AxisDirection.right,
    transitionDuration: Duration(milliseconds: 300),
  );

  /// Slide transition from left
  static PageTransitionsBuilder slideLeft = const SlideTransitionBuilder(
    direction: AxisDirection.left,
    transitionDuration: Duration(milliseconds: 300),
  );

  /// Slide transition from bottom
  static PageTransitionsBuilder slideUp = const SlideTransitionBuilder(
    direction: AxisDirection.up,
    transitionDuration: Duration(milliseconds: 300),
  );

  /// Custom shared axis transition with fade
  static PageTransitionsBuilder customSharedAxis = CustomSharedAxisPageTransitionsBuilder();

  /// Get platform-appropriate transition
  static PageTransitionsBuilder get defaultTransition {
    // Use shared axis for Android, Cupertino for iOS
    // You can also check the platform here
    return sharedAxis;
  }
}

/// Custom shared axis page transitions builder
class CustomSharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use SharedAxisTransition for horizontal shared axis
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  }
}

/// Slide transition builder
class SlideTransitionBuilder extends PageTransitionsBuilder {
  final AxisDirection direction;
  final Duration transitionDuration;

  const SlideTransitionBuilder({
    this.direction = AxisDirection.right,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Offset offset = _getOffset(direction);
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: offset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }

  Offset _getOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
      default:
        return const Offset(-1, 0);
    }
  }
}

/// Fade and scale transition
class FadeScaleTransitionBuilder extends PageTransitionsBuilder {
  final Duration transitionDuration;
  final double scaleBegin;
  final double opacityBegin;

  const FadeScaleTransitionBuilder({
    this.transitionDuration = const Duration(milliseconds: 300),
    this.scaleBegin = 0.9,
    this.opacityBegin = 0.0,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeScaleTransition(
      animation: animation,
      scaleBegin: scaleBegin,
      opacityBegin: opacityBegin,
      child: child,
    );
  }
}

/// Fade and scale transition widget
class FadeScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final double scaleBegin;
  final double opacityBegin;
  final Widget child;

  const FadeScaleTransition({
    super.key,
    required this.animation,
    this.scaleBegin = 0.9,
    this.opacityBegin = 0.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: opacityBegin + (1.0 - opacityBegin) * animation.value,
          child: Transform.scale(
            scale: scaleBegin + (1.0 - scaleBegin) * animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Custom page route with transition
class CustomPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final PageTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;

  CustomPageRoute({
    required this.child,
    this.transitionsBuilder = AppTransitions.defaultTransition,
    this.transitionDuration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return transitionsBuilder.buildTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => transitionDuration;
}

/// Slide up route for bottom sheets and modals
class SlideUpRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration transitionDuration;

  SlideUpRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => transitionDuration;
}

/// Theme with custom transitions
class AppThemeTransitions {
  static PageTransitionsTheme get transitionsTheme {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AppTransitions.sharedAxis,
        TargetPlatform.iOS: AppTransitions.cupertino,
        TargetPlatform.macOS: AppTransitions.sharedAxis,
        TargetPlatform.windows: AppTransitions.sharedAxis,
        TargetPlatform.linux: AppTransitions.sharedAxis,
      },
    );
  }

  /// Theme with fade transitions
  static PageTransitionsTheme get fadeTransitionsTheme {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AppTransitions.fade,
        TargetPlatform.iOS: AppTransitions.fade,
        TargetPlatform.macOS: AppTransitions.fade,
        TargetPlatform.windows: AppTransitions.fade,
        TargetPlatform.linux: AppTransitions.fade,
      },
    );
  }

  /// Theme with slide transitions
  static PageTransitionsTheme get slideTransitionsTheme {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AppTransitions.slideRight,
        TargetPlatform.iOS: AppTransitions.slideRight,
        TargetPlatform.macOS: AppTransitions.slideRight,
        TargetPlatform.windows: AppTransitions.slideRight,
        TargetPlatform.linux: AppTransitions.slideRight,
      },
    );
  }
}

/// Hero transition for images
class AppHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;

  const AppHero({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }
    
    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      placeholderBuilder: (context, size, child) {
        return Container(
          width: size.width,
          height: size.height,
          color: Theme.of(context).colorScheme.surfaceVariant,
        );
      },
    );
  }
}

/// Shared axis transition wrapper
class AppSharedAxisTransition extends StatelessWidget {
  final Widget child;
  final SharedAxisTransitionType transitionType;

  const AppSharedAxisTransition({
    super.key,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return SharedAxisTransition(
      animation: ModalRoute.of(context)!.animation!,
      secondaryAnimation: ModalRoute.of(context)!.secondaryAnimation!,
      transitionType: transitionType,
      child: child,
    );
  }
}
