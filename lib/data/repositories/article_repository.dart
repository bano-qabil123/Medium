import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medium_clone/core/constants/api_constants.dart';
import 'package:medium_clone/core/constants/app_constants.dart';
import 'package:medium_clone/core/errors/exceptions.dart';
import 'package:medium_clone/data/datasources/remote/supabase_client.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/models/user_model.dart';

class ArticleRepository {
  final SupabaseClientService _supabaseClient;
  
  ArticleRepository(this._supabaseClient);
  
  /// Get articles feed
  Future<List<ArticleModel>> getArticlesFeed({
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? tag,
    String? authorId,
    String? searchQuery,
    bool onlyFollowing = false,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      
      PostgrestTransformBuilder query = _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(limit)
          .offset(offset);
      
      if (tag != null) {
        query = query.contains('tags', [tag]);
      }
      
      if (authorId != null) {
        query = query.eq('author_id', authorId);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.*$searchQuery*,content.ilike.*$searchQuery*');
      }
      
      if (onlyFollowing && userId != null) {
        // Get articles from users that the current user follows
        final followsResponse = await _supabaseClient.client
            .from(ApiConstants.userFollowsTable)
            .select('following_id')
            .eq('follower_id', userId)
            .execute();
        
        if (followsResponse.error == null && followsResponse.data != null) {
          final followingIds = followsResponse.data
              .map((follow) => follow['following_id'] as String)
              .toList();
          
          if (followingIds.isNotEmpty) {
            query = query.in_('author_id', followingIds);
          } else {
            // No follows, return empty list
            return [];
          }
        }
      }
      
      final response = await query.execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      final articles = (response.data as List<dynamic>? ?? [])
          .map((json) => ArticleModel.fromSupabase(
            json,
            author: json[ApiConstants.profilesTable] != null
                ? UserModel.fromSupabase(json[ApiConstants.profilesTable])
                : null,
          ))
          .toList();
      
      // Check if user has liked/bookmarked each article
      if (userId != null) {
        final articleIds = articles.map((a) => a.id).toList();
        
        // Check likes
        if (articleIds.isNotEmpty) {
          final likesResponse = await _supabaseClient.client
              .from(ApiConstants.clapsTable)
              .select('article_id')
              .eq('user_id', userId)
              .in_('article_id', articleIds)
              .execute();
          
          if (likesResponse.error == null) {
            final likedArticleIds = (likesResponse.data as List<dynamic>? ?? [])
                .map((like) => like['article_id'] as String)
                .toSet();
            
            for (final article in articles) {
              article.copyWith(isClapped: likedArticleIds.contains(article.id));
            }
          }
        }
        
        // Check bookmarks
        if (articleIds.isNotEmpty) {
          final bookmarksResponse = await _supabaseClient.client
              .from(ApiConstants.bookmarksTable)
              .select('article_id')
              .eq('user_id', userId)
              .in_('article_id', articleIds)
              .execute();
          
          if (bookmarksResponse.error == null) {
            final bookmarkedArticleIds = (bookmarksResponse.data as List<dynamic>? ?? [])
                .map((bookmark) => bookmark['article_id'] as String)
                .toSet();
            
            for (final article in articles) {
              article.copyWith(isBookmarked: bookmarkedArticleIds.contains(article.id));
            }
          }
        }
      }
      
      return articles;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get article by ID
  Future<ArticleModel> getArticleById(String articleId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      
      final response = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('id', articleId)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'Article not found',
          code: 'article_not_found',
        );
      }
      
      final article = ArticleModel.fromSupabase(
        response.data,
        author: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
      
      // Check if user has liked/bookmarked the article
      if (userId != null) {
        final likesResponse = await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .select('id')
            .eq('user_id', userId)
            .eq('article_id', articleId)
            .maybeSingle()
            .execute();
        
        final bookmarksResponse = await _supabaseClient.client
            .from(ApiConstants.bookmarksTable)
            .select('id')
            .eq('user_id', userId)
            .eq('article_id', articleId)
            .maybeSingle()
            .execute();
        
        return article.copyWith(
          isClapped: likesResponse.data != null,
          isBookmarked: bookmarksResponse.data != null,
        );
      }
      
      return article;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Get article by slug
  Future<ArticleModel> getArticleBySlug(String slug) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      
      final response = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('slug', slug)
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      if (response.data == null) {
        throw const NotFoundException(
          message: 'Article not found',
          code: 'article_not_found',
        );
      }
      
      final article = ArticleModel.fromSupabase(
        response.data,
        author: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
      
      // Check if user has liked/bookmarked the article
      if (userId != null) {
        final likesResponse = await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .select('id')
            .eq('user_id', userId)
            .eq('article_id', article.id)
            .maybeSingle()
            .execute();
        
        final bookmarksResponse = await _supabaseClient.client
            .from(ApiConstants.bookmarksTable)
            .select('id')
            .eq('user_id', userId)
            .eq('article_id', article.id)
            .maybeSingle()
            .execute();
        
        return article.copyWith(
          isClapped: likesResponse.data != null,
          isBookmarked: bookmarksResponse.data != null,
        );
      }
      
      return article;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Create article
  Future<ArticleModel> createArticle({
    required String title,
    required String content,
    String? coverImageUrl,
    List<String>? tags,
    String status = 'draft',
    String visibility = 'public',
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      final slug = title.toSlug();
      final readTime = (content.split(RegExp(r'\s+')).length / 200).ceil();
      final excerpt = content
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .substring(0, 160 < content.length ? 160 : content.length);
      
      final articleData = {
        'title': title,
        'slug': slug,
        'content': content,
        'excerpt': excerpt,
        'cover_image_url': coverImageUrl,
        'author_id': userId,
        'status': status,
        'visibility': visibility,
        'read_time_minutes': readTime,
        'tags': tags ?? [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (status == 'published') {
        articleData['published_at'] = DateTime.now().toIso8601String();
      }
      
      final response = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .insert(articleData)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return ArticleModel.fromSupabase(
        response.data,
        author: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Update article
  Future<ArticleModel> updateArticle({
    required String articleId,
    String? title,
    String? content,
    String? coverImageUrl,
    List<String>? tags,
    String? status,
    String? visibility,
  }) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Verify article exists and belongs to user
      final existingArticle = await getArticleById(articleId);
      if (existingArticle.authorId != userId) {
        throw const UnauthorizedException(
          message: 'You can only update your own articles',
          code: 'unauthorized_update',
        );
      }
      
      final updates = <String, dynamic>{};
      
      if (title != null) {
        updates['title'] = title;
        updates['slug'] = title.toSlug();
      }
      
      if (content != null) {
        updates['content'] = content;
        updates['excerpt'] = content
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim()
            .substring(0, 160 < content.length ? 160 : content.length);
        updates['read_time_minutes'] = (content.split(RegExp(r'\s+')).length / 200).ceil();
      }
      
      if (coverImageUrl != null) {
        updates['cover_image_url'] = coverImageUrl;
      }
      
      if (tags != null) {
        updates['tags'] = tags;
      }
      
      if (status != null) {
        updates['status'] = status;
        if (status == 'published') {
          updates['published_at'] = DateTime.now().toIso8601String();
        }
      }
      
      if (visibility != null) {
        updates['visibility'] = visibility;
      }
      
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .update(updates)
          .eq('id', articleId)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .single()
          .execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      return ArticleModel.fromSupabase(
        response.data,
        author: response.data[ApiConstants.profilesTable] != null
            ? UserModel.fromSupabase(response.data[ApiConstants.profilesTable])
            : null,
      );
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Delete article
  Future<void> deleteArticle(String articleId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Verify article exists and belongs to user
      final existingArticle = await getArticleById(articleId);
      if (existingArticle.authorId != userId) {
        throw const UnauthorizedException(
          message: 'You can only delete your own articles',
          code: 'unauthorized_delete',
        );
      }
      
      // Delete cover image if it exists
      if (existingArticle.hasCoverImage) {
        final coverPath = existingArticle.coverImage.split('/').last;
        await _supabaseClient.deleteFile(
          AppConstants.coversBucket,
          'covers/$coverPath',
        );
      }
      
      await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .delete()
          .eq('id', articleId)
          .execute();
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Like article
  Future<bool> likeArticle(String articleId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Check if already liked
      final existingLike = await _supabaseClient.client
          .from(ApiConstants.clapsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle()
          .execute();
      
      if (existingLike.data != null) {
        // Unlike
        await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .delete()
            .eq('id', existingLike.data['id'])
            .execute();
        return false;
      } else {
        // Like
        await _supabaseClient.client
            .from(ApiConstants.clapsTable)
            .insert({
              'user_id': userId,
              'article_id': articleId,
            })
            .execute();
        return true;
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Bookmark article
  Future<bool> bookmarkArticle(String articleId) async {
    try {
      final userId = _supabaseClient.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException(
          message: 'User not authenticated',
          code: 'unauthenticated',
        );
      }
      
      // Check if already bookmarked
      final existingBookmark = await _supabaseClient.client
          .from(ApiConstants.bookmarksTable)
          .select('id')
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle()
          .execute();
      
      if (existingBookmark.data != null) {
        // Unbookmark
        await _supabaseClient.client
            .from(ApiConstants.bookmarksTable)
            .delete()
            .eq('id', existingBookmark.data['id'])
            .execute();
        return false;
      } else {
        // Bookmark
        await _supabaseClient.client
            .from(ApiConstants.bookmarksTable)
            .insert({
              'user_id': userId,
              'article_id': articleId,
            })
            .execute();
        return true;
      }
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Upload cover image
  Future<String> uploadCoverImage(String articleId, List<int> bytes) async {
    try {
      final path = 'covers/$articleId.jpg';
      final url = await _supabaseClient.uploadFile(
        bucket: AppConstants.coversBucket,
        path: path,
        bytes: bytes,
        contentType: 'image/jpeg',
        upsert: true,
      );
      
      // Update article with new cover image URL
      await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .update({'cover_image_url': url})
          .eq('id', articleId)
          .execute();
      
      return url;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
  
  /// Increment article views
  Future<void> incrementViews(String articleId) async {
    try {
      await _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .update({'views': 'views + 1'})
          .eq('id', articleId)
          .execute();
    } catch (e) {
      // Don't throw error for view increment
    }
  }
  
  /// Get user articles
  Future<List<ArticleModel>> getUserArticles({
    required String userId,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? status,
  }) async {
    try {
      final currentUserId = _supabaseClient.currentUser?.id;
      
      PostgrestTransformBuilder query = _supabaseClient.client
          .from(ApiConstants.articlesTable)
          .select('*, ${ApiConstants.profilesTable}(*)')
          .eq('author_id', userId)
          .order('published_at', ascending: false)
          .limit(limit)
          .offset(offset);
      
      if (status != null) {
        query = query.eq('status', status);
      } else {
        // Only show published articles unless it's the current user
        if (currentUserId != userId) {
          query = query.eq('status', 'published');
        }
      }
      
      final response = await query.execute();
      
      if (response.error != null) {
        throw exceptionFromSupabaseError(response.error);
      }
      
      final articles = (response.data as List<dynamic>? ?? [])
          .map((json) => ArticleModel.fromSupabase(
            json,
            author: json[ApiConstants.profilesTable] != null
                ? UserModel.fromSupabase(json[ApiConstants.profilesTable])
                : null,
          ))
          .toList();
      
      // Check if user has liked/bookmarked each article
      if (currentUserId != null) {
        final articleIds = articles.map((a) => a.id).toList();
        
        if (articleIds.isNotEmpty) {
          final likesResponse = await _supabaseClient.client
              .from(ApiConstants.clapsTable)
              .select('article_id')
              .eq('user_id', currentUserId)
              .in_('article_id', articleIds)
              .execute();
          
          final bookmarksResponse = await _supabaseClient.client
              .from(ApiConstants.bookmarksTable)
              .select('article_id')
              .eq('user_id', currentUserId)
              .in_('article_id', articleIds)
              .execute();
          
          if (likesResponse.error == null && bookmarksResponse.error == null) {
            final likedArticleIds = (likesResponse.data as List<dynamic>? ?? [])
                .map((like) => like['article_id'] as String)
                .toSet();
            final bookmarkedArticleIds = (bookmarksResponse.data as List<dynamic>? ?? [])
                .map((bookmark) => bookmark['article_id'] as String)
                .toSet();
            
            return articles.map((article) => article.copyWith(
              isClapped: likedArticleIds.contains(article.id),
              isBookmarked: bookmarkedArticleIds.contains(article.id),
            )).toList();
          }
        }
      }
      
      return articles;
    } catch (e) {
      throw exceptionFromSupabaseError(e);
    }
  }
}
