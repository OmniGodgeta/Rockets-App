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
  static const String _currentCacheVersion = '1';

  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  Future<List<NewsArticle>> fetchLatest({int limit = 30, bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        try {
          // Use keys to avoid the metadata-in-values problem
          final allKeys = _cacheBox.keys.toList();
          final dataKeys = allKeys.where((k) => k != 'cache_version').toList();
          
          final articles = <NewsArticle>[];
          for (final key in dataKeys) {
            final jsonStr = _cacheBox.get(key);
            if (jsonStr != null) {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              // Defensive validation during read: ensure top-level structural keys exist
              if (map['id'] != null && map['title'] != null) {
                articles.add(NewsArticle.fromJson(map));
              }
            }
            if (articles.length >= limit) break;
          }

          if (articles.isNotEmpty) return articles;
        } catch (e) {
          await _cacheBox.clear();
        }
      } else {
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

      if (articles.isNotEmpty) {
        await _cacheBox.clear();
        await _cacheBox.put('cache_version', _currentCacheVersion);

        for (var article in articles) {
          await _cacheBox.put(article.id.toString(), jsonEncode(article.toJson()));
        }
      }

      return articles;
    } else {
      throw Exception('Spaceflight News request failed: ${response.statusCode}');
    }
  }
}
