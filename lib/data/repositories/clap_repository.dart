import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/clap_model.dart';

class ClapRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  /// Add or update a clap for an article
  Future<ClapModel> clapArticle({
    required String articleId,
    required String userId,
    int count = 1,
  }) async {
    try {
      // Check if user already clapped this article
      final existingClap = await _supabase
          .from('claps')
          .select()
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingClap != null) {
        // User already clapped - increment count
        final updatedCount = (existingClap['count'] as int? ?? 1) + count;
        final response = await _supabase
            .from('claps')
            .update({
              'count': updatedCount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingClap['id'])
            .select()
            .single();
        return ClapModel.fromSupabase(response);
      } else {
        // New clap
        final response = await _supabase
            .from('claps')
            .insert({
              'user_id': userId,
              'article_id': articleId,
              'count': count,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        return ClapModel.fromSupabase(response);
      }
    } catch (e) {
      throw Exception('Failed to clap article: $e');
    }
  }

  /// Remove a clap from an article (unclap)
  Future<void> unclapArticle({
    required String articleId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('claps')
          .delete()
          .eq('article_id', articleId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to unclap article: $e');
    }
  }

  /// Get clap count for an article
  Future<int> getClapCount(String articleId) async {
    try {
      final response = await _supabase
          .from('claps')
          .select('count', const FetchOptions(count: CountOption.exact))
          .eq('article_id', articleId);

      final totalCount = response.count ?? 0;
      return totalCount;
    } catch (e) {
      return 0;
    }
  }

  /// Check if user has clapped an article
  Future<bool> hasClapped({
    required String articleId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('claps')
          .select('id')
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get claps by user
  Future<List<ClapModel>> getClapsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('claps')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ClapModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get claps for an article with user details
  Future<List<ClapModel>> getClapsForArticle(String articleId) async {
    try {
      final response = await _supabase
          .from('claps')
          .select()
          .eq('article_id', articleId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ClapModel.fromSupabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
