/// A space/rocket/astronomy news article, as returned by the
/// Spaceflight News API (https://api.spaceflightnewsapi.net/v4/articles/).
class NewsArticle {
  final int id;
  final String title;
  final String summary;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String newsSite;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.newsSite,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      summary: json['summary'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      publishedAt:
          DateTime.tryParse(json['published_at'] as String? ?? '') ??
              DateTime.now(),
      newsSite: json['news_site'] as String? ?? 'Unknown source',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'url': url,
      'image_url': imageUrl,
      'published_at': publishedAt.toIso8601String(),
      'news_site': newsSite,
    };
  }
}