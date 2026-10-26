import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  final double? padding;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;
  
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.backgroundColor,
    this.margin,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onSurface,
          size: iconSize ?? AppDimensions.iconMedium,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all(padding ?? AppDimensions.paddingSmall),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: iconColor ?? AppColors.onSurface,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.onSurface.withOpacity(0.5),
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class AppIconButtonFilled extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  final double? padding;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;
  
  const AppIconButtonFilled({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.backgroundColor,
    this.margin,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: IconButton.filled(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onPrimary,
          size: iconSize ?? AppDimensions.iconMedium,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all(padding ?? AppDimensions.paddingSmall),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: iconColor ?? AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.5),
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class AppIconButtonTonal extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  final double? padding;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;
  
  const AppIconButtonTonal({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.backgroundColor,
    this.margin,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onSurface,
          size: iconSize ?? AppDimensions.iconMedium,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all(padding ?? AppDimensions.paddingSmall),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.surface,
          foregroundColor: iconColor ?? AppColors.onSurface,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.onSurface.withOpacity(0.5),
          side: BorderSide(color: AppColors.border),
        ),
        tooltip: tooltip,
      ),
    );
  }
}
