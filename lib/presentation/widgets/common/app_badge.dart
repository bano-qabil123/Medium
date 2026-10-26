import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.labelColor,
    this.labelStyle,
    this.padding,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: shape is RoundedRectangleBorder 
            ? (shape as RoundedRectangleBorder).borderRadius 
            : BorderRadius.circular(AppDimensions.radiusFull),
        shape: shape != null ? BoxShape.rectangle : BoxShape.rectangle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppDimensions.spacingXSmall),
          ],
          Text(
            label,
            style: labelStyle ?? AppTypography.bodySmall.copyWith(
              color: labelColor ?? AppColors.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBadgeCount extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final double minWidth;
  
  const AppBadgeCount({
    super.key,
    required this.count,
    this.backgroundColor,
    this.labelColor,
    this.labelStyle,
    this.padding,
    this.minWidth = AppDimensions.iconSmall,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      constraints: BoxConstraints(minWidth: minWidth),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Center(
        child: Text(
          displayCount,
          style: labelStyle ?? AppTypography.bodySmall.copyWith(
            color: labelColor ?? AppColors.onError,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AppBadgeNotification extends StatelessWidget {
  final bool hasNotification;
  final int count;
  final Widget child;
  final Color? badgeColor;
  final Color? countColor;
  final EdgeInsetsGeometry? badgePadding;
  
  const AppBadgeNotification({
    super.key,
    required this.hasNotification,
    this.count = 0,
    required this.child,
    this.badgeColor,
    this.countColor,
    this.badgePadding,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasNotification || count == 0) {
      return child;
    }
    
    return Badge(
      label: AppBadgeCount(
        count: count,
        backgroundColor: badgeColor,
        labelColor: countColor,
        padding: badgePadding,
      ),
      child: child,
    );
  }
}

class AppBadgeIcon extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? iconSize;
  final Color? badgeColor;
  final Color? countColor;
  final EdgeInsetsGeometry? padding;
  
  const AppBadgeIcon({
    super.key,
    required this.icon,
    this.count,
    this.onPressed,
    this.iconColor,
    this.iconSize,
    this.badgeColor,
    this.countColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotification = count != null && count! > 0;
    
    return AppBadgeNotification(
      hasNotification: hasNotification,
      count: count ?? 0,
      badgeColor: badgeColor,
      countColor: countColor,
      badgePadding: padding,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onSurface,
          size: iconSize ?? AppDimensions.iconMedium,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppDimensions.buttonHeightMedium,
          minHeight: AppDimensions.buttonHeightMedium,
        ),
      ),
    );
  }
}
