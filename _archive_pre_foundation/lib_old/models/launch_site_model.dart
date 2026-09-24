import 'package:flutter/foundation.dart';

// Launch status enumeration
enum LaunchStatus {
  scheduled,       // Planned launch
  prelaunch,       // T-minus (ready for launch)  
  launch,          // Currently launching
  landed,          // Landing complete
  success,         // Mission success
  failure,          // Mission failure
  partial,         // Partial success
  terminated,      // Mission terminated
  noattempt,       // Launch not attempted
}

// Launch outcome enumeration  
enum LaunchOutcome {
  mission,         // Mission success (primary objective)
  payload,         // Payload success
  flight,          // Hardware flight success
  landing,         // Landing success
}

// Landing type enumeration
enum LandingType {
  drone,           // Drone ship landing
  ship,            // Land on drone ship
  water,           // Splash down (splashdown)
  land,            // Land launch pad
  unknown,         // Landing method unknown
}

// Launch location data
class LaunchSite {
  final String name;
  final String waist;
  final double latitude, longitude;
  final String launchpad;
  final List<double> coordinates;
  final LaunchType launchType;

  LaunchSite({
    required this.name,
    required this.waist,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.launchpad,
    this.coordinates = const [],
    this.launchType = LaunchType.rocket,
  });

  factory LaunchSite.fromJson(Map<String, dynamic> json) {
    return LaunchSite(
      name: json['name'] ?? '',
      waist: json['waist'] ?? '',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'])
          : const [],
      launchType: LaunchType.values.firstWhere(
        (t) => t.toString().split('.').last == json['launch']?.toString(),
        orElse: () => LaunchType.rocket,
      ),
    );
  }
}

// Launch type enumeration
enum LaunchType {
  rocket,          // Rocket launch
  airLaunch,       // Air-launch
  airDrop,         // Airdrop
  airplane,        // Airplane
  unclassified,    // Unclassified
}

// Payload data
class Payload {
  final String name;
  final String mass;
  final String orbitalParams;
  final int orbits;
  final int timeOfOrbit;
  final int period;
  final int reentry;
  final int decay;
  final PayloadType type;

  Payload({
    required this.name,
    this.mass = '0',
    this.orbitalParams = '',
    this.orbits = 0,
    this.timeOfOrbit = 0,
    this.period = 525,
    this.reentry = 20,
    this.decay = 1,
    this.type = PayloadType.satellite,
  });
}

// Payload type enumeration
enum PayloadType {
  satellite,
  spacecraft,
  landingCraft,
  cargo,
  pods,
  capsule,
  spacecraftBus,
  landed,
  boosted,
  unknown,
}

// Orbital parameters
class OrbitalParameters {
  final int inclination;
  final int perigee;
  final int apogee;
  final double eccentricity;
  final int semiMajorAxis;
  final int period;
  final int epoch;
  final double noAop;
  final double meanAnomaly;
  final double argumentOfPeriapsis;

  OrbitalParameters({
    required this.inclination,
    required this.perigee,
    required this.apogee,
    this.eccentricity = 0.0,
    this.semiMajorAxis = 0,
    this.period = 525,
    this.epoch = 0,
    this.noAop = 0.0,
    this.meanAnomaly = 0.0,
    this.argumentOfPeriapsis = 0.0,
  });

  factory OrbitalParameters.fromJson(Map<String, dynamic> json) {
    return OrbitalParameters(
      inclination: json['inclination'] ?? 0,
      perigee: json['perigee'] ?? 0,
      apogee: json['apogee'] ?? 0,
      eccentricity: json['eccentricity'] != null
          ? json['eccentricity'] as double
          : 0.0,
      semiMajorAxis: json['semiMajorAxis'] ?? 0,
      period: json['period'] ?? 525,
      epoch: json['epoch'] ?? 0,
      noAop: (json['noAop'] ?? 0).toDouble(),
      meanAnomaly: (json['meanAnomaly'] ?? 0).toDouble(),
      argumentOfPeriapsis: (json['argumentOfPeriapsis'] ?? 0).toDouble(),
    );
  }
}

// Payload period
class Period {
  final int days;
  final int minutes;
  final int seconds;
  final int milliseconds;

  Period({
    this.days = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.milliseconds = 0,
  });
}
