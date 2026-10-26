import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

/// SEO and Social Meta Tags Manager
/// This widget manages meta tags for web and social sharing
class AppMeta extends StatelessWidget {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String? type;
  final String? siteName;
  final String? author;
  final DateTime? publishedTime;
  final DateTime? modifiedTime;

  const AppMeta({
    super.key,
    required this.title,
    this.description,
    this.imageUrl,
    this.url,
    this.type = 'article',
    this.siteName = 'Medium Clone',
    this.author,
    this.publishedTime,
    this.modifiedTime,
  });

  @override
  Widget build(BuildContext context) {
    // This widget doesn't render anything visible
    // It's used to manage meta tags for web crawlers and social sharing
    return const SizedBox.shrink();
  }

  /// Generate HTML meta tags for web
  String get htmlMetaTags {
    final buffer = StringBuffer();
    
    // Standard meta tags
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    
    // Title
    buffer.writeln('<title>$title</title>');
    
    // Description
    if (description != null && description!.isNotEmpty) {
      buffer.writeln('<meta name="description" content="${_escapeHtml(description!)}">');
    }
    
    // Open Graph / Facebook
    buffer.writeln('<!-- Open Graph / Facebook -->');
    buffer.writeln('<meta property="og:type" content="$type">');
    buffer.writeln('<meta property="og:site_name" content="$siteName">');
    buffer.writeln('<meta property="og:title" content="${_escapeHtml(title)}">');
    if (description != null && description!.isNotEmpty) {
      buffer.writeln('<meta property="og:description" content="${_escapeHtml(description!)}">');
    }
    if (url != null && url!.isNotEmpty) {
      buffer.writeln('<meta property="og:url" content="$url">');
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      buffer.writeln('<meta property="og:image" content="$imageUrl">');
      buffer.writeln('<meta property="og:image:width" content="1200">');
      buffer.writeln('<meta property="og:image:height" content="630">');
    }
    if (publishedTime != null) {
      buffer.writeln('<meta property="og:published_time" content="${publishedTime!.toIso8601String()}">');
    }
    if (modifiedTime != null) {
      buffer.writeln('<meta property="og:modified_time" content="${modifiedTime!.toIso8601String()}">');
    }
    if (author != null && author!.isNotEmpty) {
      buffer.writeln('<meta property="og:author" content="$author">');
    }
    
    // Twitter Card
    buffer.writeln('<!-- Twitter Card -->');
    buffer.writeln('<meta name="twitter:card" content="summary_large_image">');
    buffer.writeln('<meta name="twitter:title" content="${_escapeHtml(title)}">');
    if (description != null && description!.isNotEmpty) {
      buffer.writeln('<meta name="twitter:description" content="${_escapeHtml(description!)}">');
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      buffer.writeln('<meta name="twitter:image" content="$imageUrl">');
    }
    if (siteName != null && siteName!.isNotEmpty) {
      buffer.writeln('<meta name="twitter:site" content="@$siteName">');
    }
    if (author != null && author!.isNotEmpty) {
      buffer.writeln('<meta name="twitter:creator" content="@$author">');
    }
    
    // Schema.org markup
    buffer.writeln('<!-- Schema.org markup -->');
    buffer.writeln('<meta itemprop="name" content="${_escapeHtml(title)}">');
    if (description != null && description!.isNotEmpty) {
      buffer.writeln('<meta itemprop="description" content="${_escapeHtml(description!)}">');
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      buffer.writeln('<meta itemprop="image" content="$imageUrl">');
    }
    if (publishedTime != null) {
      buffer.writeln('<meta itemprop="datePublished" content="${publishedTime!.toIso8601String()}">');
    }
    if (modifiedTime != null) {
      buffer.writeln('<meta itemprop="dateModified" content="${modifiedTime!.toIso8601String()}">');
    }
    if (author != null && author!.isNotEmpty) {
      buffer.writeln('<meta itemprop="author" content="$author">');
    }
    
    return buffer.toString();
  }

  /// Escape HTML special characters
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

/// Helper class to generate meta tags for different page types
class MetaTagGenerator {
  /// Generate meta tags for article page
  static AppMeta article({
    required String title,
    required String articleId,
    String? description,
    String? imageUrl,
    String? author,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return AppMeta(
      title: title,
      description: description,
      imageUrl: imageUrl,
      url: 'https://medium-clone.com/article/$articleId',
      type: 'article',
      siteName: 'Medium Clone',
      author: author,
      publishedTime: publishedAt,
      modifiedTime: updatedAt,
    );
  }

  /// Generate meta tags for profile page
  static AppMeta profile({
    required String username,
    required String displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return AppMeta(
      title: '$displayName (@$username) - Medium Clone',
      description: bio,
      imageUrl: avatarUrl,
      url: 'https://medium-clone.com/@$username',
      type: 'profile',
      siteName: 'Medium Clone',
      author: displayName,
    );
  }

  /// Generate meta tags for tag page
  static AppMeta tag({
    required String tagName,
    String? description,
  }) {
    return AppMeta(
      title: '#$tagName - Medium Clone',
      description: description ?? 'Articles tagged with $tagName',
      url: 'https://medium-clone.com/tag/$tagName',
      type: 'website',
      siteName: 'Medium Clone',
    );
  }

  /// Generate meta tags for home page
  static AppMeta home() {
    return AppMeta(
      title: 'Medium Clone - Read and Write Stories',
      description: 'Discover and share amazing stories from writers around the world',
      url: 'https://medium-clone.com',
      type: 'website',
      siteName: 'Medium Clone',
    );
  }

  /// Generate meta tags for search page
  static AppMeta search(String query) {
    return AppMeta(
      title: 'Search: $query - Medium Clone',
      description: 'Search results for "$query" on Medium Clone',
      url: 'https://medium-clone.com/search?q=$query',
      type: 'website',
      siteName: 'Medium Clone',
    );
  }
}

/// Widget to display social share buttons
class SocialShareButtons extends StatelessWidget {
  final String title;
  final String? url;
  final String? text;
  final String? imageUrl;

  const SocialShareButtons({
    super.key,
    required this.title,
    this.url,
    this.text,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Twitter
        IconButton(
          icon: const Icon(Icons.twitter, color: Color(0xFF1DA1F2)),
          onPressed: () => _shareToTwitter(),
          tooltip: 'Share on Twitter',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        
        // Facebook
        IconButton(
          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
          onPressed: () => _shareToFacebook(),
          tooltip: 'Share on Facebook',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        
        // LinkedIn
        IconButton(
          icon: const Icon(Icons.link, color: Color(0xFF0A66C2)),
          onPressed: () => _shareToLinkedIn(),
          tooltip: 'Share on LinkedIn',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        
        // Copy link
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          onPressed: () => _copyLink(),
          tooltip: 'Copy Link',
        ),
      ],
    );
  }

  void _shareToTwitter() {
    // Use share_plus package or url_launcher
    // final url = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url ?? '')}';
    // launchUrl(Uri.parse(url));
  }

  void _shareToFacebook() {
    // Use share_plus package or url_launcher
    // final url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url ?? '')}';
    // launchUrl(Uri.parse(url));
  }

  void _shareToLinkedIn() {
    // Use share_plus package or url_launcher
    // final url = 'https://www.linkedin.com/shareArticle?mini=true&url=${Uri.encodeComponent(url ?? '')}&title=${Uri.encodeComponent(title)}';
    // launchUrl(Uri.parse(url));
  }

  void _copyLink() {
    // Use Clipboard to copy link
    // Clipboard.setData(ClipboardData(text: url ?? ''));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Link copied to clipboard')),
    // );
  }
}
