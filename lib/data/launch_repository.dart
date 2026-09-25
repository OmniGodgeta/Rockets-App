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

  /// Set to true after a call that had to fall back to cached data because
  /// the live fetch failed (rate limit, offline, etc). The Rockets screen
  /// checks this right after awaiting fetchUpcoming() to decide whether to
  /// show a "showing cached results" notice instead of silently pretending
  /// the refresh succeeded.
  bool lastFetchUsedCacheFallback = false;

  List<Launch> _readCache() {
    if (_cacheBox.isEmpty) return [];
    final storedVersion = _cacheBox.get('cache_version');
    if (storedVersion != _currentCacheVersion) {
      return [];
    }
    try {
      // Use keys to avoid the metadata-in-values problem
      final dataKeys =
          _cacheBox.keys.where((k) => k != 'cache_version').toList();
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
      }
      launches.sort((a, b) => a.net.compareTo(b.net));
      return launches;
    } catch (e) {
      debugPrint('Error reading LaunchRepository cache: $e');
      return [];
    }
  }

  Future<List<Launch>> fetchUpcoming({int limit = 150, bool useCache = true}) async {
    lastFetchUsedCacheFallback = false;
    final cached = _readCache();

    if (useCache && cached.isNotEmpty) {
      return cached.take(limit).toList();
    }

    final List<Map<String, dynamic>> allMaps = [];
    // The Launch Library 2 API caps page size well under our own `limit`
    // (and, more importantly, anonymous access is rate-limited - verified
    // directly: `?limit=150` alone can return HTTP 429 "Request was
    // throttled" with no results at all). Page in chunks of 100 and follow
    // `next` until we hit `limit`, rather than asking for everything in one
    // shot.
    String? nextUrl = '$_baseUrl/launch/upcoming/?limit=100';
    Object? lastError;

    try {
      while (nextUrl != null && allMaps.length < limit) {
        final response = await http.get(Uri.parse(nextUrl));
        if (response.statusCode != 200) {
          try {
            final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
            lastError = errorBody['detail'] ?? 'HTTP ${response.statusCode}';
          } catch (_) {
            lastError = 'HTTP ${response.statusCode}';
          }
          break;
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final resultsList = body['results'] as List<dynamic>? ?? [];

        for (var result in resultsList) {
          if (allMaps.length >= limit) break;
          allMaps.add(result as Map<String, dynamic>);
        }
        nextUrl = body['next'];
      }
    } catch (e) {
      lastError = e;
    }

    if (allMaps.isEmpty) {
      // Live fetch failed outright (rate limit, offline, etc) - never
      // surface that as "no upcoming launches found". Fall back to
      // whatever cache we have; only throw if there's truly nothing to show.
      if (cached.isNotEmpty) {
        debugPrint(
            'LaunchRepository: live fetch failed ($lastError), serving cached data instead');
        lastFetchUsedCacheFallback = true;
        return cached.take(limit).toList();
      }
      throw Exception(lastError != null
          ? 'Could not load launches: $lastError'
          : 'Could not load launches.');
    }

    final launches = allMaps.map((map) => Launch.fromJson(map)).toList();

    // Sort chronologically by launch date (net) ascending
    launches.sort((a, b) => a.net.compareTo(b.net));

    await _cacheBox.clear();
    await _cacheBox.put('cache_version', _currentCacheVersion);
    for (var map in allMaps) {
      final id = map['id'] as String;
      await _cacheBox.put(id, jsonEncode(map));
    }

    return launches;
  }
}
