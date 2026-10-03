/// Someone in space right now, from Launch Library 2's
/// `/astronaut/?in_space=true` (https://ll.thespacedevs.com/2.2.0/astronaut/).
class Astronaut {
  const Astronaut({
    required this.name,
    required this.agency,
    required this.nationality,
    required this.imageUrl,
    required this.mission,
    required this.launchedAt,
    required this.careerDays,
    required this.flightsCount,
    required this.spacewalks,
    this.bio,
  });

  final String name;
  final String agency;
  final String nationality;
  final String? imageUrl;

  /// The flight that took them up this time, e.g. "Crew-13".
  final String mission;
  final DateTime? launchedAt;

  /// Total days in space over their career, including this flight so far.
  final int careerDays;
  final int flightsCount;
  final int spacewalks;
  final String? bio;

  /// SpaceX's mannequin in the Tesla Roadster, which the API lists as "in
  /// space" since 2018. Shown as a footnote, not as crew.
  bool get isStarman => name == 'Starman';

  /// Where they are: Shenzhou crews fly to China's Tiangong; everyone else
  /// currently flying (Crew Dragon, Soyuz, Starliner) goes to the ISS.
  String get station {
    final m = mission.toLowerCase();
    if (m.contains('shenzhou')) return 'Tiangong';
    if (isStarman) return 'Heliocentric orbit';
    return 'International Space Station';
  }

  /// Days on this flight so far.
  int daysUp(DateTime now) =>
      launchedAt == null ? 0 : now.difference(launchedAt!).inDays;

  static const _agencyShort = {
    'National Aeronautics and Space Administration': 'NASA',
    'Russian Federal Space Agency (ROSCOSMOS)': 'Roscosmos',
    'European Space Agency': 'ESA',
    'Canadian Space Agency': 'CSA',
    'China National Space Administration': 'CNSA',
    'Japan Aerospace Exploration Agency': 'JAXA',
  };

  factory Astronaut.fromJson(Map<String, dynamic> j) {
    final flights = [
      for (final f in (j['flights'] as List? ?? const []))
        (f as Map).cast<String, dynamic>(),
    ]..sort((a, b) => '${a['net']}'.compareTo('${b['net']}'));
    final last = flights.isEmpty ? null : flights.last;
    final lastName = (last?['name'] as String?) ?? '';
    final agencyName =
        ((j['agency'] as Map?)?['name'] as String?) ?? 'Unknown agency';
    return Astronaut(
      name: (j['name'] as String?) ?? 'Unknown',
      agency: (j['agency'] as Map?)?['abbrev'] as String? ??
          _agencyShort[agencyName] ??
          agencyName,
      nationality: (j['nationality'] as String?) ?? '',
      imageUrl: (j['profile_image_thumbnail'] ?? j['profile_image']) as String?,
      // "Falcon 9 Block 5 | Crew-13" -> "Crew-13"
      mission: lastName.contains('|')
          ? lastName.split('|').last.trim()
          : lastName,
      launchedAt: DateTime.tryParse('${last?['net'] ?? j['last_flight']}'),
      careerDays: parseIsoDays(j['time_in_space'] as String?),
      flightsCount: (j['flights_count'] as num?)?.toInt() ?? flights.length,
      spacewalks: (j['spacewalks_count'] as num?)?.toInt() ?? 0,
      bio: j['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'agency': {'abbrev': agency},
    'nationality': nationality,
    'profile_image_thumbnail': imageUrl,
    'flights': [
      {'name': mission, 'net': launchedAt?.toIso8601String()},
    ],
    'time_in_space': 'P${careerDays}D',
    'flights_count': flightsCount,
    'spacewalks_count': spacewalks,
    'bio': bio,
  };

  /// Whole days from an ISO-8601 duration like "P436DT6H28M11S".
  static int parseIsoDays(String? iso) {
    if (iso == null) return 0;
    final m = RegExp(r'P(?:(\d+)D)?').firstMatch(iso);
    return int.tryParse(m?.group(1) ?? '') ?? 0;
  }
}
