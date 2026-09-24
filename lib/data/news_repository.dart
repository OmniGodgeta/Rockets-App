import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_article.dart';

/// Fetches space/rocket/astronomy news from the Spaceflight News API
/// (https://api.spaceflightnewsapi.net) - no API key required.
class NewsRepository {
  static const _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  Future<List<NewsArticle>> fetchLatest({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/articles/?limit=$limit&ordering=-published_at');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Spaceflight News request failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
