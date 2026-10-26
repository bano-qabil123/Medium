import 'dart:math';
import 'package:flutter/material.dart';

class Helpers {
  /// Generate a random ID
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomString(8)}';
  }
  
  /// Generate a random string of a specific length
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// Generate a slug from a string
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'--+'), '-');
  }
  
  /// Calculate estimated read time in minutes
  static int calculateReadTime(String text) {
    const wordsPerMinute = 200;
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / wordsPerMinute).ceil();
  }
  
  /// Format a number with commas (e.g., 1000 -> "1,000")
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
  
  /// Format a number as a short string (e.g., 1000 -> "1K", 1000000 -> "1M")
  static String formatShortNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }
  
  /// Format a date as a readable string
  static String formatDate(DateTime date, {String? format}) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${date.weekday}';
    } else if (difference.inDays < 365) {
      return '${date.month}/${date.day}';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
  
  /// Format a date as a relative time string
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
  
  /// Get the initials from a name
  static String getInitials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
  }
  
  /// Debounce a function
  static Function debounce(Function func, {Duration delay = const Duration(milliseconds: 300)}) {
    Timer? timer;
    return () {
      final args = func;
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }
  
  /// Throttle a function
  static Function throttle(Function func, {Duration delay = const Duration(milliseconds: 300)}) {
    bool isRunning = false;
    return () {
      if (!isRunning) {
        isRunning = true;
        func();
        Timer(delay, () => isRunning = false);
      }
    };
  }
  
  /// Check if a string is a valid URL
  static bool isValidUrl(String url) => Uri.tryParse(url)?.hasAbsolutePath ?? false;
  
  /// Check if a string is a valid email
  static bool isValidEmail(String email) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(email);
  
  /// Check if a string is a valid username (alphanumeric + underscore)
  static bool isValidUsername(String username) => RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  
  /// Get the file extension from a URL
  static String? getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot == -1) return null;
      return path.substring(lastDot + 1).toLowerCase();
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a file is an image
  static bool isImageFile(String url) {
    final extension = getFileExtension(url)?.toLowerCase();
    return extension != null && 
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'].contains(extension);
  }
  
  /// Get the dominant color from an image (placeholder - use actual image processing in production)
  static Future<Color> getDominantColor(String imageUrl) async {
    // In a real app, you would use a package like `palette_generator`
    // For now, return a default color
    return const Color(0xFF6B6B6B);
  }
  
  /// Generate a gradient from a color
  static LinearGradient generateGradient(Color color) {
    return LinearGradient(
      colors: [
        color.withOpacity(0.1),
        color.withOpacity(0.3),
        color.withOpacity(0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  /// Get a color from a string (for consistent avatars)
  static Color getColorFromString(String text) {
    final colors = [
      const Color(0xFFFF5722),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF03A9F4),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFCDDC39),
      const Color(0xFFFFEB3B),
      const Color(0xFFFFC107),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
    ];
    
    final hash = text.hashCode;
    return colors[hash % colors.length];
  }
  
  /// Generate a placeholder avatar
  static Widget buildPlaceholderAvatar(String text, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getColorFromString(text),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          getInitials(text),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  /// Check if the app is in debug mode
  static bool get isDebugMode {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }
  
  /// Print debug message (only in debug mode)
  static void debugPrint(dynamic message) {
    if (isDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  /// Print error message
  static void errorPrint(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    print('[ERROR] $message');
    if (error != null) print('[ERROR] Error: $error');
    if (stackTrace != null) print('[ERROR] Stack: $stackTrace');
  }
}
