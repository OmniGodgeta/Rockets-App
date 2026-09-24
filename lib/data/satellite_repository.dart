import 'package:http/http.dart' as http;
import '../models/satellite_model.dart';

class SatelliteRepository {
  static const _celestrakUrl = 'https://celestrak.org/NORAD/elements/gp.php?GROUP=active&FORMAT=tle';
  List<Satellite>? _cachedSatellites;

  /// Fetches all active satellites from CelesTrak and parses TLEs.
  /// Results are cached in memory for subsequent searches.
  Future<List<Satellite>> fetchActiveSatellites() async {
    if (_cachedSatellites != null) return _cachedSatellites!;

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
        _cachedSatellites = satellites;
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
