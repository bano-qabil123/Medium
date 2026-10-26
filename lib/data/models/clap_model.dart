import 'package:freezed_annotation/freezed_annotation.dart';

part 'clap_model.freezed.dart';
part 'clap_model.g.dart';

@freezed
class ClapModel with _$ClapModel {
  const factory ClapModel({
    required String id,
    required String userId,
    required String articleId,
    @Default(1) int count,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ClapModel;

  factory ClapModel.fromJson(Map<String, dynamic> json) =>
      _$ClapModelFromJson(json);

  factory ClapModel.fromSupabase(Map<String, dynamic> json) {
    return ClapModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      articleId: json['article_id'] as String? ?? '',
      count: json['count'] as int? ?? 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'article_id': articleId,
      'count': count,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Increment clap count
  ClapModel increment() {
    return copyWith(
      count: count + 1,
      updatedAt: DateTime.now(),
    );
  }
}
