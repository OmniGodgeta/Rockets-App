import 'package:flutter_test/flutter_test.dart';
import 'package:rockets/utils/moon_phase.dart';

void main() {
  // Eclipses happen exactly at new/full moon, so their dates are trustworthy
  // anchors: 2024-04-08 total solar eclipse (new moon 18:21 UTC) and
  // 2025-03-14 total lunar eclipse (full moon 06:55 UTC).
  final newMoon = DateTime.utc(2024, 4, 8, 18, 21);
  final fullMoon = DateTime.utc(2025, 3, 14, 6, 55);

  test('finds the eclipse new moon within 2 hours', () {
    final got = MoonPhase.next(0, DateTime.utc(2024, 3, 30));
    expect(got.difference(newMoon).inMinutes.abs(), lessThan(120),
        reason: 'got $got');
  });

  test('finds the eclipse full moon within 2 hours', () {
    final got = MoonPhase.next(180, DateTime.utc(2025, 3, 2));
    expect(got.difference(fullMoon).inMinutes.abs(), lessThan(120),
        reason: 'got $got');
  });

  test('names and illumination at those moments', () {
    final n = MoonPhase.at(newMoon);
    expect(n.name, 'New Moon');
    expect(n.illumination, lessThan(0.01));
    final f = MoonPhase.at(fullMoon);
    expect(f.name, 'Full Moon');
    expect(f.illumination, greaterThan(0.99));
    // A week after new moon: first quarter, about half lit, waxing.
    final q = MoonPhase.at(newMoon.add(const Duration(hours: 177)));
    expect(q.waxing, isTrue);
    expect(q.illumination, closeTo(0.5, 0.08));
  });
}
