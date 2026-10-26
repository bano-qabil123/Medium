import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/helpers.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class ProfilePage extends ConsumerWidget {
  final String? username;
  
  const ProfilePage({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    final isCurrentUser = username == null || 
        (currentUser != null && currentUser.username == username);
    
    return MainLayout(
      title: isCurrentUser ? 'My Profile' : username ?? 'Profile',
      showBackButton: !isCurrentUser,
      actions: [
        if (isCurrentUser)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
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
          // Profile Header
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, ref, isCurrentUser, currentUser),
          ),
          
          // Articles
          SliverToBoxAdapter(
            child: _buildArticlesSection(context, ref, isCurrentUser, currentUser),
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
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          // Avatar
          AppAvatarLarge(
            imageUrl: isCurrentUser && currentUser != null 
                ? currentUser.avatarUrl 
                : null,
            name: isCurrentUser && currentUser != null 
                ? currentUser.fullName 
                : username,
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
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
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
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
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('Articles', isCurrentUser && currentUser != null 
                  ? currentUser.articlesCount.toString() 
                  : '0'),
              const SizedBox(width: AppDimensions.spacingXLarge),
              _buildStat('Followers', isCurrentUser && currentUser != null 
                  ? currentUser.followersCount.toString() 
                  : '0'),
              const SizedBox(width: AppDimensions.spacingXLarge),
              _buildStat('Following', isCurrentUser && currentUser != null 
                  ? currentUser.followingCount.toString() 
                  : '0'),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Follow/Edit Button
          if (isCurrentUser)
            AppButton(
              text: 'Edit Profile',
              onPressed: () {
                // TODO: Navigate to edit profile
              },
              fullWidth: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXLarge,
                vertical: AppDimensions.paddingMedium,
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
                horizontal: AppDimensions.paddingXLarge,
                vertical: AppDimensions.paddingMedium,
              ),
            ),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          const AppDivider(),
        ],
      ),
    );
  }

  Widget _buildArticlesSection(
    BuildContext context, 
    WidgetRef ref, 
    bool isCurrentUser, 
    dynamic currentUser,
  ) {
    final userId = isCurrentUser && currentUser != null 
        ? currentUser.id 
        : username;
    
    final articlesAsync = userId != null 
        ? ref.watch(userArticlesProvider(userId))
        : const AsyncValue.data([]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCurrentUser ? 'My Articles' : 'Articles',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrentUser)
                TextButton(
                  onPressed: () {
                    // TODO: Filter articles (drafts, published, etc.)
                  },
                  child: Row(
                    children: [
                      Text(
                        'Filter',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingXSmall),
                      const Icon(
                        Icons.filter_list,
                        size: AppDimensions.iconXSmall,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Articles List
        articlesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: AppLoading(),
          ),
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
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              child: Column(
                children: [
                  ...articles.map((article) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                        child: ArticleCardCompact(article: article),
                      )),
                ],
              ),
            );
          },
        ),
      ],
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
