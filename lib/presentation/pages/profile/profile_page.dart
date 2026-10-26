import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/article_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/article/article_card.dart';
import '../../widgets/layout/main_layout.dart';

/// Optimized profile page with ListView.builder
class ProfilePage extends ConsumerWidget {
  final String? username;
  
  const ProfilePage({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    final isCurrentUser = username == null || 
        (currentUser != null && currentUser.username == username);
    
    final userId = isCurrentUser && currentUser != null 
        ? currentUser.id 
        : username;
    
    final articlesAsync = userId != null 
        ? ref.watch(userArticlesProvider(userId))
        : const AsyncValue.data([]);
    
    return MainLayout(
      key: ValueKey('profile-${username}'),
      title: isCurrentUser ? 'My Profile' : username ?? 'Profile',
      showBackButton: !isCurrentUser,
      actions: [
        if (isCurrentUser)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            splashRadius: 24,
          ),
      ],
      floatingActionButton: isCurrentUser 
          ? FloatingActionButton(
              onPressed: () => context.push('/article/editor'),
              child: const Icon(Icons.add),
            )
          : null,
      child: CustomScrollView(
        slivers: [
          // Profile Header with RepaintBoundary
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: _buildProfileHeader(context, ref, isCurrentUser, currentUser),
            ),
          ),
          
          // Articles Section with ListView.builder
          SliverFillRemaining(
            hasScrollBody: false,
            child: articlesAsync.when(
              loading: () => const Center(child: AppLoading()),
              error: (error, stack) => AppEmptyStateError(
                message: error.toString(),
                onRetry: () => ref.refresh(userArticlesProvider(userId)),
              ),
              data: (articles) {
                if (articles.isEmpty) {
                  return AppEmptyStateNoArticles(
                    isCurrentUser: isCurrentUser,
                    onCreateArticle: () => context.push('/article/editor'),
                  );
                }
                
                // Use ListView.builder for smooth scrolling
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ArticleCardCompact(
                          key: ValueKey(articles[index].id),
                          article: articles[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context, 
    WidgetRef ref, 
    bool isCurrentUser, 
    dynamic currentUser,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar with RepaintBoundary
          RepaintBoundary(
            child: AppAvatarLarge(
              imageUrl: isCurrentUser && currentUser != null 
                  ? currentUser.avatarUrl 
                  : null,
              name: isCurrentUser && currentUser != null 
                  ? currentUser.fullName 
                  : username,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            isCurrentUser && currentUser != null 
                ? currentUser.fullName 
                : username ?? 'Unknown User',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Username
          if (isCurrentUser && currentUser != null && currentUser.username != null)
            Text(
              '@${currentUser.username}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Bio
          if (isCurrentUser && currentUser != null && currentUser.bio != null)
            Text(
              currentUser.bio!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 24),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('Articles', isCurrentUser && currentUser != null 
                  ? currentUser.articlesCount.toString() 
                  : '0'),
              const SizedBox(width: 32),
              _buildStat('Followers', isCurrentUser && currentUser != null 
                  ? currentUser.followersCount.toString() 
                  : '0'),
              const SizedBox(width: 32),
              _buildStat('Following', isCurrentUser && currentUser != null 
                  ? currentUser.followingCount.toString() 
                  : '0'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Follow/Edit Button
          if (isCurrentUser)
            AppButton(
              text: 'Edit Profile',
              onPressed: () {
                // TODO: Navigate to edit profile
              },
              fullWidth: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          else
            AppButtonSecondary(
              text: 'Follow',
              onPressed: () {
                // TODO: Follow user
              },
              fullWidth: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          
          const SizedBox(height: 24),
          const AppDivider(),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          Helpers.formatNumber(int.parse(value)),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
