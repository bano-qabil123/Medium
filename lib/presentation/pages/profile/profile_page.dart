import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/extensions.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/models/user_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_avatar.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_divider.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? username;

  const ProfilePage({super.key, this.username});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    
    return userAsync.when(
      loading: () => MainLayout(
        title: 'Profile',
        child: const Center(child: AppLoading()),
      ),
      error: (error, stack) => MainLayout(
        title: 'Profile',
        child: AppEmptyStateError(
          message: error.toString(),
          onRetry: () => ref.refresh(currentUserProvider),
        ),
      ),
      data: (user) {
        if (user == null) {
          return MainLayout(
            title: 'Profile',
            child: AppEmptyState(
              icon: Icons.person_outline,
              title: 'Not Signed In',
              message: 'Please sign in to view your profile',
              action: AppButton(
                text: 'Sign In',
                onPressed: () => context.push('/login'),
              ),
            ),
          );
        }

        return _buildProfileContent(context, user);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return MainLayout(
      title: user.displayName ?? 'Profile',
      showBackButton: widget.username != null,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
      child: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user),
          ),
          
          // Stats
          SliverToBoxAdapter(
            child: _ProfileStats(user: user),
          ),
          
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingLarge,
                ),
                child: Text(
                  user.bio!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: AppDivider()),
          ],
          
          // User's articles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Articles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppButtonSecondary(
                    text: 'New Article',
                    onPressed: () => context.push('/article/editor'),
                    fullWidth: false,
                  ),
                ],
              ),
            ),
          ),
          
          // Articles list
          _UserArticlesList(userId: user.id),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Avatar
          AppAvatar(
            key: ValueKey('profile-avatar-${user.id}'),
            imageUrl: user.avatarUrl,
            name: user.displayName,
            size: AppDimensions.avatarSizeLarge,
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Name
          Text(
            user.displayName ?? 'Unknown',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Username
          if (user.username != null && user.username!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXSmall),
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Edit profile button
          AppButtonSecondary(
            text: 'Edit Profile',
            onPressed: () => context.push('/profile/edit'),
            fullWidth: false,
            leadingIcon: const Icon(Icons.edit_outlined, size: AppDimensions.iconSmall),
          ),
          
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final UserModel user;

  const _ProfileStats({required this.user});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(context, 'Articles', user.articleCount),
            _buildStat(context, 'Followers', user.followerCount),
            _buildStat(context, 'Following', user.followingCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UserArticlesList extends ConsumerWidget {
  final String userId;

  const _UserArticlesList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(userArticlesProvider(userId));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      sliver: articlesAsync.when(
        loading: () => SliverToBoxAdapter(
          child: Column(
            children: List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.spacingMedium),
              child: ArticleCardShimmer(),
            )),
          ),
        ),
        error: (error, stack) => SliverToBoxAdapter(
          child: AppEmptyStateError(
            message: error.toString(),
            onRetry: () => ref.refresh(userArticlesProvider(userId)),
          ),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return SliverToBoxAdapter(
              child: AppEmptyStateNoArticles(
                isAuthenticated: true,
                onCreate: () => context.push('/article/editor'),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                  child: ArticleCard(
                    key: ValueKey('profile-article-${article.id}'),
                    article: article,
                    onTap: () => context.push('/article/${article.id}'),
                    showActions: false,
                  ),
                );
              },
              childCount: articles.length,
            ),
          );
        },
      ),
    );
  }
}

// Providers
final userArticlesProvider = FutureProvider.family<List<ArticleModel>, String>((ref, userId) async {
  final repository = ref.watch(articleRepositoryProvider);
  return await repository.getArticlesByUser(userId);
});

// Article Repository extension
class ArticleRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  Future<List<ArticleModel>> getArticlesByUser(String userId) async {
    try {
      final response = await _supabase
          .from('articles')
          .select('*, author:users(*)')
          .eq('author_id', userId)
          .order('published_at', ascending: false);

      return (response as List)
          .map((json) => ArticleModel.fromSupabase(json, author: json['author'] != null 
            ? UserModel.fromSupabase(json['author'] as Map<String, dynamic>) 
            : null))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});

class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Container(
            width: double.infinity * 0.8,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXSmall),
          Container(
            width: double.infinity * 0.6,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            ),
          ),
        ],
      ),
    );
  }
}
