import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medium_clone/data/models/highlight_model.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/data/models/user_model.dart';

part 'user_highlight_model.freezed.dart';
part 'user_highlight_model.g.dart';

@freezed
class UserHighlightModel with _$UserHighlightModel {
  const factory UserHighlightModel({
    required HighlightModel highlight,
    ArticleModel? article,
    UserModel? author,
  }) = _UserHighlightModel;

  factory UserHighlightModel.fromJson(Map<String, dynamic> json) =>
      _$UserHighlightModelFromJson(json);
  
  /// Get formatted text for display
  String get formattedText {
    if (highlight.text.length > 100) {
      return '${highlight.text.substring(0, 100)}...';
    }
    return highlight.text;
  }
  
  /// Get article title for display
  String get articleTitle => article?.title ?? 'Deleted Article';
  
  /// Get author name for display
  String get authorName => author?.displayName ?? 'Unknown';
  
  /// Get date for display
  String get formattedDate {
    if (highlight.createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(highlight.createdAt!);
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).ceil()} weeks ago';
    } else {
      return '${(difference.inDays / 30).ceil()} months ago';
    }
  }
}
