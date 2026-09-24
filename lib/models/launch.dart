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
  });

  factory Launch.fromJson(Map<String, dynamic> json) {
    final pad = json['pad'] as Map<String, dynamic>?;
    final location = pad?['location'] as Map<String, dynamic>?;
    final rocket = json['rocket'] as Map<String, dynamic>?;
    final configuration = rocket?['configuration'] as Map<String, dynamic>?;
    final mission = json['mission'] as Map<String, dynamic>?;
    final status = json['status'] as Map<String, dynamic>?;
    final vidUrls = json['vidURLs'] as List<dynamic>?;

    return Launch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed launch',
      net: DateTime.tryParse(json['net'] as String? ?? '') ?? DateTime.now(),
      statusName: status?['name'] as String? ?? 'Unknown',
      rocketName: configuration?['full_name'] as String? ?? 'Unknown rocket',
      padName: pad?['name'] as String? ?? 'Unknown pad',
      locationName: location?['name'] as String? ?? 'Unknown location',
      missionDescription: mission?['description'] as String?,
      imageUrl: json['image'] as String?,
      webcastUrl: (vidUrls != null && vidUrls.isNotEmpty)
          ? vidUrls.first['url'] as String?
          : null,
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
    };
  }
}