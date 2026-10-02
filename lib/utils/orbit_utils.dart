import 'dart:math';
import '../models/satellite_model.dart';
import 'package:sgp4_sdp4/sgp4_sdp4.dart';

/// Utilities for orbital mechanics and satellite tracking.
/// sgp4_sdp4's Julian.fromFullDate is off by a whole day for some months: its
/// day-of-year formula uses .round() where the original C++ truncates
/// ((275 * mon) / 9). In October that put every satellite where it had been
/// exactly 24 h earlier (checked against wheretheiss.at's live position: 0.00
/// deg error with a 1440 min shift, wrong otherwise). Build it from an exact
/// fractional day-of-year instead (1.0 = Jan 1 00:00 UTC).
Julian _julian(DateTime time) {
  final t = time.toUtc();
  final startOfYear = DateTime.utc(t.year);
  final dayOfYear =
      1.0 + t.difference(startOfYear).inMicroseconds / Duration.microsecondsPerDay;
  return Julian(t.year, dayOfYear);
}

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
      
      final julian = _julian(dt);

      // Step 4: Minutes since the TLE epoch. sgp4_sdp4's tPlusEpoch()
      // returns SECONDS (it's `gmt.spanSec(epoch())`), but getPosition()
      // takes MINUTES. Passing it straight through propagated every position
      // 60x too far: the ISS "moved" ~110deg per 30 s, the 93-min track
      // became ~60 orbits of red scribble, and the marker, next-pass time
      // and compass were all wrong. Fixed 2026-10-02.
      final tSince = orbit.tPlusEpoch(julian) / 60.0;

      // Step 5: Propagate position
      final eciPos = orbit.getPosition(tSince);
      
      // Step 6: Convert ECI to Geodetic coordinates (Lat/Lon/Alt)
      final coordGeo = eciPos.toGeo();

      // sgp4_sdp4's toGeo() documents its own lon as "radians" but wraps it
      // into [0, 2*pi) (see its source: "if (lon < 0.0) lon += TWOPI"), i.e.
      // [0deg, 360deg) once converted - NOT the [-180deg, 180deg] convention
      // every consumer here actually needs (flutter_map/LatLng's Mercator
      // math, and this file's own antimeridian-split logic below, both
      // assume standard signed longitude). Left unconverted, this was a
      // real bug: for the entire western hemisphere the raw value comes
      // back as 180-360 instead of -180-0, which flutter_map renders as a
      // wildly wrong map position - the exact "ISS teleporting" and
      // "trajectory drawn as a mess of lines" the operator reported. Half
      // of every single orbit crosses through this range, so it wasn't an
      // edge case - it was wrong twice per orbit, every orbit.
      double lonDeg = coordGeo.lon * (180.0 / pi);
      if (lonDeg > 180) lonDeg -= 360;

      return {
        'lat': coordGeo.lat * (180.0 / pi),
        'lon': lonDeg,
        'alt': coordGeo.alt,
      };
    } catch (e) {
      // Return zeroed data if propagation fails.
      return {'lat': 0.0, 'lon': 0.0, 'alt': 0.0};
    }
  }

  /// Calculates the bearing (azimuth) from a user location to a satellite position in degrees.
  static double calculateAzimuth(double userLat, double userLon, double satLat, double satLon) {
    final uLat = userLat * pi / 180;
    final uLon = userLon * pi / 180;
    final sLat = satLat * pi / 180;
    final sLon = satLon * pi / 180;

    final deltaLon = sLon - uLon;

    final y = sin(deltaLon) * cos(sLat);
    final x = cos(uLat) * sin(sLat) - sin(uLat) * cos(sLat) * cos(deltaLon);

    var azimuth = atan2(y, x) * 180 / pi;
    return (azimuth + 360) % 360;
  }

  /// Full look angle (azimuth AND elevation, both in degrees) from a user
  /// location to a satellite at a given time, using the same sgp4_sdp4
  /// Site.getLookAngle already relied on by calculateNextPass. Elevation is
  /// how far above (positive) or below (negative) the horizon the satellite
  /// is - the piece the simple azimuth-only calculateAzimuth() can't give,
  /// needed for the compass's vertical/pitch indicator.
  static Map<String, double>? getLookAngle(
    Satellite satellite,
    double userLat,
    double userLon,
    double userAltKm,
    DateTime time,
  ) {
    try {
      final tle = TLE(satellite.name, satellite.tleLine1, satellite.tleLine2);
      final orbit = Orbit(tle);
      final t = time.toUtc();
      final julian = _julian(t);
      final tSince = orbit.tPlusEpoch(julian) / 60.0; // seconds -> minutes, see getSatellitePosition
      final eciPos = orbit.getPosition(tSince);
      final site = Site.fromLatLngAlt(userLat, userLon, userAltKm);
      final lookAngle = site.getLookAngle(eciPos);
      return {
        'azimuth': (lookAngle.az * 180.0 / pi + 360) % 360,
        'elevation': lookAngle.el * 180.0 / pi,
      };
    } catch (e) {
      return null;
    }
  }

  /// Calculates when a satellite will next pass overhead given user location.
  /// This is improved from a simple altitude check to use Site.getLookAngle for actual visibility.
  /// Start time of the next pass above the horizon, or null within 24 h.
  /// Kept for callers that only need "when is it up" (the ISS screen's
  /// next-pass readout); see [calculateNextVisiblePass] for naked-eye passes.
  static DateTime? calculateNextPass(
      Satellite satellite, double userLat, double userLon, double userAltKm) {
    return _nextPass(satellite, userLat, userLon, userAltKm,
            range: const Duration(hours: 24), requireVisible: false)
        ?.start;
  }

  /// The next pass you can actually SEE: at least 10 deg up, your sky dark
  /// (sun 6+ deg below the horizon, civil twilight or darker) and the ISS
  /// itself sunlit (it shines by reflected sunlight; in Earth's shadow it's
  /// invisible even overhead). Searched 3 days ahead.
  static IssPass? calculateNextVisiblePass(
      Satellite satellite, double userLat, double userLon, double userAltKm,
      {Duration range = const Duration(days: 3), DateTime? from}) {
    return _nextPass(satellite, userLat, userLon, userAltKm,
        range: range, requireVisible: true, from: from);
  }

  static IssPass? _nextPass(Satellite satellite, double userLat,
      double userLon, double userAltKm,
      {required Duration range, required bool requireVisible, DateTime? from}) {
    // 30 s steps: the old 5 min step could jump clean over a short pass
    // (a visible ISS pass is often only 2-4 min long).
    const step = Duration(seconds: 30);
    const minElevationDeg = 10.0;
    try {
      final site = Site.fromLatLngAlt(userLat, userLon, userAltKm);
      final now = (from ?? DateTime.now()).toUtc();
      DateTime? start;
      var maxEl = 0.0;
      for (var t = now; t.isBefore(now.add(range)); t = t.add(step)) {
        final julian = _julian(t);
        // A fresh Orbit per step on purpose: sgp4_sdp4's Orbit carries
        // internal state, and reusing one across calls returns wrong
        // positions (checked: a reused Orbit never put the ISS above -16 deg
        // over Ottawa in 24 h; a fresh one gives the real 60 deg pass).
        final orbit =
            Orbit(TLE(satellite.name, satellite.tleLine1, satellite.tleLine2));
        final eci = orbit.getPosition(orbit.tPlusEpoch(julian) / 60.0);
        final elDeg = site.getLookAngle(eci).el * 180 / pi;
        var ok = requireVisible ? elDeg >= minElevationDeg : elDeg > 0;
        if (ok && requireVisible) {
          final sun = _sunDirection(t);
          ok = _sunElevationDeg(site.getPosition(julian), sun) <= -6.0 &&
              _isSunlit(eci, sun);
        }
        if (ok) {
          start ??= t;
          maxEl = max(maxEl, elDeg);
        } else if (start != null) {
          return IssPass(start: start, end: t, maxElevationDeg: maxEl);
        }
      }
      if (start != null) {
        return IssPass(start: start, end: now.add(range), maxElevationDeg: maxEl);
      }
    } catch (_) {
      // Propagation failure: no pass rather than a crash.
    }
    return null;
  }

  /// Unit vector to the Sun in the same inertial frame SGP4 uses, from the
  /// Astronomical Almanac's low-precision formula (~1 deg, plenty for "is it
  /// dark" and "is the ISS in Earth's shadow").
  static List<double> _sunDirection(DateTime t) {
    final n = t.millisecondsSinceEpoch / 86400000.0 + 2440587.5 - 2451545.0;
    final l = (280.460 + 0.9856474 * n) * pi / 180;
    final g = (357.528 + 0.9856003 * n) * pi / 180;
    final lambda = l + (1.915 * sin(g) + 0.020 * sin(2 * g)) * pi / 180;
    final eps = (23.439 - 0.0000004 * n) * pi / 180;
    return [cos(lambda), cos(eps) * sin(lambda), sin(eps) * sin(lambda)];
  }

  /// Sun's elevation seen from [observer] (geocentric zenith; <0.2 deg off
  /// from geodetic, irrelevant at a -6 deg threshold).
  static double _sunElevationDeg(Eci observer, List<double> sun) {
    final o = observer.getPos();
    final r = sqrt(o.x * o.x + o.y * o.y + o.z * o.z);
    final sinEl = (o.x * sun[0] + o.y * sun[1] + o.z * sun[2]) / r;
    return asin(sinEl.clamp(-1.0, 1.0)) * 180 / pi;
  }

  /// Cylindrical Earth-shadow test: sunlit if on the Sun's side of Earth, or
  /// far enough off the Earth-Sun axis to clear the shadow cylinder.
  static bool _isSunlit(Eci sat, List<double> sun) {
    const earthRadiusKm = 6371.0;
    final p = sat.getPos();
    final d = p.x * sun[0] + p.y * sun[1] + p.z * sun[2];
    if (d > 0) return true;
    final px = p.x - d * sun[0], py = p.y - d * sun[1], pz = p.z - d * sun[2];
    return sqrt(px * px + py * py + pz * pz) > earthRadiusKm;
  }
}

/// One pass over an observer: when it starts and ends, and how high it gets.
class IssPass {
  final DateTime start;
  final DateTime end;
  final double maxElevationDeg;
  const IssPass(
      {required this.start, required this.end, required this.maxElevationDeg});
  Duration get duration => end.difference(start);
}
