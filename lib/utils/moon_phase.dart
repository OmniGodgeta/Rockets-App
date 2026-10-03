import 'dart:math' as math;

/// The Moon's phase, computed on the phone (no network).
///
/// Sun and Moon apparent ecliptic longitudes from Meeus, *Astronomical
/// Algorithms* (ch. 25 low-precision Sun; ch. 47 main periodic terms for the
/// Moon), good to ~0.3 deg. Elongation grows ~12 deg/day, so new/full moon
/// times come out within an hour or so. Pinned by test/moon_phase_test.dart
/// against eclipse-dated new and full moons.
class MoonPhase {
  MoonPhase._(this.at, this.elongation);

  /// Phase at [at] (any time zone; converted to UTC).
  factory MoonPhase.at(DateTime at) =>
      MoonPhase._(at.toUtc(), _elongation(at.toUtc()));

  final DateTime at;

  /// Moon's ecliptic longitude minus the Sun's, 0..360 deg:
  /// 0 = new, 90 = first quarter, 180 = full, 270 = last quarter.
  final double elongation;

  static const synodicMonth = 29.530588853;

  /// Fraction of the disc lit, 0..1.
  double get illumination => (1 - math.cos(elongation * math.pi / 180)) / 2;

  /// Days since the last new moon (approximate).
  double get ageDays => elongation / 360 * synodicMonth;

  bool get waxing => elongation < 180;

  String get name {
    final e = elongation;
    if (e < 6 || e >= 354) return 'New Moon';
    if (e < 84) return 'Waxing Crescent';
    if (e < 96) return 'First Quarter';
    if (e < 174) return 'Waxing Gibbous';
    if (e < 186) return 'Full Moon';
    if (e < 264) return 'Waning Gibbous';
    if (e < 276) return 'Last Quarter';
    return 'Waning Crescent';
  }

  /// Next time after [from] the elongation reaches [target] deg (0 = new
  /// moon, 180 = full moon), to within a minute.
  static DateTime next(double target, DateTime from) {
    double off(DateTime t) {
      // signed distance to target in (-180, 180]
      var d = (_elongation(t) - target) % 360;
      if (d > 180) d -= 360;
      return d;
    }

    var a = from.toUtc();
    var fa = off(a);
    const step = Duration(hours: 6);
    for (var i = 0; i < 4 * 32; i++) {
      final b = a.add(step);
      final fb = off(b);
      // elongation increases, so the target is crossed going - to +.
      if (fa < 0 && fb >= 0) {
        var lo = a, hi = b;
        while (hi.difference(lo) > const Duration(minutes: 1)) {
          final mid = lo.add(Duration(
              microseconds: hi.difference(lo).inMicroseconds ~/ 2));
          if (off(mid) < 0) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        return hi;
      }
      a = b;
      fa = fb;
    }
    return from.add(const Duration(days: 30)); // unreachable in practice
  }

  static double _elongation(DateTime utc) {
    final jd = utc.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
    final t = (jd - 2451545.0) / 36525.0;
    double rad(double d) => d * math.pi / 180;
    double norm(double d) => (d % 360 + 360) % 360;

    // Sun (Meeus 25, low precision)
    final l0 = 280.46646 + 36000.76983 * t;
    final m = norm(357.52911 + 35999.05029 * t);
    final c = (1.914602 - 0.004817 * t) * math.sin(rad(m)) +
        0.019993 * math.sin(rad(2 * m)) +
        0.000289 * math.sin(rad(3 * m));
    final sun = norm(l0 + c);

    // Moon (Meeus 47, largest longitude terms)
    final lp = 218.3164477 + 481267.88123421 * t;
    final d = norm(297.8501921 + 445267.1114034 * t);
    final mp = norm(134.9633964 + 477198.8675055 * t);
    final f = norm(93.2720950 + 483202.0175233 * t);
    final moon = norm(lp +
        6.288774 * math.sin(rad(mp)) +
        1.274027 * math.sin(rad(2 * d - mp)) +
        0.658314 * math.sin(rad(2 * d)) +
        0.213618 * math.sin(rad(2 * mp)) -
        0.185116 * math.sin(rad(m)) -
        0.114332 * math.sin(rad(2 * f)) +
        0.058793 * math.sin(rad(2 * d - 2 * mp)) +
        0.057066 * math.sin(rad(2 * d - m - mp)) +
        0.053322 * math.sin(rad(2 * d + mp)) +
        0.045758 * math.sin(rad(2 * d - m)) -
        0.040923 * math.sin(rad(m - mp)) -
        0.034720 * math.sin(rad(d)) -
        0.030383 * math.sin(rad(m + mp)) +
        0.015327 * math.sin(rad(2 * d - 2 * f)) -
        0.012528 * math.sin(rad(mp + 2 * f)) +
        0.010980 * math.sin(rad(mp - 2 * f)));

    return norm(moon - sun);
  }
}
