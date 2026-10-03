import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/astronaut.dart';

/// People in space right now (Launch Library 2, no key). Anonymous access is
/// limited to ~15 requests an hour and shared with the launch list, so the
/// result is cached for an hour, and the cache is used if a refresh fails.
class AstronautRepository {
  static const _url =
      'https://ll.thespacedevs.com/2.2.0/astronaut/?in_space=true&limit=50&mode=detailed';
  static const _box = 'cached_astronauts';
  static const _maxAge = Duration(hours: 1);

  /// True when the last [fetchInSpace] had to fall back to an older cache.
  bool usedStaleCache = false;
  DateTime? fetchedAt;

  Future<List<Astronaut>> fetchInSpace({bool force = false}) async {
    usedStaleCache = false;
    final box = await Hive.openBox<String>(_box);
    final cachedAt = DateTime.tryParse(box.get('fetched_at') ?? '');
    final cached = box.get('people');
    if (!force &&
        cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _maxAge) {
      fetchedAt = cachedAt;
      return _decode(cached);
    }
    try {
      final res = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final results = (jsonDecode(res.body)['results'] as List)
          .map((e) => Astronaut.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      await box.put('people', jsonEncode([for (final a in results) a.toJson()]));
      await box.put('fetched_at', DateTime.now().toIso8601String());
      fetchedAt = DateTime.now();
      return results;
    } catch (_) {
      if (cached == null) rethrow;
      usedStaleCache = true;
      fetchedAt = cachedAt;
      return _decode(cached);
    }
  }

  static List<Astronaut> _decode(String s) => [
    for (final e in jsonDecode(s) as List)
      Astronaut.fromJson((e as Map).cast<String, dynamic>()),
  ];
}
