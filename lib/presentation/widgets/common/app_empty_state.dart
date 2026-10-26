import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? icon;
  final Widget? image;
  final Widget? action;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.image,
    this.action,
    this.actionText,
    this.onActionPressed,
    this.padding,
    this.titleStyle,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (image != null) ...[
            image!,
            const SizedBox(height: AppDimensions.spacingLarge),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(height: AppDimensions.spacingLarge),
          ],
          Text(
            title,
            style: titleStyle ?? AppTypography.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              message!,
              style: messageStyle ?? AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDimensions.spacingLarge),
            action!,
          ],
          if (actionText != null && onActionPressed != null) ...[
            const SizedBox(height: AppDimensions.spacingLarge),
            AppButton(
              text: actionText!,
              onPressed: onActionPressed,
            ),
          ],
        ],
      ),
    );
  }
}

class AppEmptyStateWithIcon extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final Widget? action;
  final String? actionText;
  final VoidCallback? onActionPressed;
  
  const AppEmptyStateWithIcon({
    super.key,
    required this.title,
    this.message,
    required this.icon,
    this.iconColor,
    this.iconSize,
    this.action,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: Icon(
        icon,
        size: iconSize ?? AppDimensions.iconXLarge,
        color: iconColor ?? AppColors.grey,
      ),
      action: action,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}

class AppEmptyStateNoResults extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onRetry;
  
  const AppEmptyStateNoResults({
    super.key,
    this.searchQuery,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateWithIcon(
      title: 'No results found',
      message: searchQuery != null 
          ? 'No articles match "$searchQuery"' 
          : 'Try adjusting your search or filter',
      icon: Icons.search_off,
      actionText: 'Try again',
      onActionPressed: onRetry,
    );
  }
}

class AppEmptyStateNoArticles extends StatelessWidget {
  final bool isCurrentUser;
  final VoidCallback? onCreateArticle;
  
  const AppEmptyStateNoArticles({
    super.key,
    this.isCurrentUser = false,
    this.onCreateArticle,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return AppEmptyStateWithIcon(
        title: 'No articles yet',
        message: 'Start writing your first article to share with the world',
        icon: Icons.article_outlined,
        actionText: 'Write article',
        onActionPressed: onCreateArticle,
      );
    }
    
    return AppEmptyStateWithIcon(
      title: 'No articles',
      message: 'This user has not published any articles yet',
      icon: Icons.article_outlined,
    );
  }
}

class AppEmptyStateNoComments extends StatelessWidget {
  final bool isCurrentUser;
  final VoidCallback? onCreateComment;
  
  const AppEmptyStateNoComments({
    super.key,
    this.isCurrentUser = false,
    this.onCreateComment,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      return AppEmptyStateWithIcon(
        title: 'No comments yet',
        message: 'Be the first to comment on this article',
        icon: Icons.comment_outlined,
        actionText: 'Add comment',
        onActionPressed: onCreateComment,
      );
    }
    
    return AppEmptyStateWithIcon(
      title: 'No comments',
      message: 'No one has commented on this article yet',
      icon: Icons.comment_outlined,
    );
  }
}

class AppEmptyStateError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const AppEmptyStateError({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateWithIcon(
      title: 'Something went wrong',
      message: message ?? 'We couldn\'t load the content. Please try again.',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      actionText: 'Try again',
      onActionPressed: onRetry,
    );
  }
}

class AppEmptyStateNetworkError extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const AppEmptyStateNetworkError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateWithIcon(
      title: 'No connection',
      message: 'Check your internet connection and try again',
      icon: Icons.wifi_off,
      iconColor: AppColors.grey,
      actionText: 'Retry',
      onActionPressed: onRetry,
    );
  }
}
