import 'package:flutter/material.dart';

class Launch {
  final String id;
  final String missionName;
  final String dateUtc;
  final DateTime localDateTime;
  final String timeUtc;
  final String windowStartUtc;
  final String windowEndUtc;
  final DateTime netLaunchDateUtc;
  final DateTime netLaunchLocalDate;
  final String localLaunchDate;
  final String localLaunchTime;
  final String details;
  final String launchProviders;
  final String? abortCause;
  final String? launchpad;
  final Rocket? rocket;
  final List<LaunchSite> launchSites;
  final int? flightNumber;
  final int? launchSuccess;
  final List<String>? failures;
  final List<String>? remarks;
  final int? launchOutcome;
  final int? flightTerminationLaunchCount;
  final bool delayed;
  final bool live;
  final List<RocketInfo>? coresUsed;
  final List<RocketInfo>? fairingsRecovered;
  final bool? rocketReused;
  final bool? payloadVariantReused;
  final List<dynamic>? flightHardwareStatus;
  final String? netStatus;
  final List<Payload> payload;
  final List<leg> lands;
  final List<LandingType> landingLegType;
  final List<String> landingLocations;
  final List<String> landingResults;
  final bool isTentative;
  final LaunchStatus status;
  final List<VideoSource> videoSources;

  Launch({
    required this.id,
    required this.missionName,
    required this.dateUtc,
    this.localDateTime,
    this.timeUtc,
    this.windowStartUtc,
    this.windowEndUtc,
    this.netLaunchDateUtc,
    this.netLaunchLocalDate,
    this.localLaunchDate,
    this.localLaunchTime,
    this.details,
    this.launchProviders,
    this.abortCause,
    this.launchpad,
    this.rocket,
    this.lands = const [],
    this.launchSites = const [],
    this.flightNumber,
    this.launchSuccess,
    this.failures,
    this.remarks,
    this.launchOutcome,
    this.flightTerminationLaunchCount,
    this.delayed = false,
    this.live = false,
    this.coresUsed,
    this.fairingsRecovered,
    this.rocketReused,
    this.payloadVariantReused,
    this.flightHardwareStatus,
    this.netStatus,
    required this.payload,
    required this.landingLegType,
    required this.landingLocations,
    required this.landingResults,
    this.isTentative = false,
    this.status = LaunchStatus.scheduled,
    this.videoSources = const [],
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'missionName': missionName,
    'dateUtc': dateUtc,
    'localDateTime': localDateTime?.toIso8601String(),
    'timeUtc': timeUtc,
    'windowStartUtc': windowStartUtc,
    'windowEndUtc': windowEndUtc,
    'netLaunchDateUtc': netLaunchDateUtc?.toIso8601String(),
    'netLaunchLocalDate': netLaunchLocalDate?.toIso8601String(),
    'localLaunchDate': localLaunchDate,
    'localLaunchTime': localLaunchTime,
    'details': details,
    'launchProviders': launchProviders,
    'abortCause': abortCause,
    'launchpad': launchpad,
    'mission': missions,
    'coresUsed': coresUsed,
    'fairingsRecovered': fairingsRecovered,
    'rocketReused': rocketReused,
    'payloadVariantReused': payloadVariantReused,
    'flightHardwareStatus': flightHardwareStatus,
    'netStatus': netStatus,
    'rocket': rocket?.toJson(),
    'landingLegType': landingLegType.map((e) => e.toString()).toList(),
    'landingLocations': landingLocations,
    'landingResults': landingResults,
    'status': status.toString(),
  };

  // Calculate time until launch
  Duration get timeUntilLaunch {
    final nextLaunchTime = DateTime.parse('2025-01-01T00:00:00Z');
    return nextLaunchTime.difference(DateTime.now());
  }
}

class Rocket {
  final String id;
  final String name;
  final String type;
  final String isActive;
  final List<String> variants;
  final List<String> manufacturers;
  final List<String> first_flight;
  final String debut_flight;
  final String height;
  final String diameter;
  final String mass;
  final List<String> stages;
  final List<String> boosters;
  final bool legs;
  final List<int> reused;
  final List<String> operations;
  final int payloads;
  final String costPerLaunch;
  final String success_rate_pct;
  final List<String> rockets;
  final String rocketType;
  final bool isRecoveringFairings;

  Rocket({
    required this.id,
    required this.name,
    required this.type,
    this.isActive,
    this.variants = const [],
    this.manufacturers = const [],
    this.first_flight = const [],
    required this.debut_flight,
    required this.height,
    required this.diameter,
    required this.mass,
    this.stages = const [],
    this.boosters = const [],
    this.legs = false,
    this.reused,
    this.operations = const [],
    this.payloads = 0,
    this.costPerLaunch = '$0',
    this.success_rate_pct = '',
    this.rockets = const [],
    required this.rocketType,
    this.isRecoveringFairings = true,
  });

  Map<String, dynamic> toJson() => {
    'rocket': name,
    'rockets': rockets,
    'rocket_type': rocketType,
    'type': type,
    'height_m': height,
    'diameter_m': diameter,
    'mass_kg': mass,
    'payloads': payloads,
    'cost_per_launch': costPerLaunch,
    'success_rate_pct': success_rate_pct,
    'reused': reused,
    'legs': legs,
    'active': isActive,
    'operations': operations,
    'recovered_fairings': isRecoveringFairings,
  };
}

class RocketInfo {
  final String id;
  final String missionName;
  final String success;
  final String flightNumber;

  RocketInfo({
    required this.id,
    required this.missionName,
    required this.success,
    required this.flightNumber,
  });
}

class leg {
  final int flight;
  final String date;
  final String location;

  leg({
    required this.flight,
    required this.date,
    required this.location,
  });
}

// Video stream source
class VideoSource {
  final String name;
  final String url;
  final bool isFallback;
  final String provider;
  final String quality;
  final String status;

  VideoSource({
    required this.name,
    required this.url,
    this.isFallback = false,
    this.provider = 'youtube',
    this.quality = 'auto',
    this.status = 'live',
  });

  String get fullUrl {
    if (provider == 'youtube') {
      return 'https://www.youtube.com/watch?v=$url';
    }
    return url;
  }
}

class VideoStreamManager {
  final List<VideoSource> sources;
  final String currentStream;
  final bool isLive;
  final bool hasError;
  final String errorMessage;

  VideoStreamManager({
    this.sources = const [],
    this.currentStream = '',
    this.isLive = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  void switchToFallback() {
    if (sources.isNotEmpty) {
      currentStream = sources.last.url;
      isLive = false;
    }
  }
}

enum launchStatus {
  scheduled, prelaunch, launch, landed, success, failure, partial, terminated, noattempt,
}
