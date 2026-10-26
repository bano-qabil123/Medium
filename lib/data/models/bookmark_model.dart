import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_model.freezed.dart';
part 'bookmark_model.g.dart';

@freezed
class BookmarkModel with _$BookmarkModel {
  const factory BookmarkModel({
    required String id,
    required String userId,
    required String articleId,
    DateTime? createdAt,
  }) = _BookmarkModel;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);

  factory BookmarkModel.fromSupabase(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      articleId: json['article_id'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'article_id': articleId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
