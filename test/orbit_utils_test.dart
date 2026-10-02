import 'package:flutter_test/flutter_test.dart';
import 'package:rockets/models/satellite_model.dart';
import 'package:rockets/utils/orbit_utils.dart';

/// Guards the two bugs that put the ISS in the wrong place (fixed
/// 2026-10-02): seconds passed where sgp4_sdp4 wants minutes (60x too far
/// along the orbit) and Julian.fromFullDate being a whole day off in some
/// months. Reference: wheretheiss.at's live position for this TLE at this
/// exact time, recorded when the fix was made.
void main() {
  final iss = Satellite.fromTle('ISS (ZARYA)', '25544',
      '1 25544U 98067A   26275.01380287  .00003738  00000+0  76743-4 0  9992',
      '2 25544  51.6312 131.4121 0006946 211.9293 148.1275 15.48707684588318');
  final at = DateTime.fromMillisecondsSinceEpoch(1790965408 * 1000, isUtc: true);

  test('ISS position matches a live reference fix', () {
    final p = OrbitUtils.getSatellitePosition(iss, at);
    expect(p['lat']!, closeTo(-42.027, 0.5));
    expect(p['lon']!, closeTo(65.536, 0.5));
    expect(p['alt']!, closeTo(430, 10));
  });

  test('30 s along the orbit moves ~2 deg, not ~110', () {
    final a = OrbitUtils.getSatellitePosition(iss, at);
    final b = OrbitUtils.getSatellitePosition(
        iss, at.add(const Duration(seconds: 30)));
    expect((b['lat']! - a['lat']!).abs(), lessThan(3));
  });
}
