import 'package:flutter_test/flutter_test.dart';
import 'package:rockets/models/astronaut.dart';

void main() {
  // Shape of Launch Library 2's detailed astronaut object as of 2026-10-03:
  // agency has `name` and no `abbrev`, flights are full launch objects whose
  // name is "vehicle | mission".
  final crew13 = {
    'name': 'Jessica Watkins',
    'agency': {
      'name': 'National Aeronautics and Space Administration',
      'type': 'Government',
    },
    'nationality': 'American',
    'profile_image_thumbnail': 'https://example.test/watkins.jpg',
    'time_in_space': 'P171DT23H17M14S',
    'flights_count': 2,
    'spacewalks_count': 0,
    'bio': 'Geologist.',
    'flights': [
      {'name': 'Falcon 9 Block 5 | Crew-5', 'net': '2022-04-27T07:52:55Z'},
      {'name': 'Falcon 9 Block 5 | Crew-13', 'net': '2026-10-01T15:10:06Z'},
    ],
  };

  test('parses a crew member from the live API shape', () {
    final a = Astronaut.fromJson(crew13);
    expect(a.name, 'Jessica Watkins');
    expect(a.agency, 'NASA');
    expect(a.mission, 'Crew-13');
    expect(a.station, 'International Space Station');
    expect(a.careerDays, 171);
    expect(a.flightsCount, 2);
    expect(a.launchedAt, DateTime.utc(2026, 10, 1, 15, 10, 6));
    expect(a.daysUp(DateTime.utc(2026, 10, 3, 15, 10, 6)), 2);
    expect(a.isStarman, isFalse);
  });

  test('Shenzhou crews are on Tiangong, Starman is not crew', () {
    final shenzhou = Astronaut.fromJson({
      'name': 'Zhu Yangzhu',
      'agency': {'name': 'China National Space Administration'},
      'flights': [
        {'name': 'Long March 2F | Shenzhou 23', 'net': '2026-05-24T15:08:36Z'},
      ],
      'time_in_space': 'P285D',
    });
    expect(shenzhou.agency, 'CNSA');
    expect(shenzhou.station, 'Tiangong');
    expect(shenzhou.mission, 'Shenzhou 23');

    final starman = Astronaut.fromJson({
      'name': 'Starman',
      'agency': {'name': 'SpaceX'},
      'flights': [
        {'name': 'Falcon Heavy | Demo (Test Flight)', 'net': '2018-02-06T20:45:00Z'},
      ],
    });
    expect(starman.isStarman, isTrue);
    expect(starman.station, 'Heliocentric orbit');
    expect(starman.agency, 'SpaceX');
  });

  test('cache round trip keeps the fields the screen shows', () {
    final again = Astronaut.fromJson(Astronaut.fromJson(crew13).toJson());
    expect(again.name, 'Jessica Watkins');
    expect(again.agency, 'NASA');
    expect(again.mission, 'Crew-13');
    expect(again.careerDays, 171);
    expect(again.imageUrl, 'https://example.test/watkins.jpg');
    expect(again.bio, 'Geologist.');
  });
}
