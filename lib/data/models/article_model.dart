import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medium_clone/data/models/user_model.dart';

part 'article_model.freezed.dart';
part 'article_model.g.dart';

@freezed
class ArticleModel with _$ArticleModel {
  const factory ArticleModel({
    required String id,
    required String title,
    required String slug,
    required String content,
    String? excerpt,
    String? coverImageUrl,
    required String authorId,
    UserModel? author,
    @Default('draft') String status,
    @Default('public') String visibility,
    @fs.Timestamp() DateTime? publishedAt,
    @fs.Timestamp() DateTime? updatedAt,
    @fs.Timestamp() DateTime? createdAt,
    @Default(0) int readTimeMinutes,
    @Default(0) int views,
    @Default(0) int clapsCount,
    @Default(0) int commentsCount,
    @Default(0) int highlightsCount,
    @Default(false) bool isBookmarked,
    @Default(false) bool isClapped,
    @Default([]) List<String> tags,
  }) = _ArticleModel;

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  factory ArticleModel.fromSupabase(Map<String, dynamic> json, {UserModel? author}) {
    return ArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      content: json['content'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      authorId: json['author_id'] as String? ?? '',
      author: author,
      status: json['status'] as String? ?? 'draft',
      visibility: json['visibility'] as String? ?? 'public',
      publishedAt: json['published_at'] != null 
          ? DateTime.parse(json['published_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      clapsCount: json['claps_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      highlightsCount: json['highlights_count'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      isClapped: json['is_clapped'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => tag.toString())
          .toList() ?? [],
    );
  }

  /// Convert to Supabase map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'cover_image_url': coverImageUrl,
      'author_id': authorId,
      'status': status,
      'visibility': visibility,
      'published_at': publishedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'read_time_minutes': readTimeMinutes,
      'views': views,
      'claps_count': clapsCount,
      'comments_count': commentsCount,
      'highlights_count': highlightsCount,
      'tags': tags,
    };
  }

  /// Check if the article is published
  bool get isPublished => status == 'published';
  
  /// Check if the article is a draft
  bool get isDraft => status == 'draft';
  
  /// Check if the article is archived
  bool get isArchived => status == 'archived';
  
  /// Check if the article is public
  bool get isPublic => visibility == 'public';
  
  /// Check if the article is private
  bool get isPrivate => visibility == 'private';
  
  /// Check if the article has a cover image
  bool get hasCoverImage => coverImageUrl != null && coverImageUrl!.isNotEmpty;
  
  /// Check if the article has been clapped by current user
  bool get hasBeenClapped => isClapped;
  
  /// Check if the article has been bookmarked by current user
  bool get hasBeenBookmarked => isBookmarked;
  
  /// Get cover image URL or placeholder
  String get coverImage => coverImageUrl ?? '';
  
  /// Calculate read time from content (if not already set)
  ArticleModel withReadTime() {
    if (readTimeMinutes > 0) return this;
    final wordCount = content.split(RegExp(r'\s+')).length;
    final newReadTime = (wordCount / 200).ceil();
    return copyWith(readTimeMinutes: newReadTime);
  }

  /// Generate excerpt from content (if not already set)
  ArticleModel withExcerpt({int maxLength = 160}) {
    if (excerpt != null && excerpt!.isNotEmpty) return this;
    final cleanContent = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final newExcerpt = cleanContent
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, maxLength < cleanContent.length ? maxLength : cleanContent.length);
    return copyWith(excerpt: newExcerpt);
  }

  /// Copy with updated values
  ArticleModel copyWithUpdated({
    String? title,
    String? content,
    String? excerpt,
    String? coverImageUrl,
    String? status,
    String? visibility,
    DateTime? publishedAt,
    List<String>? tags,
  }) {
    final newSlug = title != null ? title.toSlug() : slug;
    return copyWith(
      title: title ?? this.title,
      slug: newSlug,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
    ).withReadTime().withExcerpt();
  }
}

/// Extension for string to slug conversion
extension on String {
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'--+'), '-');
  }
}
