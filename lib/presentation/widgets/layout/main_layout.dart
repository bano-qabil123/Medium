import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/widgets/common/app_bar.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

class MainLayout extends ConsumerWidget {
  final String? title;
  final Widget child;
  final bool showBackButton;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  
  const MainLayout({
    super.key,
    this.title,
    required this.child,
    this.showBackButton = false,
    this.showSearch = false,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: title,
        showBackButton: showBackButton,
        showSearch: showSearch,
        onSearchPressed: onSearchPressed,
        onNotificationPressed: onNotificationPressed,
        actions: actions,
      ),
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar ?? (
        isAuthenticated ? const MainBottomNavigationBar() : null
      ),
    );
  }
}

class MainBottomNavigationBar extends ConsumerWidget {
  const MainBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    if (location == '/') {
      return 0;
    } else if (location.startsWith('/search')) {
      return 1;
    } else if (location.startsWith('/article/editor')) {
      return 2;
    } else if (location.startsWith('/notifications')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        // TODO: Navigate to search
        break;
      case 2:
        context.go('/article/editor');
        break;
      case 3:
        // TODO: Navigate to notifications
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final List<Widget>? actions;
  
  const MainAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showSearch = false,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBarWidget(
      title: title,
      showBackButton: showBackButton,
      showSearch: showSearch,
      onSearchPressed: onSearchPressed,
      onNotificationPressed: onNotificationPressed,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainLoadingOverlay extends StatelessWidget {
  const MainLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingOverlay();
  }
}
