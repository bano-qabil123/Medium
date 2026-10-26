import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final double? strokeWidth;
  final String? label;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  
  const AppLoading({
    super.key,
    this.size = AppDimensions.iconLarge,
    this.color,
    this.strokeWidth,
    this.label,
    this.labelStyle,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth ?? 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              label!,
              style: labelStyle ?? AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingSmall extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  
  const AppLoadingSmall({
    super.key,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoading(
      size: AppDimensions.iconSmall,
      color: color,
      strokeWidth: strokeWidth ?? 2,
    );
  }
}

class AppLoadingLarge extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  
  const AppLoadingLarge({
    super.key,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoading(
      size: AppDimensions.iconXLarge,
      color: color,
      strokeWidth: strokeWidth ?? 4,
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final String? label;
  
  const AppLoadingOverlay({
    super.key,
    this.color,
    this.strokeWidth,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: AppLoading(
          color: color ?? Colors.white,
          strokeWidth: strokeWidth,
          label: label,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  
  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? AppColors.greyLight,
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusSmall),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusSmall),
        child: _ShimmerEffect(
          baseColor: baseColor ?? AppColors.greyLight,
          highlightColor: highlightColor ?? AppColors.grey,
        ),
      ),
    );
  }
}

class _ShimmerEffect extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  
  const _ShimmerEffect({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor,
            baseColor,
            highlightColor,
            baseColor,
            baseColor,
          ],
          stops: const [0, 0.4, 0.5, 0.6, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double? itemWidth;
  final double spacing;
  final double? borderRadius;
  
  const AppShimmerList({
    super.key,
    required this.itemCount,
    required this.itemHeight,
    this.itemWidth,
    this.spacing = AppDimensions.spacingMedium,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => 
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: AppShimmer(
            width: itemWidth ?? double.infinity,
            height: itemHeight,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}

class AppShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  
  const AppShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AppShimmer(
        width: width ?? double.infinity,
        height: height ?? 100,
        borderRadius: borderRadius ?? AppDimensions.radiusMedium,
      ),
    );
  }
}
