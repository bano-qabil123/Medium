import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final bool showDeleteIcon;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? deleteIconColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;
  final ShapeBorder? shape;
  
  const AppChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
    this.isSelected = false,
    this.showDeleteIcon = false,
    this.icon,
    this.backgroundColor,
    this.labelColor,
    this.deleteIconColor,
    this.padding,
    this.labelPadding,
    this.labelStyle,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: labelStyle ?? AppTypography.bodySmall.copyWith(
          color: labelColor ?? (isSelected ? AppColors.onPrimary : AppColors.onSurface),
          fontWeight: FontWeight.w500,
        ),
      ),
      labelPadding: labelPadding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      selected: isSelected,
      onSelected: onPressed != null ? (selected) => onPressed!() : null,
      deleteIcon: showDeleteIcon ? const Icon(Icons.close, size: AppDimensions.iconXSmall) : null,
      onDeleted: onDeleted,
      backgroundColor: backgroundColor ?? (isSelected ? AppColors.primaryLight : AppColors.surface),
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.onPrimary,
      deleteIconColor: deleteIconColor ?? AppColors.grey,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide(color: AppColors.border),
    );
  }
}

class AppActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  
  const AppActionChip({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSelected = false,
    this.backgroundColor,
    this.labelColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: labelStyle ?? AppTypography.bodySmall.copyWith(
          color: labelColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      avatar: icon != null ? Icon(icon, size: AppDimensions.iconSmall) : null,
      selected: isSelected,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide(color: AppColors.border),
    );
  }
}

class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.icon,
    this.backgroundColor,
    this.selectedColor,
    this.labelColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: labelStyle ?? AppTypography.bodySmall.copyWith(
          color: labelColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      avatar: icon != null ? Icon(icon, size: AppDimensions.iconSmall) : null,
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedColor: selectedColor ?? AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide(color: AppColors.border),
    );
  }
}

class AppTagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final bool showDeleteIcon;
  final Color? backgroundColor;
  final Color? labelColor;
  
  const AppTagChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
    this.showDeleteIcon = false,
    this.backgroundColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      showDeleteIcon: showDeleteIcon,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      labelColor: labelColor ?? AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}
