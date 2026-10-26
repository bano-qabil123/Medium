import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/bookmark_model.dart';

class BookmarkRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  /// Add a bookmark for an article
  Future<BookmarkModel> bookmarkArticle({
    required String articleId,
    required String userId,
  }) async {
    try {
      // Check if already bookmarked
      final existing = await _supabase
          .from('bookmarks')
          .select()
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Already bookmarked, return existing
        return BookmarkModel.fromSupabase(existing);
      }

      // Create new bookmark
      final response = await _supabase
          .from('bookmarks')
          .insert({
            'user_id': userId,
            'article_id': articleId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return BookmarkModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to bookmark article: $e');
    }
  }

  /// Remove a bookmark
  Future<void> removeBookmark({
    required String articleId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('article_id', articleId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  /// Check if user has bookmarked an article
  Future<bool> hasBookmarked({
    required String articleId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select('id')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get bookmarked articles for a user
  Future<List<BookmarkModel>> getBookmarksByUser(String userId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BookmarkModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get bookmark count for an article
  Future<int> getBookmarkCount(String articleId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('article_id', articleId);
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
