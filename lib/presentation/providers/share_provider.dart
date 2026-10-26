import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

/// Share service for social sharing
class ShareService {
  /// Share text
  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  /// Share article
  Future<void> shareArticle({
    required String title,
    required String url,
    String? description,
  }) async {
    final shareText = _buildShareText(title, url, description);
    await Share.share(shareText);
  }

  /// Share to Twitter
  Future<void> shareToTwitter({
    required String title,
    required String url,
    String? via,
    List<String>? hashtags,
  }) async {
    final twitterUrl = _buildTwitterUrl(title, url, via, hashtags);
    if (await canLaunchUrl(Uri.parse(twitterUrl))) {
      await launchUrl(Uri.parse(twitterUrl));
    } else {
      // Fallback to share dialog
      await shareArticle(title: title, url: url);
    }
  }

  /// Share to Facebook
  Future<void> shareToFacebook(String url) async {
    final facebookUrl = _buildFacebookUrl(url);
    if (await canLaunchUrl(Uri.parse(facebookUrl))) {
      await launchUrl(Uri.parse(facebookUrl));
    } else {
      await shareArticle(title: 'Check this out', url: url);
    }
  }

  /// Share to LinkedIn
  Future<void> shareToLinkedIn({
    required String title,
    required String url,
    String? summary,
  }) async {
    final linkedInUrl = _buildLinkedInUrl(title, url, summary);
    if (await canLaunchUrl(Uri.parse(linkedInUrl))) {
      await launchUrl(Uri.parse(linkedInUrl));
    } else {
      await shareArticle(title: title, url: url, description: summary);
    }
  }

  /// Copy link to clipboard
  Future<void> copyLink(String text) async {
    await FlutterClipboard.copy(text);
  }

  /// Build share text
  String _buildShareText(String title, String url, String? description) {
    final buffer = StringBuffer();
    buffer.writeln(title);
    if (description != null && description.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(description);
    }
    buffer.writeln();
    buffer.write(url);
    return buffer.toString();
  }

  /// Build Twitter URL
  String _buildTwitterUrl(String title, String url, String? via, List<String>? hashtags) {
    final buffer = StringBuffer('https://twitter.com/intent/tweet?');
    
    final params = <String, String>{};
    params['text'] = title;
    params['url'] = url;
    
    if (via != null && via.isNotEmpty) {
      params['via'] = via;
    }
    
    if (hashtags != null && hashtags.isNotEmpty) {
      params['hashtags'] = hashtags.join(',');
    }
    
    buffer.write(Uri(queryParameters: params).query);
    return buffer.toString();
  }

  /// Build Facebook URL
  String _buildFacebookUrl(String url) {
    return 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
  }

  /// Build LinkedIn URL
  String _buildLinkedInUrl(String title, String url, String? summary) {
    final buffer = StringBuffer('https://www.linkedin.com/shareArticle?mini=true&');
    
    final params = <String, String>{};
    params['title'] = title;
    params['url'] = url;
    
    if (summary != null && summary.isNotEmpty) {
      params['summary'] = summary;
    }
    
    buffer.write(Uri(queryParameters: params).query);
    return buffer.toString();
  }
}

/// Share service provider
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

/// Share notifier for tracking share state
class ShareNotifier extends StateNotifier<AsyncValue<void>> {
  final ShareService _shareService;

  ShareNotifier(this._shareService) : super(const AsyncValue.data(null));

  Future<void> shareText(String text) async {
    try {
      await _shareService.shareText(text);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> shareArticle({
    required String title,
    required String url,
    String? description,
  }) async {
    try {
      await _shareService.shareArticle(
        title: title,
        url: url,
        description: description,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> shareToTwitter({
    required String title,
    required String url,
    String? via,
    List<String>? hashtags,
  }) async {
    try {
      await _shareService.shareToTwitter(
        title: title,
        url: url,
        via: via,
        hashtags: hashtags,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> copyLink(String text) async {
    try {
      await _shareService.copyLink(text);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Share provider
final shareProvider = StateNotifierProvider<ShareNotifier, AsyncValue<void>>((ref) {
  return ShareNotifier(ref.read(shareServiceProvider));
});

/// Social share buttons provider
final socialShareButtonsProvider = Provider.family<Widget, ({String title, String? url, String? text, String? imageUrl})>(
  (ref, params) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => ref.read(shareProvider.notifier).shareArticle(
            title: params.title,
            url: params.url ?? '',
            description: params.text,
          ),
          tooltip: 'Share',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        IconButton(
          icon: const Icon(Icons.twitter, color: Color(0xFF1DA1F2)),
          onPressed: () => ref.read(shareProvider.notifier).shareToTwitter(
            title: params.title,
            url: params.url ?? '',
          ),
          tooltip: 'Twitter',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        IconButton(
          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
          onPressed: () => ref.read(shareServiceProvider).shareToFacebook(
            params.url ?? '',
          ),
          tooltip: 'Facebook',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          onPressed: () => ref.read(shareProvider.notifier).copyLink(
            params.url ?? '',
          ),
          tooltip: 'Copy Link',
        ),
      ],
    );
  },
);
