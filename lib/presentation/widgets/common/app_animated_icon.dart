import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

/// Animated icon with various effects
class AppAnimatedIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Duration duration;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? tooltip;
  
  const AppAnimatedIcon({
    super.key,
    required this.icon,
    this.size = AppDimensions.iconMedium,
    this.color,
    this.duration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: size,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );

    if (!enabled) {
      return onPressed != null
          ? IconButton(
              icon: iconWidget,
              onPressed: onPressed,
              tooltip: tooltip,
            )
          : iconWidget;
    }

    if (onPressed != null) {
      return IconButton(
        icon: iconWidget,
        onPressed: onPressed,
        tooltip: tooltip,
      ).animate().scale(
        duration: duration,
        begin: const Offset(1, 1),
        end: const Offset(0.9, 0.9),
      );
    }

    return iconWidget.animate().scale(
      duration: duration,
      begin: const Offset(1, 1),
      end: const Offset(0.9, 0.9),
    );
  }
}

/// Animated icon button with ripple effect
class AppAnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? tooltip;
  final EdgeInsets? padding;
  
  const AppAnimatedIconButton({
    super.key,
    required this.icon,
    this.size = AppDimensions.iconMedium,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.onPressed,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;

    if (!enabled) {
      return IconButton(
        icon: Icon(icon, size: size, color: iconColor),
        onPressed: null,
        tooltip: tooltip,
        padding: padding,
      );
    }

    return IconButton(
      icon: Icon(icon, size: size, color: iconColor),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: padding,
      style: IconButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: iconColor,
      ),
    ).animate().scale(
      duration: duration,
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
    );
  }
}

/// Animated floating action button
class AppAnimatedFab extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration duration;
  final bool enabled;
  
  const AppAnimatedFab({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.duration = const Duration(milliseconds: 300),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    if (!enabled) {
      return FloatingActionButton(
        onPressed: null,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        tooltip: tooltip,
        child: Icon(icon),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      tooltip: tooltip,
      child: Icon(icon),
    ).animate().scale(
      duration: duration,
      begin: const Offset(1, 1),
      end: const Offset(0.9, 0.9),
    );
  }
}

/// Animated container with hover effect
class AppAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Decoration? decoration;
  final Color? hoverColor;
  
  const AppAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
    this.onTap,
    this.padding,
    this.decoration,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        padding: padding,
        decoration: decoration,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      hoverColor: hoverColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
      borderRadius: decoration is BoxDecoration 
          ? (decoration as BoxDecoration).borderRadius
          : null,
      child: Container(
        padding: padding,
        decoration: decoration,
        child: child,
      ).animate().scale(
        duration: duration,
        begin: const Offset(1, 1),
        end: const Offset(0.98, 0.98),
      ),
    );
  }
}

/// Animated button with ripple effect
class AppAnimatedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration duration;
  final bool enabled;
  final bool loading;
  final double? width;
  final double? height;
  
  const AppAnimatedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.duration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.loading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    final button = ElevatedButton.icon(
      onPressed: enabled && !loading ? onPressed : null,
      icon: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : (icon != null ? Icon(icon, size: AppDimensions.iconSmall) : const SizedBox()),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        minimumSize: Size(width ?? double.infinity, height ?? AppDimensions.buttonHeightMedium),
      ),
    );

    if (!enabled || loading) {
      return button;
    }

    return button.animate().scale(
      duration: duration,
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
    );
  }
}

/// Animated card with hover effect
class AppAnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final Decoration? decoration;
  final Color? hoverColor;
  
  const AppAnimatedCard({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
    this.onTap,
    this.margin,
    this.decoration,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = decoration ?? BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );

    if (!enabled) {
      return Container(
        margin: margin,
        decoration: cardDecoration,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      hoverColor: hoverColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.05),
      borderRadius: cardDecoration is BoxDecoration 
          ? (cardDecoration as BoxDecoration).borderRadius
          : null,
      child: Container(
        margin: margin,
        decoration: cardDecoration,
        child: child,
      ).animate().scale(
        duration: duration,
        begin: const Offset(1, 1),
        end: const Offset(0.98, 0.98),
      ),
    );
  }
}

/// Animated list tile
class AppAnimatedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Duration duration;
  final bool enabled;
  final EdgeInsets? contentPadding;
  
  const AppAnimatedListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
    );

    if (!enabled) {
      return tile;
    }

    return tile.animate().scale(
      duration: duration,
      begin: const Offset(1, 1),
      end: const Offset(0.98, 0.98),
    );
  }
}
