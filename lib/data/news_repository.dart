import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/news_article.dart';

/// Fetches space/rocket/astronomy news from the Spaceflight News API
/// (https://api.spaceflightnewsapi.net) - no API key required.
/// Implements local caching via Hive to allow offline reading of previously fetched articles.
class NewsRepository {
  static const _baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const String _cacheBoxName = 'cached_news';
  static const String _currentCacheVersion = '1'; // Initial versioning for schema consistency

  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  Future<List<NewsArticle>> fetchLatest({int limit = 30, bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      // Check cache version first
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        final cachedData = _cacheBox.values.toList();
        try {
          return cachedData
              .where((json) => json != 'cache_version')
              .take(limit)
              .map((json) => NewsArticle.fromJson(jsonDecode(json)))
              .toList();
        } catch (e) {
          // If decoding fails due to structural mismatch, invalidate and fetch fresh
          await _cacheBox.clear();
        }
      } else {
        // Version mismatch or no version found: clear and refetch
        await _cacheBox.clear();
      }
    }

    final uri = Uri.parse('$_baseUrl/articles/?limit=$limit&ordering=-published_at');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];
      final articles = results
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update cache: clear old and save new
      await _cacheBox.clear();
      await _cacheBox.put('cache_version', _currentCacheVersion);

      for (var article in articles) {
        await _cacheBox.put(article.id.toString(), jsonEncode(article.toJson()));
      }

      return articles;
    } else {
      throw Exception('Spaceflight News request failed: ${response.statusCode}');
    }
  }
}
