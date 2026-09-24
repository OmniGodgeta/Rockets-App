import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/launch.dart';

/// Fetches upcoming launches from the Launch Library 2 public API
/// (https://thespacedevs.com/llapi) - no API key required.
class LaunchRepository {
  static const _baseUrl = 'https://ll.thespacedevs.com/2.2.0';
  static const String _cacheBoxName = 'cached_launches';
  static const String _currentCacheVersion = '2'; // Using String for Hive compatibility

  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  Future<List<Launch>> fetchUpcoming({int limit = 30, bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      // Check cache version first
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        final cachedData = _cacheBox.values.toList();
        try {
          // IMPORTANT: Filter out 'cache_version' which is an entry in the box
          return cachedData
              .where((json) => json != 'cache_version')
              .take(limit)
              .map((json) => Launch.fromJson(jsonDecode(json)))
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

    final uri = Uri.parse('$_baseUrl/launch/upcoming/?limit=$limit');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Launch Library request failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];

    // Update cache with raw JSON objects from the API so they remain compatible with Launch.fromJson()
    await _cacheBox.clear();
    await _cacheBox.put('cache_version', _currentCacheVersion);

    for (var result in results) {
      final map = result as Map<String, dynamic>;
      final id = map['id'] as String;
      
      // Defensive validation: Ensure critical nested keys exist before caching/using
      if (map['rocket'] != null && map['pad'] != null && map['mission'] != null) {
        await _cacheBox.put(id, jsonEncode(result));
      }
    }

    final launches = results
        .map((json) => Launch.fromJson(json as Map<String, dynamic>))
        .toList();

    return launches;
  }
}
