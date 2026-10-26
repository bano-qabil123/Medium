import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/highlight_model.dart';

class HighlightRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  /// Add a highlight to an article
  Future<HighlightModel> addHighlight({
    required String articleId,
    required String userId,
    required String text,
    required int startIndex,
    required int endIndex,
    String color = 'FFFFD700',
  }) async {
    try {
      // Check if highlight already exists for this selection
      final existing = await _supabase
          .from('highlights')
          .select()
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .eq('start_index', startIndex)
          .eq('end_index', endIndex)
          .maybeSingle();

      if (existing != null) {
        // Update existing highlight
        final response = await _supabase
            .from('highlights')
            .update({
              'color': color,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();
        return HighlightModel.fromSupabase(response);
      }

      // Create new highlight
      final response = await _supabase
          .from('highlights')
          .insert({
            'user_id': userId,
            'article_id': articleId,
            'text': text,
            'start_index': startIndex,
            'end_index': endIndex,
            'color': color,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return HighlightModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to add highlight: $e');
    }
  }

  /// Remove a highlight
  Future<void> removeHighlight(String highlightId) async {
    try {
      await _supabase
          .from('highlights')
          .delete()
          .eq('id', highlightId);
    } catch (e) {
      throw Exception('Failed to remove highlight: $e');
    }
  }

  /// Get highlights for an article by user
  Future<List<HighlightModel>> getHighlightsForArticle({
    required String articleId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('highlights')
          .select()
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HighlightModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all highlights for a user
  Future<List<HighlightModel>> getHighlightsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('highlights')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HighlightModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get highlight count for an article
  Future<int> getHighlightCount(String articleId) async {
    try {
      final response = await _supabase
          .from('highlights')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('article_id', articleId);
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if user has highlighted this selection
  Future<bool> hasHighlighted({
    required String articleId,
    required String userId,
    required int startIndex,
    required int endIndex,
  }) async {
    try {
      final response = await _supabase
          .from('highlights')
          .select('id')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .eq('start_index', startIndex)
          .eq('end_index', endIndex)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
