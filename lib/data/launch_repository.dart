import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/launch.dart';

/// Fetches upcoming launches from the Launch Library 2 public API
/// (https://thespacedevs.com/llapi) - no API key required.
class LaunchRepository {
  static const _baseUrl = 'https://ll.thespacedevs.com/2.2.0';
  static const String _cacheBoxName = 'cached_launches';
  static const String _currentCacheVersion = '2';

  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  Future<List<Launch>> fetchUpcoming({int limit = 30, bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        try {
          // Use keys to avoid the metadata-in-values problem
          final allKeys = _cacheBox.keys.toList();
          final dataKeys = allKeys.where((k) => k != 'cache_version').toList();
          
          final launches = <Launch>[];
          for (final key in dataKeys) {
            final jsonStr = _cacheBox.get(key);
            if (jsonStr != null) {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              // Defensive validation during read: ensure top-level structural keys exist
              if (map['rocket'] != null && map['pad'] != null && map['mission'] != null) {
                launches.add(Launch.fromJson(map));
              } else {
                debugPrint('Skipping corrupted launch record in cache: $key');
              }
            }
            if (launches.length >= limit) break;
          }

          if (launches.isNotEmpty) return launches;
        } catch (e) {
          debugPrint('Error reading LaunchRepository cache: $e');
          await _cacheBox.clear();
        }
      } else {
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

    if (results.isNotEmpty) {
      await _cacheBox.clear();
      await _cacheBox.put('cache_version', _currentCacheVersion);
      for (var result in results) {
        final map = result as Map<String, dynamic>;
        final id = map['id'] as String;
        // Store the raw JSON object to preserve nesting for Launch.fromJson()
        await _cacheBox.put(id, jsonEncode(result));
      }
    }

    return results
        .map((json) => Launch.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}