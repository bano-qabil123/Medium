import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/signup_page.dart';
import 'presentation/pages/article/article_detail_page.dart';
import 'presentation/pages/article/article_editor_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createRouter(ref);
    
    return MaterialApp.router(
      title: 'Medium Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: false, // Disable in production for performance
      redirect: (context, state) {
        final isAuth = ref.read(isAuthenticatedProvider);
        final isAuthPage = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/signup';
        
        // Don't block on async checks - use sync provider
        if (!isAuth && !isAuthPage) return '/login';
        if (isAuth && isAuthPage) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => const SignupPage(),
        ),
        GoRoute(
          path: '/article/:id',
          builder: (_, state) => ArticleDetailPage(
            key: ValueKey(state.pathParams['id']),
            articleId: state.pathParams['id']!,
          ),
        ),
        GoRoute(
          path: '/article/editor',
          builder: (_, __) => const ArticleEditorPage(),
        ),
        GoRoute(
          path: '/article/:id/edit',
          builder: (_, state) => ArticleEditorPage(
            key: ValueKey('edit-${state.pathParams["id"]}'),
            articleId: state.pathParams['id'],
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsPage(),
        ),
      ],
    );
  }
}
