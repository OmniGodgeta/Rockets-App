/// A single upcoming or past rocket launch, as returned by the
/// Launch Library 2 API (https://ll.thespacedevs.com/2.2.0/launch/).
class Launch {
  final String id;
  final String name;
  final DateTime net;
  final String statusName;
  final String rocketName;
  final String padName;
  final String locationName;
  final String? missionDescription;
  final String? imageUrl;
  final String? webcastUrl;
  final bool webcastIsFallback;
  final double? padLatitude;
  final double? padLongitude;
  final String providerName;

  const Launch({
    required this.id,
    required this.name,
    required this.net,
    required this.statusName,
    required this.rocketName,
    required this.padName,
    required this.locationName,
    this.missionDescription,
    this.imageUrl,
    this.webcastUrl,
    this.webcastIsFallback = false,
    this.padLatitude,
    this.padLongitude,
    this.providerName = 'Unknown provider',
  });

  /// Whether this launch is imminent or in progress right now - from 10
  /// minutes before its scheduled time to 2 hours after (covers holds,
  /// delays within the window, and the flight itself for most missions).
  bool get isHappeningNow {
    final now = DateTime.now().toUtc();
    final start = net.subtract(const Duration(minutes: 10));
    final end = net.add(const Duration(hours: 2));
    return now.isAfter(start) && now.isBefore(end);
  }

  factory Launch.fromJson(Map<String, dynamic> json) {
    final pad = json['pad'] as Map<String, dynamic>?;
    final location = pad?['location'] as Map<String, dynamic>?;
    final rocket = json['rocket'] as Map<String, dynamic>?;
    final configuration = rocket?['configuration'] as Map<String, dynamic>?;
    final mission = json['mission'] as Map<String, dynamic>?;
    final status = json['status'] as Map<String, dynamic>?;
    final vidUrls = json['vidURLs'] as List<dynamic>?;
    final provider = json['launch_service_provider'] as Map<String, dynamic>?;

    final fullRocketName = configuration?['full_name'] as String?;
    final providerName = provider?['name'] as String? ?? 'Unknown provider';

    // Starship fallback removed as it is no longer needed; SpaceX Starship launches
    // correctly appear in the rocket configuration field in recent LL2 API responses.
    String? webcastUrl = (vidUrls != null && vidUrls.isNotEmpty)
        ? vidUrls.first['url'] as String?
        : null;
    bool webcastIsFallback = false;
    // LL2's vidURLs is usually empty for SpaceX: they stream on X, not
    // YouTube, so there's rarely a per-launch video entry for the API to
    // surface. Fall back to their known livestream sources rather than
    // showing no watch link at all for the provider that launches most often.
    if (webcastUrl == null && providerName.toLowerCase().contains('spacex')) {
      webcastUrl = 'https://x.com/SpaceX';
      webcastIsFallback = true;
    }

    return Launch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed launch',
      net: DateTime.tryParse(json['net'] as String? ?? '') ?? DateTime.now(),
      statusName: status?['name'] as String? ?? 'Unknown',
      rocketName: fullRocketName ?? 'Unknown rocket',
      padName: pad?['name'] as String? ?? 'Unknown pad',
      locationName: location?['name'] as String? ?? 'Unknown location',
      missionDescription: mission?['description'] as String?,
      imageUrl: json['image'] as String?,
      webcastUrl: webcastUrl,
      webcastIsFallback: webcastIsFallback,
      padLatitude: double.tryParse(pad?['latitude'] as String? ?? ''),
      padLongitude: double.tryParse(pad?['longitude'] as String? ?? ''),
      providerName: providerName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'net': net.toIso8601String(),
      'statusName': statusName,
      'rocketName': rocketName,
      'padName': padName,
      'locationName': locationName,
      'missionDescription': missionDescription,
      'imageUrl': imageUrl,
      'webcastUrl': webcastUrl,
      'webcastIsFallback': webcastIsFallback,
      'padLatitude': padLatitude,
      'padLongitude': padLongitude,
      'providerName': providerName,
    };
  }
}
