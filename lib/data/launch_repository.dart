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

  Future<List<Launch>> fetchUpcoming({int limit = 150, bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        try {
          // Use keys to avoid the metadata-in-values problem
          final dataKeys = _cacheBox.keys.where((k) => k != 'cache_version').toList();
          
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

          if (launches.isNotEmpty) {
            launches.sort((a, b) => a.net.compareTo(b.net));
            return launches;
          }
        } catch (e) {
          debugPrint('Error reading LaunchRepository cache: $e');
          await _cacheBox.clear();
        }
      } else {
        await _cacheBox.clear();
      }
    }

    final List<Map<String, dynamic>> allMaps = [];
    String? nextUrl = '$_baseUrl/launch/upcoming/?limit=$limit';

    while (nextUrl != null && allMaps.length < limit) {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode != 200) break;
      
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final resultsList = body['results'] as List<dynamic>? ?? [];
      
      for (var result in resultsList) {
        if (allMaps.length >= limit) break;
        allMaps.add(result as Map<String, dynamic>);
      }
      nextUrl = body['next'];
    }

    final launches = allMaps
        .map((map) => Launch.fromJson(map))
        .toList();

    // Sort chronologically by launch date (net) ascending
    launches.sort((a, b) => a.net.compareTo(b.net));

    if (launches.isNotEmpty) {
      await _cacheBox.clear();
      await _cacheBox.put('cache_version', _currentCacheVersion);
      for (var map in allMaps) {
        final id = map['id'] as String;
        await _cacheBox.put(id, jsonEncode(map));
      }
    }

    return launches;
  }
}
