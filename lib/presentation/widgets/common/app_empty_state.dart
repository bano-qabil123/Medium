import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';

/// Empty state widget for when there's no data
class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final Widget? action;
  final bool showIcon;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.action,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                size: AppDimensions.iconXLarge,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimensions.spacingLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state with error message
class AppEmptyStateError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppEmptyStateError({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon ?? Icons.error_outline,
      title: 'Error',
      message: message,
      action: onRetry != null
          ? AppButtonSecondary(
              text: 'Retry',
              onPressed: onRetry,
            )
          : null,
    );
  }
}

/// Empty state for loading
class AppEmptyStateLoading extends StatelessWidget {
  final String? message;

  const AppEmptyStateLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.hourglass_empty,
      title: 'Loading',
      message: message ?? 'Please wait while we load your content',
      showIcon: true,
    );
  }
}

/// Empty state for no results
class AppEmptyStateNoResults extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onClear;

  const AppEmptyStateNoResults({
    super.key,
    required this.searchTerm,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      message: 'No articles found for "$searchTerm"',
      action: onClear != null
          ? AppButtonSecondary(
              text: 'Clear Search',
              onPressed: onClear,
            )
          : null,
    );
  }
}

/// Empty state for no bookmarks
class AppEmptyStateNoBookmarks extends StatelessWidget {
  final VoidCallback? onBrowse;

  const AppEmptyStateNoBookmarks({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.bookmark_border,
      title: 'No Bookmarks',
      message: 'Save articles to read later by tapping the bookmark icon',
      action: onBrowse != null
          ? AppButtonSecondary(
              text: 'Browse Articles',
              onPressed: onBrowse,
            )
          : null,
    );
  }
}

/// Empty state for no highlights
class AppEmptyStateNoHighlights extends StatelessWidget {
  final VoidCallback? onBrowse;

  const AppEmptyStateNoHighlights({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.highlight_alt,
      title: 'No Highlights',
      message: 'Start highlighting text in articles to save your favorite quotes',
      action: onBrowse != null
          ? AppButtonSecondary(
              text: 'Browse Articles',
              onPressed: onBrowse,
            )
          : null,
    );
  }
}

/// Empty state for no articles
class AppEmptyStateNoArticles extends StatelessWidget {
  final VoidCallback? onCreate;
  final bool isAuthenticated;

  const AppEmptyStateNoArticles({
    super.key,
    this.onCreate,
    this.isAuthenticated = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated && onCreate != null) {
      return AppEmptyState(
        icon: Icons.edit_outlined,
        title: 'No Articles Yet',
        message: 'Start writing your first story',
        action: AppButton(
          text: 'Write Article',
          onPressed: onCreate,
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.article_outlined,
      title: 'No Articles',
      message: 'There are no articles to display',
    );
  }
}

/// Empty state for no comments
class AppEmptyStateNoComments extends StatelessWidget {
  final VoidCallback? onAddComment;

  const AppEmptyStateNoComments({super.key, this.onAddComment});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.comment_outlined,
      title: 'No Comments Yet',
      message: 'Be the first to comment on this article',
      action: onAddComment != null
          ? AppButton(
              text: 'Add Comment',
              onPressed: onAddComment,
            )
          : null,
    );
  }
}

/// Empty state for no notifications
class AppEmptyStateNoNotifications extends StatelessWidget {
  const AppEmptyStateNoNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.notifications_none,
      title: 'No New Notifications',
      message: 'You will see notifications here when you receive them',
    );
  }
}

/// Empty state for no followers
class AppEmptyStateNoFollowers extends StatelessWidget {
  const AppEmptyStateNoFollowers({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.people_outline,
      title: 'No Followers Yet',
      message: 'Your followers will appear here',
    );
  }
}

/// Empty state for no following
class AppEmptyStateNoFollowing extends StatelessWidget {
  final VoidCallback? onDiscover;

  const AppEmptyStateNoFollowing({super.key, this.onDiscover});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.person_add_outlined,
      title: 'Not Following Anyone',
      message: 'Start following writers to see their articles in your feed',
      action: onDiscover != null
          ? AppButtonSecondary(
              text: 'Discover Writers',
              onPressed: onDiscover,
            )
          : null,
    );
  }
}
