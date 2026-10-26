import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/helpers.dart';

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
    this.size = AppDimensions.avatarSizeMedium,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final displayName = name ?? 'U';
    
    if (hasImage) {
      return Container(
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
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: size,
            height: size,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(displayName, size),
            errorWidget: (context, url, error) => _buildPlaceholder(displayName, size),
          ),
        ),
      );
    }
    
    return _buildPlaceholder(displayName, size);
  }
  
  Widget _buildPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Helpers.getColorFromString(name),
        shape: BoxShape.circle,
        border: showBorder 
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : null,
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
      imageUrl: imageUrl,
      name: name,
      size: AppDimensions.avatarSizeSmall,
      showBorder: showBorder,
    );
  }
}

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
      imageUrl: imageUrl,
      name: name,
      size: AppDimensions.avatarSizeLarge,
      showBorder: showBorder,
    );
  }
}

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
    this.size = AppDimensions.avatarSizeSmall,
    this.spacing = AppDimensions.spacingXSmall,
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
          imageUrl: imageUrls[i],
          name: names[i],
          size: size,
        ),
      );
    }
    
    if (remaining > 0 && showMoreIndicator) {
      avatars.add(
        Container(
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
                padding: EdgeInsets.only(right: spacing),
                child: avatar,
              ))
          .toList(),
    );
  }
}
