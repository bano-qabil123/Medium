import 'package:hive/hive.dart';
import 'package:medium_clone/data/models/article_model.dart';

/// Local cache for articles using Hive
class ArticleCache {
  static const String boxName = 'articles';
  late final Box<ArticleModel> _box;

  /// Initialize the cache
  Future<void> init() async {
    _box = await Hive.openBox<ArticleModel>(boxName);
  }

  /// Save an article to cache
  Future<void> saveArticle(ArticleModel article) async {
    await _box.put(article.id, article);
  }

  /// Get an article from cache
  ArticleModel? getArticle(String articleId) {
    return _box.get(articleId);
  }

  /// Get multiple articles from cache
  List<ArticleModel> getArticles(List<String> articleIds) {
    return articleIds
        .map((id) => _box.get(id))
        .whereType<ArticleModel>()
        .toList();
  }

  /// Get all cached articles
  List<ArticleModel> getAllArticles() {
    return _box.values.toList();
  }

  /// Delete an article from cache
  Future<void> deleteArticle(String articleId) async {
    await _box.delete(articleId);
  }

  /// Clear all cached articles
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Check if article is cached
  bool hasArticle(String articleId) {
    return _box.containsKey(articleId);
  }

  /// Get article count
  int getArticleCount() {
    return _box.length;
  }

  /// Close the box
  Future<void> close() async {
    await _box.close();
  }
}

/// Singleton instance
final articleCache = ArticleCache();

/// Hive adapter for ArticleModel
class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 0;

  @override
  ArticleModel read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final slug = reader.readString();
    final content = reader.readString();
    final excerpt = reader.readString();
    final coverImageUrl = reader.readString();
    final authorId = reader.readString();
    final status = reader.readString();
    final visibility = reader.readString();
    final publishedAt = reader.readString();
    final updatedAt = reader.readString();
    final createdAt = reader.readString();
    final readTimeMinutes = reader.readInt();
    final views = reader.readInt();
    final clapsCount = reader.readInt();
    final commentsCount = reader.readInt();
    final highlightsCount = reader.readInt();
    final isBookmarked = reader.readBool();
    final isClapped = reader.readBool();
    final tags = reader.readStringList();

    return ArticleModel(
      id: id,
      title: title,
      slug: slug,
      content: content,
      excerpt: excerpt.isEmpty ? null : excerpt,
      coverImageUrl: coverImageUrl.isEmpty ? null : coverImageUrl,
      authorId: authorId,
      status: status,
      visibility: visibility,
      publishedAt: publishedAt.isEmpty ? null : DateTime.parse(publishedAt),
      updatedAt: updatedAt.isEmpty ? null : DateTime.parse(updatedAt),
      createdAt: createdAt.isEmpty ? null : DateTime.parse(createdAt),
      readTimeMinutes: readTimeMinutes,
      views: views,
      clapsCount: clapsCount,
      commentsCount: commentsCount,
      highlightsCount: highlightsCount,
      isBookmarked: isBookmarked,
      isClapped: isClapped,
      tags: tags,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.slug);
    writer.writeString(obj.content);
    writer.writeString(obj.excerpt ?? '');
    writer.writeString(obj.coverImageUrl ?? '');
    writer.writeString(obj.authorId);
    writer.writeString(obj.status);
    writer.writeString(obj.visibility);
    writer.writeString(obj.publishedAt?.toIso8601String() ?? '');
    writer.writeString(obj.updatedAt?.toIso8601String() ?? '');
    writer.writeString(obj.createdAt?.toIso8601String() ?? '');
    writer.writeInt(obj.readTimeMinutes);
    writer.writeInt(obj.views);
    writer.writeInt(obj.clapsCount);
    writer.writeInt(obj.commentsCount);
    writer.writeInt(obj.highlightsCount);
    writer.writeBool(obj.isBookmarked);
    writer.writeBool(obj.isClapped);
    writer.writeStringList(obj.tags);
  }
}
