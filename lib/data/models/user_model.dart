import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? website,
    String? twitterHandle,
    @Default(false) bool isVerified,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int articlesCount,
    @fs.Timestamp() DateTime? createdAt,
    @fs.Timestamp() DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      website: json['website'] as String?,
      twitterHandle: json['twitter_handle'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      articlesCount: json['articles_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Convert to Supabase map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'website': website,
      'twitter_handle': twitterHandle,
      'is_verified': isVerified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'articles_count': articlesCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get full name (display name or username)
  String get fullName => displayName ?? username ?? 'User';
  
  /// Get initials
  String get initials {
    final name = fullName;
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Check if the user has a valid avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Get avatar URL or placeholder
  String get avatar => avatarUrl ?? '';

  /// Copy with updated values
  UserModel copyWithUpdated({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? website,
    String? twitterHandle,
  }) {
    return copyWith(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      updatedAt: DateTime.now(),
    );
  }
}
