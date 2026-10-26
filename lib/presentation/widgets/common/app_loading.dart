import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

/// Optimized loading widget with const constructors
class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoading({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Small loading indicator with const constructors
class AppLoadingSmall extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingSmall({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Shimmer loading for text
class AppShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;
  final double spacing;
  final bool enabled;

  const AppShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return SizedBox(
        width: width,
        height: height * lines + spacing * (lines - 1),
      );
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lines,
          (index) => Padding(
            padding: EdgeInsets.only(top: index > 0 ? spacing : 0),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for article card
class AppShimmerArticleCard extends StatelessWidget {
  final bool enabled;

  const AppShimmerArticleCard({
    super.key,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox(height: 200);
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image placeholder
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            // Title placeholder
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            // Description placeholder
            Container(
              width: double.infinity * 0.8,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            // Author info placeholder
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for list items
class AppShimmerListItem extends StatelessWidget {
  final bool enabled;
  final double height;

  const AppShimmerListItem({
    super.key,
    this.enabled = true,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return SizedBox(height: height);
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity * 0.6,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXSmall),
                  Container(
                    width: double.infinity * 0.4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for avatar
class AppShimmerAvatar extends StatelessWidget {
  final double size;
  final bool enabled;

  const AppShimmerAvatar({
    super.key,
    this.size = 48,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return SizedBox(width: size, height: size);
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Full page shimmer loading
class AppShimmerFullPage extends StatelessWidget {
  final bool enabled;

  const AppShimmerFullPage({
    super.key,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox();
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Title
            Container(
              width: double.infinity * 0.7,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            // Subtitle
            Container(
              width: double.infinity * 0.5,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Content
            ...List.generate(5, (index) => Padding(
              padding: EdgeInsets.only(top: index > 0 ? AppDimensions.spacingMedium : 0),
              child: Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                ),
              ),
            )),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for comment
class AppShimmerComment extends StatelessWidget {
  final bool enabled;

  const AppShimmerComment({
    super.key,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox(height: 80);
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      enabled: enabled,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXSmall),
                  Container(
                    width: double.infinity * 0.8,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Container(
                    width: double.infinity * 0.6,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
