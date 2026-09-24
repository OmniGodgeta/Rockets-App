import 'package:flutter/foundation.dart';

/// Launch site with coordinates and facility information
/// 
/// Represents a launch location worldwide
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
class LaunchSite implements Comparable<LaunchSite> {
  /// Site code identifier
  final String code;
  
  /// Full site name
  final String name;
  
  /// Latitude in degrees
  final double lat;
  
  /// Longitude in degrees
  final double lon;
  
  /// Maximum precision of coordinates
  final double? maxPrecision;
  
  /// Launchpad number
  final int? launchpad;
  
  /// Launch site area code
  final String? area;
  
  /// Country code
  final String? country;
  
  /// UTC offset
  final int? utcOffset;
  
  /// Whether this site is active
  final bool isActive;
  
  LaunchSite({
    this.code = '',
    this.name = '',
    this.lat = 0.0,
    this.lon = 0.0,
    this.maxPrecision,
    this.launchpad,
    this.area,
    this.country,
    this.utcOffset,
    this.isActive = true,
  });

  /// Check if site is near location
  bool isNear(double lat, double lon, [double maxDistanceKm = 100]) {
    final distance = calculateDistance(lat, lon, this.lat, this.lon);
    return distance <= maxDistanceKm;
  }

  /// Calculate distance from this site to a point (Haversine formula)
  double distanceTo(double latitude, double longitude) {
    return calculateDistance(lat, lon, latitude, longitude);
  }

  /// Get display name with country
  String get displayName {
    if (country != null && country!.isNotEmpty) {
      return '$name, $country';
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaunchSite && runtimeType == other.runtimeType &&
      code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  int compareTo(LaunchSite other) {
    return name.compareTo(other.name);
  }
}

/// Calculate great-circle distance between two points (Haversine formula)
/// Returns distance in kilometers
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  
  final dLat = lat2 - lat1;
  final dLon = lon2 - lon1;
  
  final a = (dLat.toRadians() * 0.01745329252) * 
            (dLat.toRadians() * 0.01745329252) + 
            ((lat1.toRadians() * 0.01745329252).cos() * 
             (dLat.toRadians() * 0.01745329252).cos()) *
            ((lon1.toRadians() * 0.01745329252).sin() * 
             (dLon.toRadians() * 0.01745329252).sin());
  
  final c = 2 * a.sqrt().asin();
  
  return earthRadiusKm * c;
}
