import 'package:flutter/foundation.dart';

/// Orbital trajectory and mission parameters
/// 
/// Contains orbital mechanics data for launched payloads
/// 
/// @author Hermes Agent Team  
/// @date 2026-09-23
class Orbit implements Comparable<Orbit> {
  /// Unique orbit identifier
  final String id;
  
  /// Perigee altitude in kilometers
  @JsonKey(name: 'perigee_km')
  final double? perigeeKm;
  
  /// Apogee altitude in kilometers
  @JsonKey(name: 'apogee_km')
  final double? apogeeKm;
  
  /// Semi-major axis in kilometers
  @JsonKey(name: 'semi_major_axis')
  final double? semiMajorAxis;
  
  /// Inclination in degrees
  @JsonKey(name: 'inclination_deg')
  final double? inclinationDeg;
  
  /// Period in hours
  @JsonKey(name: 'period_hours')
  final double? periodHours;
  
  /// Eccentricity
  @JsonKey(name: 'eccentricity')
  final double? eccentricity;
  
  /// Orbit type designation
  @JsonKey(name: 'orbit_type')
  final String orbitType;
  
  /// Mean motion (revolutions per day)
  @JsonKey(name: 'mean_motion')
  final int? meanMotion;
  
  /// RAAN (Right Ascension of Ascending Node)
  @JsonKey(name: 'raan')
  final double? raan;
  
  /// Argument of perigee
  @JsonKey(name: 'arg_perigee')
  final double? argPerigee;
  
  /// Argument of latitude
  @JsonKey(name: 'arg_lat')
  final double? argLat;
  
  /// Period classification
  final OrbitPeriod period;
  
  /// Mission payload
  @JsonKey(name: 'mission_payload')
  final Map<String, String>? missionPayload;

  Orbit({
    this.id = '',
    this.perigeeKm,
    this.apogeeKm,
    this.semiMajorAxis,
    this.inclinationDeg,
    this.periodHours,
    this.eccentricity,
    this.orbitType = '',
    this.meanMotion,
    this.raan,
    this.argPerigee,
    this.argLat,
    this.period = OrbitPeriod.geo,
    this.missionPayload,
  });

  /// Get average altitude for circular orbits
  double get averageAltitude {
    if (perigeeKm == null || apogeeKm == null) return 0;
    return (perigeeKm! + apogeeKm!) / 2;
  }

  /// Get circularity ratio (1.0 = perfectly circular)
  double get circularityRatio {
    if (perigeeKm == null || apogeeKm == null || perigeeKm! == apogeeKm!) return 1.0;
    final altitudeDiff = (apogeeKm! - perigeeKm!).abs() / (perigeeKm! + apogeeKm!);
    return (1.0 - altitudeDiff);
  }

  /// Get orbit visual color based on inclination
  String get visualColor {
    if (inclinationDeg == null) return '#00A1DE';  // Default (LEO)
    
    // GEO
    if (inclinationDeg! < 1 && period == OrbitPeriod.geo) return '#8B4513';
    
    // Medium Earth Orbit
    if (apogeeKm != null && apogeeKm! > 35786 && apogeeKm! < 50000) {
      return '#D2691E';
    }
    
    return '#00A1DE';  // LEO default
  }

  /// Get visual opacity based on inclination (more inclined = more translucent)
  double get visualOpacity {
    if (inclinationDeg == null) return 0.8;
    return 1.0 - (inclinationDeg! / 180.0) * 0.5;
  }

  /// Check if orbit is polar
  bool get isPolar => inclinationDeg != null && inclinationDeg! >= 90;

  /// Check if orbit is sun-synchronous
  bool get isSunSynchronous {
    return orbitType.toLowerCase().contains('ss') ||
           orbitType.toLowerCase().contains('sun');
  }

  /// Check if orbit is elliptical
  bool get isElliptical => (apogeeKm != null && perigeeKm != null) &&
                           (apogeeKm! != perigeeKm!);

  /// Compare with another orbit
  @override
  int compareTo(Orbit other) {
    final orbitTypeCompare = orbitType.compareTo(other.orbitType);
    if (orbitTypeCompare != 0) return orbitTypeCompare;
    return orbitType.length.compareTo(other.orbitType.length);
  }

  /// Get inclination category
  String get inclinationCategory {
    if (inclinationDeg == null) return 'Unknown';
    
    final inc = inclinationDeg!;
    if (isPolar) return 'Polar';
    if (inc < 1) return 'Geostationary';
    if (inc > 80) return 'Inclined';
    if (inc < 28.5) return 'Equatorial';
    return 'Medium Inclination';
  }
}

/// Orbit period classification
enum OrbitPeriod {
  low('Low Ear th Orbit (LEO)', 200, 2000, '#00A1DE', 8),
  medium('Medium Earth Orbit (MEO)', 2000, 50000, '#D2691E', 4),
  high('High Earth Orbit (HEO)', 50000, 100000, '#8B4513', 2),
  geo('Geostationary (GEO)', 35500, 36000, '#8B4513', 36),
  
  sunSync('Sun-Synchronous (SSO)', 200, 2000, '#FF8C00', 8);

  final String description;
  final double minAltitude;
  final double maxAltitude;
  final String color;
  final double periodHours;

  const OrbitPeriod(this.description, this.minAltitude, this.maxAltitude, this.color, this.periodHours);

  @override
  String toString() => description;
}

/// Orbital position at a given time
class OrbitalPosition {
  final double longitude;
  final double latitude;
  final double ascendingNode;
  final double eccentricAnomaly;
  final double meanAnomaly;
  final double trueAnomaly;

  OrbitalPosition({
    required this.longitude,
    required this.latitude,
    required this.ascendingNode,
    required this.eccentricAnomaly,
    required this.meanAnomaly,
    required this.trueAnomaly,
  });

  factory OrbitalPosition.fromLaunch(
    double launchLat,
    double launchLon,
    double inclination,
  ) {
    // Simplified initial orbit injection position
    final initialLat = launchLat;
    final initialLon = launchLon;
    
    return OrbitalPosition(
      longitude: initialLon,
      latitude: initialLat,
      ascendingNode: launchLon,
      eccentricAnomaly: 0.0,
      meanAnomaly: 0.0,
      trueAnomaly: 0.0,
    );
  }

  factory OrbitalPosition.fromOrbit(
    Orbit orbit,
    DateTime time,
  ) {
    // Placeholder - full orbital mechanics computation would require
    // Kepler's equations and perturbation considerations
    return OrbitalPosition(
      longitude: 0.0,
      latitude: 0.0,
      ascendingNode: orbit.raan ?? 0.0,
      eccentricAnomaly: 0.0,
      meanAnomaly: (orbit.periodHours ?? 0).toDouble(),
      trueAnomaly: 0.0,
    );
  }
}

/// Extension for Orbit
extension OrbitExtension on Orbit {
  String get altitudeDisplay {
    if (perigeeKm == null || apogeeKm == null) return 'Circular ${averageAltitude} km';
    return 'Elliptical: ${perigeeKm!} - ${apogeeKm!} km';
  }
}
