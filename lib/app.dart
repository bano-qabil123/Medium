import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/pages/auth/login_page.dart';
import 'package:medium_clone/presentation/pages/auth/signup_page.dart';
import 'package:medium_clone/presentation/pages/home/home_page.dart';
import 'package:medium_clone/presentation/pages/article/article_detail_page.dart';
import 'package:medium_clone/presentation/pages/article/article_editor_page.dart';
import 'package:medium_clone/presentation/pages/profile/profile_page.dart';
import 'package:medium_clone/presentation/pages/settings/settings_page.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/routes/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Medium Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
