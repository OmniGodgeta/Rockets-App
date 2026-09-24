import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/launch.dart';
import '../models/rocket.dart';

class ApiService {
  // API base URLs
  static const String spacexApi = 'https://api.spacexdata.com/v4';
  static const String nasaApi = 'https://api.nasa.gov';
  
  // Get all SpaceX launches
  static Future<List<Launch>> getSpaceXLaunches() async {
    try {
      final response = await http.get(Uri.parse('$spacexApi/launches'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = (data['launches'] as List)
            .map((json) => Launch(
              id: json['id'] as String,
              missionName: json['name'] as String,
              dateUtc: json['date_utc'] as String,
              flightNumber: json['flight_number'] as int,
              success: json['success'] as int,
              details: json['details'] as String,
              upcoming: json['upcoming'] as bool,
              tbd: json['tbd'] as bool,
              rocketId: json['rocket'] as String,
              live: json['live'] as bool,
              launchSites: <LaunchSite>[
                LaunchSite(
                  name: json['launchpad'] as String? ?? 'KSC Launch Complex 39A',
                ),
              ],
              isTentative: json['tentative'] as bool?,
              videoSources: _extractVideoSources(json['links'] as Map<String, String>?),
            ))
            .toList();
        return list;
      }
    } catch (e) {
      print('Error fetching SpaceX launches: $e');
    }
    return [];
  }

  // Get all rockets
  static Future<List<Rocket>> getRockets() async {
    try {
      final response = await http.get(Uri.parse('$spacexApi/rockets'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rockets'] as List)
            .map((json) => Rocket(
              id: json['id'] as String,
              name: json['name'] as String,
              type: json['type'] as String,
              active: json['active'] as bool,
              firstFlight: json['first_flight'] as String,
              manufacturer: json['manufacturer'] as String?,
              height: json['height'] as String,
              diameter: json['diameter'] as String,
            ))
            .toList();
      }
    } catch (e) {
      print('Error fetching rockets: $e');
    }
    return [];
  }

  // Get upcoming launches (SpaceX + NASA + others)
  static Stream<List<Launch>> streamUpcomingLaunches() async* {
    try {
      final launches = await getSpaceXLaunches();
      // Add NASA and other launches as mock data
      final allLaunches = [...launches, ..._mockOtherLaunches];
      
      // Yield every 60 seconds
      while (true) {
        yield allLaunches.where((l) => l.upcoming || l.live).toList();
        await Future.delayed(const Duration(seconds: 60));
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 60));
      yield [];
    }
  }

  // Extract video sources from launch links
  static List<VideoSource> _extractVideoSources(Map<String, String>? links) {
    final sources = <VideoSource>[];
    
    // NASA launch streams
    if (links != null && links.containsKey('redirection') && links['redirection']!.contains('nasa')) {
      sources.add(VideoSource(
        name: 'NASA Launch Stream',
        url: links['redirection'] ?? '',
        provider: 'nasa',
      ));
    }
    
    // YouTube streams
    if (links != null && links.containsKey('youtube')) {
      final videoId = links['youtube']?.split('/').last
          .split('&')[0]
          .split('=')
          .last ?? '';
      if (videoId.isNotEmpty) {
        sources.add(VideoSource(
          name: 'YouTube Stream',
          url: videoId,
          provider: 'youtube',
        ));
      }
    }
    
    return sources;
  }

  // Get launch by ID
  static Future<Launch?> getLaunchById(String id) async {
    try {
      final response = await http.get(Uri.parse('$spacexApi/launches/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Launch(
          id: data['id'] as String,
          missionName: data['name'] as String,
          dateUtc: data['date_utc'] as String,
          flightNumber: data['flight_number'] as int?,
          success: data['success'] as int? ?? 0,
          details: data['details'] as String?,
          upcoming: data['upcoming'] as bool?,
          tbd: data['tbd'] as bool?,
          rocketId: data['rocket'] as String?,
          live: data['live'] as bool?,
          launchSites: <LaunchSite>[
            LaunchSite(
              name: data['launchpad'] as String? ?? '',
            ),
          ],
          isTentative: data['tentative'] as bool?,
          videoSources: _extractVideoSources(data['links'] as Map<String, String>?),
        );
      }
    } catch (e) {
      return null;
    }
  }

  // Get launch pad info
  static Future<List<dynamic>> getLaunchPads() async {
    try {
      final response = await http.get(Uri.parse('$spacexApi/launchpads'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['launchpads'] as List;
      }
    } catch (e) {
      print('Error fetching launch pads: $e');
    }
    return [];
  }
}

// Mock/non-SpaceX launch data
class MockData {
  static const List<Launch> _mockOtherLaunches = const <Launch>[
    Launch(
      id: 'nasa-mission-1',
      missionName: 'Artemis II Lunar Mission',
      dateUtc: '2025-02-15T12:00:00.000Z',
      flightNumber: 100,
      success: 0,
      details: 'NASA Artemis II lunar crewed mission',
      upcoming: true,
      tbd: true,
      rocketId: 'sln1',
      isTentative: true,
      videoSources: const <VideoSource>[
        VideoSource(
          name: 'NASA TV',
          url: 'nasa-rocket-return-artemis-ii-stream',
          provider: 'nasa',
        ),
      ],
    ),
    Launch(
      id: 'rocket-lab-1',
      missionName: 'Electron - Earth Observation',
      dateUtc: '2025-01-10T04:30:00.000Z',
      flightNumber: 101,
      success: 0,
      details: 'Rocket Lab Electron launch',
      upcoming: true,
      rocketId: 'rl-1',
      videoSources: const <VideoSource>[
        VideoSource(
          name: 'Rocket Lab Stream',
          url: 'electron-launch',
          provider: 'rocketlab',
        ),
      ],
    ),
    Launch(
      id: 'isro-1',
      missionName: 'PSLV-C60',
      dateUtc: '2025-01-20T08:00:00.000Z',
      flightNumber: 102,
      success: 0,
      details: 'ISRO Earth observation satellite',
      upcoming: true,
      tbd: true,
      rocketId: 'pslv',
      isTentative: true,
    ),
    Launch(
      id: 'esa-mission-1',
      missionName: 'Galileo Pathfinder',
      dateUtc: '2025-03-01T10:00:00.000Z',
      flightNumber: 103,
      success: 0,
      details: 'ESA Ariane 6 test flight',
      upcoming: true,
      rocketId: 'ariane6',
      isTentative: true,
    ),
  ];
}
