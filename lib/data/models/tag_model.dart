import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
class TagModel with _$TagModel {
  const factory TagModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    @Default(0) int articlesCount,
    @Default(false) bool isFollowing,
    DateTime? createdAt,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  factory TagModel.fromSupabase(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      articlesCount: json['articles_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  /// Convert to Supabase map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'articles_count': articlesCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get display name
  String get displayName => name;

  /// Copy with updated values
  TagModel copyWithUpdated({
    String? name,
    String? description,
  }) {
    final newSlug = name != null ? name.toSlug() : slug;
    return copyWith(
      name: name ?? this.name,
      slug: newSlug,
      description: description ?? this.description,
    );
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
