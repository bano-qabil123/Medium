import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';

/// Optimized avatar widget with caching and RepaintBoundary
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final BoxFit? fit;
  
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final displayName = name ?? 'U';
    
    // Use RepaintBoundary to isolate avatar repaints
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder 
              ? Border.all(
                  color: borderColor ?? AppColors.primary,
                  width: borderWidth,
                )
              : null,
        ),
        child: hasImage 
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: fit ?? BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(displayName, size),
                  errorWidget: (context, url, error) => _buildPlaceholder(displayName, size),
                  fadeInImage: true,
                  fadeInDuration: const Duration(milliseconds: 200),
                  cacheKey: imageUrl,
                  maxHeightDiskCache: 200,
                ),
              )
            : _buildPlaceholder(displayName, size),
      ),
    );
  }
  
  Widget _buildPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Helpers.getColorFromString(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          Helpers.getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Small avatar (32px)
class AppAvatarSmall extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool showBorder;
  
  const AppAvatarSmall({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      name: name,
      size: 32,
      showBorder: showBorder,
    );
  }
}

/// Medium avatar (48px) - Default
class AppAvatarMedium extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool showBorder;
  
  const AppAvatarMedium({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      name: name,
      size: 48,
      showBorder: showBorder,
    );
  }
}

/// Large avatar (72px)
class AppAvatarLarge extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool showBorder;
  
  const AppAvatarLarge({
    super.key,
    this.imageUrl,
    this.name,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      key: key,
      imageUrl: imageUrl,
      name: name,
      size: 72,
      showBorder: showBorder,
    );
  }
}

/// Avatar group with optimized rendering
class AppAvatarGroup extends StatelessWidget {
  final List<String?> imageUrls;
  final List<String?> names;
  final double size;
  final double spacing;
  final int maxAvatars;
  final bool showMoreIndicator;
  
  const AppAvatarGroup({
    super.key,
    required this.imageUrls,
    required this.names,
    this.size = 32,
    this.spacing = 4,
    this.maxAvatars = 3,
    this.showMoreIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatars = <Widget>[];
    final remaining = imageUrls.length - maxAvatars;
    
    for (int i = 0; i < imageUrls.length && i < maxAvatars; i++) {
      avatars.add(
        AppAvatar(
          key: ValueKey('avatar-${imageUrls[i]}-$i'),
          imageUrl: imageUrls[i],
          name: names[i],
          size: size,
        ),
      );
    }
    
    if (remaining > 0 && showMoreIndicator) {
      avatars.add(
        Container(
          key: const ValueKey('avatar-more'),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+$remaining',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: avatars
          .map((avatar) => Padding(
                key: ValueKey('avatar-padding-${avatars.indexOf(avatar)}'),
                padding: EdgeInsets.only(right: spacing),
                child: avatar,
              ))
          .toList(),
    );
  }
}
