class AppConstants {
  static const String appName = 'Medium Clone';
  static const String appVersion = '1.0.0';
  
  // Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // Storage buckets
  static const String avatarsBucket = 'avatars';
  static const String coversBucket = 'covers';
  static const String attachmentsBucket = 'attachments';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Image constraints
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1200;
  static const int imageCompressionQuality = 80;
  
  // Article
  static const int minArticleTitleLength = 5;
  static const int maxArticleTitleLength = 120;
  static const int minArticleContentLength = 50;
  
  // User
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Deep linking
  static const String deepLinkScheme = 'mediumclone';
  static const String deepLinkHost = 'callback';
  static const String webRedirectUrl = 'http://localhost:5000/callback';
}
