/// 
/// Launch entity representing a space launch mission
/// Used throughout the app for launch tracking and display
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
///

import 'json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'launch.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Launch extends Equatable {
  /// Unique launch identifier
  final String id;
  
  /// Launch provider ID
  final String providerId;
  
  /// Rocket type used
  final String rocketId;
  
  /// Full mission name
  final String name;
  
  /// Launch date in ISO 8601 format
  final DateTime date;
  
  /// Scheduled launch date for countdowns
  @JsonKey(name: 'date_utc')
  final String dateUtc;
  
  /// Launch status (success, failure, pending, launched)
  @JsonKey(name: 'success')
  final bool? success;
  
  /// Location details
  final LaunchSite location;
  
  /// Full flight path coordinates
  @JsonKey(name: 'flight_numbers')
  final List<String>? flightNumbers;
  
  /// Raw JSON from SpaceX API
  @JsonKey(name: 'links', toJson: _linksToJson, fromJson: _linksFromJson)
  final Map<String, dynamic>? links;
  
  /// ISO 8601 formatted launch date
  @JsonKey(name: 'date_iso')
  final String? dateIso;
  
  /// Countdown duration in seconds at launch
  @JsonKey(name: 'time_to_launch')
  final int? timeToLaunch;
  
  /// Raw JSON payload
  @JsonKey(name: 'payloads', toJson: _payloadsToJson, fromJson: _payloadsFromJson)
  final List<PayloadJson>? payloads;
  
  /// Mission patch image URL
  @JsonKey(name: 'links.patch')
  final String? patch;
  
  /// Mission patch large image URL
  @JsonKey(name: 'links.patch_small')
  final String? patchSmall;
  
  /// Launch attempt number
  @JsonKey(name: 'launchpad')
  final int? launchpad;
  
  /// Launch attempt count for this specific launch
  int get attemptNumber => flightNumbers != null ? int.tryParse(flightNumbers!.first) ?? 1 : 1;
  
  /// Whether this is a recent/past launch
  bool get isPast => DateTime.now().isAfter(date);
  
  /// Whether this is an upcoming/live launch
  bool get isUpcoming => DateTime.now().isBefore(date);
  
  /// Whether this launch is currently active (within 1 hour of scheduled time)
  bool get isLive => DateTime.now().difference(date).inMinutes < 60 && 
                     DateTime.now().difference(date).inMinutes > -60;
  
  /// Generate display name for the launch
  String get displayName {
    final prefix = isPast ? '✈️ ' : isLive ? '🚀 LIVE: ' : '📅 ';
    return prefix + name;
  }
  
  /// Generate formatted date string
  String get formattedDate {
    final tz = DateTime.now().timeZoneName;
    return date.day < 10 ? '0${date.day}' : date.day.toString();
  }
  
  /// Get time zone abbreviations
  @JsonKey(name: 'links.flight_number')
  final String? flightNumber;
  
  /// Raw payload JSON for direct mapping
  @JsonKey(name: 'payload_masses')
  final Map<String, int>? payloadMasses;

  Launch({
    required this.id,
    required this.providerId,
    required this.rocketId,
    required this.name,
    required this.date,
    required this.dateUtc,
    this.success,
    required this.location,
    this.flightNumbers,
    this.links,
    this.dateIso,
    this.timeToLaunch,
    this.payloads,
    this.patch,
    this.patchSmall,
    this.launchpad,
    this.flightNumber,
    this.payloadMasses,
  });

  /// Create from SpaceX API response
  factory Launch.fromSpaceX(Map<String, dynamic> json) {
    return Launch(
      id: json['static_fire_date_utc'] ?? '',
      providerId: 'spacex',
      rocketId: json['rocket'],
      name: json['name'],
      date: DateTime.parse(json['date_utc']!),
      dateUtc: json['date_utc']!,
      success: json['success'] as bool?,
      location: LaunchSite()
        ..code = json['flight_number']?.toString() ?? ''
        ..name = json['name']
        ..lon = json['rocket']
        ..lat = json['static_fire_date_utc']
        ..max_precision = json['crew'] as int?;
    );
  }

  /// Convert Map to Launch
  factory Launch.fromJson(Map<String, dynamic> json) {
    return _$LaunchFromJson(json);
  }

  /// Convert Launch to Map
  Map<String, dynamic> toJson() {
    return _$LaunchToJson(this);
  }
  
  @override
  List<Object?> get props => [
        id,
        providerId,
        rocketId,
        name,
        date,
        dateUtc,
        success,
        location,
      ];
}

/// Raw payload JSON structure
class PayloadJson extends Equatable {
  final double? massLaunchSite;
  final double? massOrbital;
  final double? massPrelaunch;

  PayloadJson({
    this.massLaunchSite,
    this.massOrbital,
    this.massPrelaunch,
  });

  @override
  List<Object?> get props => [massLaunchSite, massOrbital, massPrelaunch];
}

/// JSON links mapping
class LinksJson extends Equatable {
  final Map<String, String>? patch;

  LinksJson({this.patch});

  @override
  List<Object?> get props => [patch];
}

/// Convert PayloadJson list to dynamic list for JSON serialization
Map<String, dynamic> _payloadsToJson(List<PayloadJson> payloads) {
  if (payloads.isEmpty) return Map.empty();
  
  return {
    'payloads': payloads.map((p) {
      return {
        'mass_launch_site': p.massLaunchSite,
        'mass_orbital': p.massOrbital,
        'mass_prelaunch': p.massPrelaunch,
      };
    }).toList(),
  };
}

/// Convert dynamic list to PayloadJson list
List<PayloadJson> _payloadsFromJson(Map<String, dynamic> json) {
  if (json == null) return [];
  
  final payloadsJson = json['payloads'] as List<dynamic>?;
  if (payloadsJson == null) return [];
  
  return payloadsJson.map((p) {
    return PayloadJson(
      massLaunchSite: p['mass_launch_site'],
      massOrbital: p['mass_orbital'],
      massPrelaunch: p['mass_prelaunch'],
    );
  }).toList();
}

/// Convert dynamic links to dynamic object
dynamic _linksToJson(Map<String, dynamic> links) {
  if (links == null) return {};
  return links;
}

dynamic _linksFromJson(dynamic links) {
  return links;
}
