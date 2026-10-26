import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'highlight_model.freezed.dart';
part 'highlight_model.g.dart';

@freezed
class HighlightModel with _$HighlightModel {
  const factory HighlightModel({
    required String id,
    required String userId,
    required String articleId,
    required String text,
    required int startIndex,
    required int endIndex,
    @Default('FFFFD700') String color,
    DateTime? createdAt,
  }) = _HighlightModel;

  factory HighlightModel.fromJson(Map<String, dynamic> json) =>
      _$HighlightModelFromJson(json);

  factory HighlightModel.fromSupabase(Map<String, dynamic> json) {
    return HighlightModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      articleId: json['article_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      startIndex: json['start_index'] as int? ?? 0,
      endIndex: json['end_index'] as int? ?? 0,
      color: json['color'] as String? ?? 'FFFFD700',
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
      'text': text,
      'start_index': startIndex,
      'end_index': endIndex,
      'color': color,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Get color from hex string
  Color get colorValue {
    try {
      return Color(int.parse(color, radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFFFFD700); // Default to gold
    }
  }
  
  /// Get background color for highlight (with opacity)
  Color get highlightColor => colorValue.withOpacity(0.3);
  
  /// Get border color for highlight
  Color get borderColor => colorValue.withOpacity(0.6);
}
