import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/models/comment_model.dart';
import 'package:medium_clone/data/models/user_model.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String type,
    String? articleId,
    ArticleModel? article,
    String? commentId,
    CommentModel? comment,
    String? fromUserId,
    UserModel? fromUser,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromSupabase(Map<String, dynamic> json, {
    ArticleModel? article,
    CommentModel? comment,
    UserModel? fromUser,
  }) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      articleId: json['article_id'] as String?,
      article: article,
      commentId: json['comment_id'] as String?,
      comment: comment,
      fromUserId: json['from_user_id'] as String?,
      fromUser: fromUser,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  /// Convert to Supabase map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'article_id': articleId,
      'comment_id': commentId,
      'from_user_id': fromUserId,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get notification message
  String get message {
    switch (type) {
      case 'new_comment':
        return fromUser?.displayName != null
            ? '${fromUser!.displayName} commented on your article'
            : 'Someone commented on your article';
      case 'new_like':
        return fromUser?.displayName != null
            ? '${fromUser!.displayName} liked your article'
            : 'Someone liked your article';
      case 'new_follower':
        return fromUser?.displayName != null
            ? '${fromUser!.displayName} started following you'
            : 'You have a new follower';
      case 'mention':
        return fromUser?.displayName != null
            ? '${fromUser!.displayName} mentioned you in a comment'
            : 'Someone mentioned you in a comment';
      default:
        return 'New notification';
    }
  }

  /// Get notification icon
  String get icon {
    switch (type) {
      case 'new_comment':
        return 'comment';
      case 'new_like':
        return 'heart';
      case 'new_follower':
        return 'user_add';
      case 'mention':
        return 'at';
      default:
        return 'bell';
    }
  }

  /// Check if the notification is unread
  bool get isUnread => !isRead;

  /// Mark as read
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }
}
