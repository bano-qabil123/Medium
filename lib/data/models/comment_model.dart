import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medium_clone/data/models/user_model.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    required String articleId,
    required String userId,
    UserModel? user,
    String? parentId,
    required String content,
    @Default('pending') String status,
    @Default(0) int clapsCount,
    @Default(false) bool isClapped,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<CommentModel> replies,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  factory CommentModel.fromSupabase(Map<String, dynamic> json, {UserModel? user}) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      articleId: json['article_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      user: user,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      clapsCount: json['claps_count'] as int? ?? 0,
      isClapped: json['is_clapped'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      replies: [],
    );
  }

  /// Convert to Supabase map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'article_id': articleId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'status': status,
      'claps_count': clapsCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if the comment is approved
  bool get isApproved => status == 'approved';
  
  /// Check if the comment is pending
  bool get isPending => status == 'pending';
  
  /// Check if the comment is spam
  bool get isSpam => status == 'spam';
  
  /// Check if the comment is deleted
  bool get isDeleted => status == 'deleted';
  
  /// Check if the comment is a reply
  bool get isReply => parentId != null;
  
  /// Check if the comment has replies
  bool get hasReplies => replies.isNotEmpty;
  
  /// Get the depth of the comment (0 for top-level, 1 for reply, etc.)
  int get depth {
    if (!isReply) return 0;
    return 1; // In a real app, you would traverse up the parent chain
  }

  /// Copy with updated values
  CommentModel copyWithUpdated({
    String? content,
    String? status,
  }) {
    return copyWith(
      content: content ?? this.content,
      status: status ?? this.status,
      updatedAt: DateTime.now(),
    );
  }
}
