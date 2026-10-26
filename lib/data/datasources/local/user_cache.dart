import 'package:hive/hive.dart';
import 'package:medium_clone/data/models/user_model.dart';

/// Local cache for users using Hive
class UserCache {
  static const String boxName = 'users';
  late final Box<UserModel> _box;

  /// Initialize the cache
  Future<void> init() async {
    _box = await Hive.openBox<UserModel>(boxName);
  }

  /// Save a user to cache
  Future<void> saveUser(UserModel user) async {
    await _box.put(user.id, user);
  }

  /// Get a user from cache
  UserModel? getUser(String userId) {
    return _box.get(userId);
  }

  /// Get multiple users from cache
  List<UserModel> getUsers(List<String> userIds) {
    return userIds
        .map((id) => _box.get(id))
        .whereType<UserModel>()
        .toList();
  }

  /// Get all cached users
  List<UserModel> getAllUsers() {
    return _box.values.toList();
  }

  /// Delete a user from cache
  Future<void> deleteUser(String userId) async {
    await _box.delete(userId);
  }

  /// Clear all cached users
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Check if user is cached
  bool hasUser(String userId) {
    return _box.containsKey(userId);
  }

  /// Get user count
  int getUserCount() {
    return _box.length;
  }

  /// Close the box
  Future<void> close() async {
    await _box.close();
  }
}

/// Singleton instance
final userCache = UserCache();

/// Hive adapter for UserModel
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final id = reader.readString();
    final email = reader.readString();
    final displayName = reader.readString();
    final username = reader.readString();
    final avatarUrl = reader.readString();
    final bio = reader.readString();
    final website = reader.readString();
    final twitter = reader.readString();
    final location = reader.readString();
    final articleCount = reader.readInt();
    final followerCount = reader.readInt();
    final followingCount = reader.readInt();
    final createdAt = reader.readString();
    final updatedAt = reader.readString();

    return UserModel(
      id: id,
      email: email.isEmpty ? null : email,
      displayName: displayName.isEmpty ? null : displayName,
      username: username.isEmpty ? null : username,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      bio: bio.isEmpty ? null : bio,
      website: website.isEmpty ? null : website,
      twitter: twitter.isEmpty ? null : twitter,
      location: location.isEmpty ? null : location,
      articleCount: articleCount,
      followerCount: followerCount,
      followingCount: followingCount,
      createdAt: createdAt.isEmpty ? null : DateTime.parse(createdAt),
      updatedAt: updatedAt.isEmpty ? null : DateTime.parse(updatedAt),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.email ?? '');
    writer.writeString(obj.displayName ?? '');
    writer.writeString(obj.username ?? '');
    writer.writeString(obj.avatarUrl ?? '');
    writer.writeString(obj.bio ?? '');
    writer.writeString(obj.website ?? '');
    writer.writeString(obj.twitter ?? '');
    writer.writeString(obj.location ?? '');
    writer.writeInt(obj.articleCount);
    writer.writeInt(obj.followerCount);
    writer.writeInt(obj.followingCount);
    writer.writeString(obj.createdAt?.toIso8601String() ?? '');
    writer.writeString(obj.updatedAt?.toIso8601String() ?? '');
  }
}
