import 'package:flutter/foundation.dart';

// Simplified launch model - avoids circular import
class Launch {
  final String id;
  final String missionName;
  final String dateUtc;
  final int flightNumber;
  final int success;
  final String details;
  final bool upcoming;
  final bool tbd;
  final String rocketId;
  final bool live;
  final List<String> launchSites;
  final bool isTentative;
  final List<VideoSource> videoSources;

  Launch({
    required this.id,
    required this.missionName,
    required this.dateUtc,
    this.flightNumber = 0,
    this.success = 0,
    required this.details,
    this.upcoming = false,
    this.tbd = false,
    this.rocketId = '',
    this.live = false,
    this.launchSites = const [],
    this.isTentative = false,
    this.videoSources = const [],
  });

  DateTime get launchDate {
    try {
      return DateTime.parse(dateUtc);
    } catch (_) {
      return DateTime.now();
    }
  }
}

class VideoSource {
  final String name;
  final String url;
  final bool isFallback;
  final String provider;

  VideoSource({
    required this.name,
    required this.url,
    this.isFallback = false,
    this.provider = 'youtube',
  });
}
