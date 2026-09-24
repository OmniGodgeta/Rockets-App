import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Rocket/Spacecraft information
/// 
/// Represents a launch vehicle with its technical specifications
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
class Rocket implements Comparable<Rocket> {
  /// Unique identifier
  final String id;
  
  /// Manufacturer/provider ID
  final String manufacturer;
  
  /// Full rocket name
  final String name;
  
  /// Type designation (e.g., Falcon 9, Long March 5)
  @JsonKey(name: 'type')
  final String type;
  
  /// Height in meters
  @JsonKey(name: 'height_m')
  final double? heightM;
  
  /// Height in feet
  @JsonKey(name: 'height_ft')
  final double? heightFt;
  
  /// Diameter in meters
  @JsonKey(name: 'diameter_m')
  final double? diameterM;
  
  /// Maximum reusability flights
  @JsonKey(name: 'reusability')
  final String? reusability;
  
  /// Description
  final String description;
  
  /// Launch capability rating
  final LaunchCapacity? launchCapability;
  
  /// Active status
  final bool isActive;
  
  /// Image URL
  final String? image;
  
  /// Wikipedia URL
  @JsonKey(name: 'wikipedia')
  final String? wikipedia;
  
  Rocket({
    this.id = '',
    this.manufacturer = '',
    this.name = '',
    this.type = '',
    this.heightM,
    this.heightFt,
    this.diameterM,
    this.reusability,
    this.description = '',
    this.launchCapability,
    this.isActive = true,
    this.image,
    this.wikipedia,
  });

  /// Check if rocket matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           type.toLowerCase().contains(lowerQuery) ||
           manufacturer.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery);
  }

  /// Get launch capacity tier
  String get capacityTier {
    if (launchCapability != null) {
      if (launchCapability!.payload > 20000) return 'Heavy';
      else if (launchCapability!.payload > 10000) return 'Medium';
      else if (launchCapability!.payload > 5000) return 'Light/Medium';
      return 'Light';
    }
    return 'Unknown';
  }

  /// Calculate payload ratio
  double get payloadRatio {
    if (heightM == null || launchCapability == null || launchCapability!.payload == 0) return 0.0;
    return (launchCapability!.payload / heightM!) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rocket && runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(Rocket other) {
    return name.compareTo(other.name);
  }
}

/// Launch payload information
@JsonSerializable(explicitToJson: true)
class Payload implements Comparable<Payload> {
  final String id;
  final String name;
  
  @JsonKey(name: 'mass_launch_site')
  final double? massLaunchSite;
  
  @JsonKey(name: 'mass_orbital')
  final double? massOrbital;
  
  @JsonKey(name: 'mass_prelaunch')
  final double? massPrelaunch;
  
  @JsonKey(name: 'class')
  final String? class_;
  
  @JsonKey(name: 'customer')
  final String? customer;
  
  final String? description;

  Payload({
    this.id = '',
    this.name = '',
    this.massLaunchSite,
    this.massOrbital,
    this.massPrelaunch,
    this.class_,
    this.customer,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payload && runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(Payload other) {
    return name.compareTo(other.name);
  }
}

/// Payload class/category
class PayloadClass extends Enum {
  static const light = PayloadClass('light', 'Light payload');
  static const small = PayloadClass('small', 'Small payload');
  static const medium = PayloadClass('medium', 'Medium payload');
  static const large = PayloadClass('large', 'Large payload');
  static const superheavy = PayloadClass('super-heavy', 'Super heavy payload');
  
  final String name;
  final String display;

  const PayloadClass(this.name, this.display);

  @override
  String toString() => name;
  
  String get displayName => display;
  
  int get priority {
    switch (name) {
      case 'light': return 0;
      case 'small': return 1;
      case 'medium': return 2;
      case 'large': return 3;
      case 'super-heavy': return 4;
      default: return 0;
    }
  }
}

/// Launch capacity metrics
@JsonSerializable(explicitToJson: true)
class LaunchCapacity {
  final double payload;  // Kilograms
  final double diameter;  // Meters
  final double height;  // Meters
  final String orbitType;  // LEO, GTO, SSO, etc.
  final double orbitAltitude;  // Kilometers

  LaunchCapacity({
    required this.payload,
    required this.diameter,
    required this.height,
    required this.orbitType,
    required this.orbitAltitude,
  });

  factory LaunchCapacity.fromJson(Map<String, dynamic> json) {
    return LaunchCapacity(
      payload: json['payload'],
      diameter: json['diameter'],
      height: json['height'],
      orbitType: json['orbit_type'],
      orbitAltitude: json['orbit_altitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return _$LaunchCapacityToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class _LaunchCapacity {
  @JsonKey(includeIfNull: false)
  final double? payload;

  @JsonKey(includeIfNull: false)
  final double? diameter;

  @JsonKey(includeIfNull: false)
  final double? height;

  @JsonKey(includeIfNull: false)
  final String? orbitType;

  @JsonKey(includeIfNull: false)
  final double? orbitAltitude;
}
