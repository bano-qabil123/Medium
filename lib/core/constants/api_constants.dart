class ApiConstants {
  // Auth
  static const String authStateKey = 'auth_state';
  static const String userSessionKey = 'user_session';
  
  // Tables
  static const String profilesTable = 'profiles';
  static const String articlesTable = 'articles';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String bookmarksTable = 'bookmarks';
  static const String followsTable = 'follows';
  static const String tagsTable = 'tags';
  static const String articleTagsTable = 'article_tags';
  static const String notificationsTable = 'notifications';
  static const String viewsTable = 'views';
  
  // Storage paths
  static const String avatarStoragePath = 'avatars';
  static const String coverStoragePath = 'covers';
  static const String attachmentStoragePath = 'attachments';
  
  // RLS Policies
  static const String publicReadPolicy = 'Public read access';
  static const String authenticatedReadPolicy = 'Authenticated read access';
  static const String ownerWritePolicy = 'Owner write access';
  
  // Error codes
  static const String authError = 'auth_error';
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';
  static const String notFoundError = 'not_found_error';
  static const String unauthorizedError = 'unauthorized_error';
  static const String conflictError = 'conflict_error';
}
