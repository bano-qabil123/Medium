import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  
  const AppDivider({
    super.key,
    this.height = AppDimensions.dividerHeight,
    this.thickness = AppDimensions.dividerHeight,
    this.indent = AppDimensions.dividerIndent,
    this.endIndent = AppDimensions.dividerIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.border,
    );
  }
}

class AppVerticalDivider extends StatelessWidget {
  final double width;
  final double thickness;
  final Color? color;
  
  const AppVerticalDivider({
    super.key,
    this.width = 1,
    this.thickness = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: width,
      thickness: thickness,
      color: color ?? AppColors.border,
    );
  }
}

class AppSectionDivider extends StatelessWidget {
  final String? title;
  final double padding;
  final bool showDivider;
  
  const AppSectionDivider({
    super.key,
    this.title,
    this.padding = AppDimensions.paddingMedium,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: const AppDivider(),
      );
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDivider) const AppDivider(),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            title!,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
        ],
      ),
    );
  }
}
