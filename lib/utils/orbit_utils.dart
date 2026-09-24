import 'dart:math';
import '../models/satellite_model.dart';
import 'package:sgp4_sdp4/sgp4_sdp4.dart';

/// Utilities for orbital mechanics and satellite tracking.
class OrbitUtils {
  /// Uses SGP4 to propagate the satellite's position given its TLE data and a specific timestamp.
  /// Returns a Map containing 'lat', 'lon', and 'alt' (altitude in kilometers).
  static Map<String, double> getSatellitePosition(Satellite satellite, DateTime time) {
    final String t1 = satellite.tleLine1;
    final String t2 = satellite.tleLine2;

    try {
      // Step 1: Create a TLE object from strings
      final tle = TLE(satellite.name, t1, t2);
      
      // Step 2: Create an Orbit object which handles propagation
      final orbit = Orbit(tle);

      // Step 3: Convert DateTime to Julian date required by the library.
      final dt = time.toUtc();
      
      // Fixing positional arguments error based on julian.dart definition:
      // Julian.fromFullDate(int year, int mon, int day, int hour, int min, {double sec = 0.0})
      final julian = Julian.fromFullDate(
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        sec: dt.second + (dt.millisecond / 1000.0),
      );

      // Step 4: Calculate minutes since epoch
      final tSince = orbit.tPlusEpoch(julian);

      // Step 5: Propagate position
      final eciPos = orbit.getPosition(tSince);
      
      // Step 6: Convert ECI to Geodetic coordinates (Lat/Lon/Alt)
      final coordGeo = eciPos.toGeo();

      // Converting radians to degrees for user convenience in the UI.
      return {
        'lat': coordGeo.lat * (180.0 / pi),
        'lon': coordGeo.lon * (180.0 / pi),
        'alt': coordGeo.alt,
      };
    } catch (e) {
      // Return zeroed data if propagation fails.
      return {'lat': 0.0, 'lon': 0.0, 'alt': 0.0};
    }
  }

  /// Calculates when a satellite will next pass overhead given user location.
  static DateTime? calculateNextPass(Satellite satellite, double userLat, double userLon) {
    final now = DateTime.now().toUtc();
    const searchRangeHours = 24;
    const stepMinutes = 5;

    for (int i = 0; i <= (searchRangeHours * 60 / stepMinutes); i++) {
      final testTime = now.add(Duration(minutes: i * stepMinutes));
      final pos = getSatellitePosition(satellite, testTime);

      // Check if altitude is significantly above ground level (e.g., > 100 km).
      if (pos['alt']! > 100.0) {
        return testTime;
      }
    }

    return null;
  }
}
