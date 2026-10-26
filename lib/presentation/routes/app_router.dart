import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/constants/app_constants.dart';
import 'package:medium_clone/presentation/pages/auth/login_page.dart';
import 'package:medium_clone/presentation/pages/auth/signup_page.dart';
import 'package:medium_clone/presentation/pages/home/home_page.dart';
import 'package:medium_clone/presentation/pages/article/article_detail_page.dart';
import 'package:medium_clone/presentation/pages/article/article_editor_page.dart';
import 'package:medium_clone/presentation/pages/profile/profile_page.dart';
import 'package:medium_clone/presentation/pages/settings/settings_page.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Route names
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String articleDetail = '/article/:id';
  static const String articleEditor = '/article/editor';
  static const String editArticle = '/article/:id/edit';
  static const String profile = '/profile/:username';
  static const String myProfile = '/profile';
  static const String settings = '/settings';
  
  static String getArticleDetail(String id) => '/article/$id';
  static String getEditArticle(String id) => '/article/$id/edit';
  static String getProfile(String username) => '/profile/$username';
}

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: router,
    initialLocation: AppRoutes.home,
    routes: router._routes,
    redirect: router._redirectLogic,
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  
  RouterNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
  
  List<GoRoute> get _routes => [
    // Home
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
      routes: [
        // Article detail
        GoRoute(
          path: 'article/:id',
          builder: (context, state) {
            final id = state.pathParams['id']!;
            return ArticleDetailPage(articleId: id);
          },
          routes: [
            // Edit article
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id = state.pathParams['id']!;
                return ArticleEditorPage(articleId: id);
              },
            ),
          ],
        ),
        // New article
        GoRoute(
          path: 'article/editor',
          builder: (context, state) => const ArticleEditorPage(),
        ),
        // Profile
        GoRoute(
          path: 'profile/:username',
          builder: (context, state) {
            final username = state.pathParams['username']!;
            return ProfilePage(username: username);
          },
        ),
        // My profile
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        // Settings
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    // Login
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    // Signup
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupPage(),
    ),
  ];
  
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.signup;
    
    // If not authenticated and not on auth page, redirect to login
    if (!isAuthenticated && !isOnAuthPage) {
      return AppRoutes.login;
    }
    
    // If authenticated and on auth page, redirect to home
    if (isAuthenticated && isOnAuthPage) {
      return AppRoutes.home;
    }
    
    // Otherwise, no redirect
    return null;
  }
}
