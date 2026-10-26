import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/article_view_model.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ArticleViewRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  /// Track an article view
  Future<ArticleViewModel> trackView({
    required String articleId,
    String? userId,
    String? referrer,
  }) async {
    try {
      // Get device info
      String deviceInfo = 'Unknown';
      try {
        final deviceInfoPlugin = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          deviceInfo = '${androidInfo.manufacturer} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          deviceInfo = '${iosInfo.name} ${iosInfo.model}';
        }
      } catch (e) {
        deviceInfo = 'Unknown';
      }

      // Check if this user already viewed this article today
      final existingView = await _supabase
          .from('article_views')
          .select()
          .eq('article_id', articleId)
          .eq('user_id', userId)
          .gte('viewed_at', DateTime.now().subtract(const Duration(hours: 24)).toIso8601String())
          .maybeSingle();

      if (existingView != null) {
        // Already viewed today, don't count again
        return ArticleViewModel.fromSupabase(existingView);
      }

      // Create new view
      final response = await _supabase
          .from('article_views')
          .insert({
            'article_id': articleId,
            'user_id': userId,
            'viewed_at': DateTime.now().toIso8601String(),
            'referrer': referrer,
            'device_info': deviceInfo,
          })
          .select()
          .single();

      // Increment article view count
      await _supabase
          .from('articles')
          .update({
            'views': 'views + 1',
          })
          .eq('id', articleId);

      return ArticleViewModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to track view: $e');
    }
  }

  /// Get view count for an article
  Future<int> getViewCount(String articleId) async {
    try {
      final response = await _supabase
          .from('article_views')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('article_id', articleId);
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get views for an article over time
  Future<Map<String, int>> getViewsOverTime({
    required String articleId,
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'day',
  }) async {
    try {
      final response = await _supabase
          .from('article_views')
          .select('viewed_at')
          .eq('article_id', articleId)
          .gte('viewed_at', startDate.toIso8601String())
          .lte('viewed_at', endDate.toIso8601String())
          .order('viewed_at', ascending: true);

      final views = <String, int>{};
      for (final view in response as List) {
        final date = DateTime.parse(view['viewed_at'] as String);
        String key;
        if (groupBy == 'day') {
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'.toString();
        } else if (groupBy == 'week') {
          final week = (date.difference(startDate).inDays / 7).floor();
          key = 'Week ${week + 1}';
        } else {
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}'.toString();
        }
        views[key] = (views[key] ?? 0) + 1;
      }
      return views;
    } catch (e) {
      return {};
    }
  }

  /// Get popular articles (most viewed)
  Future<List<ArticleViewModel>> getPopularArticles({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('article_views')
          .select('article_id, count(*) as view_count')
          .groupBy('article_id')
          .order('view_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ArticleViewModel(
                id: json['id'] ?? '',
                articleId: json['article_id'] as String,
                viewedAt: null,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
