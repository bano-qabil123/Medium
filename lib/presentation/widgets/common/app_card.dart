import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final bool? borderOnForeground;
  final Clip? clipBehavior;
  final bool hasBorder;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.margin,
    this.shape,
    this.borderOnForeground,
    this.clipBehavior,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? AppColors.surface,
      elevation: elevation ?? AppDimensions.cardElevation,
      margin: margin,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: hasBorder 
            ? BorderSide(
                color: borderColor ?? AppColors.border,
                width: borderWidth ?? AppDimensions.cardBorderWidth,
              )
            : BorderSide.none,
      ),
      borderOnForeground: borderOnForeground,
      clipBehavior: clipBehavior ?? Clip.none,
      child: child,
    );
    
    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }
    
    return card;
  }
}

class AppCardElevated extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final VoidCallback? onTap;
  
  const AppCardElevated({
    super.key,
    required this.child,
    this.color,
    this.elevation = 4,
    this.margin,
    this.shape,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? AppColors.surface,
      elevation: elevation,
      margin: margin,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: child,
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
}

class AppCardOutlined extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final VoidCallback? onTap;
  
  const AppCardOutlined({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.margin,
    this.shape,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? AppColors.surface,
      elevation: 0,
      margin: margin,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: borderColor ?? AppColors.border,
          width: borderWidth ?? 1,
        ),
      ),
      child: child,
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
}
