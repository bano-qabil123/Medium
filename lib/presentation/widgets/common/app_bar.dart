import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/widgets/common/app_icon_button.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final bool centerTitle;
  
  const AppBarWidget({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.showSearch = false,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: centerTitle,
      title: title != null 
          ? Text(
              title!,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      leading: leading ?? (
        showBackButton 
            ? AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              )
            : null
      ),
      actions: [
        if (showSearch)
          AppIconButton(
            icon: Icons.search,
            onPressed: onSearchPressed ?? () {},
          ),
        if (onNotificationPressed != null)
          AppIconButton(
            icon: Icons.notifications_outlined,
            onPressed: onNotificationPressed,
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SliverAppBarWidget extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  
  const SliverAppBarWidget({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.pinned = true,
    this.floating = true,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      title: title != null 
          ? Text(
              title!,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      leading: leading ?? (
        showBackButton 
            ? AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              )
            : null
      ),
      actions: actions,
    );
  }
}
