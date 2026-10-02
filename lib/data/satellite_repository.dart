import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/satellite_model.dart';

/// Fetches all active satellites from CelesTrak and parses TLEs.
/// Implements local caching via Hive to allow offline operation.
class SatelliteRepository {
  static const _celestrakUrl =
      'https://celestrak.org/NORAD/elements/gp.php?GROUP=active&FORMAT=tle';
  static const String _issCatalogNumber = '25544';
  static const String _cacheBoxName = 'cached_satellites';
  static const String _currentCacheVersion = '1';

  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
  }

  /// Fetches just the ISS's TLE via its own CelesTrak catalog-number query
  /// (CATNR=25544), rather than the full active-satellite catalog (thousands
  /// of entries) used elsewhere - the ISS Live Now screen only needs this one
  /// satellite.
  ///
  /// CelesTrak is intermittently slow: on 2026-10-02 this exact query hung
  /// for 20 s+ while the full catalog answered, and with no timeout the
  /// screen spun forever. So: CelesTrak with a timeout, then wheretheiss.at's
  /// copy of the same TLE, then the last good TLE saved on the device (a TLE
  /// stays usable for days, so a cached one still places the ISS correctly).
  Future<Satellite> fetchIssSatellite() async {
    const timeout = Duration(seconds: 12);
    try {
      final response = await http
          .get(Uri.parse(
              'https://celestrak.org/NORAD/elements/gp.php?CATNR=$_issCatalogNumber&FORMAT=tle'))
          .timeout(timeout);
      if (response.statusCode == 200) {
        final lines = response.body
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        if (lines.length >= 3) return await _saveIss(lines[0], lines[1], lines[2]);
      }
    } catch (e) {
      debugPrint('ISS TLE: CelesTrak failed ($e), trying wheretheiss.at');
    }
    try {
      final response = await http
          .get(Uri.parse(
              'https://api.wheretheiss.at/v1/satellites/$_issCatalogNumber/tles'))
          .timeout(timeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final l1 = body['line1'] as String?;
        final l2 = body['line2'] as String?;
        if (l1 != null && l2 != null) {
          return await _saveIss(
              (body['header'] as String?) ?? 'ISS (ZARYA)', l1, l2);
        }
      }
    } catch (e) {
      debugPrint('ISS TLE: wheretheiss.at failed ($e), trying cache');
    }
    final cached = (await _issBox())?.get('tle');
    if (cached != null) {
      final parts = cached.split('\n');
      if (parts.length == 3) {
        return Satellite.fromTle(
            parts[0], _issCatalogNumber, parts[1], parts[2]);
      }
    }
    throw Exception('Could not reach any ISS orbit source');
  }

  Future<Satellite> _saveIss(String name, String line1, String line2) async {
    await (await _issBox())?.put('tle', '$name\n$line1\n$line2');
    return Satellite.fromTle(name, _issCatalogNumber, line1, line2);
  }

  /// Last good ISS TLE, in its own box: _cacheBox is cleared on every catalog
  /// refresh. Opened on demand (several callers never run init(), e.g. ISS
  /// Live Now and the notification service) and null if Hive isn't ready,
  /// in which case the cache is simply skipped.
  Future<Box<String>?> _issBox() async {
    try {
      return await Hive.openBox<String>('iss_tle');
    } catch (e) {
      debugPrint('ISS TLE cache unavailable: $e');
      return null;
    }
  }

  Future<List<Satellite>> fetchActiveSatellites({bool useCache = true}) async {
    if (useCache && _cacheBox.isNotEmpty) {
      final storedVersion = _cacheBox.get('cache_version');
      if (storedVersion == _currentCacheVersion) {
        try {
          // Use keys to avoid the metadata-in-values problem
          final dataKeys =
              _cacheBox.keys.where((k) => k != 'cache_version').toList();

          final satellites = <Satellite>[];
          for (final key in dataKeys) {
            final jsonStr = _cacheBox.get(key);
            if (jsonStr != null) {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              // Defensive validation during read
              if (map['name'] != null && map['noradId'] != null) {
                satellites.add(Satellite.fromJson(map));
              } else {
                debugPrint('Skipping corrupted satellite in cache: $key');
              }
            }
            if (satellites.length >= 1000) break; // Sanity limit
          }

          if (satellites.isNotEmpty) return satellites;
        } catch (e) {
          debugPrint('Error reading SatelliteRepository cache: $e');
          await _cacheBox.clear();
        }
      } else {
        await _cacheBox.clear();
      }
    }

    try {
      final response = await http.get(Uri.parse(_celestrakUrl));
      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        final List<Satellite> satellites = [];

        for (int i = 0; i < lines.length - 2; i++) {
          final name = lines[i].trim();
          if (name.isEmpty || name.startsWith('#')) continue;

          final line1 = lines[i + 1].trim();
          final line2 = lines[i + 2].trim();

          if (line1.isNotEmpty && line2.isNotEmpty) {
            final noradId = _extractNoradId(line2);
            satellites.add(Satellite.fromTle(name, noradId, line1, line2));
            i += 2;
          }
        }

        if (satellites.isNotEmpty) {
          await _cacheBox.clear();
          await _cacheBox.put('cache_version', _currentCacheVersion);

          for (var satellite in satellites) {
            // Use a stable key: combine name and NORAD ID or similar if available
            final cacheKey = '${satellite.name}_${satellite.noradId}';
            await _cacheBox.put(cacheKey, jsonEncode(satellite.toJson()));
          }
        }

        return satellites;
      } else {
        throw Exception('Failed to fetch satellites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching satellites: $e');
    }
  }

  String _extractNoradId(String line2) {
    if (line2.length >= 7) {
      return line2.substring(2, 7).trim();
    }
    return 'unknown';
  }
}
