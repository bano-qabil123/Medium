import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/tag_model.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Tag Repository
class TagRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  /// Get all tags
  Future<List<TagModel>> getAllTags() async {
    try {
      final response = await _supabase
          .from('tags')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => TagModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get trending tags (most used in last 7 days)
  Future<List<TagModel>> getTrendingTags({int limit = 10}) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      // Get article tags from the last 7 days
      final response = await _supabase
          .from('article_tags')
          .select('tag_id, count(*) as article_count')
          .gte('created_at', sevenDaysAgo.toIso8601String())
          .groupBy('tag_id')
          .order('article_count', ascending: false)
          .limit(limit);

      // Get tag details
      final tagIds = (response as List).map((json) => json['tag_id'] as String).toList();
      
      if (tagIds.isEmpty) return [];

      final tagsResponse = await _supabase
          .from('tags')
          .select()
          .in_('id', tagIds);

      return (tagsResponse as List)
          .map((json) => TagModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get tags for an article
  Future<List<TagModel>> getTagsForArticle(String articleId) async {
    try {
      final response = await _supabase
          .from('article_tags')
          .select('tags(*)')
          .eq('article_id', articleId);

      return (response as List)
          .map((json) => TagModel.fromSupabase(json['tags'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get articles by tag
  Future<List<String>> getArticlesByTag(String tagId, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('article_tags')
          .select('article_id')
          .eq('tag_id', tagId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => json['article_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Follow a tag
  Future<void> followTag(String tagId, String userId) async {
    try {
      await _supabase
          .from('user_followed_tags')
          .insert({
            'user_id': userId,
            'tag_id': tagId,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to follow tag: $e');
    }
  }

  /// Unfollow a tag
  Future<void> unfollowTag(String tagId, String userId) async {
    try {
      await _supabase
          .from('user_followed_tags')
          .delete()
          .eq('user_id', userId)
          .eq('tag_id', tagId);
    } catch (e) {
      throw Exception('Failed to unfollow tag: $e');
    }
  }

  /// Check if user follows a tag
  Future<bool> isFollowingTag(String tagId, String userId) async {
    try {
      final response = await _supabase
          .from('user_followed_tags')
          .select('id')
          .eq('user_id', userId)
          .eq('tag_id', tagId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get tags followed by user
  Future<List<TagModel>> getFollowedTags(String userId) async {
    try {
      final response = await _supabase
          .from('user_followed_tags')
          .select('tags(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TagModel.fromSupabase(json['tags'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search tags
  Future<List<TagModel>> searchTags(String query) async {
    try {
      final response = await _supabase
          .from('tags')
          .select()
          .ilike('name', '%$query%')
          .limit(10);

      return (response as List)
          .map((json) => TagModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

// Tag Repository Provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

// All Tags Provider
final allTagsProvider = FutureProvider<List<TagModel>>((ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getAllTags();
});

// Trending Tags Provider
final trendingTagsProvider = FutureProvider<List<TagModel>>((ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getTrendingTags();
});

// Tags for Article Provider
final articleTagsProvider = FutureProvider.family<List<TagModel>, String>((ref, articleId) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getTagsForArticle(articleId);
});

// Followed Tags Provider
final followedTagsProvider = FutureProvider<List<TagModel>>((ref) async {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  if (userId == null) return [];
  
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getFollowedTags(userId);
});

// Tag Follow State Provider
class TagFollowNotifier extends StateNotifier<AsyncValue<bool>> {
  final TagRepository _repository;
  final String _tagId;
  final String? _userId;

  TagFollowNotifier(this._repository, this._tagId, this._userId)
      : super(const AsyncValue.data(false));

  Future<void> loadStatus() async {
    if (_userId == null) {
      state = const AsyncValue.data(false);
      return;
    }

    try {
      final isFollowing = await _repository.isFollowingTag(_tagId, _userId!);
      state = AsyncValue.data(isFollowing);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleFollow() async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('Please sign in to follow tags'),
        StackTrace.current,
      );
      return;
    }

    try {
      final currentStatus = state.valueOrNull ?? false;
      if (currentStatus) {
        await _repository.unfollowTag(_tagId, _userId!);
      } else {
        await _repository.followTag(_tagId, _userId!);
      }
      await loadStatus();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Tag Follow Provider for a specific tag
final tagFollowProvider = StateNotifierProvider.family<
  TagFollowNotifier,
  AsyncValue<bool>,
  String
>((ref, tagId) {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  final repository = ref.watch(tagRepositoryProvider);
  final notifier = TagFollowNotifier(repository, tagId, userId);
  notifier.loadStatus();
  return notifier;
});

// Is Following Tag Provider
final isFollowingTagProvider = Provider.family<bool, String>((ref, tagId) {
  final followState = ref.watch(tagFollowProvider(tagId));
  return followState.valueOrNull ?? false;
});
